import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'PrintSettingsScreen.dart';

class PrintReceiptScreen extends StatefulWidget {
  @override
  _PrintReceiptScreenState createState() => _PrintReceiptScreenState();
}

class _PrintReceiptScreenState extends State<PrintReceiptScreen> {
  List<Map<String, dynamic>> receipts = [
    {
      'voucherNumber': 'W-12345',
      'transactionDate': DateTime.now().subtract(Duration(days: 1)),
      'amount': '150 USD',
      'synced': true,
      'selected': false,
    },
    {
      'voucherNumber': 'W-12346',
      'transactionDate': DateTime.now().subtract(Duration(days: 2)),
      'amount': '200 USD',
      'synced': false,
      'selected': false,
    },
    {
      'voucherNumber': 'W-12347',
      'transactionDate': DateTime.now(),
      'amount': '250 USD',
      'synced': true,
      'selected': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: _buildAppBar(), // Use the AppBar method here
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildFilterOptions(),
            ListView.builder(
              itemCount: receipts.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) => _buildReceiptCard(receipts[index], index),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
      backgroundColor: Color(0xFFF9F9F9),
    );
  }


  AppBar _buildAppBar() {
    return AppBar(
      elevation: 4,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: Container(
          color: Colors.white.withOpacity(0.2),
          height: 1.0,
        ),
      ),
      title: Text('Print Receipt',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontFamily: 'NotoSansUI',
          )),
      backgroundColor: Color(0xFFC62828),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildFilterOptions() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Voucher Number',
                suffixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Filter logic here
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptCard(Map<String, dynamic> receipt, int index) {
    return Card(
      elevation: 5,
      shadowColor: Colors.grey.withOpacity(0.5),
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
      child: ListTile(
        leading: Checkbox(
          value: receipt['selected'],
          onChanged: (bool? value) {
            setState(() {
              receipts[index]['selected'] = value!;
            });
          },
        ),
        title: Text('Voucher: ${receipt['voucherNumber']}'),
        subtitle: Text('Amount: ${receipt['amount']} - Date: ${receipt['transactionDate'].toString().split(' ')[0]}'),
        trailing: Wrap(
          spacing: 12,
          children: <Widget>[
            Icon(receipt['synced'] ? Icons.check_circle : Icons.error, color: receipt['synced'] ? Colors.green : Colors.red),
            IconButton(
              icon: Icon(Icons.print),
              onPressed: receipt['synced'] ? () => Navigator.push(context, MaterialPageRoute(builder: (context) => PrintSettingsScreen())) : null,
            ),
            IconButton(
              icon: Icon(Icons.send),
              onPressed: receipt['synced'] ? () => _sendReceipt(receipt) : null,
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildActionButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(  // Use Expanded widget
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),  // Add padding to ensure some space between buttons
              child: ElevatedButton(
                onPressed: _printSelectedReceipts,
                child: Text('Print Selected', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFC62828),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.2),
                  textStyle: TextStyle(letterSpacing: 1.2),
                ),
              ),
            ),
          ),
          Expanded(  // Use Expanded widget
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),  // Add padding to ensure some space between buttons
              child: ElevatedButton(
                onPressed: _sendSelectedReceipts,
                child: Text('Send Selected', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                  elevation: 5,
                  shadowColor: Colors.black.withOpacity(0.2),
                  textStyle: TextStyle(letterSpacing: 1.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _styledElevatedButton({
    required VoidCallback onPressed,
    required String text,
    required Color color,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all(color),
        padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 14.h, horizontal: 30.w)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
              side: BorderSide(color: Colors.white24), // subtle border color
            )
        ),
        elevation: MaterialStateProperty.all(6), // slightly raised
        shadowColor: MaterialStateProperty.all(Colors.black45), // darker shadow for more depth
        overlayColor: MaterialStateProperty.resolveWith<Color>(
                (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return color.withOpacity(0.5);
              if (states.contains(MaterialState.hovered)) return color.withOpacity(0.1);
              return color; // Default case
            }
        ),
      ),
    );
  }


  void _printReceipt(Map<String, dynamic> receipt) {

  }

  void _printSelectedReceipts() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => PrintSettingsScreen()),
    );
  }

  void _sendReceipt(Map<String, dynamic> receipt) {
    // Send logic for individual receipt
  }

  void _sendSelectedReceipts() {
    // Send logic for selected receipts
  }
}
