import 'package:flutter/foundation.dart';
import 'estimate_item.dart';
import 'history_record.dart';

class Estimate {
  String id;
  String number;
  DateTime createdAt;
  DateTime updatedAt;
  String clientName;
  String address;
  String objectType;
  int rooms;
  double area;
  double perimeter;
  double height;
  List<EstimateItem> items;
  List<HistoryRecord> history;
  double subtotal;
  double total;
  String status;
  bool isTemplate;
  bool isFavorite;
  String notes;
  bool isDraft;
  DateTime? lastAutoSave;
  
  Estimate({
    String? id,
    required this.number,
    required this.clientName,
    required this.address,
    required this.objectType,
    required this.rooms,
    required this.area,
    required this.perimeter,
    required this.height,
    List<EstimateItem>? items,
    List<HistoryRecord>? history,
    this.subtotal = 0,
    this.total = 0,
    this.status = 'draft',
    this.isTemplate = false,
    this.isFavorite = false,
    this.notes = '',
    this.isDraft = false,
    this.lastAutoSave,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt = DateTime.now(),
        updatedAt = DateTime.now(),
        items = items ?? [],
        history = history ?? [];
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'client_name': clientName,
      'address': address,
      'object_type': objectType,
      'rooms': rooms,
      'area': area,
      'perimeter': perimeter,
      'height': height,
      'subtotal': subtotal,
      'total': total,
      'status': status,
      'is_template': isTemplate ? 1 : 0,
      'is_favorite': isFavorite ? 1 : 0,
      'notes': notes,
      'is_draft': isDraft ? 1 : 0,
      'last_auto_save': lastAutoSave?.toIso8601String(),
    };
  }
  
  factory Estimate.fromMap(Map<String, dynamic> map) {
    return Estimate(
      id: map['id'],
      number: map['number'],
      clientName: map['client_name'],
      address: map['address'],
      objectType: map['object_type'],
      rooms: map['rooms'],
      area: map['area'],
      perimeter: map['perimeter'],
      height: map['height'],
      subtotal: map['subtotal'],
      total: map['total'],
      status: map['status'],
      isTemplate: map['is_template'] == 1,
      isFavorite: map['is_favorite'] == 1,
      notes: map['notes'],
      isDraft: map['is_draft'] == 1,
      lastAutoSave: map['last_auto_save'] != null 
          ? DateTime.parse(map['last_auto_save']) 
          : null,
    );
  }
  
  void addItem(EstimateItem item) {
    items.add(item);
    recalculateTotals();
  }
  
  void removeItem(String itemId) {
    items.removeWhere((item) => item.id == itemId);
    recalculateTotals();
  }
  
  void recalculateTotals() {
    subtotal = items.fold(0, (sum, item) => sum + item.total);
    // Можно добавить налоги, скидки и т.д.
    total = subtotal;
    updatedAt = DateTime.now();
  }
  
  void addHistoryRecord(String action, String details) {
    history.add(HistoryRecord(
      estimateId: id,
      action: action,
      details: details,
    ));
  }
  
  Estimate clone() {
    return Estimate(
      number: '$number (Копия)',
      clientName: clientName,
      address: address,
      objectType: objectType,
      rooms: rooms,
      area: area,
      perimeter: perimeter,
      height: height,
      items: items.map((item) => item.clone()).toList(),
      subtotal: subtotal,
      total: total,
      status: 'draft',
      isTemplate: false,
      notes: notes,
      isDraft: true,
    );
  }
}
