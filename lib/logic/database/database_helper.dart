import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:montra/logic/api/bank/models/bank_model.dart';
import 'package:montra/logic/api/wallet/models/wallet_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'montra.db');

    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  // Insert or update the balance
  Future<void> upsertAccountBalance(double balance) async {
    final db = await database;

    // Check if a balance record already exists
    final existing = await db.query('account_balance', limit: 1);

    if (existing.isNotEmpty) {
      // Update the existing record
      await db.update(
        'account_balance',
        {'balance': balance, 'updated_at': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [existing.first['id']],
      );
    } else {
      // Insert a new record
      await db.insert('account_balance', {
        'balance': balance,
        'updated_at': DateTime.now().toIso8601String(),
      });
    }
  }

  // Retrieve the balance
  Future<double?> getAccountBalance() async {
    final db = await database;

    final result = await db.query('account_balance', limit: 1);
    if (result.isNotEmpty) {
      return result.first['balance'] as double;
    }
    return null; // Return null if no balance is stored
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE wallets (
      name TEXT NOT NULL,
      balance REAL NOT NULL,
      userId TEXT NOT NULL,
      walletNumber TEXT PRIMARY KEY
    )
  ''');

    await db.execute('''
    CREATE TABLE banks (
      name TEXT NOT NULL,
      balance REAL NOT NULL,
      userId TEXT NOT NULL,
      accountNumber TEXT PRIMARY KEY,
      createdAt TEXT NOT NULL
    )
  ''');

    // Add the budget table
    await db.execute('''
    CREATE TABLE budget (
      budget_id TEXT PRIMARY KEY,
      total_budget INTEGER DEFAULT 0,
      name TEXT,
      user_id TEXT NOT NULL,
      current INTEGER DEFAULT 0,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');

    // Add the expense table
    await db.execute('''
    CREATE TABLE expense (
      expense_id TEXT PRIMARY KEY,
      amount INTEGER DEFAULT 0,
      user_id TEXT NOT NULL,
      source TEXT CHECK (source IN ('wallet', 'bank', 'cash', 'creditCard')),
      attachment TEXT,
      description TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      bank_name TEXT,
      wallet_name TEXT,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');

    // Add the income table
    await db.execute('''
    CREATE TABLE income (
      income_id TEXT PRIMARY KEY,
      amount INTEGER DEFAULT 0,
      user_id TEXT NOT NULL,
      source TEXT CHECK (source IN ('wallet', 'bank', 'cash', 'creditCard')),
      attachment TEXT,
      description TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      bank_name TEXT,
      wallet_name TEXT,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');

    // Add the transfer table
    await db.execute('''
    CREATE TABLE transfer (
      transfer_id TEXT PRIMARY KEY,
      amount INTEGER DEFAULT 0,
      sender TEXT,
      receiver TEXT,
      is_expense BOOLEAN,
      user_id TEXT NOT NULL,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE account_balance (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      balance REAL NOT NULL,
      updated_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''');

    await db.execute('''
    CREATE TABLE expense_stats (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      stats TEXT NOT NULL
    )
  ''');
  }

  Future<void> deleteDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'montra.db');
    await deleteDatabase(path);
  }

  // CRUD for Wallets
  Future<int> insertWallet(WalletModel wallet) async {
    final db = await database;
    return await db.insert('wallets', wallet.toJson());
  }

  Future<List<WalletModel>> getWallets() async {
    final db = await database;
    final result = await db.query('wallets');
    return result.map((json) => WalletModel.fromJson(json)).toList();
  }

  // CRUD for Banks
  Future<int> insertBank(BankModel bank) async {
    final db = await database;
    return await db.insert('banks', bank.toJson());
  }

  Future<List<BankModel>> getBanks() async {
    final db = await database;
    final result = await db.query('banks');
    return result.map((json) => BankModel.fromJson(json)).toList();
  }

  // Insert or update income
  Future<void> upsertIncome(List<Map<String, dynamic>> incomes) async {
    final db = await database;

    // Clear existing income data
    await db.delete('income');

    // Insert new income data
    for (var income in incomes) {
      await db.insert('income', income);
    }
  }

  // Retrieve income
  Future<List<Map<String, dynamic>>> getIncome() async {
    final db = await database;
    return await db.query('income');
  }

  Future<void> upsertExpenses(List<Map<String, dynamic>> expenses) async {
    final db = await database;

    // Clear existing expense data
    await db.delete('expense');

    // Insert new expense data
    for (var expense in expenses) {
      await db.insert('expense', expense);
    }
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;
    return await db.query('expense');
  }

  Future<void> upsertExpenseStats(Map<String, dynamic> stats) async {
    final db = await database;

    // Clear existing stats data
    await db.delete('expense_stats');

    // Insert new stats data
    await db.insert(
      'expense_stats',
      {'stats': jsonEncode(stats)}, // Serialize stats to a JSON string
    );
  }

  Future<Map<String, dynamic>?> getExpenseStats() async {
    final db = await database;

    final result = await db.query('expense_stats', limit: 1);
    if (result.isNotEmpty) {
      return jsonDecode(result.first['stats'] as String)
          as Map<String, dynamic>;
    }
    return null; // Return null if no stats are stored
  }
}
