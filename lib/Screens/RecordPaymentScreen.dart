import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../Custom_Widgets/CustomExpansionTile.dart';
import 'PaymentConfirmationScreen.dart';
import '../Services/LocalizationService.dart';
import 'package:provider/provider.dart';

class RecordPaymentScreen extends StatefulWidget {
  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _msisdnController = TextEditingController();
  final TextEditingController _prNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String? _selectedCurrency;
  String? _selectedPaymentMethod;
  List<String> _currencies = ['USD', 'EUR', 'QAR'];
  List<String> _paymentMethods = ['Cash', 'Check', 'Credit Card'];

  bool _isCustomerDetailsExpanded = false;
  bool _isPaymentInfoExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  String recordPayment = "";
  String customerDetails = "";
  String paymentInformation = "";
  String submitPayment = "";
  String currency = "";
  String amount = "";
  String notes = "";
  String paymentMethod = "";
  String customerName = "";
  String fieldsMissedMessageError = "";
  String fieldsMissedMessageSuccess = "";
  @override
  void initState() {
    super.initState();
    final localizationService = Provider.of<LocalizationService>(
        context, listen: false);
    recordPayment = localizationService.getLocalizedString('recordPayment');
    customerDetails = localizationService.getLocalizedString('customerDetails');
    paymentInformation = localizationService.getLocalizedString('paymentInformation');
    submitPayment = localizationService.getLocalizedString('submitPayment');
    paymentMethod = localizationService.getLocalizedString('paymentMethod');
    currency = localizationService.getLocalizedString('currency');
    notes = localizationService.getLocalizedString('notes');
    amount = localizationService.getLocalizedString('amount');
    customerName = localizationService.getLocalizedString('customerName');
    fieldsMissedMessageError = localizationService.getLocalizedString('fieldsMissedMessageError');
    fieldsMissedMessageSuccess = localizationService.getLocalizedString('fieldsMissedMessageSuccess');

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    return Scaffold(
      appBar: AppBar( elevation: 4,  // Adds a subtle shadow for depth
          bottom: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: Container(
          color: Colors.white.withOpacity(0.2), // subtle separator for visual definition
          height: 1.0,
        ),
      ),
        title: Text(recordPayment,
            style: TextStyle(color: Colors.white, fontSize: 20.sp     ,   fontFamily: 'NotoSansUI',)),
        backgroundColor: Color(0xFFC62828),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _submitPayment,
            tooltip: 'Save Payment',color: Colors.white,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildExpandableSection(
                title: customerDetails,
                iconData: Icons.account_circle,
                isExpanded: _isCustomerDetailsExpanded,
                children: [
                  _buildTextField(_customerNameController, customerName,
                      Icons.person_outline),
                  _buildTextField(
                      _msisdnController, 'MSISDN', Icons.phone_android),
                  _buildTextField(_prNumberController, 'PR#', Icons.receipt),
                ],
                onExpansionChanged: (bool expanded) {
                  setState(() => _isCustomerDetailsExpanded = expanded);
                },
                checkIfFilled: () {
                  return _customerNameController.text.isNotEmpty &&
                      _msisdnController.text.isNotEmpty &&
                      _prNumberController.text.isNotEmpty;
                }),
            _buildExpandableSection(
                title: paymentInformation,
                iconData: Icons.payment,
                isExpanded: _isPaymentInfoExpanded,
                children: [
                  _buildTextField(
                      _amountController, amount, Icons.attach_money),
                  _buildDropdown(currency, _currencies),
                  _buildDropdown(paymentMethod, _paymentMethods),
                  _buildTextField(_notesController, notes, Icons.note_add,
                      maxLines: 3),
                ],
                onExpansionChanged: (bool expanded) {
                  setState(() => _isPaymentInfoExpanded = expanded);
                },
                checkIfFilled: () {
                  return _amountController.text.isNotEmpty &&
                      _selectedCurrency != null &&
                      _selectedPaymentMethod != null &&
                      _notesController.text.isNotEmpty;
                }),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData iconData,
    required List<Widget> children,
    required bool isExpanded,
    required ValueChanged<bool> onExpansionChanged,
    required bool Function() checkIfFilled, // A function that checks if the fields are filled
  }) {
    bool isFilled = checkIfFilled();
    Color iconColor = isFilled ? Color(0xFF4CAF50) : Colors.grey[600]!; // Adjust color based on field status
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: CustomExpansionTile(
        initiallyExpanded: isExpanded,
        title: Text(title, style: TextStyle(        fontFamily: 'NotoSansUI',fontSize: 18.sp, fontWeight: FontWeight.bold, color: iconColor)),
        leading: Icon(iconData, size: 30.sp, color: iconColor),
        children: children,
        onExpansionChanged: onExpansionChanged,
        animationDuration: Duration(milliseconds: 200), // Set your desired speed of the animation
      ),
    );
  }



  Widget _buildTextField(
      TextEditingController controller, String labelText, IconData icon,
      {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,labelStyle: TextStyle(        fontFamily: 'NotoSansUI',),
          prefixIcon: Icon(icon, color: Color(0xFFC62828)),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          fillColor: Colors.white,
          filled: true,
        ),
        style: TextStyle(fontSize: 14.sp),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,labelStyle: TextStyle(        fontFamily: 'NotoSansUI'),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        value: label == 'Currency' ? _selectedCurrency : _selectedPaymentMethod,
        onChanged: (String? newValue) {
          setState(() {
            if (label == 'Currency') {
              _selectedCurrency = newValue;
            } else {
              _selectedPaymentMethod = newValue;
            }
          });
        },
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: GestureDetector(
        onTapDown: (_) => _animationController.forward(),
        onTapUp: (_) => _animationController.reverse(),
        child: ScaleTransition(
          scale: _buttonScaleAnimation,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC62828),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _submitPayment,
              child: Text(
                submitPayment,
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontFamily: 'NotoSansUI'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submitPayment() {
    if ([_customerNameController.text, _msisdnController.text, _prNumberController.text, _amountController.text, _selectedCurrency, _selectedPaymentMethod].any((element) => element == null || element.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(fieldsMissedMessageError, style: TextStyle(fontFamily: 'NotoSansUI',)),
            backgroundColor: Colors.red),
      );
      return;
    }

    // Assuming you have a model or class for passing payment details
    PaymentDetails paymentDetails = PaymentDetails(
      customerName: _customerNameController.text,
      msisdn: _msisdnController.text,
      prNumber: _prNumberController.text,
      amount: double.parse(_amountController.text),  // Ensure that amount is a double, handle parsing errors as needed
      paymentMethod: _selectedPaymentMethod!,
      date: DateTime.now().toString(), // Example date, adjust formatting as needed
      currency: _selectedCurrency!,  // Example currency
    );

    // Navigate to the Payment Confirmation Screen
    Navigator.push(context, MaterialPageRoute(
      builder: (context) => PaymentConfirmationScreen(paymentDetails: paymentDetails),
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(fieldsMissedMessageSuccess, style: TextStyle(fontFamily: 'NotoSansUI',)),
          backgroundColor: Color(0xFF4CAF50)),
    );

    _clearFields();
  }



  void _clearFields() {
    _customerNameController.clear();
    _msisdnController.clear();
    _prNumberController.clear();
    _amountController.clear();
    _notesController.clear();
    _selectedCurrency = null;
    _selectedPaymentMethod = null;
  }


}

