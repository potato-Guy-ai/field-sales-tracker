import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../core/database/database_helper.dart';
import '../models/customer.dart';

class CustomerRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final Uuid _uuid = const Uuid();

  Future<String> addCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    await db.insert('customers', customer.toMap());
    return customer.id;
  }

  Future<void> updateCustomer(Customer customer) async {
    final db = await _dbHelper.database;
    await db.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<void> updateBalance(String customerId, double newBalance) async {
    final db = await _dbHelper.database;
    await db.update(
      'customers',
      {'balance': newBalance},
      where: 'id = ?',
      whereArgs: [customerId],
    );
  }

  Future<void> adjustBalance(String customerId, double adjustment) async {
    final db = await _dbHelper.database;
    await db.rawUpdate('''
      UPDATE customers 
      SET balance = balance + ? 
      WHERE id = ?
    ''', [adjustment, customerId]);
  }

  Future<void> deleteCustomer(String id) async {
    final db = await _dbHelper.database;
    await db.delete('customers', where: 'id = ?', whereArgs: [id]);
  }

  Future<Customer?> getCustomerById(String id) async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (result.isEmpty) return null;
    return Customer.fromMap(result.first);
  }

  Future<List<Customer>> getAllCustomers() async {
    final db = await _dbHelper.database;
    final result = await db.query('customers', orderBy: 'name ASC');
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<List<Customer>> searchCustomers(String query) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT * FROM customers 
      WHERE name LIKE ? OR phone LIKE ? OR door_number LIKE ?
      ORDER BY name ASC
    ''', ['%$query%', '%$query%', '%$query%']);
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<List<Customer>> getCustomersWithBalance() async {
    final db = await _dbHelper.database;
    final result = await db.query(
      'customers',
      where: 'balance > 0',
      orderBy: 'balance DESC',
    );
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<double> getTotalOutstandingBalance() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(balance) as total FROM customers');
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
