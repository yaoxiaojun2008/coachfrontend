import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/recommended_article_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RecommendedService {
  final SupabaseClient _supabase;

  RecommendedService(this._supabase);

  static const String CACHE_KEY = 'recommendedContentCache';
  static const int CACHE_DURATION_HOURS = 24;

  Future<Map<String, List<RecommendedArticleModel>>> getRecommendedContent() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString(CACHE_KEY);

    if (cachedData != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(cachedData);
        final lastUpdated = DateTime.parse(decoded['lastUpdated']);
        if (DateTime.now().difference(lastUpdated).inHours < CACHE_DURATION_HOURS) {
          final news = (decoded['news'] as List).map((e) => RecommendedArticleModel.fromJson(e)).toList();
          final blogs = (decoded['blogs'] as List).map((e) => RecommendedArticleModel.fromJson(e)).toList();
          return {'news': news, 'blogs': blogs};
        }
      } catch (e) {
        print('Cache invalid: $e');
      }
    }

    return await fetchAndCacheRecommendedContent();
  }

  Future<Map<String, List<RecommendedArticleModel>>> fetchAndCacheRecommendedContent() async {
     try {
       final newsResponse = await _supabase
          .from('recommended_articles')
          .select('*')
          .eq('type', 'News')
          .eq('is_pushed_to_client', true)
          .order('pulled_at', ascending: false)
          .limit(3);
        
       final blogResponse = await _supabase
          .from('recommended_articles')
          .select('*')
          .eq('type', 'Blog')
          .eq('is_pushed_to_client', true)
          .order('pulled_at', ascending: false)
          .limit(3);
        
        final news = (newsResponse as List).map((e) => RecommendedArticleModel.fromJson(e)).toList();
        final blogs = (blogResponse as List).map((e) => RecommendedArticleModel.fromJson(e)).toList();

        // Cache
        final prefs = await SharedPreferences.getInstance();
        final cacheData = {
          'news': news.map((e) => e.toJson()).toList(),
          'blogs': blogs.map((e) => e.toJson()).toList(),
          'lastUpdated': DateTime.now().toIso8601String(),
        };
        await prefs.setString(CACHE_KEY, jsonEncode(cacheData));

        return {'news': news, 'blogs': blogs};

     } catch (e) {
       throw Exception('Failed to fetch recommended content: $e');
     }
  }
}
