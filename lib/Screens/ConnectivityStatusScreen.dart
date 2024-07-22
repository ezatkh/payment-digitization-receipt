import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart'; // Add intl package for date formatting
import '../Services/LocalizationService.dart';
import 'package:provider/provider.dart';
class ConnectivityStatusScreen extends StatefulWidget {
  @override
  _ConnectivityStatusScreenState createState() => _ConnectivityStatusScreenState();
}

class _ConnectivityStatusScreenState extends State<ConnectivityStatusScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconScale;
  String _connectivityStatus = "Checking connectivity...";
  String _syncStatus = "Syncing data...";
  String _lastSyncTime = "Not synced yet";
  String _retry ="Retry";
  String _titleScreen="Connectivity & Sync Status";
  Future<void> _initializeLocalization() async {
    print("initLocalization inside Connectivity Status Screen function");
    await Provider.of<LocalizationService>(context, listen: false).initLocalization();
    setState(() {
      // Update state with localized strings after initialization
      _connectivityStatus = Provider.of<LocalizationService>(context, listen: false).getLocalizedString('checkingConnectivity');
      _syncStatus = Provider.of<LocalizationService>(context, listen: false).getLocalizedString('syncingData');
      _lastSyncTime = Provider.of<LocalizationService>(context, listen: false).getLocalizedString('notSyncedYet');
      _retry=Provider.of<LocalizationService>(context, listen: false).getLocalizedString('retry');
      _titleScreen=Provider.of<LocalizationService>(context, listen: false).getLocalizedString('connectivitySyncStatus');
    });
  }
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
    );
    _initializeLocalization();
    _iconScale = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticInOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _connectivityStatus = Provider.of<LocalizationService>(context, listen: false).getLocalizedString('connected');
          _syncStatus = Provider.of<LocalizationService>(context, listen: false).getLocalizedString('dataSync');
          _lastSyncTime = Provider.of<LocalizationService>(context, listen: false).getLocalizedString('lastSync') +" "+ DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());
        });
        _controller.reverse();
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _connectivityStatus = Provider.of<LocalizationService>(context, listen: false).getLocalizedString('disconnected');
          _syncStatus = Provider.of<LocalizationService>(context, listen: false).getLocalizedString('syncFailed');
        });
        _controller.forward();
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
//Provider.of<LocalizationService>(context, listen: false).getLocalizedString('')

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: Size(360, 690));
    return Scaffold(
      appBar: _buildAppBar(),
      body: Container(
        width: double.infinity,
        height: ScreenUtil().screenHeight,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE30613), Color(0xFFA60016)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [ Spacer(),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _iconScale.value,
                child: Icon(Icons.wifi, size: 100.sp, color: Colors.white),
              ),
            ),
            Text(
              _connectivityStatus,
              style: TextStyle(fontSize: 18.sp, color: Colors.white,fontFamily: "NotoSansUI",),
            ),
            SizedBox(height: 44.h),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Transform.scale(
                scale: _iconScale.value,
                child: Icon(Icons.sync, size: 80.sp, color: Colors.white),
              ),
            ),  SizedBox(height: 11.h),
            Text(
              _syncStatus,
              style: TextStyle( fontFamily: "NotoSansUI",fontSize: 16.sp, color: Colors.white),
            ),
            SizedBox(height: 20.h),
            Text(
              _lastSyncTime,
              style: TextStyle( fontFamily: "NotoSansUI",fontSize: 14.sp, fontStyle: FontStyle.italic, color: Colors.white70),
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () {
              },
              style: ElevatedButton.styleFrom(foregroundColor: Color(0xFFA60016), backgroundColor: Colors.white),
              child: Text(_retry,style: TextStyle(fontFamily: "NotoSansUI",),),
            ),
            SizedBox(height: 20.h),
            // Additional status info or actions can be added here
          ],
        ),
      ),
    );
  }
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 4,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE30613), Color(0xFFA60016)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      ),

      title: Text(_titleScreen,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontFamily: 'NotoSansUI',
          )),
      backgroundColor: Colors.transparent, // Important to set it to transparent
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white), // Ensure the icon is visible
        onPressed: () => Navigator.pop(context),
      ),
    );
  }


}
