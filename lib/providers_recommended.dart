import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/recommended_service.dart';
import 'providers.dart';

final recommendedServiceProvider = Provider<RecommendedService>((ref) {
  return RecommendedService(ref.watch(supabaseClientProvider));
});

final recommendedContentProvider = FutureProvider((ref) async {
  return ref.watch(recommendedServiceProvider).getRecommendedContent();
});
