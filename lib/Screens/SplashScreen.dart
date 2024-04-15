import 'package:flutter/material.dart';
import 'LoginScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoOpacity;
  late Animation<double> _backgroundLighten;
  late Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 3));

    _logoOpacity = Tween(begin: 0.0, end: 1.0).animate(_controller);
    _backgroundLighten = Tween(begin: 0.2, end: 1.0).animate(_controller);
    _logoScale = Tween(begin: 1.2, end: 1.0).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateToLogin(context);
      }
    });
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.of(context).pushReplacement(_createRoute());
  }

  Route _createRoute() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => LoginScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = 0.0;
        const end = 1.0;
        const curve = Curves.slowMiddle;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var fadeAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(_backgroundLighten.value),
            ),
            child: Center(
              child: Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Image.asset('assets/images/logo_ooredoo.png'), // Replace with your asset path
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
