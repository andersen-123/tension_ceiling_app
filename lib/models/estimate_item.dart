class EstimateItem {
  String id;
  String name;
  String unit;
  double quantity;
  double price;
  double total;
  String category;
  String? notes;
  
  EstimateItem({
    String? id,
    required this.name,
    required this.unit,
    required this.quantity,
    required this.price,
    String? category,
    this.notes,
  })  : id = id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        category = category ?? 'Материалы',
        total = quantity * price;
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'quantity': quantity,
      'price': price,
      'total': total,
      'category': category,
      'notes': notes,
    };
  }
  
  factory EstimateItem.fromMap(Map<String, dynamic> map) {
    return EstimateItem(
      id: map['id'],
      name: map['name'],
      unit: map['unit'],
      quantity: map['quantity'],
      price: map['price'],
      category: map['category'],
      notes: map['notes'],
    );
  }
  
  void updateQuantity(double newQuantity) {
    quantity = newQuantity;
    total = quantity * price;
  }
  
  void updatePrice(double newPrice) {
    price = newPrice;
    total = quantity * price;
  }
  
  EstimateItem clone() {
    return EstimateItem(
      name: name,
      unit: unit,
      quantity: quantity,
      price: price,
      category: category,
      notes: notes,
    );
  }
}
