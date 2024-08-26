import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'dart:io';

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

  Future<dynamic> uploadFile({
    required File file,
    required String fileName,
    required String emailDetailsJson,
  }) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(url!));

      // Add headers
      request.headers.addAll(headers ?? {
        'Content-Type': 'multipart/form-data',
      });

      // Add email details
      request.fields['emailDetails'] = emailDetailsJson;

      // Add file
      var fileStream = http.ByteStream(file.openRead());
      var length = await file.length();
      var multipartFile = http.MultipartFile(
        'files',
        fileStream,
        length,
        filename: '${fileName}.pdf',
        contentType: MediaType('application', 'pdf'),
      );
      request.files.add(multipartFile);

      // Send request
      var response = await request.send();

      // Get response body
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        print('File uploaded successfully.');
        return response.statusCode;
      } else {
        try {
          final decodedResponse = jsonDecode(responseBody);

          // Access individual fields
          String errorMessage = decodedResponse['error'];
          String errorDetail = decodedResponse['errorInDetail'];
          // print('Error: $errorMessage');
          // print('Error Detail: $errorDetail');

          // Check if the token is expired
          if (errorMessage == 'Unauthorized' && errorDetail == 'JWT Authentication Failed') {
            return 401;
          }
        } catch (e) {
          print('Failed to decode JSON: $e');
        }
        return null;
      }
    } catch (e) {
      print('Error during HTTP request: $e');
      return null;
    }
  }

}