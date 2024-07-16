import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

class Payment {
  String voucherSerialNumber;
  String customerName;
  String? msisdn;
  String? prNumber;
  String paymentMethod;
  double? amount;
  double? amountCheck;
  int? checkNumber;
  String? bankBranch;
  DateTime? dueDateCheck;
  String? currency;
  String? paymentInvoiceFor;
  String status;
  int? id;

  //user
  //date

  void printAllFields() {
    print("id: " + (this.id.toString()));
    print("customerName: " + (this.customerName ?? ''));
    print("msisdn: " + (this.msisdn ?? ''));
    print("prNumber: " + (this.prNumber ?? ''));
    print("paymentMethod: " + (this.paymentMethod ?? ''));
    print("amount: " + (this.amount?.toString() ?? ''));
    print("amountCheck: " + (this.amountCheck?.toString() ?? ''));
    print("checkNumber: " + (this.checkNumber.toString() ?? ''));
    print("bankBranch: " + (this.bankBranch ?? ''));
    print("dueDateCheck: " + (this.dueDateCheck.toString() ?? ''));
    print("currency: " + (this.currency ?? ''));
    print("paymentInvoiceFor: " + (this.paymentInvoiceFor ?? ''));
    print("status: " + this.status);
  }
  Payment({
    this.voucherSerialNumber = '',
    this.id,
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
    this.paymentInvoiceFor,
    required this.status
  })
  {
    printAllFields();
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      status: map['status'],
      id: map['id'],
      paymentMethod: map['paymentMethod'],
      customerName: map['customerName'],
      msisdn: (map['msisdn'] !=null && map.containsKey('msisdn'))?map['msisdn']: null,
      prNumber: (map['prNumber'] !=null && map.containsKey('prNumber'))?map['prNumber']: null,
      amount: (map['amount'] !=null && map.containsKey('amount')) ?map['amount']: null,
      amountCheck: (map['amountCheck']!=null && map.containsKey('amountCheck'))?map['amountCheck']: null,
      checkNumber: (map['checkNumber']!=null && map.containsKey('checkNumber'))?map['checkNumber']: null,
      bankBranch: (map['bankBranch']!=null && map.containsKey('bankBranch'))?map['bankBranch']: null,
      dueDateCheck: (map['dueDateCheck'] != 'null' && map['dueDateCheck'] != '') ? DateTime.parse(map['dueDateCheck']) : null,
      currency: (map['currency'] !=null && map.containsKey('currency'))?map['currency']: null,
      paymentInvoiceFor: (map['paymentInvoiceFor'] !=null && map.containsKey('paymentInvoiceFor'))?map['paymentInvoiceFor']: null,

    );
  }
}
