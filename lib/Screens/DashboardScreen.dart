import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

 import 'LoginScreen.dart';
import 'MoreScreen.dart';
import 'NotificationsScreen.dart';
import 'PaymentHistoryScreen.dart';
import 'PrintReceiptScreen.dart';
import 'RecordPaymentScreen.dart';

class DashboardScreen extends StatefulWidget {
  DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex2 = 0;  // Starting index
  List<DashboardItemModel> dashboardItems = []; // Initialize as empty list

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex2 = index;
    });
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MoreScreen()),
      );
    }
    else if(index==0){
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => DashboardScreen()),
      );
    }
  }
  void _navigateTo(Widget screen) {
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
  // Define a list of dashboard items with icons and titles
  @override
  void initState() {
    super.initState();
    dashboardItems = [
      DashboardItemModel(iconData: Icons.payment, title: 'Record Payment', onTap: () => _navigateTo(RecordPaymentScreen())),
      DashboardItemModel(iconData: Icons.history, title: 'Payment History', onTap: () => _navigateTo(PaymentHistoryScreen())),
      DashboardItemModel(iconData: Icons.print, title: 'Print Receipt', onTap: () => _navigateTo(PrintReceiptScreen())),
      DashboardItemModel(iconData: Icons.search, title: 'Quick Search', onTap: () {}), // Assuming SearchScreen exists

      DashboardItemModel(iconData: Icons.bar_chart, title: 'Reports', onTap: () {}),
      DashboardItemModel(iconData: Icons.people, title: 'User Management', onTap: () {}),
      DashboardItemModel(iconData: Icons.help_outline, title: 'Support', onTap: () {}),

      DashboardItemModel(iconData: Icons.signal_cellular_alt, title: 'Connectivity Status', onTap: () {} ), // Assuming a method to show status
      DashboardItemModel(iconData: Icons.settings, title: 'Settings', onTap: () {}),
    ];
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,  elevation:0, // Removes the shadow under the AppBar
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(4.0),
            child: Container(
              color: Colors.grey[300], // Color for the bottom border
              height: 1.0,
            ),
          ),
          leading: IconButton(
            iconSize: 34,
            icon: Icon(
              Icons.logout_outlined,
              color: Color(0xffd21816),
            ),
            onPressed: () {
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
            },
          ),

          title: Image.asset(
            'assets/images/logo_ooredoo.png', // Replace with your asset's path
            fit: BoxFit.contain,
            height: AppBar().preferredSize.height*2, // Ensures the logo is contained within the AppBar height
          ),
          // backgroundColor: appBarTopColor,
          centerTitle: true,  actions: [
          IconButton(
            iconSize: 34,
            icon: Icon(
              Icons.notifications_none_outlined,
              color: Color(0xffd21816),
            ), // Right side icon
            onPressed: () {
              _navigateTo(NotificationsScreen());
            },
          ),
        ],
        ),
        body: GridView.builder(
          padding: EdgeInsets.all(10.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 6.w, // Reduced spacing
            mainAxisSpacing: 6.h, // Reduced spacing
            childAspectRatio: 1/1.5 , // Adjust aspect ratio to fit the design
          ),
          itemCount: dashboardItems.length,
          itemBuilder: (context, index) {
            return DashboardItem(
              iconData: dashboardItems[index].iconData,
              title: dashboardItems[index].title,
              onTap: () {
                if (dashboardItems[index].title == 'Record Payment') {
                  _navigateTo(RecordPaymentScreen());
                } else if (dashboardItems[index].title == 'Payment History') {
                  _navigateTo(PaymentHistoryScreen());
                }
                else if (dashboardItems[index].title == 'Print Receipt') {
                  _navigateTo(PrintReceiptScreen());
                }
              },

            );
          },
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[ BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Home
          ),

            BottomNavigationBarItem(
              icon: Icon(Icons.work_outline),
              label: 'Services', // Services
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart),
              label: 'My Account', // My Account
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu),
              label: 'More', // More
            ),
          ],
          currentIndex: _selectedIndex2,
          selectedItemColor: Color(0xFFC62828),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          onTap: _onItemTapped,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          backgroundColor: Colors.white,
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: _buildLogoutDialogContent(context),
        );
      },
    );
  }

  Widget _buildLogoutDialogContent(BuildContext context) {
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





class DashboardItemModel {
  final IconData iconData;
  final String title;

  DashboardItemModel({required this.iconData, required this.title, required void Function() onTap});
}

class DashboardItem extends StatefulWidget {
  final IconData iconData;
  final String title;
  final VoidCallback onTap;

  const DashboardItem({
    Key? key,
    required this.iconData,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  _DashboardItemState createState() => _DashboardItemState();
}

class _DashboardItemState extends State<DashboardItem> {
  bool isTapped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => isTapped = true),
      onTapCancel: () => setState(() => isTapped = false),
      onTapUp: (_) => setState(() => isTapped = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isTapped ? Color(0xFFC62828) : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              offset: Offset(0, 3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(8.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(widget.iconData, size: 40.sp, color: isTapped ? Colors.white : Color(0xFFC62828)),
              SizedBox(height: 4.h),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  overflow: TextOverflow.clip ,
                  fontFamily: 'NotoSansUI',
                  color: isTapped ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  }
