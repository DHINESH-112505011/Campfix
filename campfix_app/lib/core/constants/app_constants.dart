import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppConstants {
  AppConstants._();

  static const String appName = 'CampFix';
  static const String appTagline = 'Report. Assign. Fix. Track.';
  static const String appVersion = '1.0.0';

  // Points to the live Render deployment. Set to false to test against
  // your local backend (npm run dev) during development instead.
  static const bool _useProductionApi = true;
  static const String _productionApiUrl = 'https://campfix-backend.onrender.com/api';

  static String get apiBaseUrl {
    if (_useProductionApi) return _productionApiUrl;
    if (kIsWeb) return 'http://localhost:5000/api';
    if (Platform.isAndroid) return 'http://10.0.2.2:5000/api';
    return 'http://localhost:5000/api';
  }
}