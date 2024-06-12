import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../Services/LocalizationService.dart';

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
                      _buildSettingOption(Icons.language, 'languageRegion', onTap: () {
                        // TODO: Handle Language & Region setting
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
                        // TODO: Handle Logout
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
}
