import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Models/Bank.dart';
import '../Models/Currency.dart';
import '../Services/Networking.dart';

class LovApiService {
  static const String baseUrl = 'http://localhost:10005/ApplicationUtils/getLOVList?listname=';

  // Generic method to fetch lists from the backend
  static Future<List<T>> fetchList<T>(String listName, Function fromMap) async {
    final String url = '$baseUrl$listName';
    final NetworkHelper networkHelper = NetworkHelper(url: url);
    final response = await networkHelper.getData();

    if (response != null) {
      List<dynamic> listJson = response['data'];
      return listJson.map((json) => fromMap(json)).toList().cast<T>();
    } else {
      throw Exception('Failed to load $listName');
    }
  }

  // Fetch all currencies from the backend
  static Future<List<Currency>> fetchCurrencies() async {
    return fetchList<Currency>('CURRENCY', (json) => Currency.fromMap(json));
  }

  // Fetch all banks from the backend
  static Future<List<Bank>> fetchBanks() async {
    return fetchList<Bank>('BANK', (json) => Bank.fromMap(json));
  }
}
