import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static const String appName = 'CampFix';
  static const String appTagline = 'Report. Assign. Fix. Track.';
  static const String appVersion = '1.0.0';

  static String get apiBaseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api'; // Android emulator -> host machine
    return 'http://localhost:5000/api'; // Linux/macOS/Windows desktop, iOS simulator
  }
}