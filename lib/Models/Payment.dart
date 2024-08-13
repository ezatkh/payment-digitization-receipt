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
  DateTime? transactionDate;
  DateTime? lastUpdatedDate;
  String? cancelReason;
  DateTime? cancellationDate;

  void printAllFields() {
    if(this.status.toLowerCase() == 'saved')
      print("lastUpdatedDate: " + this.lastUpdatedDate.toString() ?? '');
    else print("transactionDate: " + this.transactionDate.toString() ?? '');
    print("voucherSerialNumber: " + (this.voucherSerialNumber.toString()));
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
    print("cancelReason: " + (this.cancelReason ?? '')); // New field
    print("cancellationDate: " + (this.cancellationDate?.toString() ?? '')); // New field

  }
  Payment({
    this.transactionDate,
    this.lastUpdatedDate,
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
    required this.status,
    this.cancelReason= '',
    this.cancellationDate
  })
  {
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      status: map['status'],
      id: map['id'],
      voucherSerialNumber: map['voucherSerialNumber'] ?? ''  ,
      lastUpdatedDate:(map['lastUpdatedDate'] != 'null' && map['lastUpdatedDate'] != ''&&  map['lastUpdatedDate'] != null) ? DateTime.parse(map['lastUpdatedDate']) : null,
      transactionDate:(map['transactionDate'] != 'null' && map['transactionDate'] != '' &&  map['transactionDate'] != null) ? DateTime.parse(map['transactionDate']) : null,
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
      cancelReason: (map['cancelReason'] != null && map.containsKey('cancelReason')) ? map['cancelReason'] : null,
      cancellationDate:(map['cancellationDate'] != 'null' && map['cancellationDate'] != '' &&  map['cancellationDate'] != null) ? DateTime.parse(map['cancellationDate']) : null,

    );
  }
  Map<String, dynamic> toMap() {
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
      'paymentInvoiceFor': paymentInvoiceFor,
      'status': status,
      'voucherSerialNumber': voucherSerialNumber,
      'id': id,
      'transactionDate': transactionDate?.toIso8601String(),
      'lastUpdatedDate': lastUpdatedDate?.toIso8601String(),
      'cancelReason': cancelReason,
      'cancellationDate': cancellationDate?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Payment(voucherSerialNumber: $voucherSerialNumber, customerName: $customerName, msisdn: $msisdn, prNumber: $prNumber, paymentMethod: $paymentMethod, amount: $amount, amountCheck: $amountCheck, checkNumber: $checkNumber, bankBranch: $bankBranch, dueDateCheck: $dueDateCheck, currency: $currency, paymentInvoiceFor: $paymentInvoiceFor, status: $status, id: $id, transactionDate: $transactionDate, lastUpdatedDate: $lastUpdatedDate, cancelReason: $cancelReason, cancellationDate: $cancellationDate)';
  }
}
