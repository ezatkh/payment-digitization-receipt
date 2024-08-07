import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../Services/LocalizationService.dart';

class CustomPopups {

  static void showCustomDialog({
    required BuildContext context,
    required Icon icon,
    required String title,
    required String message,
    required String deleteButtonText,
    required VoidCallback onPressButton,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(height: 20),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: Text(Provider.of<LocalizationService>(context, listen: false).getLocalizedString('cancel'), style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text(deleteButtonText),
              onPressed: () {
                Navigator.of(context).pop();
                onPressButton();

              },
            ),
          ],
        );
      },
    );
  }


  static Future<void> showConfirmDialog(BuildContext context, VoidCallback onConfirm) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Confirm Payment',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          content: Text(
            'Are you sure you want to confirm this payment?',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.black54,
            ),
          ),
          actions: [
            TextButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.blue,
                ),
              ),
              onPressed: () {
                onConfirm();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
