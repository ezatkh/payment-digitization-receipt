import 'package:flutter/cupertino.dart';

class LogoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Assuming that you want a larger logo, the width is set to a greater value.
    // The aspect ratio of the logo will be preserved.
    double logoWidth = MediaQuery.of(context).size.width * 0.5; // 50% of screen width
    double logoHeight = MediaQuery.of(context).size.height * 0.5; // 50% of screen width

    return Center(
      child: Image.asset(
        'assets/images/Init Logo.png',

        height: logoHeight,
        // If you have specified your image in different sizes in the assets folder,
        // the best fitting size will be used.
      ),
    );
  }
}