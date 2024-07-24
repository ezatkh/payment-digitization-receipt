import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:ui';  // Required for ImageFilter
import '../Services/LocalizationService.dart';
import 'package:provider/provider.dart';
import '../Custom_Widgets/CustomPopups.dart';
class PaymentCancellationScreen extends StatefulWidget {
  final int id;

  PaymentCancellationScreen({required this.id});

  @override
  _PaymentCancellationScreenState createState() => _PaymentCancellationScreenState();
}

class _PaymentCancellationScreenState extends State<PaymentCancellationScreen> {
  String cancelPayment = '';
  String reasonForCancellation = '';
  String enterTheReason = '';
  String back = '';
  String confirmCancellation = '';
  String confirmCancellationBody = '';
  String confirm = '';
  String cancel = '';

  void _initializeLocalizationStrings() {
    final localizationService = Provider.of<LocalizationService>(context, listen: false);
    cancelPayment = localizationService.getLocalizedString('cancelPayment');
    reasonForCancellation = localizationService.getLocalizedString('reasonForCancellation');
    enterTheReason = localizationService.getLocalizedString('enterTheReason');
    back = localizationService.getLocalizedString('back');
    confirmCancellation = localizationService.getLocalizedString('confirmCancellation');
    confirmCancellationBody = localizationService.getLocalizedString('confirmCancellationBody');
    confirm = localizationService.getLocalizedString('confirm');
    cancel = localizationService.getLocalizedString('cancel');
  }

  @override
  void initState() {
    super.initState();
    _initializeLocalizationStrings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F7F7),
      appBar: AppBar(
        elevation: 4,
        title: Text(
          cancelPayment,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontFamily: 'NotoSansUI',
          ),
        ),
        backgroundColor: Color(0xFFC62828),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputCard(context, reasonForCancellation, enterTheReason),
            SizedBox(height: 24.h),
            _buildActionButton(context, cancelPayment, Color(0xFFD32F2F)),
            SizedBox(height: 12.h),
            _buildActionButton(context, back, Colors.black, isOutlined: true),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(BuildContext context, String label, String hint, {int maxLines = 3}) {
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
        foregroundColor: isOutlined ? color : Colors.white,
        backgroundColor: isOutlined ? Colors.transparent : color,
        minimumSize: Size(double.infinity, 48.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        side: isOutlined ? BorderSide(color: color, width: 2) : BorderSide.none,
        padding: EdgeInsets.symmetric(vertical: 12.h),
      ),
      onPressed: () {
        if (isOutlined) {
          Navigator.pop(context);
        } else {
          CustomPopups.showCustomDialog(  context: context,
            icon: Icon(Icons.delete_forever, size: 60, color: Colors.red),
            title: 'Cancel Payment',
            message: 'Are you sure you want to cancel this payment?',
            deleteButtonText: 'Ok',
            onPressButton: () {
              // Your delete logic here
            },);
          //_showConfirmationDialog(context);
        }
      },
      child: Text(
        text,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
      ),
    );
  }


}
