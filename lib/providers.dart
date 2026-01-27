import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/api_service.dart';
import 'services/ai_service.dart';
import 'services/auth_service.dart';
import 'services/essay_service.dart';
import 'models/user_model.dart';

final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService(ref.watch(supabaseClientProvider));
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService(ref.watch(apiServiceProvider));
});

final essayServiceProvider = Provider<EssayService>((ref) {
  return EssayService(ref.watch(supabaseClientProvider));
});

final authStateProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).onAuthStateChange;
});

final sessionProvider = Provider<Session?>((ref) {
  final authState = ref.watch(authStateProvider).value;
  return authState?.session ?? ref.watch(supabaseClientProvider).auth.currentSession;
});

final userProvider = Provider<UserModel>((ref) {
  final session = ref.watch(sessionProvider);
  final user = session?.user;
  
  return UserModel(
    name: user?.email?.split('@')[0] ?? "Guest",
    level: "B2 Intermediate",
    avatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuBbgMzQAemg9hfw8Avdlmuz4zi70OIjHlgeABrKIvs0gHBkeju9DVqvJPddyOHI666DlKu6t04ADZ7tCw91wNpyeTn0ZTta4YEZGlqoA3CeUe3Ng2zygg2_7HB2PiGZVbnN21Qg0qdubaNobOcHUyJaURh8R__aoS95ZKeic8GSX5w3IrO5Dp9WJRUnpqcZthoWIOpXwVlpPXBJeZmdNIF4Ck8oGQC1VGSGgqqAR4AERAHtg4ehi1ELJJ5p-pM-zxo9OpKYjSJP4iLC",
    email: user?.email,
  );
});
