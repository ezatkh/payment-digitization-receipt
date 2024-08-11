import 'package:flutter/material.dart';
import '../Models/Bank.dart';
import '../Models/Currency.dart';
import 'LOV_Services.dart';
import 'database.dart';


class LOVCompareService {
  // Compare and sync currencies
  static Future<void> compareAndSyncCurrencies() async {
    try {
      // Fetch remote currencies
      List<Currency> remoteCurrencies = await LovApiService.fetchCurrencies();

      // Fetch local currencies
      List<Map<String, dynamic>> localCurrencies = await DatabaseProvider.getAllCurrencies();

      // Convert local currencies to a map for easier comparison
      Map<String, Map<String, dynamic>> localCurrenciesMap = {
        for (var currency in localCurrencies) currency['id']: currency
      };

      // Compare remote currencies with local
      for (var remoteCurrency in remoteCurrencies) {
        final id = remoteCurrency.id;
        final remoteData = remoteCurrency.toMap();

        if (localCurrenciesMap.containsKey(id)) {
          // Update existing local record
          await DatabaseProvider.updateCurrency(id, remoteData);
        } else {
          // Insert new record
          await DatabaseProvider.insertCurrency(remoteData);
        }
      }

      // Delete currencies that are in local but not in remote
      for (var localCurrency in localCurrencies) {
        if (!remoteCurrencies.any((remote) => remote.id == localCurrency['id'])) {
          await DatabaseProvider.deleteCurrency(localCurrency['id']);
        }
      }
    } catch (e) {
      print('Error comparing and syncing currencies: $e');
    }
  }

  // Compare and sync banks
  static Future<void> compareAndSyncBanks() async {
    try {
      // Fetch remote banks
      List<Bank> remoteBanks = await LovApiService.fetchBanks();

      // Fetch local banks
      List<Map<String, dynamic>> localBanks = await DatabaseProvider.getAllBanks();

      // Convert local banks to a map for easier comparison
      Map<String, Map<String, dynamic>> localBanksMap = {
        for (var bank in localBanks) bank['id']: bank
      };

      // Compare remote banks with local
      for (var remoteBank in remoteBanks) {
        final id = remoteBank.id;
        final remoteData = remoteBank.toMap();

        if (localBanksMap.containsKey(id)) {
          // Update existing local record
          await DatabaseProvider.updateBank(id, remoteData);
        } else {
          // Insert new record
          await DatabaseProvider.insertBank(remoteData);
        }
      }

      // Delete banks that are in local but not in remote
      for (var localBank in localBanks) {
        if (!remoteBanks.any((remote) => remote.id == localBank['id'])) {
          await DatabaseProvider.deleteBank(localBank['id']);
        }
      }
    } catch (e) {
      print('Error comparing and syncing banks: $e');
    }
  }
}
