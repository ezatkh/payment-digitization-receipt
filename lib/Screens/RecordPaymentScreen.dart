import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'PaymentConfirmationScreen.dart';
import '../Models/Payment.dart';
import '../Services/LocalizationService.dart';
import 'package:intl/intl.dart';

class RecordPaymentScreen extends StatefulWidget {
  @override
  _RecordPaymentScreenState createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _msisdnController = TextEditingController();
  final TextEditingController _prNumberController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _amountCheckController = TextEditingController();
  final TextEditingController _checkNumberController = TextEditingController();
  final TextEditingController _bankBranchController = TextEditingController();
  final TextEditingController _dueDateCheckController = TextEditingController();
  final TextEditingController _paymentInvoiceForController = TextEditingController();
  final FocusNode _customerNameFocusNode = FocusNode();
  final FocusNode _msisdnFocusNode = FocusNode();
  final FocusNode _prNumberFocusNode = FocusNode();
  final FocusNode _amountFocusNode = FocusNode();
  final FocusNode _amountCheckFocusNode = FocusNode();
  final FocusNode _checkNumberFocusNode = FocusNode();
  final FocusNode _bankBranchFocusNode = FocusNode();
  final FocusNode _dueDateCheckFocusNode = FocusNode();
  final FocusNode _paymentInvoiceForNode = FocusNode();
  String? _selectedCurrency;
  String? _selectedPaymentMethod;
  List<String> _currencies = ['usd', 'euro', 'ils', 'jd'];
  List<String> _paymentMethods = ['cash', 'check'];
  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  String recordPayment = "";
  String customerDetails = "";
  String paymentInformation = "";
  String confirmPayment = "";
  String savePayment = "";
  String currency = "";
  String amount = "";
  String amountCheck = "";
  String checkNumber = "";
  String bankBranchCheck = "";
  String dueDateCheck = "";
  String paymentMethod = "";
  String customerName = "";
  String fieldsMissedMessageError = "";
  String fieldsMissedMessageSuccess = "";
  String paymentInvoiceFor = "";
  String PR = "";
  String MSISDN = "";
  String cash = "";
  String check = "";
  String requiredFields="";

  @override
  void initState() {
    super.initState();
    final localizationService =
        Provider.of<LocalizationService>(context, listen: false);
    requiredFields = localizationService.getLocalizedString('requiredFields');
    recordPayment = localizationService.getLocalizedString('recordPayment');
    customerDetails = localizationService.getLocalizedString('customerDetails');
    paymentInformation = localizationService.getLocalizedString('paymentInformation');
    savePayment = localizationService.getLocalizedString('savePayment');
    confirmPayment = localizationService.getLocalizedString('confirmPayment');
    paymentMethod = localizationService.getLocalizedString('paymentMethod');
    currency = localizationService.getLocalizedString('currency');
    amount = localizationService.getLocalizedString('amount');
    amountCheck = localizationService.getLocalizedString('amountCheck');
    checkNumber = localizationService.getLocalizedString('checkNumber');
    bankBranchCheck = localizationService.getLocalizedString('bankBranchCheck');
    dueDateCheck = localizationService.getLocalizedString('dueDateCheck');
    customerName = localizationService.getLocalizedString('customerName');
    fieldsMissedMessageError =
        localizationService.getLocalizedString('fieldsMissedMessageError');
    fieldsMissedMessageSuccess =
        localizationService.getLocalizedString('fieldsMissedMessageSuccess');
    PR = localizationService.getLocalizedString('PR');
    MSISDN = localizationService.getLocalizedString('MSISDN');
    cash = localizationService.getLocalizedString('cash');
    check = localizationService.getLocalizedString('check');
    paymentInvoiceFor = localizationService.getLocalizedString('paymentInvoiceFor');

    // Localize and ensure unique values
    _paymentMethods = _paymentMethods
        .map((method) => localizationService.getLocalizedString(method))
        .toSet()
        .toList();
    _currencies = _currencies
        .map((currency) => localizationService.getLocalizedString(currency))
        .toSet()
        .toList();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _customerNameController.dispose();
    _msisdnController.dispose();
    _prNumberController.dispose();
    _amountController.dispose();
    _amountCheckController.dispose();
    _checkNumberController.dispose();
    _bankBranchController.dispose();
    _dueDateCheckController.dispose();
    _paymentInvoiceForController.dispose();


    _customerNameFocusNode.dispose();
    _msisdnFocusNode.dispose();
    _prNumberFocusNode.dispose();
    _amountFocusNode.dispose();
    _amountCheckFocusNode.dispose();
    _checkNumberFocusNode.dispose();
    _bankBranchFocusNode.dispose();
    _dueDateCheckFocusNode.dispose();
    _paymentInvoiceForNode.dispose();
    super.dispose();
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
        title: Text(recordPayment,
            style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontFamily: 'NotoSansUI')),
        backgroundColor: Color(0xFFC62828),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.w),
          child: Column(
            children: [
              _buildExpandableSection(
                title: customerDetails,
                iconData: Icons.account_circle,
                children: [
                  _buildTextField(
                    _customerNameController,
                    customerName,
                    Icons.person_outline,
                    focusNode: _customerNameFocusNode,
                      required:true
                  ),
                  _buildTextField(
                    _msisdnController,
                    MSISDN,
                    Icons.phone_android,
                    focusNode: _msisdnFocusNode,
                  ),
                  _buildTextField(
                    _prNumberController,
                    PR,
                    Icons.numbers_sharp,
                    focusNode: _prNumberFocusNode,
                  ),
                ],
                checkIfFilled: () {
                  return _customerNameController.text.isNotEmpty;
                },
              ),
              _buildExpandableSection(
                title: paymentInformation,
                iconData: Icons.payment,
                children: [
                  //
                  _buildDropdown(paymentMethod, _paymentMethods,required: true),
                  if (_selectedPaymentMethod == cash)
                    ...[
                      _buildTextField(
                        _amountController,
                        amount,
                        Icons.attach_money,
                        focusNode: _amountFocusNode,
                          required:true
                      ),
                      _buildDropdown(currency, _currencies,required: true),
                    ],

                  if (_selectedPaymentMethod == check)
                    ...[
                      _buildTextField(
                        _amountCheckController,
                        amountCheck,
                        Icons.attach_money,
                        focusNode: _amountCheckFocusNode,
                          required:true
                      ),
                      _buildTextField(
                        _checkNumberController,
                        checkNumber,
                        Icons.receipt_long_outlined,
                        focusNode: _checkNumberFocusNode,
                          required:true
                      ),
                      _buildTextField(
                        _bankBranchController,
                        bankBranchCheck,
                        Icons.account_balance_outlined,
                        focusNode: _bankBranchFocusNode,
                          required:true
                      ),
                      _buildTextField(
                        _dueDateCheckController,
                        dueDateCheck,
                        Icons.date_range_outlined,
                        focusNode: _dueDateCheckFocusNode,
                          isDate: true,
                          required:true
                      ),
                    ],
                  _buildTextField(
                    _paymentInvoiceForController,
                    paymentInvoiceFor,
                    Icons.receipt,
                    maxLines: 3,
                    focusNode: _paymentInvoiceForNode,
                  ),
                ],
                checkIfFilled: () {
                  if (_selectedPaymentMethod == cash) {
                    return _amountController.text.isNotEmpty &&
                        _selectedCurrency != null;
                  } else if (_selectedPaymentMethod == check) {
                    return _amountCheckController.text.isNotEmpty &&
                        _checkNumberController.text.isNotEmpty &&
                        _bankBranchController.text.isNotEmpty &&
                        _dueDateCheckController.text.isNotEmpty;
                  }
                  return false;
                },
              ),
              Row(
                children: [
                  Expanded(child: _buildSaveButton()), // Takes full width
                  SizedBox(width: 16.w), // Adjust spacing between buttons
                  Expanded(child: _buildConfirmedButton()), // Takes full width
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpandableSection({
    required String title,
    required IconData iconData,
    required List<Widget> children,
    required bool Function() checkIfFilled,
  }) {
    bool isFilled = checkIfFilled();
    Color iconColor = isFilled ? Color(0xFF4CAF50) : Colors.grey[600]!;
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 5.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: EdgeInsets.all(11.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(iconData, size: 22.sp, color: iconColor),
                SizedBox(width: 10.w),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'NotoSansUI',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...children,
                SizedBox(height: 8.h),
                _buildRequiredFieldsIndicator(checkIfFilled),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequiredFieldsIndicator(bool Function() checkIfFilled) {
    return Row(
      children: [
        Text(
          '* ',
          style: TextStyle(color: Colors.red),
        ),
        Text(
          requiredFields,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12.sp,
          ),
        ),
      ],
    );
  }


  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      setState(() {
        controller.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  Widget _buildTextField(TextEditingController controller, String labelText, IconData icon,
      {int maxLines = 1,
        required FocusNode focusNode,
        bool required = false,
        bool isDate = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 16.w),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        maxLines: maxLines,
        readOnly: isDate, // Make the field read-only if it's a date field
        decoration: InputDecoration(
          labelText: labelText + (required ? ' *' : ''), // Add '*' if required
          labelStyle: TextStyle(
              fontFamily: 'NotoSansUI',
              fontSize: 12.sp,
              color: Colors.grey[500]),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Icon(icon, color: Color(0xFFC62828)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color(0xFFC62828),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          fillColor: Colors.white,
          filled: true,
        ),
        style: TextStyle(fontSize: 14.sp, color: Colors.black),
        onTap: isDate ? () => _selectDate(context, controller) : null,
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, {bool required = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.w),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          labelStyle: TextStyle(
            fontFamily: 'NotoSansUI',
            fontSize: 12.sp,
            color: Colors.grey[500],
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[400]!,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Color(0xFFC62828),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: Colors.grey[300]!,
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: Colors.white,
        ),
        value: label == currency ? _selectedCurrency : _selectedPaymentMethod,
        onChanged: (String? newValue) {
          setState(() {
            if (label == currency) {
              _selectedCurrency = newValue;
            } else {
              _selectedPaymentMethod = newValue;
              _clearPaymentMethodFields(); // Clear fields when payment method changes
            }
          });
        },
        items: items.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.sp,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  bool _validateFields() {
    // Validate customer name
    if (_customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Customer name is required."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate payment method
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Payment method is required."),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }

    // Validate based on selected payment method
    if (_selectedPaymentMethod == cash) {
      // Validate amount for cash payment
      if (_amountController.text.isEmpty || _selectedCurrency == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fieldsMissedMessageError),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
      // Validate amount format (accepts decimal numbers)
      if (double.tryParse(_amountController.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid amount format for cash."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    } else if (_selectedPaymentMethod == check) {
      // Validate fields for check payment
      if (_amountCheckController.text.isEmpty ||
          _checkNumberController.text.isEmpty ||
          _bankBranchController.text.isEmpty ||
          _dueDateCheckController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fieldsMissedMessageError),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Validate amount check format (accepts decimal numbers)
      if (double.tryParse(_amountCheckController.text) == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Invalid amount format for check."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }

      // Validate check number (only numeric characters)
      if (!RegExp(r'^[0-9]*$').hasMatch(_checkNumberController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Check number must contain only numbers."),
            backgroundColor: Colors.red,
          ),
        );
        return false;
      }
    }

    return true;
  }

  Widget _buildConfirmedButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _confirmPayment,
              child: Text(
                confirmPayment,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontFamily: 'NotoSansUI'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
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
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              onPressed: _savePayment,
              child: Text(
                savePayment,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontFamily: 'NotoSansUI'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmPayment() {
    print("_confirmPaymentMethod");
    if (!_validateFields()) return;

    Payment paymentDetails = _preparePaymentObject('Confirmed');
    // Use paymentDetails as needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment confirmed."),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );


      // Navigate to PaymentConfirmationScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentConfirmationScreen(paymentDetails: paymentDetails)),
      );

  }
  void _savePayment() {
    if (!_validateFields()) return;

    Payment paymentDetails = _preparePaymentObject('Saved');
    // Use paymentDetails as needed
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment saved."),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );


      // Navigate to PaymentConfirmationScreen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => PaymentConfirmationScreen(paymentDetails: paymentDetails)),
      );

  }
  Payment _preparePaymentObject(String status) {
    DateTime? parseDueDate;
    if (_selectedPaymentMethod!.toLowerCase() == 'cash' || _selectedPaymentMethod!.toLowerCase() == 'كاش') {
      if ([_customerNameController.text, _amountController.text, _selectedCurrency, _selectedPaymentMethod]
          .any((element) => element == null || element.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fieldsMissedMessageError),
            backgroundColor: Colors.red,
          ),
        );
        return Payment(customerName: '', paymentMethod: '', status: '');
      }
    } else if (_selectedPaymentMethod!.toLowerCase() == 'check' || _selectedPaymentMethod!.toLowerCase() == 'شيك') {
      if ([_customerNameController.text, _selectedPaymentMethod, _amountCheckController.text,
        _checkNumberController.text, _bankBranchController.text, _dueDateCheckController.text]
          .any((element) => element == null || element.isEmpty)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(fieldsMissedMessageError),
            backgroundColor: Colors.red,
          ),
        );
        return Payment(customerName: '', paymentMethod: '', status: '');
      }
      if (_selectedPaymentMethod!.toLowerCase() == 'check' || _selectedPaymentMethod!.toLowerCase() == 'شيك') {
        if (_dueDateCheckController.text.isNotEmpty) {
           parseDueDate = DateFormat('yyyy-MM-dd').parse(_dueDateCheckController.text);
          print("the date before saved to database ${parseDueDate.toString()}");
        }
      }

    }

Payment paymentDetail= Payment(
  customerName: _customerNameController.text,
  msisdn: _msisdnController.text.isNotEmpty?_msisdnController.text: null,
  prNumber: _prNumberController.text!,
  paymentMethod: _selectedPaymentMethod!,
  amount: _selectedPaymentMethod!.toLowerCase() == 'cash' ||_selectedPaymentMethod!.toLowerCase() == 'كاش'? double.tryParse(_amountController.text) : null,
  currency: _selectedPaymentMethod!.toLowerCase() == 'cash' ||_selectedPaymentMethod!.toLowerCase() == 'كاش'? _selectedCurrency: null,
  paymentInvoiceFor: _paymentInvoiceForController.text.length>0?_paymentInvoiceForController.text:null,
  amountCheck: _selectedPaymentMethod!.toLowerCase() == 'check'||_selectedPaymentMethod!.toLowerCase() == 'شيك' ? double.tryParse(_amountCheckController.text) : null,
  checkNumber: _selectedPaymentMethod!.toLowerCase() == 'check' ||_selectedPaymentMethod!.toLowerCase() == 'شيك'?  int.tryParse(_checkNumberController.text) : null,
  bankBranch: _selectedPaymentMethod!.toLowerCase() == 'check' ||_selectedPaymentMethod!.toLowerCase() == 'شيك'? _bankBranchController.text : null,
  dueDateCheck: parseDueDate , // Formatting the date
  status: status,
);
    return paymentDetail;
  }

  void _clearPaymentMethodFields() {
    _amountController.clear();
    _amountCheckController.clear();
    _checkNumberController.clear();
    _bankBranchController.clear();
    _dueDateCheckController.clear();
  }
  void _clearFields() {
    _customerNameController.clear();
    _msisdnController.clear();
    _prNumberController.clear();
    _amountController.clear();
    _paymentInvoiceForController.clear();
    _selectedCurrency = null;
    _selectedPaymentMethod = null;
  }
}
