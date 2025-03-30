import 'dart:async';
import 'dart:convert';
import 'package:montra/logic/blocs/network_bloc/network_helper.dart';
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
    // When creating your database or during a migration
    await db.execute('''
CREATE TABLE budgets (
  budget_id TEXT PRIMARY KEY,
  total_budget INTEGER DEFAULT 0,
  name TEXT,
  user_id TEXT NOT NULL,
  current INTEGER DEFAULT 0,
  created_at TEXT DEFAULT CURRENT_TIMESTAMP,
  is_synced INTEGER DEFAULT 1,
  pending_deletion INTEGER DEFAULT 0,
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

    await db.execute('''
CREATE TABLE wallet_names (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL
)
''');

    await db.execute('''
    CREATE TABLE offline_income (
      income_id TEXT PRIMARY KEY,
      amount INTEGER DEFAULT 0,
      user_id TEXT NOT NULL,
      source TEXT,
      attachment TEXT,
      description TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      bank_name TEXT,
      wallet_name TEXT
    )
  ''');

    await db.execute('''
      CREATE TABLE offline_expense (
        expense_id TEXT PRIMARY KEY,
        amount INTEGER DEFAULT 0,
        user_id TEXT NOT NULL,
        source TEXT,
        attachment TEXT,
        description TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        bank_name TEXT,
        wallet_name TEXT
      )
''');

    await db.execute('''
      CREATE TABLE offline_transfer (
        transfer_id TEXT PRIMARY KEY,
        amount INTEGER DEFAULT 0,
        sender TEXT,
        receiver TEXT,
        is_expense INTEGER,
        user_id TEXT NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
  ''');
  }

  Future<void> deleteDatabaseFile() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }

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

    return result.map((row) {
      return WalletModel(
        name: row['name'] as String,
        amount: (row['balance'] as num).toInt(), // 👈 map balance → amount
        userId: row['userId'] as String,
        walletNumber: row['walletNumber'] as String,
      );
    }).toList();
  }

  // CRUD for Banks
  Future<int> insertBank(BankModel bank) async {
    final db = await database;
    return await db.insert('banks', bank.toJson());
  }

  Future<List<BankModel>> getBanks() async {
    final db = await database;
    final result = await db.query('banks');

    return result.map((row) {
      return BankModel(
        name: row['name'] as String,
        amount: (row['balance'] as num).toInt(), // 👈 map balance → amount
        userId: row['userId'] as String,
        accountNumber: row['accountNumber'] as String,
        createdAt: DateTime.parse(row['createdAt'] as String),
      );
    }).toList();
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

  Future<void> upsertTransfers(List<Map<String, dynamic>> transfers) async {
    final db = await database;

    // Clear existing transfer data
    await db.delete('transfer');

    // Insert new transfer data
    for (var transfer in transfers) {
      await db.insert('transfer', transfer);
    }
  }

  Future<List<Map<String, dynamic>>> getTransfers() async {
    final db = await database;
    return await db.query('transfer');
  }

  // Insert or update wallet names
  Future<void> upsertWalletNames(List<String> walletNames) async {
    final db = await database;

    // Clear existing wallet names
    await db.delete('wallet_names');

    // Insert new wallet names
    for (var walletName in walletNames) {
      await db.insert('wallet_names', {'name': walletName});
    }
  }

  // Retrieve wallet names
  Future<List<String>> getWalletNames() async {
    final db = await database;

    final result = await db.query('wallet_names');
    return result.map((row) => row['name'] as String).toList();
  }

  Future<void> insertOfflineIncome(Map<String, dynamic> income) async {
    final db = await database;
    await db.insert('offline_income', income);
  }

  Future<List<Map<String, dynamic>>> getOfflineIncomes() async {
    final db = await database;
    return await db.query('offline_income');
  }

  Future<void> clearOfflineIncomes() async {
    final db = await database;
    await db.delete('offline_income');
  }

  Future<void> insertOfflineExpense(Map<String, dynamic> expense) async {
    final db = await database;
    await db.insert('offline_expense', expense);
  }

  Future<List<Map<String, dynamic>>> getOfflineExpenses() async {
    final db = await database;
    return await db.query('offline_expense');
  }

  Future<void> clearOfflineExpenses() async {
    final db = await database;
    await db.delete('offline_expense');
  }

  Future<void> insertOfflineTransfer(Map<String, dynamic> transfer) async {
    final db = await database;
    await db.insert('offline_transfer', transfer);
  }

  Future<List<Map<String, dynamic>>> getOfflineTransfers() async {
    final db = await database;
    return await db.query('offline_transfer');
  }

  Future<void> clearOfflineTransfers() async {
    final db = await database;
    await db.delete('offline_transfer');
  }

  Future<List<Map<String, dynamic>>> getBudgets() async {
    final db = await database;
    return await db.query('budget');
  }

  Future<String?> getUserId() async {
    final db = await database;
    final results = await db.query('users', limit: 1);
    return results.isNotEmpty ? results.first['user_id'] as String : null;
  }

  // Insert a new budget
  Future<int> insertBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.insert('budgets', budget);
  }

  // Update an existing budget
  Future<int> updateBudget(Map<String, dynamic> budget) async {
    final db = await database;
    return await db.update(
      'budgets',
      budget,
      where: 'budget_id = ?',
      whereArgs: [budget['budget_id']],
    );
  }

  // Delete a budget
  Future<void> deleteBudget(String budgetId) async {
    final db = await database;
    final isConnected = await NetworkHelper.checkNow();

    if (!isConnected) {
      // Mark as pending deletion if offline
      await db.update(
        'budgets',
        {'pending_deletion': 1},
        where: 'budget_id = ?',
        whereArgs: [budgetId],
      );
    } else {
      // Delete budget from local DB if online
      await db.delete('budgets', where: 'budget_id = ?', whereArgs: [budgetId]);
    }
  }

  // Mark a budget as synced with server
  Future<void> markBudgetAsSynced(String budgetId) async {
    final db = await database;
    await db.update(
      'budgets',
      {'is_synced': 1},
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
  }

  // Mark a budget for deletion when back online
  Future<int> markBudgetForDeletion(String budgetId) async {
    final db = await database;
    return await db.update(
      'budgets',
      {'pending_deletion': 1},
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );
  }

  // Upsert budgets (used for syncing from server)
  // Insert or update budget
  Future<void> upsertBudgets(List<Map<String, dynamic>> budgets) async {
    final db = await database;

    // Iterate over all budgets to insert or update
    for (var budget in budgets) {
      // Mark as unsynced if the device is offline
      final isConnected = await NetworkHelper.checkNow();
      budget['is_synced'] = isConnected ? 1 : 0;

      final existingBudget = await db.query(
        'budgets',
        where: 'budget_id = ?',
        whereArgs: [budget['budget_id']],
      );

      if (existingBudget.isNotEmpty) {
        // Update existing budget
        await db.update(
          'budgets',
          budget,
          where: 'budget_id = ?',
          whereArgs: [budget['budget_id']],
        );
      } else {
        // Insert new budget
        await db.insert('budgets', budget);
      }
    }
  }

  // Get budgets by month (as shown in original code)
  Future<List<Map<String, dynamic>>> getBudgetsByMonth(String month) async {
    final db = await database;
    // Implement as needed - this is a placeholder based on the original code
    return await db.query(
      'budgets',
      where: 'strftime("%Y-%m", created_at) = ? AND pending_deletion = 0',
      whereArgs: [month],
    );
  }

  Future<void> replaceAllBudgets(List<Map<String, dynamic>> budgets) async {
    final db = await database;
    await db.transaction((txn) async {
      // Keep track of local budgets that were synced
      final localBudgetIds = await txn.query(
        'budgets',
        columns: ['budget_id'],
        where: "budget_id LIKE 'local_%' AND is_synced = 1",
      );

      // Delete all budgets that aren't pending local changes
      await txn.delete(
        'budgets',
        where: "is_synced = 1 AND pending_deletion = 0",
      );

      // Insert all budgets from server
      for (final budget in budgets) {
        await txn.insert('budgets', budget);
      }

      // Clean up any local budgets that were successfully synced
      for (final localBudget in localBudgetIds) {
        await txn.delete(
          'budgets',
          where: 'budget_id = ?',
          whereArgs: [localBudget['budget_id']],
        );
      }
    });
  }

  Future<List<Map<String, dynamic>>> getAllBudgets() async {
    final db = await database;

    // Retrieve all budgets that are not marked for deletion
    return await db.query('budgets', where: 'pending_deletion = 0');
  }

  Future<List<Map<String, dynamic>>> getUnSyncedBudgets() async {
    final db = await database;
    return await db.query('budgets', where: 'is_synced = 0');
  }

  Future<List<Map<String, dynamic>>> getBudgetsPendingDeletion() async {
    final db = await database;
    return await db.query('budgets', where: 'pending_deletion = 1');
  }

  Future<Map<String, dynamic>?> getBudgetById(String budgetId) async {
    final db = await database;

    // Query the database for the specific budget by its ID
    final result = await db.query(
      'budgets',
      where: 'budget_id = ?',
      whereArgs: [budgetId],
    );

    if (result.isNotEmpty) {
      return result.first; // Return the first matching result
    } else {
      return null; // Return null if no matching budget is found
    }
  }
}
