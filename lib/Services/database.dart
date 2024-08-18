import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
        cancelReason TEXT,
        lastUpdatedDate TEXT,
        transactionDate TEXT,
        cancellationDate TEXT,
        userId TEXT
      )
      
      
    ''');

    await db.execute('''
      CREATE TABLE currencies (
        id TEXT PRIMARY KEY,
        arabicName TEXT,
        englishName TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE banks(
        id TEXT PRIMARY KEY,
        arabicName TEXT,
        englishName TEXT
      )
    ''');
  }

  static Future<List<Map<String, dynamic>>> getAllPayments(String userId) async {
    print("printAllPayments method , database.dart started");

    Database db = await database;

    // Query the database to get all payments based on userId
    List<Map<String, dynamic>> payments = await db.query(
      'payments',
      where: 'userId = ?',
      whereArgs: [userId],
    );
    print("printAllPayments method , database.dart finished");
    return payments;
  }

  //Retrieve ConfirmedPayments
  static Future<List<Map<String, dynamic>>> getConfirmedOrCancelledPendingPayments() async {
    Database db = await database;
    List<Map<String, dynamic>> payments = await db.query(
      'payments',
      where: 'status IN (?, ?)',
      whereArgs: ['Confirmed', 'CancelPending'],
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
        await updateTransactionDate(id);
      }
    } catch (e) {
      print('Error updating payment status: $e');
      throw Exception('Failed to update payment status');
    }
  }

  // Update Transaction Date
  static Future<void> updateTransactionDate(int id) async {
    try {
      Database db = await database;
      Map<String, dynamic>? payment = await getPaymentById(id);
      if (payment != null) {
        String? currentTransactionDate = payment['transactionDate'];

        // Only update if the current transaction date is null
        if (currentTransactionDate == null) {
          String now = formatDateTimeWithMilliseconds(DateTime.now());
          await db.update(
            'payments',
            {'transactionDate': now},
            where: 'id = ?',
            whereArgs: [id],
          );
          print('Transaction date updated to now for payment with id $id');
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
    print("updatePayment method in database.dart started");
    print(updatedData);
    updatedData['lastUpdatedDate'] = formatDateTimeWithMilliseconds(DateTime.now());
    if(updatedData["status"].toLowerCase() == "confirmed"){
      updatedData['transactionDate'] = formatDateTimeWithMilliseconds(DateTime.now());

    }
     Database db = await database;
     await db.update('payments', updatedData, where: 'id = ?', whereArgs: [id]);
    print("updatePayment method in database.dart finished");

  }

  // Save a new payment record
  static Future<int> savePayment(Map<String, dynamic> paymentData) async {
    print("savePayment method in database.dart started");
    Database db = await database;

    // Check if the status is 'Confirmed' and set the transaction date
    if (paymentData['status'] != null && paymentData['status'].toLowerCase() == 'confirmed') {
      paymentData['transactionDate'] = formatDateTimeWithMilliseconds(DateTime.now());
      paymentData['lastUpdatedDate'] = formatDateTimeWithMilliseconds(DateTime.now());
    } else if (paymentData['status'] != null && paymentData['status'].toLowerCase() == 'saved') {
      // Set the last updated date to now
      paymentData['lastUpdatedDate'] = formatDateTimeWithMilliseconds(DateTime.now());
    }

    // Insert the payment data into the database and return the ID of the new row
    int id = await db.insert('payments', paymentData);
    print("the id of new payment is to return : ${id}");
    Map<String, dynamic>? newPayment = await getPaymentById(id);
    print("the new payment after saved to db :");
    print(newPayment);
    print("savePayment method in database.dart finished");

    return id;
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

  static String formatDateTimeWithMilliseconds(DateTime dateTime) {
    final DateFormat formatter = DateFormat('yyyy-MM-ddTHH:mm:ss.SSS');
    print(formatter.format(dateTime)); // This should print the date and time without milliseconds
    return formatter.format(dateTime);
  }

  // Cancel a payment by voucherSerialNumber
// Cancel a payment by voucherSerialNumber
  static Future<void> cancelPayment(String voucherSerialNumber, String cancelReason,String formattedCancelDateTime ,String newStatus) async {

    print("cancelPayment method, database.dart started");
    try {
      Database db = await database;

      await db.update(
        'payments',
        {
          'status': newStatus,
          'cancelReason': cancelReason,
          'cancellationDate': formattedCancelDateTime,
        },
        where: 'voucherSerialNumber = ?',
        whereArgs: [voucherSerialNumber],
      );

     print('Payment with voucherSerialNumber $voucherSerialNumber has been cancelled with these details : ${cancelReason}:${formattedCancelDateTime}');
    } catch (e) {
      print('Error cancelling payment: $e');
      throw Exception('Failed to cancel payment');
    }
    print("cancelPayment method, database.dart finished");
  }

  static Future<List<Map<String, dynamic>>> getPaymentsWithDateFilter(
      DateTime? fromDate,
      DateTime? toDate,
      List<String>? statuses ,String userId) async {
    //print("getPaymentsWithDateFilter method, database.dart");
    //print("from date: $fromDate, to date: $toDate, statuses: $statuses");

    Database db = await database;

    // Start with the base query
    String query = 'SELECT * FROM payments WHERE userId = "$userId"';

    // Add date filters if they are provided
    if (fromDate != null && fromDate.toString().isNotEmpty) {
      query += ' AND transactionDate >= "${fromDate.toIso8601String()}"';
    }
    if (toDate != null && toDate.toString().isNotEmpty) {
      DateTime endOfDay = DateTime(toDate.year, toDate.month, toDate.day, 23, 59, 59);
      query += ' AND transactionDate <= "${endOfDay.toIso8601String()}"';
    }

    // Add status filters if they are provided
    if (statuses != null && statuses.isNotEmpty) {
      // Escape single quotes in statuses
      statuses = statuses.map((status) => status.replaceAll("'", "''")).toList();
      String statusList = statuses.map((status) => "'$status'").join(', ');
      query += ' AND status IN ($statusList)';
    }


    // Execute the query
    List<Map<String, dynamic>> result = await db.rawQuery(query);
    return result;
  }

  // CRUD operations for the currencies table

  // Insert a currency record
  static Future<void> insertCurrency(Map<String, dynamic> currencyData) async {
    Database db = await database;
    await db.insert('currencies', currencyData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  // Retrieve all currency records
  static Future<List<Map<String, dynamic>>> getAllCurrencies() async {
    Database db = await database;
    List<Map<String, dynamic>> currencies = await db.query('currencies');
    return currencies;
  }

  // Retrieve a specific currency by ID
  static Future<Map<String, dynamic>?> getCurrencyById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'currencies',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  // Update a currency record
  static Future<void> updateCurrency(String id, Map<String, dynamic> updatedData) async {
    Database db = await database;
    await db.update(
      'currencies',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> clearAllCurrencies() async {
    final db = await database;
    await db.delete('currencies'); // Replace 'currencies' with your actual table name
  }

  // Delete a currency record by ID
  static Future<void> deleteCurrency(String id) async {
    print("deleteCurrency method in database.dart started");
    Database db = await database;
    await db.delete('currencies', where: 'id = ?', whereArgs: [id]);
    print("deleteCurrency method in database.dart finished");
  }

  // Clear the currencies table
  static Future<void> clearCurrencies() async {
    print("clearCurrencies method in database.dart started");
    Database db = await database;
    await db.delete('currencies');
    print('Currencies table cleared');
    print("clearCurrencies method in database.dart finished");
  }

  //crud operations for bank
  static Future<void> insertBank(Map<String, dynamic> bankData) async {
    Database db = await database;
    await db.insert('banks', bankData, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  static Future<List<Map<String, dynamic>>> getAllBanks() async {
    Database db = await database;
    return await db.query('banks');
  }

  static Future<Map<String, dynamic>?> getBankById(String id) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(
      'banks',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> updateBank(String id, Map<String, dynamic> updatedData) async {
    Database db = await database;
    await db.update(
      'banks',
      updatedData,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<void> deleteBank(String id) async {
    Database db = await database;
    await db.delete('banks', where: 'id = ?', whereArgs: [id]);
  }

  static Future<void> clearAllBanks() async {
    Database db = await database;
    await db.delete('banks');
  }

}
