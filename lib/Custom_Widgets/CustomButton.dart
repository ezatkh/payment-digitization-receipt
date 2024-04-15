import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Wrap the ElevatedButton with a Container or SizedBox to limit its width
    return Center(
      child: SizedBox(
        width: 255, // Specify the desired width here
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed, // Disable button if loading
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, backgroundColor: theme.primaryColor,
            padding: const EdgeInsets.symmetric(vertical: 12.0), // Adjust padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20), // Rounded corners
            ),
            elevation: 4, // Elevation for depth
            textStyle: theme.textTheme.button?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          child: isLoading
              ? const SizedBox(
            height: 24, width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white,
            ),
          )
              : Text(text),
        ),
      ),
    );
  }
}
