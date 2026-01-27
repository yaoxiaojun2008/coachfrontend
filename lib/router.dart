import 'package:flutter/material.dart';
import 'screens/recommended_feed_screen.dart';
import 'screens/recommended_content_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'providers.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/writing_coach_screen.dart';
import 'screens/reading_coach_screen.dart';
import 'screens/writing_history_screen.dart';
import 'screens/quiz_analysis_screen.dart';
import 'screens/reading_history_screen.dart';
import 'screens/article_reader_screen.dart';
import 'screens/chat_screen.dart';
import 'models/article_model.dart';
import 'widgets/responsive_layout.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: ValueNotifier(authState.value), // This might need a better wrapper
    redirect: (context, state) {
      final isLoggedIn = ref.read(sessionProvider) != null;
      final isAuthRoute = state.uri.path == '/auth';

      if (!isLoggedIn && !isAuthRoute) {
        // Allow public routes? For now strict.
        // Actually Home is mostly public? Vite app shows Home.
        // If specific routes require auth, we check them.
        final protectedRoutes = ['/writing-coach', '/reading-coach', '/history', '/writing-history', '/quiz-analysis', '/chat'];
        if (protectedRoutes.contains(state.uri.path)) {
          return '/auth';
        }
      }

      if (isLoggedIn && isAuthRoute) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/writing-coach',
        builder: (context, state) => const WritingCoachScreen(),
      ),
       GoRoute(
        path: '/writing-history',
        builder: (context, state) => const WritingHistoryScreen(),
      ),
       GoRoute(
        path: '/reading-coach',
        builder: (context, state) => const ReadingCoachScreen(),
      ),
       GoRoute(
        path: '/quiz-analysis',
        builder: (context, state) => const QuizAnalysisScreen(),
      ),
      GoRoute(
        path: '/history', // Reading History
        builder: (context, state) => const ReadingHistoryScreen(),
      ),
      GoRoute(
        path: '/article-reader',
        builder: (context, state) {
           final article = state.extra as ArticleModel;
           return ArticleReaderScreen(article: article);
        },
      ),
      GoRoute(
        path: '/recommended-feed',
        builder: (context, state) => const RecommendedFeedScreen(),
      ),
      GoRoute(
        path: '/recommended-content',
        builder: (context, state) => const RecommendedContentScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => const ChatScreen(),
      ),
    ],
  );
});
