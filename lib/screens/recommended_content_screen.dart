import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:intl/intl.dart';
import '../models/recommended_article_model.dart';
import '../providers_recommended.dart';
import '../core/theme.dart';

class RecommendedContentScreen extends ConsumerStatefulWidget {
  const RecommendedContentScreen({super.key});

  @override
  ConsumerState<RecommendedContentScreen> createState() => _RecommendedContentScreenState();
}

class _RecommendedContentScreenState extends ConsumerState<RecommendedContentScreen> {
  bool _isLoading = true;
  List<RecommendedArticleModel> _newsItems = [];
  List<RecommendedArticleModel> _blogItems = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final service = ref.read(recommendedServiceProvider);
      final data = await service.getRecommendedContent();
      if (mounted) {
        setState(() {
          _newsItems = data['news'] ?? [];
          _blogItems = data['blogs'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshContent() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final service = ref.read(recommendedServiceProvider);
      final data = await service.fetchAndCacheRecommendedContent(); // Force fetching fresh data
      if (mounted) {
        setState(() {
          _newsItems = data['news'] ?? [];
          _blogItems = data['blogs'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
       debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Recommended Content')),
        body: Center(
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               Text('Error: $_error'),
               ElevatedButton(onPressed: _loadContent, child: const Text('Retry')),
             ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommended Content'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshContent,
            tooltip: 'Refresh content',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800), // Limit width for better centering
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Content'),
                  onPressed: _refreshContent,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 24),
                _Section(title: 'Latest News', items: _newsItems, onLaunch: _launchUrl),
                const SizedBox(height: 24),
                _Section(title: 'Latest Blogs', items: _blogItems, onLaunch: _launchUrl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<RecommendedArticleModel> items;
  final Function(String) onLaunch;

  const _Section({required this.title, required this.items, required this.onLaunch});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ...items.map((item) => GestureDetector(
          onTap: () => onLaunch(item.url),
          child: Container(
             margin: const EdgeInsets.only(bottom: 12),
             padding: const EdgeInsets.all(12),
             decoration: BoxDecoration(
               color: Theme.of(context).colorScheme.surface,
               borderRadius: BorderRadius.circular(12),
               border: Border.all(color: Colors.grey.withOpacity(0.2)),
             ),
             child: Row(
               children: [
                 Container(
                   width: 64, height: 64,
                   decoration: BoxDecoration(
                     color: Colors.grey[200],
                     borderRadius: BorderRadius.circular(8),
                   ),
                   child: item.imageUrl != null 
                     ? ClipRRect(
                         borderRadius: BorderRadius.circular(8),
                         child: Image.network(
                           item.imageUrl!,
                           width: 64,
                           height: 64,
                           fit: BoxFit.cover,
                           errorBuilder: (context, error, stackTrace) {
                             return const Icon(Icons.image, color: Colors.grey, size: 32,);
                           },
                           loadingBuilder: (context, child, loadingStatus) {
                             if (loadingStatus != null) {
                               return Center(
                                 child: SizedBox(
                                   width: 24,
                                   height: 24,
                                   child: CircularProgressIndicator(
                                     strokeWidth: 2,
                                     value: loadingStatus.expectedTotalBytes != null
                                         ? loadingStatus.cumulativeBytesLoaded / loadingStatus.expectedTotalBytes!
                                         : null,
                                   ),
                                 ),
                               );
                             }
                             return child;
                           },
                         ),
                       )
                     : const Icon(Icons.image, color: Colors.grey, size: 32,),
                 ),
                 const SizedBox(width: 12),
                 Expanded(
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold)),
                       const SizedBox(height: 4),
                       Text(item.snippet, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                       const SizedBox(height: 4),
                       Text('${item.source} • ${DateFormat.yMMMd().format(item.pulledAt)}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                     ],
                   ),
                 )
               ],
             ),
          ),
        )),
      ],
    );
  }
}
