import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'DashboardScreen.dart';
import 'MoreScreen.dart';

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    int _selectedIndex2 = 1;  // Starting index
    void _onItemTapped(int index) {
      setState(() {
        _selectedIndex2 = index;
      });
      if (index == 2) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MoreScreen()),
        );
      }
      else if (index ==1) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>ProfileScreen()  ),
        );
      }
      else if(index==0){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DashboardScreen()),
        );
      }
    }
    ScreenUtil.init(context, designSize: Size(360, 690));

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(leading: Text(' '),
          title: Text(
            'Profile',
            style: TextStyle(color: Colors.white, fontFamily: "NotoSansUI", fontSize: 20.sp),
          ),
          backgroundColor: Color(0xFFA60016),
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[ BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home', // Home
          ),

            // BottomNavigationBarItem(
            //   icon: Icon(Icons.work_outline),
            //   label: 'Services', // Services
            // ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_sharp),
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
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20.h),
              ProfileIcon(
                radius: 60.r, // You can adjust the radius as needed
                imageUrl: 'https://via.placeholder.com/150', // Replace with actual user image URL if available
              ),

              SizedBox(height: 20.h),
              Text(
                'John Doe',
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, fontFamily: "NotoSansUI"),
              ),
              Text(
                'Account Manager',
                style: TextStyle(fontSize: 18.sp, color: Colors.grey[700], fontFamily: "NotoSansUI"),
              ),
              SizedBox(height: 30.h),
              Container(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildProfileCard(
                      child: Column(
                        children: [
                          _buildProfileInfo('Email', 'johndoe@example.com'),
                          _buildProfileInfo('Phone', '+1234567890'),
                          _buildProfileInfo('Region', 'North Territory'),
                        ],
                      ),
                    ),
                    _buildProfileCard(
                      child: Column(
                        children: [
                          _buildProfileInfo('Department', 'Sales'),
                          _buildProfileInfo('Last Login', '2023-04-12 08:30 AM'),
                          _buildProfileInfo('System Role', 'Admin'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard({required Widget child}) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.h),
        child: child,
      ),
    );
  }

  Widget _buildProfileInfo(String title, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: Colors.black54, fontFamily: "NotoSansUI")),
          Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w400, fontFamily: "NotoSansUI")),
        ],
      ),
    );
  }
}

class ProfileIcon extends StatelessWidget {
  final double radius;
  final String imageUrl;

  ProfileIcon({this.radius = 60, this.imageUrl = 'https://via.placeholder.com/150'});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: radius,
      width: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 2), // changes position of shadow
          ),
        ],
        image: DecorationImage(
          fit: BoxFit.cover,
          image: NetworkImage(imageUrl),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.transparent,
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.bottomRight,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.person, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }
}
