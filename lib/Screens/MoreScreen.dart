import 'dart:ui';

import 'package:digital_payment_app/Screens/PaymentCancellationScreen.dart';
import 'package:digital_payment_app/Screens/ProfileScreen.dart';
import 'package:digital_payment_app/Services/LocalizationService.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'DashboardScreen.dart';
import 'LoginScreen.dart';
import 'NotificationsScreen.dart';
import 'PaymentHistoryScreen.dart';


class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(360, 690));

    return ChangeNotifierProvider<LocalizationService>(
      create: (_) {
        var localizationState = LocalizationService();
        localizationState.initLocalization(); // Initialize localization
        return localizationState;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: Text(' '),
          elevation: 4,
          backgroundColor: const Color(0xFFC62828),
          toolbarHeight: 111.h,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(4.0),
            child: Container(
              color: Colors.grey[300], // Color for the bottom border
              height: 1.0,
            ),
          ),
          title: _buildAppBarTitle(context),
          centerTitle: true,
        ),
        body: Consumer<LocalizationService>(
          builder: (context, localizationService, child) {
            return _buildMenuList(context, localizationService);
          },
        ),

        bottomNavigationBar: _buildBottomNavigationBar(context), // i want to add parameter
      ),
    );
  }

  Widget _buildAppBarTitle(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: const Color(0xFFf4f4f4),
          child: Icon(Icons.person_outline_sharp, color: const Color(0xFFC62828), size: 40.sp),
          radius: 27.sp,
        ),
        Text(
          'Username',
          style: TextStyle(
            fontSize: 26.sp,
            letterSpacing: 1,
            fontFamily: "NotoSansUI",
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6.h),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfileScreen()),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.arrow_back_ios_sharp, color: Colors.white, size: 16.sp),
              SizedBox(width: 8.w),
              Text(
                'My Profile',
                style: TextStyle(
                  fontSize: 13.sp,
                  letterSpacing: 0.5,
                  fontFamily: "NotoSansUI",
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuList(BuildContext context,LocalizationService localizationService) {
    final labelsLocalization= [
      localizationService.getLocalizedString('notifications'),
      localizationService.getLocalizedString('paymentHistory'),
      localizationService.getLocalizedString('paymentCancellation'),
      localizationService.getLocalizedString('aboutus'),
      localizationService.getLocalizedString('logout'),
    ];
    final labelsItems= ['notifications','paymentHistory','paymentCancellation','aboutus','logout'];
    return ListView.separated(
      padding: EdgeInsets.all(14.w),
      itemCount: labelsLocalization.length,
      separatorBuilder: (context, index) => Divider(color: Colors.grey.shade300, height: 20.h),
      itemBuilder: (context, index) => _buildMenuItem(context,labelsItems[index], labelsLocalization[index]),
    );
  }

  Widget _buildMenuItem(BuildContext context,String labelTitle ,String label) {
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade500,
          fontFamily: "NotoSansUI",
        ),
      ),
      onTap: () => _handleTap(context,labelTitle ,label),
    );
  }

  void _handleTap(BuildContext context,String labelTitle, String label) {
    print("tap detail: $label");
    switch (labelTitle) {
      case 'paymentHistory':
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaymentHistoryScreen()));
        break;
      case 'notifications':
        _navigateTo(context, NotificationsScreen()); // Fixed to pass context
        break;
      case 'logout':
        _showLogoutDialog(context);
        break;
      case 'aboutus':
        _showAboutDialog(context);
        break;
        case 'paymentCancellation':
          _navigateTo(context, PaymentCancellationScreen()); // Fixed to pass context
        break;
    }
  }
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: contentBox(context),
        );
      },
    );
  }
  Widget contentBox(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(left: 20.w, top: 45.h, right: 20.w, bottom: 20.h),
          margin: EdgeInsets.only(top: 45.h),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                'About Payment Receipt Digitization',
                style: TextStyle(fontSize: 22.sp,fontFamily: 'NotoSansUI',fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              Text(
                'Transitioning from physical voucher receipt books, this application brings the ease '
                    'of recording and managing payments through a mobile interface. Alongside printing '
                    'capabilities and advanced security measures, the app offers a seamless transition to '
                    'digital processes, ensuring high performance and reliability for sales account managers.',
                style: TextStyle(fontSize: 14.sp ,fontFamily: 'NotoSansUI',),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 22.h),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'OK',
                    style: TextStyle( fontFamily: 'NotoSansUI',fontSize: 18.sp, color: Color(0xFFC62828)),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 20.w,
          right: 20.w,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: 45.h,
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(45.h)),
              child: Image.asset( 'assets/images/Init Logo.png',), // Replace with your app's logo or suitable graphic
            ),
          ),
        ),
      ],
    );
  }
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false,
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: _buildLogoutDialogContent(dialogContext),
          ),
        );
      },
    );
  }
  Widget _buildLogoutDialogContent(BuildContext context ,) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.0),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.44),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.0,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontFamily: "NotoSansUI",
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Ooredoo theme color
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildDialogButton(
                    context: context,
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(), // Close the dialog
                    backgroundColor: Colors.grey.shade300,
                    textColor: Colors.black,
                  ),
                  _buildDialogButton(
                    context: context,
                    label: 'Logout',
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    backgroundColor: Color(0xFFC62828), // Ooredoo theme color
                    textColor: Colors.white,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildDialogButton({
    required BuildContext context,
    required String label,
    required VoidCallback onPressed,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: TextStyle(fontFamily: "NotoSansUI", color: textColor)),
    );
  }
  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
        // BottomNavigationBarItem(icon: Icon(Icons.work_outline), label: 'Services'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline_sharp), label: 'My Account'),
        BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'More'),
      ],
      currentIndex: 2,
      selectedItemColor: const Color(0xFFC62828),
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DashboardScreen()));
        }
        else if (index == 1) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
        }
      },
    );
  }


}
