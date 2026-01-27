import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../models/article_model.dart';
import 'package:intl/intl.dart';

class ReadingHistoryScreen extends ConsumerStatefulWidget {
  const ReadingHistoryScreen({super.key});

  @override
  ConsumerState<ReadingHistoryScreen> createState() => _ReadingHistoryScreenState();
}

class _ReadingHistoryScreenState extends ConsumerState<ReadingHistoryScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _attempts = [];

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final user = ref.read(sessionProvider)?.user;
      if (user == null) return;

      final supabase = ref.read(supabaseClientProvider);
      
      final data = await supabase
          .from('user_quiz_attempts')
          .select('''
            id, 
            score, 
            total_questions, 
            created_at,
            articles (
                id,
                title,
                content,
                type,
                level
            )
          ''')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _attempts = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleReadAgain(Map<String, dynamic> attempt) {
    final articleData = attempt['articles'];
    final article = ArticleModel(
        id: articleData['id'],
        title: articleData['title'],
        content: articleData['content'], // content in DB is array or string? Supabase returns what is stored.
        // If stored as array (jsonb), select returns it as List<dynamic>. 
        // ArticleModel handles dynamic content.
        type: 'article',
        level: articleData['level'],
    );
    
    context.push('/article-reader', extra: article);
  }

  String _formatDate(String dateString) {
    return DateFormat('MMM d, yyyy • hh:mm a').format(DateTime.parse(dateString).toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reading History', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _attempts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       Icon(Icons.history, size: 48, color: Colors.grey.withOpacity(0.5)),
                       const SizedBox(height: 16),
                       const Text('No reading history yet.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _attempts.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final attempt = _attempts[index];
                    final article = attempt['articles'];
                    final score = attempt['score'];
                    final total = attempt['total_questions'];
                    final isPerfect = score == total;

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.withOpacity(0.2)),
                      ),
                      child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Row(
                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                             crossAxisAlignment: CrossAxisAlignment.start,
                             children: [
                               Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     Text(article['title'] ?? 'Untitled', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                     const SizedBox(height: 4),
                                     Text(_formatDate(attempt['created_at']), style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                   ],
                                 ),
                               ),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                 decoration: BoxDecoration(
                                   color: isPerfect ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(8),
                                 ),
                                 child: Text('$score/$total', style: TextStyle(fontWeight: FontWeight.bold, color: isPerfect ? Colors.green : Colors.blue)),
                               )
                             ],
                           ),
                           const SizedBox(height: 16),
                           Align(
                             alignment: Alignment.centerRight,
                             child: TextButton.icon(
                               onPressed: () => _handleReadAgain(attempt),
                               icon: const Text('Read Again', style: TextStyle(fontWeight: FontWeight.bold)),
                               label: const Icon(Icons.arrow_forward, size: 16),
                               style: TextButton.styleFrom(
                                 foregroundColor: Theme.of(context).primaryColor,
                                 padding: EdgeInsets.zero,
                                 minimumSize: Size.zero,
                                 tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                               ),
                             ),
                           )
                         ],
                      ),
                    );
                  },
                ),
    );
  }
}
