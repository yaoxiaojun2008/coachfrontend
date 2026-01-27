import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  static String get apiBaseUrl => dotenv.env['VITE_API_BASE_URL'] ?? dotenv.env['API_BASE_URL'] ?? 'http://127.0.0.1:8000/api';
  static String get supabaseUrl => dotenv.env['VITE_SUPABASE_URL'] ?? dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['VITE_SUPABASE_ANON_KEY'] ?? dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
