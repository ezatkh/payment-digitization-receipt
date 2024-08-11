import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  final String? url;
  final Map<String, dynamic>? map;
  final Map<String, String>? headers;
  final String method;

  NetworkHelper({
    this.url,
    this.map,
    this.headers,
    this.method = 'POST', // Default method is POST
  });

  Future<dynamic> getData() async {
    print("api :${url}:${map}:${headers}");

    try {
      http.Response response;
      if (method == 'POST') {
        response = await http.post(
          Uri.parse(url!),
          headers: headers ?? {
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: map != null ? jsonEncode(map) : null,
        );
      } else if (method == 'GET') {
        response = await http.get(
          Uri.parse(url!),
          headers: headers ?? {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        );
      } else {
        throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode == 200) {
        print("status iss 200");
        return jsonDecode(response.body);
      } else {
        print("status is: ${response.statusCode}");
        print("Response body: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error during HTTP request: $e");
      return null;
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