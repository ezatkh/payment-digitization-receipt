import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  final String? url;
  final Map<String, dynamic>? map;

  NetworkHelper({this.url, this.map});

  Future getData() async {
    http.Response response = await http.post(
      Uri.parse(url!),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(map),
    );
    if (response.statusCode == 200) {
      String data = utf8.decode(response.bodyBytes);
      print(response.body);
      return jsonDecode(data);
    } else {
      print(response.statusCode);
    }
  }

  Future<bool> testConnection() async {
    try {
      http.Response response = await http.get(Uri.parse(url!));
      if (response.statusCode == 200) {
        print('response'+response.toString());
        return true;
      } else {
        print('response'+response.toString());
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}
