import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    Widget _buildSettingSection(String title, List<Widget> options) {
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
              child: Text(title, style: TextStyle(fontFamily: "NotoSansUI", fontSize: 16.sp, fontWeight: FontWeight.bold)),
            ),
            ...options,
          ],
        ),
      );
    }
    Widget _buildSettingOption(IconData icon, String title, {VoidCallback? onTap}) {
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
                  Text(title, style: TextStyle(fontFamily: "NotoSansUI", fontSize: 16.sp)),
                ],
              ),
              Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
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
              _buildSettingOption(Icons.language, 'Language & Region', onTap: () {
                // TODO: Handle Language & Region setting
              }),
              _buildSettingOption(Icons.palette, 'Theme', onTap: () {
                // TODO: Handle Theme
              }),
            ]),
            _buildSettingSection('Account', [
              _buildSettingOption(Icons.lock_outline, 'Security', onTap: () {
                // TODO: Handle Security
              }),
              _buildSettingOption(Icons.archive_outlined, 'Data & Storage', onTap: () {
                // TODO: Handle Data & Storage
              }),
              _buildSettingOption(Icons.logout, 'Logout', onTap: () {
                // TODO: Handle Logout
              }),
            ]),
            _buildSettingSection('Notifications', [
              _buildSettingOption(Icons.notifications_active, 'Notification Settings', onTap: () {
                // TODO: Handle Notifications
              }),
            ]),
            _buildSettingSection('Other', [
              _buildSettingOption(Icons.print, 'Printer Settings', onTap: () {
                // TODO: Handle Printer Settings
              }),
              _buildSettingOption(Icons.info_outline, 'About & Help', onTap: () {
                // TODO: Handle About & Help
              }),
            ]),
          ],
        ),
      ),
    );
  }
}
