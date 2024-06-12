import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';  // Required for ImageFilter

class PaymentCancellationScreen extends StatelessWidget {
  final List<String> paymentIds = ['PR12345', 'PR67890', 'PR23456'];  // Example PR#s

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 4,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.0),
          child: Container(
            color: Colors.white.withOpacity(0.2),
            height: 1.0,
          ),
        ),
        title: Text('Cancel Payment',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontFamily: 'NotoSansUI',
            )),
        backgroundColor: Color(0xFFC62828),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSelectionCard(context),
            SizedBox(height: 24.h),
            _buildInputCard(context, 'Reason for Cancellation', 'Enter the reason'),
            SizedBox(height: 16.h),
            _buildInputCard(context, 'Additional Details (optional)', 'Add more details', maxLines: 3),
            SizedBox(height: 30.h),
            _buildActionButton(context, 'Cancel Payment', Color(0xFFD32F2F)),
            SizedBox(height: 12.h),
            _buildActionButton(context, 'Back', Colors.black, isOutlined: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionCard(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Payment to Cancel", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              underline: Container(height: 0),
              items: paymentIds.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {},
              hint: Text("Choose a payment"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, String label, String hint, {int maxLines = 1}) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black54,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 8.h),
            TextField(
              maxLines: maxLines,
              decoration: InputDecoration(
                fillColor: Color(0xFFE0E0E0),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: hint,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String text, Color color, {bool isOutlined = false}) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white, backgroundColor: color,
        minimumSize: Size(double.infinity, 33.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: isOutlined ? BorderSide(color: color) : BorderSide.none,
      ),
      onPressed: () {
        if (isOutlined) {
          Navigator.pop(context);
        } else {
          _showConfirmationDialog(context);
        }
      },
      child: Text(text, style: TextStyle(fontSize: 18.sp)),
    );
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Cancellation"),
          content: Text("Are you sure you want to cancel this payment?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                // TODO: Implement the cancellation logic
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
