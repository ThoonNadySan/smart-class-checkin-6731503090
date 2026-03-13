import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import '../firebase_options.dart';

class FirebaseSyncService {
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> initialize() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
    } catch (error) {
      _initialized = false;
      log(
        'Firebase initialization skipped: $error',
        name: 'FirebaseSyncService',
      );
    }
  }

  static Future<void> uploadCheckin(Map<String, dynamic> payload) async {
    if (!_initialized) return;
    try {
      await FirebaseFirestore.instance.collection('checkins').add(payload);
    } catch (error) {
      log(
        'Failed to sync check-in: $error',
        name: 'FirebaseSyncService',
      );
    }
  }

  static Future<void> uploadCheckout(Map<String, dynamic> payload) async {
    if (!_initialized) return;
    try {
      await FirebaseFirestore.instance.collection('checkouts').add(payload);
    } catch (error) {
      log(
        'Failed to sync checkout: $error',
        name: 'FirebaseSyncService',
      );
    }
  }
}
