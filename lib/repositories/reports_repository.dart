import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';

class ReportsRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<Map<String, dynamic>> getDailyReport(DateTime date) async {
    final db = await _dbHelper.database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final salesResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sales,
        SUM(total_amount) as total_revenue,
        SUM(payment_amount) as total_payments,
        SUM(total_amount - payment_amount) as total_credit
      FROM sales
      WHERE sale_date >= ? AND sale_date < ?
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);

    final profitResult = await db.rawQuery('''
      SELECT SUM((unit_price - cost_price) * quantity) as total_profit
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      WHERE s.sale_date >= ? AND s.sale_date < ?
    ''', [startOfDay.millisecondsSinceEpoch, endOfDay.millisecondsSinceEpoch]);

    return {
      'total_sales': salesResult.first['total_sales'] ?? 0,
      'total_revenue': (salesResult.first['total_revenue'] as num?)?.toDouble() ?? 0.0,
      'total_payments': (salesResult.first['total_payments'] as num?)?.toDouble() ?? 0.0,
      'total_credit': (salesResult.first['total_credit'] as num?)?.toDouble() ?? 0.0,
      'total_profit': (profitResult.first['total_profit'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<Map<String, dynamic>> getDateRangeReport(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;

    final salesResult = await db.rawQuery('''
      SELECT 
        COUNT(*) as total_sales,
        SUM(total_amount) as total_revenue,
        SUM(payment_amount) as total_payments,
        SUM(total_amount - payment_amount) as total_credit
      FROM sales
      WHERE sale_date BETWEEN ? AND ?
    ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);

    final profitResult = await db.rawQuery('''
      SELECT SUM((unit_price - cost_price) * quantity) as total_profit
      FROM sale_items si
      JOIN sales s ON si.sale_id = s.id
      WHERE s.sale_date BETWEEN ? AND ?
    ''', [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch]);

    return {
      'total_sales': salesResult.first['total_sales'] ?? 0,
      'total_revenue': (salesResult.first['total_revenue'] as num?)?.toDouble() ?? 0.0,
      'total_payments': (salesResult.first['total_payments'] as num?)?.toDouble() ?? 0.0,
      'total_credit': (salesResult.first['total_credit'] as num?)?.toDouble() ?? 0.0,
      'total_profit': (profitResult.first['total_profit'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<List<Map<String, dynamic>>> getCustomerProfitReport() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        c.id,
        c.name,
        COUNT(s.id) as total_sales,
        SUM(s.total_amount) as total_revenue,
        SUM((si.unit_price - si.cost_price) * si.quantity) as total_profit
      FROM customers c
      JOIN sales s ON c.id = s.customer_id
      JOIN sale_items si ON s.id = si.sale_id
      GROUP BY c.id, c.name
      ORDER BY total_profit DESC
    ''');
  }

  Future<List<Map<String, dynamic>>> getProductPerformance() async {
    final db = await _dbHelper.database;
    return await db.rawQuery('''
      SELECT 
        st.id,
        st.name,
        SUM(si.quantity) as total_quantity_sold,
        SUM(si.total) as total_revenue,
        SUM((si.unit_price - si.cost_price) * si.quantity) as total_profit
      FROM stock st
      JOIN sale_items si ON st.id = si.stock_id
      GROUP BY st.id, st.name
      ORDER BY total_profit DESC
    ''');
  }
}
