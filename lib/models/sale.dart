class Sale {
  final String id;
  final String customerId;
  final double totalAmount;
  final double paymentAmount;
  final String? paymentMethod;
  final String? notes;
  final DateTime saleDate;

  Sale({
    required this.id,
    required this.customerId,
    required this.totalAmount,
    required this.paymentAmount,
    this.paymentMethod,
    this.notes,
    required this.saleDate,
  });

  double get balanceAmount => totalAmount - paymentAmount;
  bool get isFullyPaid => paymentAmount >= totalAmount;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'total_amount': totalAmount,
      'payment_amount': paymentAmount,
      'payment_method': paymentMethod,
      'notes': notes,
      'sale_date': saleDate.millisecondsSinceEpoch,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      customerId: map['customer_id'],
      totalAmount: map['total_amount'],
      paymentAmount: map['payment_amount'],
      paymentMethod: map['payment_method'],
      notes: map['notes'],
      saleDate: DateTime.fromMillisecondsSinceEpoch(map['sale_date']),
    );
  }
}

class SaleItem {
  final String id;
  final String saleId;
  final String stockId;
  final double quantity;
  final double unitPrice;
  final double costPrice;
  final double total;

  SaleItem({
    required this.id,
    required this.saleId,
    required this.stockId,
    required this.quantity,
    required this.unitPrice,
    required this.costPrice,
    required this.total,
  });

  double get profit => (unitPrice - costPrice) * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sale_id': saleId,
      'stock_id': stockId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'cost_price': costPrice,
      'total': total,
    };
  }

  factory SaleItem.fromMap(Map<String, dynamic> map) {
    return SaleItem(
      id: map['id'],
      saleId: map['sale_id'],
      stockId: map['stock_id'],
      quantity: map['quantity'],
      unitPrice: map['unit_price'],
      costPrice: map['cost_price'],
      total: map['total'],
    );
  }
}
