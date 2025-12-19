class EstimateItem {
  final String name;
  final String unit;
  final double price;
  final double quantity;

  EstimateItem({
    required this.name,
    required this.unit,
    required this.price,
    required this.quantity,
  });

  // Автоматически вычисляемую общую стоимость
  double get total => price * quantity;

  // Для отладки
  @override
  String toString() {
    return 'EstimateItem(name: $name, unit: $unit, price: $price, quantity: $quantity, total: $total)';
  }
}
