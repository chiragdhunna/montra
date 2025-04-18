import 'package:flutter_test/flutter_test.dart';
import 'package:montra/logic/database/database_helper.dart';
import 'package:montra/logic/api/wallet/models/wallet_model.dart';
import 'package:montra/logic/api/bank/models/bank_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'dart:io';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory dbFolder;
  late String dbPath;

  setUpAll(() async {
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
  });

  setUp(() async {
    dbFolder = await Directory.systemTemp.createTemp('montra_test_');
    dbPath = join(dbFolder.path, 'montra.db');
    await databaseFactory.setDatabasesPath(dbFolder.path);
    await deleteDatabase(dbPath);
    await DatabaseHelper().deleteDatabaseFile();
  });

  tearDown(() async {
    await DatabaseHelper().deleteDatabaseFile();
    if (await dbFolder.exists()) {
      await dbFolder.delete(recursive: true);
    }
  });

  test('Database should be created and is open', () async {
    final db = await DatabaseHelper().database;
    expect(db.isOpen, true);
  });

  test('Account balance insert/update and retrieve', () async {
    final dbHelper = DatabaseHelper();
    await dbHelper.upsertAccountBalance(1234.56);
    final balance = await dbHelper.getAccountBalance();
    expect(balance, closeTo(1234.56, 0.01));

    await dbHelper.upsertAccountBalance(789.00);
    final updatedBalance = await dbHelper.getAccountBalance();
    expect(updatedBalance, closeTo(789.00, 0.01));
  });

  test('Insert and retrieve wallet', () async {
    final dbHelper = DatabaseHelper();
    final wallet = WalletModel(
      name: 'Test Wallet',
      amount: 500,
      userId: 'user123',
      walletNumber: 'wallet123',
    );

    final walletMap = {
      'name': wallet.name,
      'balance': wallet.amount.toDouble(),
      'userId': wallet.userId,
      'walletNumber': wallet.walletNumber,
    };

    final db = await dbHelper.database;
    await db.insert('wallets', walletMap);

    final wallets = await dbHelper.getWallets();
    expect(wallets.length, 1);
    expect(wallets[0].name, 'Test Wallet');
    expect(wallets[0].amount, 500);
  });

  test('Insert and retrieve bank', () async {
    final dbHelper = DatabaseHelper();
    final bank = BankModel(
      name: 'Test Bank',
      amount: 1000,
      userId: 'user123',
      accountNumber: 'acc123',
      createdAt: DateTime.now(),
    );

    final bankMap = {
      'name': bank.name,
      'balance': bank.amount.toDouble(),
      'userId': bank.userId,
      'accountNumber': bank.accountNumber,
      'createdAt': bank.createdAt.toIso8601String(),
    };

    final db = await dbHelper.database;
    await db.insert('banks', bankMap);

    final banks = await dbHelper.getBanks();
    expect(banks.length, 1);
    expect(banks[0].name, 'Test Bank');
    expect(banks[0].amount, 1000);
  });

  test('Insert and retrieve income', () async {
    final dbHelper = DatabaseHelper();
    final incomes = [
      {
        'income_id': 'inc1',
        'amount': 1000,
        'user_id': 'user123',
        'source': 'wallet',
        'description': 'Test Income',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    await dbHelper.upsertIncome(incomes);
    final result = await dbHelper.getIncome();
    expect(result.length, 1);
    expect(result[0]['income_id'], 'inc1');
  });

  test('Insert and retrieve expenses', () async {
    final dbHelper = DatabaseHelper();
    final expenses = [
      {
        'expense_id': 'exp1',
        'amount': 200,
        'user_id': 'user123',
        'source': 'bank',
        'description': 'Groceries',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    await dbHelper.upsertExpenses(expenses);
    final result = await dbHelper.getExpenses();
    expect(result.length, 1);
    expect(result[0]['expense_id'], 'exp1');
  });

  test('Insert and retrieve transfers', () async {
    final dbHelper = DatabaseHelper();
    final transfers = [
      {
        'transfer_id': 'tr1',
        'amount': 250,
        'sender': 'wallet123',
        'receiver': 'acc123',
        'is_expense': 0,
        'user_id': 'user123',
        'created_at': DateTime.now().toIso8601String(),
      },
    ];

    await dbHelper.upsertTransfers(transfers);
    final result = await dbHelper.getTransfers();
    expect(result.length, 1);
    expect(result[0]['transfer_id'], 'tr1');
    expect(result[0]['amount'], 250);
  });

  test('Insert and retrieve wallet names', () async {
    final dbHelper = DatabaseHelper();
    final names = ['Primary Wallet', 'Emergency Fund', 'Trip Fund'];
    await dbHelper.upsertWalletNames(names);
    final result = await dbHelper.getWalletNames();
    expect(result.length, 3);
    expect(result, containsAll(names));
  });

  test('Insert and retrieve notification', () async {
    final dbHelper = DatabaseHelper();
    final notification = {
      'title': 'Budget Exceeded',
      'subtitle': 'Your monthly budget has been exceeded',
      'time': DateTime.now().toIso8601String(),
    };
    await dbHelper.insertNotification(notification);
    final result = await dbHelper.getNotifications();
    expect(result.length, 1);
    expect(result[0]['title'], 'Budget Exceeded');
  });

  test('Clear all notifications', () async {
    final dbHelper = DatabaseHelper();
    await dbHelper.clearAllNotifications();
    final result = await dbHelper.getNotifications();
    expect(result.isEmpty, true);
  });

  test('Insert and retrieve offline income', () async {
    final dbHelper = DatabaseHelper();
    final income = {
      'income_id': 'offline1',
      'amount': 400,
      'user_id': 'user123',
      'source': 'cash',
      'description': 'Side job',
      'created_at': DateTime.now().toIso8601String(),
    };
    await dbHelper.insertOfflineIncome(income);
    final result = await dbHelper.getOfflineIncomes();
    expect(result.length, 1);
    expect(result[0]['income_id'], 'offline1');
  });

  test('Clear offline incomes', () async {
    final dbHelper = DatabaseHelper();
    await dbHelper.clearOfflineIncomes();
    final result = await dbHelper.getOfflineIncomes();
    expect(result.isEmpty, true);
  });

  test('Insert and retrieve expense stats', () async {
    final dbHelper = DatabaseHelper();
    final stats = {
      'totalExpense': 1200,
      'categories': {'Food': 600, 'Transport': 300, 'Other': 300},
    };
    await dbHelper.upsertExpenseStats(stats);
    final result = await dbHelper.getExpenseStats();
    expect(result?['totalExpense'], 1200);
    expect(result?['categories']['Food'], 600);
  });
}
