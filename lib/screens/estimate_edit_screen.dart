import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tension_ceiling_app/models/estimate.dart';
import 'package:tension_ceiling_app/models/estimate_item.dart';
import 'package:tension_ceiling_app/database/database_helper.dart';
import 'package:tension_ceiling_app/widgets/client_info_form.dart';
import 'package:tension_ceiling_app/widgets/estimate_item_card.dart';
import 'package:tension_ceiling_app/widgets/total_summary.dart';
import 'package:tension_ceiling_app/services/auto_save_service.dart';

class EstimateEditScreen extends StatefulWidget {
  final Estimate? estimate;
  final bool isTemplate;
  
  const EstimateEditScreen({
    Key? key,
    this.estimate,
    this.isTemplate = false,
  }) : super(key: key);
  
  @override
  _EstimateEditScreenState createState() => _EstimateEditScreenState();
}

class _EstimateEditScreenState extends State<EstimateEditScreen> {
  late Estimate _estimate;
  final _formKey = GlobalKey<FormState>();
  late AutoSaveService _autoSaveService;
  
  @override
  void initState() {
    super.initState();
    
    if (widget.estimate != null) {
      _estimate = widget.estimate!;
    } else {
      _estimate = Estimate(
        number: 'СМ-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
        clientName: '',
        address: '',
        objectType: 'квартира',
        rooms: 1,
        area: 0,
        perimeter: 0,
        height: 2.5,
        isTemplate: widget.isTemplate,
        isDraft: true,
      );
    }
    
    _autoSaveService = Provider.of<AutoSaveService>(context, listen: false);
    _startAutoSave();
  }
  
  void _startAutoSave() {
    _autoSaveService.startAutoSave(
      _estimate,
      _saveEstimate,
      interval: Duration(seconds: 30),
    );
  }
  
  Future<void> _saveEstimate() async {
    if (!_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    _estimate.updatedAt = DateTime.now();
    _estimate.recalculateTotals();
    
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    
    if (_estimate.id.isEmpty) {
      await databaseHelper.insertEstimate(_estimate);
    } else {
      await databaseHelper.updateEstimate(_estimate);
    }
  }
  
  void _addNewItem() {
    setState(() {
      _estimate.addItem(EstimateItem(
        name: 'Новая позиция',
        unit: 'шт.',
        quantity: 1,
        price: 0,
      ));
    });
  }
  
  void _updateItem(int index, EstimateItem item) {
    setState(() {
      _estimate.items[index] = item;
      _estimate.recalculateTotals();
    });
  }
  
  void _removeItem(int index) {
    setState(() {
      _estimate.removeItem(_estimate.items[index].id);
    });
  }
  
  void _duplicateItem(int index) {
    setState(() {
      final item = _estimate.items[index].clone();
      _estimate.addItem(item);
    });
  }
  
  Future<void> _saveAsTemplate() async {
    final template = _estimate.clone();
    template.isTemplate = true;
    template.number = 'Шаблон ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}';
    
    final databaseHelper = Provider.of<DatabaseHelper>(context, listen: false);
    await databaseHelper.insertEstimate(template);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Шаблон сохранен')),
    );
  }
  
  Future<void> _exportEstimate() async {
    await _saveEstimate();
    
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.picture_as_pdf),
                title: Text('Экспорт в PDF'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать экспорт в PDF
                },
              ),
              ListTile(
                leading: Icon(Icons.table_chart),
                title: Text('Экспорт в Excel'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать экспорт в Excel
                },
              ),
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Поделиться'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Реализовать отправку
                },
              ),
            ],
          ),
        );
      },
    );
  }
  
  @override
  void dispose() {
    _autoSaveService.stopAutoSave();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_estimate.isTemplate ? 'Редактирование шаблона' : 'Редактирование сметы'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveEstimate,
          ),
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: _saveAsTemplate,
          ),
          IconButton(
            icon: Icon(Icons.ios_share),
            onPressed: _exportEstimate,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Информация о клиенте и объекте
            ClientInfoForm(
              estimate: _estimate,
              onChanged: (estimate) {
                setState(() {
                  _estimate = estimate;
                });
              },
            ),
            
            SizedBox(height: 24),
            
            // Список позиций
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Позиции сметы',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        TextButton.icon(
                          icon: Icon(Icons.add),
                          label: Text('Добавить'),
                          onPressed: _addNewItem,
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 16),
                    
                    if (_estimate.items.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(Icons.list, size: 64, color: Colors.grey[300]),
                            SizedBox(height: 16),
                            Text(
                              'Нет позиций',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _estimate.items.length,
                        separatorBuilder: (context, index) => Divider(),
                        itemBuilder: (context, index) {
                          return EstimateItemCard(
                            item: _estimate.items[index],
                            onChanged: (item) => _updateItem(index, item),
                            onRemove: () => _removeItem(index),
                            onDuplicate: () => _duplicateItem(index),
                            isLast: index == _estimate.items.length - 1,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 24),
            
            // Итоги
            TotalSummary(estimate: _estimate),
            
            SizedBox(height: 24),
            
            // Условия оплаты
            PaymentTermsCard(),
            
            SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
