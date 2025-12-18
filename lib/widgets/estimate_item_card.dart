import 'package:flutter/material.dart';
import 'package:tension_ceiling_app/models/estimate_item.dart';

class EstimateItemCard extends StatefulWidget {
  final EstimateItem item;
  final Function(EstimateItem) onChanged;
  final Function() onRemove;
  final Function() onDuplicate;
  final bool isLast;
  
  const EstimateItemCard({
    Key? key,
    required this.item,
    required this.onChanged,
    required this.onRemove,
    required this.onDuplicate,
    this.isLast = false,
  }) : super(key: key);
  
  @override
  _EstimateItemCardState createState() => _EstimateItemCardState();
}

class _EstimateItemCardState extends State<EstimateItemCard> {
  late EstimateItem _item;
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _item = widget.item;
    _initializeControllers();
  }
  
  void _initializeControllers() {
    _nameController.text = _item.name;
    _quantityController.text = _item.quantity.toString();
    _priceController.text = _item.price.toStringAsFixed(2);
  }
  
  void _updateItem() {
    final newItem = EstimateItem(
      id: _item.id,
      name: _nameController.text,
      unit: _item.unit,
      quantity: double.tryParse(_quantityController.text) ?? 0,
      price: double.tryParse(_priceController.text) ?? 0,
      category: _item.category,
      notes: _item.notes,
    );
    
    setState(() {
      _item = newItem;
    });
    
    widget.onChanged(newItem);
  }
  
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Наименование',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    onChanged: (_) => _updateItem(),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 80,
                  child: DropdownButtonFormField<String>(
                    value: _item.unit,
                    items: ['м²', 'м.п.', 'шт.', 'компл.', 'упак.'].map((unit) {
                      return DropdownMenuItem(
                        value: unit,
                        child: Text(unit),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _item.unit = value;
                        });
                        _updateItem();
                      }
                    },
                    decoration: InputDecoration(
                      labelText: 'Ед.',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: InputDecoration(
                      labelText: 'Количество',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _updateItem(),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    decoration: InputDecoration(
                      labelText: 'Цена',
                      border: OutlineInputBorder(),
                      prefixText: '₽ ',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    onChanged: (_) => _updateItem(),
                  ),
                ),
                SizedBox(width: 12),
                Container(
                  width: 120,
                  child: TextFormField(
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Сумма',
                      border: OutlineInputBorder(),
                      prefixText: '₽ ',
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    initialValue: _item.total.toStringAsFixed(2),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 12),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(Icons.content_copy, size: 20),
                  onPressed: widget.onDuplicate,
                  tooltip: 'Дублировать',
                ),
                IconButton(
                  icon: Icon(Icons.delete, size: 20, color: Colors.red),
                  onPressed: widget.onRemove,
                  tooltip: 'Удалить',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
