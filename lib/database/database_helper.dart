import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/estimate.dart';
import '../models/estimate_item.dart';
import '../models/history_record.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  
  factory DatabaseHelper() => _instance;
  
  DatabaseHelper._internal();
  
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'estimates.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDatabase,
    );
  }
  
  Future<void> _createDatabase(Database db, int version) async {
    // Таблица смет
    await db.execute('''
      CREATE TABLE estimates(
        id TEXT PRIMARY KEY,
        number TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        client_name TEXT NOT NULL,
        address TEXT NOT NULL,
        object_type TEXT NOT NULL,
        rooms INTEGER NOT NULL,
        area REAL NOT NULL,
        perimeter REAL NOT NULL,
        height REAL NOT NULL,
        subtotal REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL,
        is_template INTEGER NOT NULL,
        is_favorite INTEGER NOT NULL,
        notes TEXT,
        is_draft INTEGER NOT NULL,
        last_auto_save TEXT
      )
    ''');
    
    // Таблица позиций сметы
    await db.execute('''
      CREATE TABLE estimate_items(
        id TEXT PRIMARY KEY,
        estimate_id TEXT NOT NULL,
        name TEXT NOT NULL,
        unit TEXT NOT NULL,
        quantity REAL NOT NULL,
        price REAL NOT NULL,
        total REAL NOT NULL,
        category TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (estimate_id) REFERENCES estimates (id) ON DELETE CASCADE
      )
    ''');
    
    // Таблица истории изменений
    await db.execute('''
      CREATE TABLE history_records(
        id TEXT PRIMARY KEY,
        estimate_id TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        action TEXT NOT NULL,
        details TEXT,
        user TEXT,
        FOREIGN KEY (estimate_id) REFERENCES estimates (id) ON DELETE CASCADE
      )
    ''');
    
    // Создание индексов для ускорения поиска
    await db.execute('CREATE INDEX idx_estimates_status ON estimates(status)');
    await db.execute('CREATE INDEX idx_estimates_template ON estimates(is_template)');
    await db.execute('CREATE INDEX idx_items_estimate ON estimate_items(estimate_id)');
    await db.execute('CREATE INDEX idx_history_estimate ON history_records(estimate_id)');
  }
  
  // CRUD операции для смет
  Future<int> insertEstimate(Estimate estimate) async {
    final db = await database;
    
    // Вставляем смету
    await db.insert('estimates', estimate.toMap());
    
    // Вставляем позиции
    for (var item in estimate.items) {
      await db.insert('estimate_items', {
        ...item.toMap(),
        'estimate_id': estimate.id,
      });
    }
    
    // Вставляем историю
    for (var record in estimate.history) {
      await db.insert('history_records', record.toMap());
    }
    
    return 1;
  }
  
  Future<List<Estimate>> getAllEstimates({bool? isTemplate}) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (isTemplate != null) {
      whereClause = 'is_template = ?';
      whereArgs.add(isTemplate ? 1 : 0);
    }
    
    final List<Map<String, dynamic>> maps = whereClause.isNotEmpty
        ? await db.query('estimates', where: whereClause, whereArgs: whereArgs)
        : await db.query('estimates');
    
    List<Estimate> estimates = [];
    
    for (var map in maps) {
      final estimate = Estimate.fromMap(map);
      
      // Получаем позиции сметы
      final items = await getEstimateItems(estimate.id);
      estimate.items = items;
      
      // Получаем историю
      final history = await getEstimateHistory(estimate.id);
      estimate.history = history;
      
      estimates.add(estimate);
    }
    
    return estimates;
  }
  
  Future<Estimate?> getEstimate(String id) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'estimates',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    
    final estimate = Estimate.fromMap(maps.first);
    estimate.items = await getEstimateItems(id);
    estimate.history = await getEstimateHistory(id);
    
    return estimate;
  }
  
  Future<List<EstimateItem>> getEstimateItems(String estimateId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'estimate_items',
      where: 'estimate_id = ?',
      whereArgs: [estimateId],
    );
    
    return maps.map((map) => EstimateItem.fromMap(map)).toList();
  }
  
  Future<List<HistoryRecord>> getEstimateHistory(String estimateId) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'history_records',
      where: 'estimate_id = ?',
      whereArgs: [estimateId],
      orderBy: 'timestamp DESC',
    );
    
    return maps.map((map) => HistoryRecord.fromMap(map)).toList();
  }
  
  Future<int> updateEstimate(Estimate estimate) async {
    final db = await database;
    
    // Обновляем смету
    await db.update(
      'estimates',
      estimate.toMap(),
      where: 'id = ?',
      whereArgs: [estimate.id],
    );
    
    // Удаляем старые позиции
    await db.delete(
      'estimate_items',
      where: 'estimate_id = ?',
      whereArgs: [estimate.id],
    );
    
    // Вставляем новые позиции
    for (var item in estimate.items) {
      await db.insert('estimate_items', {
        ...item.toMap(),
        'estimate_id': estimate.id,
      });
    }
    
    // Добавляем запись в историю
    await db.insert('history_records', {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'estimate_id': estimate.id,
      'timestamp': DateTime.now().toIso8601String(),
      'action': 'updated',
      'details': 'Смета обновлена',
    });
    
    return 1;
  }
  
  Future<int> deleteEstimate(String id) async {
    final db = await database;
    return await db.delete(
      'estimates',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  
  Future<void> saveDraft(Estimate estimate) async {
    estimate.isDraft = true;
    estimate.lastAutoSave = DateTime.now();
    await updateEstimate(estimate);
  }
  
  Future<List<Estimate>> searchEstimates(String query) async {
    final db = await database;
    
    final List<Map<String, dynamic>> maps = await db.query(
      'estimates',
      where: '''
        client_name LIKE ? OR 
        address LIKE ? OR 
        number LIKE ? OR 
        object_type LIKE ?
      ''',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );
    
    List<Estimate> estimates = [];
    
    for (var map in maps) {
      final estimate = Estimate.fromMap(map);
      estimate.items = await getEstimateItems(estimate.id);
      estimates.add(estimate);
    }
    
    return estimates;
  }
}
