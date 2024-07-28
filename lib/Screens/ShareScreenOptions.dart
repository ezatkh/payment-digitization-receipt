import 'package:flutter/material.dart';
import 'package:flutter_social_content_share/flutter_social_content_share.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ShareScreenOptions extends StatelessWidget {
  const ShareScreenOptions({Key? key}) : super(key: key);

  void _shareEmail() async {
    String? result = await FlutterSocialContentShare.shareOnEmail(
      recipients: ["example@example.com"],
      subject: "Subject appears here",
      body: "Body appears here",
      isHTML: true,
    );
    print(result);
  }

  void _shareWhatsApp() async {
    String? result = await FlutterSocialContentShare.shareOnWhatsapp(
      "0000000",
      "Text appears here",
    );
    print(result);
  }

  void _sharePrinter() {
    // Your printer sharing implementation here
    print('Printer share triggered');
  }

  Widget _buildCustomDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      height: 1.0,
      color: Colors.grey[200], // Custom grey color for the divider
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Share Options',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  _buildCustomDivider(), // Custom divider
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.solidEnvelope),
                    title: Text(
                      'Share via Email',
                      style: TextStyle(fontSize: 14.0), // Reduced font size
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _shareEmail();
                    },
                  ),
                  _buildCustomDivider(), // Custom divider
                  ListTile(
                    leading: FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                    title: Text(
                      'Share via WhatsApp',
                      style: TextStyle(fontSize: 14.0), // Reduced font size
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _shareWhatsApp();
                    },
                  ),
                  _buildCustomDivider(), // Custom divider
                  ListTile(
                    leading: Icon(Icons.print, color: Colors.blue), // Default Flutter icon for Printer
                    title: Text(
                      'Print',
                      style: TextStyle(fontSize: 14.0), // Reduced font size
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _sharePrinter();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
