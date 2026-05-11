import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OfflineQueueService {
  static const _transactionsKey = 'pending_transactions';
  static const _collectionsKey = 'pending_collections';

  static final OfflineQueueService _instance = OfflineQueueService._internal();
  factory OfflineQueueService() => _instance;
  OfflineQueueService._internal();

  Future<int> get pendingCount async {
    final prefs = await SharedPreferences.getInstance();
    final tx = prefs.getStringList(_transactionsKey) ?? [];
    final col = prefs.getStringList(_collectionsKey) ?? [];
    return tx.length + col.length;
  }

  Future<List<Map<String, dynamic>>> get pendingTransactions async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_transactionsKey) ?? [];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> get pendingCollections async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_collectionsKey) ?? [];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  Future<void> enqueueTransaction(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_transactionsKey) ?? [];
    list.add(jsonEncode(payload));
    await prefs.setStringList(_transactionsKey, list);
  }

  Future<void> enqueueCollection(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_collectionsKey) ?? [];
    list.add(jsonEncode(payload));
    await prefs.setStringList(_collectionsKey, list);
  }

  Future<void> dequeueTransaction(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_transactionsKey) ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList(_transactionsKey, list);
    }
  }

  Future<void> dequeueCollection(int index) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_collectionsKey) ?? [];
    if (index >= 0 && index < list.length) {
      list.removeAt(index);
      await prefs.setStringList(_collectionsKey, list);
    }
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
    await prefs.remove(_collectionsKey);
  }

  Future<void> clearTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_transactionsKey);
  }

  Future<void> clearCollections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_collectionsKey);
  }
}
