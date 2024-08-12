import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../Models/Bank.dart';
import '../Models/Currency.dart';
import '../Services/networking.dart';

class LovApiService {
  static const String baseUrl = 'http://192.168.20.65:8080/ApplicationUtils/getLOVList?listname=';

  // Generic method to fetch lists from the backend
  static Future<List<T>> fetchList<T>(String listName, Function fromMap) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? tokenID = prefs.getString('token');
    String fullToken = "Barer ${tokenID}";

    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'tokenID': fullToken, // Adjust the key if necessary
    };

    final String url = '$baseUrl$listName';
    final NetworkHelper networkHelper = NetworkHelper(url: url, headers: headers,method:'GET');
    final response = await networkHelper.getData();

    if (response != null) {
    } else {
      throw Exception('Failed to load $listName');
    }
    return response.map((json) => fromMap(json)).toList().cast<T>();
  }

  // Fetch all currencies from the backend
  static Future<List<Currency>> fetchCurrencies() async {
    return fetchList<Currency>('CURRENCY', (json) => Currency.fromMapArabic(json));
  }

  // Fetch all banks from the backend
  static Future<List<Bank>> fetchBanks() async {
    return fetchList<Bank>('BANKS', (json) => Bank.fromMapArabic(json));
  }
}
