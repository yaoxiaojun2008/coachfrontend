import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/article_model.dart';
import '../core/theme.dart';

class ArticleReaderScreen extends StatefulWidget {
  final ArticleModel article;

  const ArticleReaderScreen({super.key, required this.article});

  @override
  State<ArticleReaderScreen> createState() => _ArticleReaderScreenState();
}

class _ArticleReaderScreenState extends State<ArticleReaderScreen> {
  // Webview integration skipped for now, assuming mostly content based. 
  // If URL exists, we can launchUrl.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             if (context.canPop()) context.pop();
             else context.go('/');
          },
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.article.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(widget.article.url ?? 'Generated Article', style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
        actions: [
          if (widget.article.url != null)
            IconButton(
              icon: const Icon(Icons.open_in_new),
              onPressed: () {
                // launchUrl(Uri.parse(widget.article.url!));
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.article.content == null)
              Center(
                child: Column(
                  children: [
                    const Icon(Icons.web_asset_off, size: 60, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text('No content available.'),
                    if (widget.article.url != null)
                      ElevatedButton(onPressed: (){}, child: const Text('Open in Browser'))
                  ],
                ),
              )
            else
               ...widget.article.contentAsList.map((p) => Padding(
                 padding: const EdgeInsets.only(bottom: 16),
                 child: Text(p, style: const TextStyle(fontSize: 18, height: 1.6, fontFamily: 'serif')),
               )),
          ],
        ),
      ),
    );
  }
}
