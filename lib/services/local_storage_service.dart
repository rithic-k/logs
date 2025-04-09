import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/log_entry_model.dart';
import '../models/transaction_model.dart' as models;
import '../models/category_model.dart' as models;
import '../models/budget_model.dart';

class LocalStorageService {
  static Database? _database;
  static final LocalStorageService _instance = LocalStorageService._internal();

  LocalStorageService._internal();

  static Future<LocalStorageService> initialize() async {
    _database ??= await _initDatabase();
    return _instance;
  }

  static Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'daily_tracker.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  static Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE logs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        content TEXT NOT NULL,
        date TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon TEXT NOT NULL,
        is_expense INTEGER NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT NOT NULL,
        amount REAL NOT NULL,
        type INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories (id)
      )
    ''');
  }

  // Log Entry Methods
  Future<int> insertLog(LogEntry log) async {
    return await _database!.insert('logs', log.toMap());
  }

  Future<List<LogEntry>> getLogs() async {
    final List<Map<String, dynamic>> maps = await _database!.query('logs');
    return List.generate(maps.length, (i) => LogEntry.fromMap(maps[i]));
  }

  Future<int> deleteLog(int id) async {
    return await _database!.delete(
      'logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Transaction Methods
  Future<int> insertTransaction(models.Transaction transaction) async {
    return await _database!.insert('transactions', transaction.toMap());
  }

  Future<List<models.Transaction>> getTransactions() async {
    final List<Map<String, dynamic>> maps =
        await _database!.query('transactions');
    return List.generate(
        maps.length, (i) => models.Transaction.fromMap(maps[i]));
  }

  // Category Methods
  Future<int> insertCategory(models.Category category) async {
    return await _database!.insert('categories', category.toMap());
  }

  Future<List<models.Category>> getCategories() async {
    final List<Map<String, dynamic>> maps =
        await _database!.query('categories');
    return List.generate(maps.length, (i) => models.Category.fromMap(maps[i]));
  }

  // Budget Methods
  Future<int> insertBudget(Budget budget) async {
    return await _database!.insert('budgets', budget.toMap());
  }

  Future<List<Budget>> getBudgets() async {
    final List<Map<String, dynamic>> maps = await _database!.query('budgets');
    return List.generate(maps.length, (i) => Budget.fromMap(maps[i]));
  }
}
