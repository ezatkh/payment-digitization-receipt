import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserManagementScreen extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  final List<Map<String, dynamic>> _users = List.generate(
    10,
    (index) => {
      "name": "User #$index",
      "role": "Salesperson",
      "avatar": Icons.person_outline,
      "isActive": index % 2 == 0,
    },
  );

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        leading: CircleAvatar(
          radius: 25.r,
          backgroundColor: user['isActive'] ? Colors.green : Colors.grey,
          child: Icon(user['avatar'], size: 24.sp, color: Colors.white),
        ),
        title: Text(user['name'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
        subtitle: Text(user['role'], style: TextStyle(fontSize: 14.sp, color: Colors.grey[700])),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.blue[300]),
              onPressed: () {
                // Edit user logic
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red[300]),
              onPressed: () {
                // Delete user logic
              },
            ),
          ],
        ),
      ),
    );
  }
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 4,
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(4.0),
        child: Container(
          color: Colors.white.withOpacity(0.2),
          height: 1.0,
        ),
      ),
      title: Text('User Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontFamily: 'NotoSansUI',
          )),
      backgroundColor: Color(0xFFC62828),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));

    return Scaffold(
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Search Users',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onChanged: (value) {},
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: ListView.builder(
                itemCount: _users.length,
                itemBuilder: (context, index) => _buildUserCard(_users[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.person_add),
        backgroundColor: Color(0xFFC62828),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
    );
  }
}
