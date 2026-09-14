import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Centralized Supabase access point. Never call Supabase.instance directly
/// from screens/repositories — always go through this service.
class SupabaseService {
  SupabaseService._();

  static Future<void> initialize() async {
    final url = dotenv.env['SUPABASE_URL'];
    final anonKey = dotenv.env['SUPABASE_ANON_KEY'];

    if (url == null || url.isEmpty || anonKey == null || anonKey.isEmpty) {
      throw Exception(
        'Supabase configuration missing. Check your .env file has '
        'SUPABASE_URL and SUPABASE_ANON_KEY set.',
      );
    }

    await Supabase.initialize(
      url: url,
      publishableKey: anonKey,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  static User? get currentUser => auth.currentUser;

  static bool get isLoggedIn => currentUser != null;
}