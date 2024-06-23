import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../Services/LocalizationService.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  String notifications = "";
  String noNotificationsYet = "";
  String checkBackHereForUpdates = "";
  @override
  void initState() {
    super.initState();
    final localizationService = Provider.of<LocalizationService>(
        context, listen: false);
    notifications = localizationService.getLocalizedString('notifications');
    noNotificationsYet = localizationService.getLocalizedString('noNotificationsYet');
    checkBackHereForUpdates = localizationService.getLocalizedString('checkBackHereForUpdates');
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    return Scaffold(
      appBar: AppBar(  bottom: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: Container(
          color: Colors.grey[300], // Color for the bottom border
          height: 1.0,
        ),
      ),
        backgroundColor: Colors.white, // Set to white or any appropriate color from the image.
        elevation: 0, // Adds subtle shadow for depth; adjust as needed.
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey), // Icon color is black or similar to the image.
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          notifications, // Replace with your actual title text if necessary.
          style: TextStyle(fontWeight: FontWeight.bold,
            color: Colors.black, // Title color is black or similar to the image.
            fontSize: 20.sp,
            fontFamily: 'NotoSansUI',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey), // If there's a menu icon in the image.
            onPressed: () {
              // Add menu open logic here if necessary
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 100.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 20.h),
            Text(
              noNotificationsYet,
              style: TextStyle(
                fontSize: 20.sp,fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
                fontFamily: 'NotoSansUI',
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              checkBackHereForUpdates,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey.shade600,
                fontFamily: 'NotoSansUI',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
