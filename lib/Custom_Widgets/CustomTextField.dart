import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String hint;
  final IconData icon;
  final bool obscureText;
  final ValueChanged<String> onChanged;

  // Constructor for CustomTextField
  // hint: Placeholder text shown in the TextField
  // icon: Icon displayed inside the TextField
  // obscureText: Whether the text is obscured (useful for passwords)
  // onChanged: Callback for when the text changes
  const CustomTextField({
    required this.hint,
    required this.icon,
    this.obscureText = false,
    required this.onChanged,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(fontSize: 16, color: Colors.black87);
    const hintStyle = TextStyle(color: Colors.black45);
    final borderRadius = BorderRadius.circular(8);

    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        obscureText: obscureText,
        onChanged: onChanged,
        style: textStyle,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: hintStyle,
          prefixIcon: Icon(icon, color: Theme.of(context).primaryColor),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.all(18.0),
          border: OutlineInputBorder(
              borderRadius: borderRadius, borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: borderRadius,
            borderSide: BorderSide(color: Colors.red.shade400, width: 1),
          ),
        ),
      ),
    );
  }
}
