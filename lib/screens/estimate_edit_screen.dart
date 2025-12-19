import 'package:flutter/material.dart';
import '../models/estimate.dart';
import '../models/estimate_item.dart';
import '../database/database_helper.dart';

class EstimateEditScreen extends StatefulWidget {
  final Estimate? existingEstimate;

  const EstimateEditScreen({super.key, this.existingEstimate});

  @override
  State<EstimateEditScreen> createState() => _EstimateEditScreenState();
}

class _EstimateEditScreenState extends State<EstimateEditScreen> {
  // Контроллеры для основных полей сметы
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Контроллеры для НОВОЙ позиции
  final _newItemNameController = TextEditingController();
  final _newItemUnitController = TextEditingController(text: 'м²');
  final _newItemPriceController = TextEditingController();
  final _newItemQuantityController = TextEditingController(text: '1.0');

  // Список позиций в текущей смете
  List<EstimateItem> _items = [];

  @override
  void initState() {
    super.initState();

    // Если редактируем существующую смету, загружаем данные
    if (widget.existingEstimate != null) {
      final estimate = widget.existingEstimate!;
      _titleController.text = estimate.title;
      _descriptionController.text = estimate.description ?? '';
      // Здесь позже загрузим items из БД
    }
  }

  @override
  void dispose() {
    // Очищаем контроллеры
    _titleController.dispose();
    _descriptionController.dispose();
    _newItemNameController.dispose();
    _newItemUnitController.dispose();
    _newItemPriceController.dispose();
    _newItemQuantityController.dispose();
    super.dispose();
  }

  // ДОБАВИТЬ новую позицию
  void _addNewItem() {
    final name = _newItemNameController.text.trim();
    final unit = _newItemUnitController.text.trim();
    final priceText = _newItemPriceController.text.replaceAll(',', '.');
    final quantityText = _newItemQuantityController.text.replaceAll(',', '.');
    
    final price = double.tryParse(priceText) ?? 0.0;
    final quantity = double.tryParse(quantityText) ?? 1.0;

    if (name.isEmpty) {
      _showMessage('Введите название позиции', isError: true);
      return;
    }

    if (price <= 0) {
      _showMessage('Цена должна быть больше 0', isError: true);
      return;
    }

    setState(() {
      _items.add(EstimateItem(
        name: name,
        unit: unit.isNotEmpty ? unit : 'шт.',
        price: price,
        quantity: quantity,
      ));
    });

    // Очищаем поля для новой позиции
    _newItemNameController.clear();
    _newItemPriceController.clear();
    _newItemQuantityController.text = '1.0';
    
    // Прячем клавиатуру
    FocusScope.of(context).unfocus();
    
    _showMessage('Позиция "$name" добавлена');
  }

  // УДАЛИТЬ позицию
  void _removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      final itemName = _items[index].name;
      setState(() {
        _items.removeAt(index);
      });
      _showMessage('Позиция "$itemName" удалена');
    }
  }

  // СОХРАНИТЬ всю смету
  Future<void> _saveEstimate() async {
    final title = _titleController.text.trim();
    
    if (title.isEmpty) {
      _showMessage('Введите название сметы', isError: true);
      return;
    }

    if (_items.isEmpty) {
      _showMessage('Добавьте хотя бы одну позицию', isError: true);
      return;
    }

    // Создаем объект сметы
    final estimate = Estimate(
      id: widget.existingEstimate?.id,
      title: title,
      description: _descriptionController.text.isNotEmpty 
          ? _descriptionController.text 
          : null,
      totalPrice: _calculateTotal(),
      createdAt: widget.existingEstimate?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      final db = await DatabaseHelper.instance.database;
      
      if (estimate.id == null) {
        // НОВАЯ смета
        await db.insert(
          'estimates', 
          estimate.toMap(),
        );
        _showMessage('✅ Смета сохранена', isSuccess: true);
      } else {
        // ОБНОВЛЕНИЕ существующей
        await db.update(
          'estimates',
          estimate.toMap(),
          where: 'id = ?',
          whereArgs: [estimate.id],
        );
        _showMessage('✅ Смета обновлена', isSuccess: true);
      }

      // Возвращаемся назад через 1.5 секунды
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) {
        Navigator.pop(context, true);
      }
      
    } catch (error) {
      _showMessage('❌ Ошибка: $error', isError: true);
    }
  }

  // ПОКАЗАТЬ сообщение
  void _showMessage(String message, {bool isError = false, bool isSuccess = false}) {
    if (!mounted) return;
    
    Color backgroundColor = Colors.grey[800]!;
    if (isError) backgroundColor = Colors.red;
    if (isSuccess) backgroundColor = Colors.green;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ВЫЧИСЛИТЬ общую сумму
  double _calculateTotal() {
    double total = 0.0;
    for (var item in _items) {
      total += item.total;
    }
    return total;
  }

  // ПОСТРОИТЬ интерфейс
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.existingEstimate != null 
            ? 'Редактировать смету' 
            : 'Новая смета'
        ),
        actions: [
          IconButton(
            onPressed: _saveEstimate,
            icon: const Icon(Icons.save),
            tooltip: 'Сохранить смету',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 1. ОСНОВНЫЕ ДАННЫЕ
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Название сметы *',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.title),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Описание (необязательно)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      maxLines: 2,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 2. СПИСОК ПОЗИЦИЙ
            Expanded(
              child: Column(
                children: [
                  // Заголовок и итог
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Позиции:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'ИТОГО: ${_calculateTotal().toStringAsFixed(2)} ₽',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Количество: ${_items.length} позиций'),

                  const SizedBox(height: 12),

                  // Список позиций
                  Expanded(
                    child: _items.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.list_alt,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Позиций пока нет',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey,
                                  ),
                                ),
                                const Text('Добавьте первую ниже'),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.blue[100],
                                    child: Text((index + 1).toString()),
                                  ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  subtitle: Text(
                                    '${item.quantity} ${item.unit} × ${item.price.toStringAsFixed(2)} ₽',
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${item.total.toStringAsFixed(2)} ₽',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        onPressed: () => _removeItem(index),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 3. ДОБАВЛЕНИЕ НОВОЙ ПОЗИЦИИ
            Card(
              color: Colors.grey[50],
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Добавить позицию',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Название и единица измерения
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextField(
                            controller: _newItemNameController,
                            decoration: const InputDecoration(
                              labelText: 'Название *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: TextField(
                            controller: _newItemUnitController,
                            decoration: const InputDecoration(
                              labelText: 'Ед.',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Цена и количество
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _newItemPriceController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Цена *',
                              border: OutlineInputBorder(),
                              isDense: true,
                              prefixText: '₽ ',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _newItemQuantityController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Кол-во',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: _addNewItem,
                          icon: const Icon(Icons.add_circle),
                          label: const Text('Добавить'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
