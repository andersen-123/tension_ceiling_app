class Estimate {
  final int? id; // Будет null для новой сметы
  final String title;
  final String? description;
  final double totalPrice;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Estimate({
    this.id,
    required this.title,
    this.description,
    required this.totalPrice,
    required this.createdAt,
    this.updatedAt,
  });

  // Конвертируем объект в Map для сохранения в БД
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'total_price': totalPrice,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // Создаем объект из Map (при чтении из БД)
  factory Estimate.fromMap(Map<String, dynamic> map) {
    return Estimate(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      totalPrice: (map['total_price'] as num).toDouble(),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String) 
          : null,
    );
  }

  // Для отладки
  @override
  String toString() {
    return 'Estimate(id: $id, title: $title, totalPrice: $totalPrice)';
  }
}
