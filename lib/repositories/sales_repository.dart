import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/sale.dart';
import '../repositories/stock_repository.dart';
import '../repositories/customer_repository.dart';

class SalesRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final StockRepository _stockRepo = StockRepository();
  final CustomerRepository _customerRepo = CustomerRepository();
  final Uuid _uuid = const Uuid();

  Future<String> createSale({
    required String customerId,
    required List<SaleItem> items,
    required double paymentAmount,
    String? paymentMethod,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    final saleId = _uuid.v4();
    final totalAmount = items.fold(0.0, (sum, item) => sum + item.total);

    return await db.transaction((txn) async {
      // Insert sale
      await txn.insert('sales', {
        'id': saleId,
        'customer_id': customerId,
        'total_amount': totalAmount,
        'payment_amount': paymentAmount,
        'payment_method': paymentMethod,
        'notes': notes,
        'sale_date': DateTime.now().millisecondsSinceEpoch,
      });

      // Insert sale items and update stock
      for (final item in items) {
        await txn.insert('sale_items', item.toMap());
        
        final stock = await _stockRepo.getStockById(item.stockId);
        if (stock != null) {
          await _stockRepo.adjustQuantity(
            item.stockId,
            -item.quantity,
            stock.unit,
          );
        }
      }

      // Update customer balance
      final balanceChange = totalAmount - paymentAmount;
      if (balanceChange != 0) {
        await _customerRepo.adjustBalance(customerId, balanceChange);
      }

      return saleId;
    });
  }

  Future<void> addPayment({
    required String customerId,
    required double amount,
    required String paymentMethod,
    String? notes,
  }) async {
    final db = await _dbHelper.database;
    
    await db.transaction((txn) async {
      // Insert payment record
      await txn.insert('payments', {
        'id': _uuid.v4(),
        'customer_id': customerId,
        'amount': amount,
        'payment_method': paymentMethod,
        'payment_date': DateTime.now().millisecondsSinceEpoch,
        'notes': notes,
      });

      // Reduce customer balance
      await _customerRepo.adjustBalance(customerId, -amount);
    });
  }

  Future<List<Sale>> getSalesByCustomer(String customerId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'sales',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'sale_date DESC',
    );
    return result.map((map) => Sale.fromMap(map)).toList();
  }

  Future<List<Sale>> getSalesByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'sales',
      where: 'sale_date BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'sale_date DESC',
    );
    return result.map((map) => Sale.fromMap(map)).toList();
  }

  Future<List<SaleItem>> getSaleItems(String saleId) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'sale_items',
      where: 'sale_id = ?',
      whereArgs: [saleId],
    );
    return result.map((map) => SaleItem.fromMap(map)).toList();
  }

  Future<double> getTodayTotalSales() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final result = await db.rawQuery('''
      SELECT SUM(total_amount) as total 
      FROM sales 
      WHERE sale_date >= ?
    ''', [startOfDay.millisecondsSinceEpoch]);
    
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<double> getTodayProfit() async {
    final db = await _dbHelper.database;
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    final result = await db.rawQuery('''
      SELECT SUM((unit_price - cost_price) * quantity) as profit
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      WHERE s.sale_date >= ?
    ''', [startOfDay.millisecondsSinceEpoch]);
    
    return (result.first['profit'] as num?)?.toDouble() ?? 0.0;
  }
}
