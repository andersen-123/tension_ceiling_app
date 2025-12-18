import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'database/database_helper.dart';
import 'services/auto_save_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Инициализация базы данных
  final databaseHelper = DatabaseHelper();
  await databaseHelper.initDatabase();
  
  // Инициализация автосохранения
  final autoSaveService = AutoSaveService();
  
  runApp(
    MultiProvider(
      providers: [
        Provider<DatabaseHelper>(create: (_) => databaseHelper),
        Provider<AutoSaveService>(create: (_) => autoSaveService),
      ],
      child: MyApp(),
    ),
  );
}
