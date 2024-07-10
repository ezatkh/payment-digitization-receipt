import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static const _databaseName = 'payments.db';
  static const _databaseVersion = 1;

  // Singleton instance of the database
  static Database? _database;

  // Private constructor to prevent instantiation
  DatabaseProvider._();

  // Get the singleton instance of the database
  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  // Initialize the database
  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
    );
  }

  // Create tables in the database
  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        voucherSerialNumber TEXT,
        customerName TEXT,
        msisdn TEXT,
        prNumber TEXT,
        paymentMethod TEXT,
        amount REAL,
        amountCheck REAL,
        checkNumber NUMERIC,
        bankBranch TEXT,
        dueDateCheck TEXT,
        currency TEXT,
        paymentInvoiceFor TEXT,
        status TEXT,
        createdDate TEXT
      )
    ''');
  }
  // Retrieve all payments
  static Future<List<Map<String, dynamic>>> getAllPayments() async {
    Database db = await database;
    return await db.query('payments');
  }

// Retrieve payments between start and end dates

  // static Future<List<Map<String, dynamic>>> getPaymentsBetweenDates(DateTime startDate, DateTime endDate) async {
  //   Database db = await database;
  //   String formattedStartDate = startDate.toIso8601String();
  //   String formattedEndDate = endDate.toIso8601String();
  //
  //   return await db.rawQuery('''
  //   SELECT * FROM payments
  //   WHERE dueDateCheck BETWEEN ? AND ?
  // ''', [formattedStartDate, formattedEndDate]);
  // }

// Save a new payment record
  static Future<void> savePayment(Map<String, dynamic> paymentData) async {
    Database db = await database;
    await db.insert('payments', paymentData);
  }

// Edit payment information (including status)
  static Future<void> updatePayment(int id, Map<String, dynamic> updatedData) async {
    Database db = await database;
    await db.update('payments', updatedData, where: 'id = ?', whereArgs: [id]);
  }

// Delete a payment by ID
  static Future<void> deletePayment(int id) async {
    Database db = await database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

}
