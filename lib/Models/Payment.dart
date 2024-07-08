import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../Services/networking.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter/material.dart';

class Payment {
  String voucherSerialNumber;
  String customerName;
  String? msisdn;
  String? prNumber;
  String paymentMethod;
  double? amount;
  double? amountCheck;
  String? checkNumber;
  String? bankBranch;
  DateTime? dueDateCheck;
  String? currency;
  String? notes;

  Payment({
    this.voucherSerialNumber = '',
    required this.customerName,
    required this.paymentMethod,
    this.msisdn,
    this.prNumber,
    this.amount,
    this.amountCheck,
    this.checkNumber,
    this.bankBranch,
    this.dueDateCheck,
    this.currency,
    this.notes,
  });

  // Method to create a Payment object from a JSON map
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      voucherSerialNumber: json['voucherSerialNumber'],
      customerName: json['customerName'],
      msisdn: json['msisdn'],
      prNumber: json['prNumber'],
      paymentMethod: json['paymentMethod'],
      amount: json['amount']?.toDouble(),
      amountCheck: json['amountCheck']?.toDouble(),
      checkNumber: json['checkNumber'],
      bankBranch: json['bankBranch'],
      dueDateCheck: json['dueDateCheck'] != null ? DateTime.parse(
          json['dueDateCheck']) : null,
      currency: json['currency'],
      notes: json['notes'],
    );
  }

  // Method to convert a Payment object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'voucherSerialNumber': voucherSerialNumber,
      'customerName': customerName,
      'msisdn': msisdn,
      'prNumber': prNumber,
      'paymentMethod': paymentMethod,
      'amount': amount,
      'amountCheck': amountCheck,
      'checkNumber': checkNumber,
      'bankBranch': bankBranch,
      'dueDateCheck': dueDateCheck?.toIso8601String(),
      'currency': currency,
      'notes': notes,
    };
  }
}
