import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_sync_service.dart';

class StorageService {
  static const String _checkinKey = 'checkins';
  static const String _checkoutKey = 'checkouts';

  static Future<void> saveCheckin({
    required double latitude,
    required double longitude,
    required String qrCodeData,
    required String previousTopic,
    required String expectedTopic,
    required int mood,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_checkinKey) ?? [];
    final data = {
      'studentId': 'student_001',
      'timestamp': DateTime.now().toIso8601String(),
      'gpsLatitude': latitude,
      'gpsLongitude': longitude,
      'qrCodeData': qrCodeData,
      'previousTopic': previousTopic,
      'expectedTopic': expectedTopic,
      'mood': mood,
    };
    existing.add(jsonEncode(data));
    await prefs.setStringList(_checkinKey, existing);
    await FirebaseSyncService.uploadCheckin(data);
  }

  static Future<void> saveCheckout({
    required double latitude,
    required double longitude,
    required String qrCodeData,
    required String learnedToday,
    required String feedback,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getStringList(_checkoutKey) ?? [];
    final data = {
      'studentId': 'student_001',
      'timestamp': DateTime.now().toIso8601String(),
      'gpsLatitude': latitude,
      'gpsLongitude': longitude,
      'qrCodeData': qrCodeData,
      'learnedToday': learnedToday,
      'feedback': feedback,
    };
    existing.add(jsonEncode(data));
    await prefs.setStringList(_checkoutKey, existing);
    await FirebaseSyncService.uploadCheckout(data);
  }

  static Future<List<Map<String, dynamic>>> getCheckins() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_checkinKey) ?? [];
    return raw
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }

  static Future<List<Map<String, dynamic>>> getCheckouts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_checkoutKey) ?? [];
    return raw
        .map((item) => jsonDecode(item) as Map<String, dynamic>)
        .toList()
        .reversed
        .toList();
  }

  static Future<Map<String, int>> getDashboardStats() async {
    final prefs = await SharedPreferences.getInstance();
    final checkins = (prefs.getStringList(_checkinKey) ?? []).length;
    final checkouts = (prefs.getStringList(_checkoutKey) ?? []).length;

    return {
      'checkins': checkins,
      'checkouts': checkouts,
      'totalActivities': checkins + checkouts,
    };
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_checkinKey);
    await prefs.remove(_checkoutKey);
  }
}
