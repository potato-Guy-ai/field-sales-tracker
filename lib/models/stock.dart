class Stock {
  final String id;
  final String name;
  final double quantityPieces;
  final double quantityWeight;
  final String unit;
  final double costPrice;
  final double sellingPrice;
  final double lowStockThreshold;
  final DateTime createdAt;

  Stock({
    required this.id,
    required this.name,
    required this.quantityPieces,
    required this.quantityWeight,
    required this.unit,
    required this.costPrice,
    required this.sellingPrice,
    required this.lowStockThreshold,
    required this.createdAt,
  });

  bool get isLowStock {
    final total = unit == 'pieces' ? quantityPieces : quantityWeight;
    return total <= lowStockThreshold;
  }

  double get currentQuantity {
    return unit == 'pieces' ? quantityPieces : quantityWeight;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'quantity_pieces': quantityPieces,
      'quantity_weight': quantityWeight,
      'unit': unit,
      'cost_price': costPrice,
      'selling_price': sellingPrice,
      'low_stock_threshold': lowStockThreshold,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory Stock.fromMap(Map<String, dynamic> map) {
    return Stock(
      id: map['id'],
      name: map['name'],
      quantityPieces: map['quantity_pieces'],
      quantityWeight: map['quantity_weight'],
      unit: map['unit'],
      costPrice: map['cost_price'],
      sellingPrice: map['selling_price'],
      lowStockThreshold: map['low_stock_threshold'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  Stock copyWith({
    String? name,
    double? quantityPieces,
    double? quantityWeight,
    String? unit,
    double? costPrice,
    double? sellingPrice,
    double? lowStockThreshold,
  }) {
    return Stock(
      id: id,
      name: name ?? this.name,
      quantityPieces: quantityPieces ?? this.quantityPieces,
      quantityWeight: quantityWeight ?? this.quantityWeight,
      unit: unit ?? this.unit,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt,
    );
  }
}
