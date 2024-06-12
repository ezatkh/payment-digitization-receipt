import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../Services/LocalizationService.dart';
import 'package:provider/provider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  DateTime? _selectedFromDate;
  DateTime? _selectedToDate;
  String paymentHistory='';
  String from='';
  String to='';
  String search='';
  void _initializeLocalizationStrings( ) {
    final localizationService = Provider.of<LocalizationService>(
        context, listen: false);
    paymentHistory = localizationService.getLocalizedString('paymentHistory');
    from = localizationService.getLocalizedString('from');
    to = localizationService.getLocalizedString('to');
    search = localizationService.getLocalizedString('search');
  }

  @override
  void initState() {
    super.initState();
    // Initialize the localization strings
    _initializeLocalizationStrings();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: AppBar(
        elevation: 4,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.white.withOpacity(0.2),
            height: 1.0,
          ),
        ),
        title: Text(paymentHistory,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontFamily: 'NotoSansUI',
            )),
        backgroundColor: Color(0xFFC62828),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildDateFilterSection(),
            SizedBox(height: 20.h),
            _buildSearchButton(),
            SizedBox(height: 20.h),
            _buildPaymentRecordsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterSection() {
    return Row(
      children: [
        Expanded(
          child: _buildDateField(
            context,
            label: from,
            controller: _fromDateController,
            onDateSelected: (date) {
              setState(() => _selectedFromDate = date);
            },
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _buildDateField(
            context,
            label: to,
            controller: _toDateController,
            onDateSelected: (date) {
              setState(() => _selectedToDate = date);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateField(BuildContext context,
      {required String label,
        required TextEditingController controller,
        required Function(DateTime) onDateSelected}) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: Icon(Icons.calendar_today, color: Color(0xFFC62828)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        fillColor: Colors.white,
        filled: true,
      ),
      readOnly: true,
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
        );
        if (picked != null && picked != _selectedFromDate) {
          controller.text = DateFormat('yyyy-MM-dd').format(picked);
          onDateSelected(picked);
        }
      },
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.search, color: Colors.white),
      label: Text(search,
          style: TextStyle(fontSize: 14.sp, fontFamily: 'NotoSansUI')),
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFC62828),
        minimumSize: Size(double.infinity, 40.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: () {},
    );
  }

  Widget _buildPaymentRecordsList() {
    List<PaymentRecord> paymentRecords = [
      PaymentRecord(
          customerName: "John Doe",
          amount: 150.00,
          date: "2023-04-12",
          paymentMethod: "Credit Card",
          msisdn: "123456789",
          prNumber: "PR1234",
          currency: "USD"),
      PaymentRecord(
          customerName: "Jane Smith",
          amount: 200.00,
          date: "2023-04-11",
          paymentMethod: "Cash",
          msisdn: "987654321",
          prNumber: "PR1235",
          currency: "EUR"),
      PaymentRecord(
          customerName: "Alice Johnson",
          amount: 300.00,
          date: "2023-04-10",
          paymentMethod: "Check",
          msisdn: "192837465",
          prNumber: "PR1236",
          currency: "QAR"),
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: paymentRecords.length,
      itemBuilder: (context, index) {
        return _buildPaymentRecordItem(paymentRecords[index]);
      },
    );
  }

  Widget _buildPaymentRecordItem(PaymentRecord record) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFFC62828),
            child: Icon(Icons.payment, color: Colors.white),
          ),
          title: Text(record.customerName,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
          subtitle: Text('${record.currency} ${record.amount.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600)),
          childrenPadding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
          children: [
            _paymentDetailRow('Payment Method', record.paymentMethod),
            _paymentDetailRow('PR#', record.prNumber),
            _paymentDetailRow('Date', record.date),
            _paymentDetailRow('Currency', record.currency),
            _paymentDetailRow('MSISDN', record.msisdn),
          ],
          onExpansionChanged: (bool expanded) {
            // Optionally add analytics or state management hooks here
          },
        ),
      ),
    );
  }

  Widget _paymentDetailRow(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade800)),
          Text(value, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: Colors.black87)),
        ],
      ),
    );
  }
}

class PaymentRecord {
  final String customerName;
  final double amount;
  final String paymentMethod;
  final String date;
  final String msisdn;
  final String prNumber;
  final String currency;

  PaymentRecord({
    required this.customerName,
    required this.amount,
    required this.paymentMethod,
    required this.date,
    required this.msisdn,
    required this.prNumber,
    required this.currency,
  });
}
