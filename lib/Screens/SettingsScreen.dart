import 'dart:ui';

import 'package:digital_payment_app/Screens/LanguageSettingsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import '../Services/LocalizationService.dart';
import 'DashboardScreen.dart';
import 'LoginScreen.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    Widget _buildSettingSection(String title, List<Widget> options, LocalizationService localizationService) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 16.h),
        padding: EdgeInsets.all(12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              spreadRadius: 0,
              blurRadius: 6,
              offset: Offset(0, 2), // subtle shadow for depth
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              child: Text(
                localizationService.getLocalizedString(title.toLowerCase()),
                style: TextStyle(fontFamily: "NotoSansUI", fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
            ),
            ...options,
          ],
        ),
      );
    }

    Widget _buildSettingOption(IconData icon, String title, {VoidCallback? onTap, LocalizationService? localizationService}) {
      return InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: Color(0xFFC62828), size: 24.sp),
                  SizedBox(width: 20.w),
                  Text(
                    localizationService!.getLocalizedString(title),
                    style: TextStyle(fontFamily: "NotoSansUI", fontSize: 16.sp),
                  ),
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    return ChangeNotifierProvider<LocalizationService>(
      create: (_) {
        var localizationState = LocalizationService();
        localizationState.initLocalization(); // Initialize localization
        return localizationState;
      },
      child: Consumer<LocalizationService>(
        builder: (context, localizationService, child) {
          return Directionality(
            textDirection: localizationService.selectedLanguageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              appBar: AppBar(
                title: Text(
                  localizationService.getLocalizedString('settings'),
                  style: TextStyle(fontFamily: "NotoSansUI", fontSize: 18.sp, color: Colors.white),
                ),
                backgroundColor: Color(0xFFA60016),
                elevation: 0,
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildSettingSection('Preferences', [
                      _buildSettingOption(Icons.language, 'languageSettings', onTap: () {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            transitionDuration: Duration(milliseconds: 500), // Adjust as necessary
                            pageBuilder: (context, animation, secondaryAnimation) {
                              return SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(1.0, 0.0), // From right to left
                                  end: Offset.zero,
                                ).animate(animation),
                                child: LanguageSettingsScreen(),
                              );
                            },
                          ),
                        );
                     //   _handleChangeLanguage(context,localizationService);
                      }, localizationService: localizationService),
                      _buildSettingOption(Icons.palette, 'theme', onTap: () {
                        // TODO: Handle Theme
                      }, localizationService: localizationService),
                    ], localizationService),
                    _buildSettingSection('Account', [
                      _buildSettingOption(Icons.lock_outline, 'security', onTap: () {
                        // TODO: Handle Security
                      }, localizationService: localizationService),
                      _buildSettingOption(Icons.archive_outlined, 'dataStorage', onTap: () {
                        // TODO: Handle Data & Storage
                      }, localizationService: localizationService),
                      _buildSettingOption(Icons.logout, 'logout', onTap: () {
                        _showLogoutDialog(context);
                      }, localizationService: localizationService),
                    ], localizationService),
                    _buildSettingSection('Notifications', [
                      _buildSettingOption(Icons.notifications_active, 'notificationSettings', onTap: () {
                        // TODO: Handle Notifications
                      }, localizationService: localizationService),
                    ], localizationService),
                    _buildSettingSection('Other', [
                      _buildSettingOption(Icons.print, 'printerSettings', onTap: () {
                        // TODO: Handle Printer Settings
                      }, localizationService: localizationService),
                      _buildSettingOption(Icons.info_outline, 'aboutHelp', onTap: () {
                        // TODO: Handle About & Help
                      }, localizationService: localizationService),
                    ], localizationService),
                  ],
                ),
              ),
            ),
          );
        },
      ),
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
}



// void _handleChangeLanguage(
//     BuildContext context, LocalizationService localizationService) async {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext dialogContext) {
//       return Dialog(
//         backgroundColor: Colors.transparent,
//         child: _buildProgressDialog(localizationService),
//       );
//     },
//   );
//
//   await Future.delayed(const Duration(seconds: 2));
//   Navigator.of(context).pop(); // Dismiss the progress indicator dialog
//
//   // Toggle language
//   if (localizationService.selectedLanguageCode == 'en') {
//     localizationService.selectedLanguageCode = 'ar';
//   } else {
//     localizationService.selectedLanguageCode = 'en';
//   }
//
//   // Example navigation after language change with animation
//   Navigator.pushReplacement(
//     context,
//     PageRouteBuilder(
//       pageBuilder: (context, animation, secondaryAnimation) =>
//           FadeTransition(
//             opacity: animation,
//             child: DashboardScreen(),
//           ),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         return FadeTransition(
//           opacity: animation,
//           child: child,
//         );
//       },
//       transitionDuration: Duration(milliseconds: 1500),
//     ),
//   );
// }

// Widget _buildProgressDialog(LocalizationService localizationService) {
//   return Dialog(
//     backgroundColor: Colors.transparent,
//     child: Stack(
//       alignment: Alignment.center,
//       children: [
//         BackdropFilter(
//           filter: ImageFilter.blur(sigmaX: 7, sigmaY:7),
//           child: Container(
//             width: double.infinity,
//             height: double.infinity,
//           ),
//         ),
//         Container(
//           padding: EdgeInsets.all(20.w),
//           decoration: BoxDecoration(
//             color: Colors.transparent,
//             borderRadius: BorderRadius.circular(10.r),
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               SpinKitFadingCircle(
//                 itemBuilder: (BuildContext context, int index) {
//                   return DecoratedBox(
//                     decoration: BoxDecoration(
//                       shape: BoxShape.circle,
//                       color: index.isEven ? Colors.white : Colors.grey[300],
//                     ),
//                   );
//                 },
//               ),
//               SizedBox(height: 10.h),
//               Text(
//                 localizationService.getLocalizedString('pleaseWait'),
//                 style: TextStyle(
//                   decoration: TextDecoration.none,
//                   color: Colors.white.withOpacity(0.8), // Slightly brighter text
//                   fontFamily: 'NotoSansUI',
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
// }
