import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/stock.dart';

class StockRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> addStock(Stock stock) async {
    final db = await _dbHelper.database;
    await db.insert('stock', stock.toMap());
    return stock.id;
  }

  Future<void> updateStock(Stock stock) async {
    final db = await _dbHelper.database;
    await db.update(
      'stock',
      stock.toMap(),
      where: 'id = ?',
      whereArgs: [stock.id],
    );
  }

  Future<void> deleteStock(String id) async {
    final db = await _dbHelper.database;
    await db.delete('stock', where: 'id = ?', whereArgs: [id]);
  }

  Future<Stock?> getStockById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'stock',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Stock.fromMap(result.first);
  }

  Future<List<Stock>> getAllStock() async {
    final db = await _dbHelper.database;
    final result = await db.query('stock', orderBy: 'name ASC');
    return result.map((map) => Stock.fromMap(map)).toList();
  }

  Future<List<Stock>> getLowStockItems() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT * FROM stock 
      WHERE (CASE WHEN unit = 'pieces' THEN quantity_pieces ELSE quantity_weight END) <= low_stock_threshold
      ORDER BY name ASC
    ''');
    return result.map((map) => Stock.fromMap(map)).toList();
  }

  Future<void> adjustQuantity(String stockId, double adjustment, String unit) async {
    final db = await _dbHelper.database;
    final field = unit == 'pieces' ? 'quantity_pieces' : 'quantity_weight';
    await db.rawUpdate('''
      UPDATE stock 
      SET $field = $field + ? 
      WHERE id = ?
    ''', [adjustment, stockId]);
  }

  Future<List<Stock>> searchStock(String query) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'stock',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((map) => Stock.fromMap(map)).toList();
  }
}
