import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:intl/intl.dart';
import 'dart:typed_data'; // Added for Uint8List
import '../models/recommended_article_model.dart';
import '../providers_recommended.dart';
import '../core/theme.dart';

class RecommendedContentScreen extends ConsumerStatefulWidget {
  const RecommendedContentScreen({super.key});

  @override
  ConsumerState<RecommendedContentScreen> createState() => _RecommendedContentScreenState();
}

// Transparent 1x1 PNG image - now defined as a function instead of a const
final Uint8List kTransparentImage = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0xDA, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

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
                         // Using a custom image loading approach to better handle CORS issues
                         child: _buildThumbnailImage(item.imageUrl!),
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
        )).toList(),
      ],
    );
  }
  
  // Custom method to build image with better error handling for CORS
  Widget _buildThumbnailImage(String imageUrl) {
    // Check if the URL is from a domain known to have CORS issues
    // For such domains, we'll still try to load but with improved error handling
    bool hasKnownCORSIssue = imageUrl.contains('fsdn.com');
    
    return FadeInImage(
      placeholder: MemoryImage(kTransparentImage),
      image: NetworkImage(_sanitizeImageUrl(imageUrl)),
      width: 64,
      height: 64,
      fit: BoxFit.cover,
      // Improved error handling to show a more meaningful icon
      imageErrorBuilder: (context, error, stackTrace) {
        // Log the error for debugging purposes
        debugPrint('Failed to load image: $imageUrl, Error: $error');
        
        // For URLs known to have CORS issues, we show a warning icon
        IconData iconToShow = hasKnownCORSIssue 
            ? Icons.warning_amber_outlined 
            : Icons.broken_image_outlined;
            
        return Container(
          color: Colors.grey[300],
          width: 64,
          height: 64,
          child: Icon(iconToShow, color: Colors.grey[600]),
        );
      },
    );
  }
  
  // Sanitize image URL to prevent some common issues
  String _sanitizeImageUrl(String imageUrl) {
    // Remove fragments and normalize the URL
    var uri = Uri.parse(imageUrl);
    return uri.replace(fragment: "").toString();
  }
}