import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers.dart';
import '../models/lesson_model.dart';
import '../core/theme.dart';
import '../widgets/responsive_layout.dart';

class ReadingCoachScreen extends ConsumerStatefulWidget {
  const ReadingCoachScreen({super.key});

  @override
  ConsumerState<ReadingCoachScreen> createState() => _ReadingCoachScreenState();
}

class _ReadingCoachScreenState extends ConsumerState<ReadingCoachScreen> {
  LessonModel? _lesson;
  bool _isLoading = true;
  int _currentQuestionIndex = 0;
  final Map<int, int> _userAnswers = {}; // Question Index -> Option ID
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    _loadLesson();
  }

  /// Sanitizes content by removing or replacing external images that cause CORS issues
  String _sanitizeContent(String content) {
    // Remove or replace external image sources that cause CORS issues
    // This regex looks for img tags with the problematic domain
    String patternStr = '<img[^>]*src\\s*=\\s*["\'][^"\']*https://a\\.fsdn\\.com[^"\']*["\'][^>]*/?>';
    RegExp corsProblematicImagePattern = RegExp(
      patternStr,
      caseSensitive: false,
      multiLine: true,
    );
    
    // Replace problematic images with a placeholder icon
    String sanitizedContent = content.replaceAll(corsProblematicImagePattern, 
      '<div style="display: flex; align-items: center; justify-content: center; padding: 10px; border: 1px solid #ddd; border-radius: 4px; margin: 5px 0;">'
      '<span style="margin-right: 8px;">🖼️</span>'
      '<span>External Image Blocked (CORS)</span>'
      '</div>');
    
    // Additional sanitization for markdown-style image links
    RegExp markdownImagePattern = RegExp(r'!\[([^\]]*)\]\(https://a\.fsdn\.com[^\)]*\)');
    sanitizedContent = sanitizedContent.replaceAllMapped(markdownImagePattern, (match) {
      String altText = match.group(1) ?? 'Image';
      return '[$altText](blocked-image)';
    });
    
    return sanitizedContent.trim();
  }

  Future<void> _loadLesson() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('last_generated_lesson');
    
    if (cached != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(cached);
        final lesson = LessonModel.fromJson(json);
        // Basic validation
        if (lesson.questions.isNotEmpty) {
           setState(() {
             _lesson = lesson;
             _isLoading = false;
           });
           
           // Restore answers
           final cachedAnswers = prefs.getString('last_quiz_answers');
           if (cachedAnswers != null) {
             final Map<String, dynamic> answersJson = jsonDecode(cachedAnswers);
             answersJson.forEach((k, v) {
               _userAnswers[int.parse(k)] = v as int;
             });
             // Set initial selection
             if (_userAnswers.containsKey(0)) {
               setState(() => _selectedAnswer = _userAnswers[0]);
             }
           }
           return;
        }
      } catch (e) {
        // Cache invalid
        await prefs.remove('last_generated_lesson');
        await prefs.remove('last_quiz_answers');
      }
    }

    // Call API
    try {
      final aiService = ref.read(aiServiceProvider);
      // generateReadingLesson maps "B2", optional topic
      final data = await aiService.generateReadingLesson("B2");
      
      // Data is Map<String, dynamic>. Parse to LessonModel.
      // Assuming API returns JSON compatible with LessonModel
      final lesson = LessonModel.fromJson(data);
      
      await prefs.setString('last_generated_lesson', jsonEncode(lesson.toJson()));
      await prefs.remove('last_quiz_answers');

      if (mounted) {
        setState(() {
          _lesson = lesson;
          _isLoading = false;
          _userAnswers.clear();
          _selectedAnswer = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        // Show error
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _handleAnswerSelect(int optionId) {
    setState(() {
      _selectedAnswer = optionId;
      _userAnswers[_currentQuestionIndex] = optionId;
    });
    // Update cache
    SharedPreferences.getInstance().then((prefs) {
      // Map<int, int> to Map<String, int> for JSON
      final jsonMap = _userAnswers.map((key, value) => MapEntry(key.toString(), value));
      prefs.setString('last_quiz_answers', jsonEncode(jsonMap));
    });
  }

  Future<void> _handleNext() async {
    if (_lesson == null) return;

    if (_currentQuestionIndex < _lesson!.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = _userAnswers[_currentQuestionIndex];
      });
    } else {
      // Submit
      try {
         final user = ref.read(sessionProvider)?.user;
         final supabase = ref.read(supabaseClientProvider);

         if (user != null) {
           // 1. Insert Article
           // Check logic in ReadingCoach.tsx: insert article first to get ID.
           final articleData = await supabase
             .from('articles')
             .insert({
               'title': _lesson!.article.title,
               'content': _lesson!.article.contentAsString, // Stored as single string or handle array
               'type': 'Generated',
               'level': 'B2'
             })
             .select()
             .single();
            
            // 2. Calculate score
            int correctCount = 0;
            _lesson!.questions.asMap().forEach((idx, q) {
              if (_userAnswers[idx] == q.correctId) correctCount++;
            });

            // 3. Insert Attempt
            await supabase.from('user_quiz_attempts').insert({
              'user_id': user.id,
              'article_id': articleData['id'],
              'score': correctCount,
              'total_questions': _lesson!.questions.length,
              'user_answers': _userAnswers // Supabase stores JSONB
            });
         }
      } catch (e) {
        print("Error saving progress: $e");
      }

      context.push('/quiz-analysis');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               CircularProgressIndicator(),
               SizedBox(height: 16),
               Text('Generating Lesson with AI...'),
             ],
          ),
        ),
      );
    }
    
    if (_lesson == null) return const Scaffold(body: Center(child: Text('Error loading lesson')));

    final question = _lesson!.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _lesson!.questions.length;

    return ResponsiveLayout(
      currentRoute: '/reading-coach',
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            // Progress Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('QUIZ PROGRESS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      Text('${_currentQuestionIndex + 1} of ${_lesson!.questions.length} Questions', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(value: progress, minHeight: 6, borderRadius: BorderRadius.circular(3)),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // Article Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.article, size: 16, color: AppTheme.primary),
                    const SizedBox(width: 8),
                     const Text('READING MATERIAL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(_lesson!.article.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                // Using Html widget if available, otherwise using Text with sanitization
                ..._buildArticleContent(),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Question
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                 children: [
                   Container(
                     width: 24, height: 24,
                     alignment: Alignment.center,
                     decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
                     child: Text('0${_currentQuestionIndex + 1}', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                   ),
                   const SizedBox(width: 8),
                   Expanded(child: Text(question.text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                 ],
               ),
               const SizedBox(height: 16),
               ...question.options.map((option) {
                 final isSelected = _selectedAnswer == option.id;
                 return GestureDetector(
                   onTap: () => _handleAnswerSelect(option.id),
                   child: Container(
                     margin: const EdgeInsets.only(bottom: 12),
                     padding: const EdgeInsets.all(16),
                     decoration: BoxDecoration(
                       color: isSelected ? AppTheme.primary.withOpacity(0.05) : Theme.of(context).colorScheme.surface,
                       borderRadius: BorderRadius.circular(12),
                       border: Border.all(
                         color: isSelected ? AppTheme.primary : Colors.grey.withOpacity(0.2),
                         width: isSelected ? 2 : 1
                       ),
                     ),
                     child: Row(
                       children: [
                         Container(
                           width: 32, height: 32,
                           alignment: Alignment.center,
                           decoration: BoxDecoration(
                             color: isSelected ? AppTheme.primary : ((Theme.of(context).brightness == Brightness.dark) ? Colors.grey[800] : Colors.grey[100]),
                             borderRadius: BorderRadius.circular(8),
                           ),
                           child: Text(option.label, style: TextStyle(
                             fontWeight: FontWeight.bold,
                             color: isSelected ? Colors.white : AppTheme.primary
                           )),
                         ),
                         const SizedBox(width: 12),
                         Expanded(child: Text(option.text)),
                       ],
                     ),
                   ),
                 );
               }),
            ],
          ),

          const SizedBox(height: 24),

          // Action Button
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: _selectedAnswer != null ? _handleNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                 mainAxisAlignment: MainAxisAlignment.center,
                 children: [
                   Text(_currentQuestionIndex < _lesson!.questions.length - 1 ? 'Next Question' : 'Submit Quiz', style: const TextStyle(fontWeight: FontWeight.bold)),
                   const SizedBox(width: 8),
                   Icon(_currentQuestionIndex < _lesson!.questions.length - 1 ? Icons.arrow_forward : Icons.check_circle, size: 20),
                 ],
              ),
            ),
          ),
          const SizedBox(height: 80), // Extra space for bottom nav on mobile
        ],
      ),
    ),
  );
}

  /// Builds the article content, handling both plain text and HTML content safely
  List<Widget> _buildArticleContent() {
    List<Widget> contentWidgets = [];
    
    for (String paragraph in _lesson!.article.contentAsList) {
      // Sanitize the paragraph to remove problematic images
      String sanitizedParagraph = _sanitizeContent(paragraph);
      
      // Add the sanitized paragraph to the content
      contentWidgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            sanitizedParagraph, 
            style: const TextStyle(height: 1.6, fontSize: 14),
          ),
        ),
      );
    }
    
    return contentWidgets;
  }
}