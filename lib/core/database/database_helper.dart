import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'field_sales.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Routes table
    await db.execute('''
      CREATE TABLE routes (
        id TEXT PRIMARY KEY,
        name TEXT,
        created_at INTEGER NOT NULL,
        is_active INTEGER DEFAULT 0
      )
    ''');

    // Route points table
    await db.execute('''
      CREATE TABLE route_points (
        id TEXT PRIMARY KEY,
        route_id TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (route_id) REFERENCES routes (id) ON DELETE CASCADE
      )
    ''');

    // Customers table
    await db.execute('''
      CREATE TABLE customers (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        phone TEXT,
        door_number TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        groups TEXT,
        balance REAL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // Stock table
    await db.execute('''
      CREATE TABLE stock (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        quantity_pieces REAL DEFAULT 0,
        quantity_weight REAL DEFAULT 0,
        unit TEXT,
        cost_price REAL NOT NULL,
        selling_price REAL NOT NULL,
        low_stock_threshold REAL DEFAULT 0,
        created_at INTEGER NOT NULL
      )
    ''');

    // Sales table
    await db.execute('''
      CREATE TABLE sales (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        total_amount REAL NOT NULL,
        payment_amount REAL NOT NULL,
        payment_method TEXT,
        notes TEXT,
        sale_date INTEGER NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Sale items table
    await db.execute('''
      CREATE TABLE sale_items (
        id TEXT PRIMARY KEY,
        sale_id TEXT NOT NULL,
        stock_id TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_price REAL NOT NULL,
        cost_price REAL NOT NULL,
        total REAL NOT NULL,
        FOREIGN KEY (sale_id) REFERENCES sales (id) ON DELETE CASCADE,
        FOREIGN KEY (stock_id) REFERENCES stock (id)
      )
    ''');

    // Payments table
    await db.execute('''
      CREATE TABLE payments (
        id TEXT PRIMARY KEY,
        customer_id TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_date INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (customer_id) REFERENCES customers (id) ON DELETE CASCADE
      )
    ''');

    // Indexes for performance
    await db.execute('CREATE INDEX idx_customer_door ON customers(door_number)');
    await db.execute('CREATE INDEX idx_customer_phone ON customers(phone)');
    await db.execute('CREATE INDEX idx_sales_date ON sales(sale_date)');
    await db.execute('CREATE INDEX idx_sales_customer ON sales(customer_id)');
  }
}
