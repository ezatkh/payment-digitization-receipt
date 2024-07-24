import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Services/LocalizationService.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PaymentCancellationScreen extends StatelessWidget {
  final int id;

  PaymentCancellationScreen({required this.id});

  void _initializeLocalizationStrings(BuildContext context) {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    // Fetch localization strings from LocalizationService
  }

  @override
  Widget build(BuildContext context) {
    _initializeLocalizationStrings(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancel Payment',
              style: TextStyle(
                color: Colors.black,
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Voucher Number: $id',
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Reason for Cancellation',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter the reason...',
                fillColor: Color(0xFFF2F2F2),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel', style: TextStyle(fontSize: 16.sp)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFC62828),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Handle cancellation confirmation here
                    Navigator.of(context).pop();
                  },
                  child: Text('Confirm', style: TextStyle(fontSize: 16.sp)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
