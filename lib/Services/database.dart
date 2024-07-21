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
        lastUpdatedDate TEXT,
        transactionDate TEXT
      )
    ''');
  }
  // Retrieve all payments
  static Future<List<Map<String, dynamic>>> getAllPayments() async {
    Database db = await database;
    return await db.query('payments');
  }

  //Retrieve Co
  static Future<List<Map<String, dynamic>>> getConfirmedPayments() async {
    Database db = await database;
    List<Map<String, dynamic>> payments = await db.query(
      'payments',
      where: 'status = ?',
      whereArgs: ['Confirmed'],
    );
    return payments;
  }

  //Retrieve a specific payment
  static Future<Map<String, dynamic>?> getPaymentById(int id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'payments',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  //update the voucher serial number by id
  static Future<void> updatePaymentvoucherSerialNumber(int id, String voucherSerialNumber) async {
    try {
      Database db = await database;

      // Check the current voucher serial number in the database
      List<Map<String, dynamic>> payments = await db.query('payments', where: 'id = ?', whereArgs: [id]);
      if (payments.isNotEmpty) {
        String? currentVoucherNumber = payments.first['voucherSerialNumber'];

        // Only update if the current voucher number is null
        if (currentVoucherNumber == null) {
          await db.update(
            'payments',
            {'voucherSerialNumber': voucherSerialNumber},
            where: 'id = ?',
            whereArgs: [id],
          );
          print('Voucher serial number updated for payment with id $id');
        } else {
          print('Voucher serial number already exists for payment with id $id. Skipping update.');
        }
      } else {
        throw Exception('Payment with id $id not found');
      }
    } catch (e) {
      print('Error updating voucher serial number: $e');
      // Handle the error as per your application's requirements
      throw Exception('Failed to update voucher serial number');
    }
  }

  // Update payment status
  static Future<void> updatePaymentStatus(int id, String status) async {
    try {
      Database db = await database;
      // Update payment status
      await db.update(
        'payments',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Payment status updated successfully for payment with id $id');

      // If the status is 'Confirmed', also update the transaction date
      if (status.toLowerCase() == 'confirmed') {
        String currentDateTime = DateTime.now().toIso8601String();
        await updateTransactionDate(id, currentDateTime);
      }
    } catch (e) {
      print('Error updating payment status: $e');
      throw Exception('Failed to update payment status');
    }
  }

  // Update Transaction Date
  static Future<void> updateTransactionDate(int id, String transactionDate) async {
    try {
      Database db = await database;
      Map<String, dynamic>? payment = await getPaymentById(id);
      if (payment != null) {
        String? currentTransactionDate = payment['transactionDate'];

        // Only update if the current transaction date is null
        if (currentTransactionDate == null) {
          await db.update(
            'payments',
            {'transactionDate': transactionDate},
            where: 'id = ?',
            whereArgs: [id],
          );
          print('Transaction date updated for payment with id $id');
        } else {
          print('Transaction date already exists for payment with id $id. Skipping update.');
        }
      } else {
        throw Exception('Payment with id $id not found');
      }
    } catch (e) {
      print('Error updating transaction date: $e');
      throw Exception('Failed to update transaction date');
    }
  }

  // Update last Update Date
  static Future<void> updateLastUpdatedDate(int id, String lastUpdatedDate) async {
    try {
      Database db = await database;
      await db.update(
        'payments',
        {'lastUpdatedDate': lastUpdatedDate},
        where: 'id = ?',
        whereArgs: [id],
      );
      print('Last updated date updated for payment with id $id');
    } catch (e) {
      print('Error updating last updated date: $e');
      throw Exception('Failed to update last updated date');
    }
  }

  // Edit payment information
  static Future<void> updatePayment(int id, Map<String, dynamic> updatedData) async {
    Database db = await database;
    updatedData['lastUpdatedDate'] = DateTime.now().toIso8601String();
    await db.update('payments', updatedData, where: 'id = ?', whereArgs: [id]);
  }

  // Save a new payment record
  static Future<void> savePayment(Map<String, dynamic> paymentData) async {
    Database db = await database;
    paymentData['lastUpdatedDate'] = DateTime.now().toIso8601String();
    await db.insert('payments', paymentData);
  }

  // Delete a payment by ID
  static Future<void> deletePayment(int id) async {
    Database db = await database;
    await db.delete('payments', where: 'id = ?', whereArgs: [id]);
  }

  // Clear Date base
  static Future<void> clearDatabase() async {
    Database db = await database;
    await db.delete('payments');
    print('Database cleared');
  }

}
