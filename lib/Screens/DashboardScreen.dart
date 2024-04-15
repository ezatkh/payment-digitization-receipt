import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
 class DashboardScreen extends StatelessWidget {
  @override

  Widget build(BuildContext context) {
    // Extracted exact colors from the provided image
    const Color topGradientColor = Color(0xFFe53c38); // Red color at the top of the icon
    const Color appBarTopColor = Color(0xFF04181f); // Red color at the top of the icon
    const Color bottomGradientColor = Color(0xFFC62828); // Darker red color at the bottom of the icon
    const Color backgroundColor = Color(0xFF04181f); // Background color

    return Scaffold(
      backgroundColor: appBarTopColor.withOpacity(0.9),
      appBar: AppBar(
        leading: IconButton(iconSize:44,
          icon: Icon(Icons.menu,color: Color(0xffde6361)  ), // App drawer icon
          onPressed: () {
            // Handle app drawer opening
          },
        ),
        title: Text('Dashboard',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
        backgroundColor: appBarTopColor,
        actions: [
          IconButton(iconSize:44,
            icon: Icon(Icons.logout_outlined,color: Color(0xffde6361)  ,), // Right side icon
            onPressed: () {
              // Handle action
            },
          ),
        ],
      ),
      body: GridView.builder(
        padding: EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
        ),
        itemCount: 6, // Replace with actual number of dashboard items
        itemBuilder: (context, index) {
          // Replace 'Icons.dashboard' and 'Item $index' with actual icons and titles
          return DashboardItem(
            iconData: Icons.dashboard,
            title: 'Item $index',
            topGradientColor: topGradientColor,
            bottomGradientColor: bottomGradientColor,
            onTap: () {
              // Handle item tap
            },
          );
        },
      ),
      bottomNavigationBar: CurvedNavigationBar(
         index: 0,
        height: 55.0,
        items: <Widget>[
          Icon(Icons.add, size: 30),
          Icon(Icons.list, size: 30),
          Icon(Icons.compare_arrows, size: 30),
          Icon(Icons.call_split, size: 30),
          Icon(Icons.perm_identity, size: 30),
        ],
        color: Color(0xFFe63f3d)  ,
        buttonBackgroundColor: Color(0xFFe2b298),
        backgroundColor: appBarTopColor,
        animationCurve: Curves.easeInOut,
        animationDuration: Duration(milliseconds: 600),
        onTap: (index) {

        },
        letIndexChange: (index) => true,
      ),
    );
  }
}

class DashboardItem extends StatelessWidget {
  final IconData iconData;
  final String title;
  final Color topGradientColor;
  final Color bottomGradientColor;
  final VoidCallback onTap;

  const DashboardItem({
    Key? key,
    required this.iconData,
    required this.title,
    required this.topGradientColor,
    required this.bottomGradientColor,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Shadow for a faux 3D effect
    final List<BoxShadow> boxShadow = [
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        offset: Offset(2, 2),
        blurRadius: 6,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: Colors.black.withOpacity(0.2),
        offset: Offset(-2, -2),
        blurRadius: 6,
        spreadRadius: 1,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20), // Rounded corners
        gradient: LinearGradient(
          colors: [topGradientColor, bottomGradientColor],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: boxShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(iconData, size: 40, color: Colors.white),
              SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
