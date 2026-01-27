import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/main.dart';
import 'package:frontend/providers.dart';
import 'package:frontend/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {
  @override
  final GoTrueClient auth = FakeGoTrueClient();
}

class FakeGoTrueClient extends Fake implements GoTrueClient {
  @override
  Session? get currentSession => null;

  @override
  Stream<AuthState> get onAuthStateChange => Stream.value(AuthState(AuthChangeEvent.initialSession, null));
}

void main() { 
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  testWidgets('App builds and navigates to default route', (WidgetTester tester) async {
      final fakeSupabase = FakeSupabaseClient();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            supabaseClientProvider.overrideWithValue(fakeSupabase),
            userProvider.overrideWithValue(UserModel(name: 'Guest', level: 'B1', avatar: '')),
          ],
          child: const MyApp(),
        ),
      );

      // Verify that we have a MaterialApp
      expect(find.byType(MaterialApp), findsOneWidget);

      await tester.pumpAndSettle();

      // Should be on Home Screen and showing Guest
      expect(find.textContaining('Hi, Guest!'), findsOneWidget);
  });
}
