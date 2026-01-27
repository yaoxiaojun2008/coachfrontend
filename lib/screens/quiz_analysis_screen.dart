import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/lesson_model.dart';
import '../core/theme.dart';
import 'dart:math' as math;

class QuizAnalysisScreen extends StatefulWidget {
  const QuizAnalysisScreen({super.key});

  @override
  State<QuizAnalysisScreen> createState() => _QuizAnalysisScreenState();
}

class _QuizAnalysisScreenState extends State<QuizAnalysisScreen> {
  LessonModel? _lesson;
  Map<int, int> _userAnswers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedLesson = prefs.getString('last_generated_lesson');
    final cachedAnswers = prefs.getString('last_quiz_answers');

    if (cachedLesson != null) {
      try {
        final lesson = LessonModel.fromJson(jsonDecode(cachedLesson));
        final Map<int, int> userAnswers = {};
        if (cachedAnswers != null) {
          final Map<String, dynamic> answersJson = jsonDecode(cachedAnswers);
          answersJson.forEach((k, v) {
            userAnswers[int.parse(k)] = v as int;
          });
        }

        setState(() {
          _lesson = lesson;
          _userAnswers = userAnswers;
          _isLoading = false;
        });
      } catch (e) {
        setState(() => _isLoading = false);
      }
    } else {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_lesson == null) return const Scaffold(body: Center(child: Text("No quiz data found.")));

    int correctCount = 0;
    _lesson!.questions.asMap().forEach((idx, q) {
      if (_userAnswers[idx] == q.correctId) correctCount++;
    });

    final scorePercentage = (correctCount / _lesson!.questions.length * 100).round();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Analysis'),
        leading: IconButton(onPressed: () => context.go('/'), icon: const Icon(Icons.close)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: Scrollbar(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 100),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Score Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppTheme.primary.withOpacity(0.2), AppTheme.primary.withOpacity(0.05)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scorePercentage == 100 ? 'Perfect!' : scorePercentage >= 60 ? 'Great effort!' : 'Keep practicing!',
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scorePercentage == 100 ? "You've mastered this article." : "Review the answers below to improve.",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text('$correctCount/${_lesson!.questions.length}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                              const SizedBox(width: 4),
                              const Text('Correct', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                            ],
                          ),
                        ],
                      ),
                      // Progress Circle
                      SizedBox(
                        width: 80, height: 80,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: scorePercentage / 100,
                              strokeWidth: 8,
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              color: AppTheme.primary,
                            ),
                            Center(child: Text('$scorePercentage%', style: const TextStyle(fontWeight: FontWeight.bold))),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Questions
                ..._lesson!.questions.asMap().entries.map((entry) {
                   final idx = entry.key;
                   final q = entry.value;
                   final userAnswerId = _userAnswers[idx];
                   final isCorrect = userAnswerId == q.correctId;
                   final userOption = q.options.firstWhere(
                     (o) => o.id == userAnswerId, 
                     orElse: () => QuestionOption(id: -1, label: '', text: 'No Answer')
                   );
                   final correctOption = q.options.firstWhere((o) => o.id == q.correctId);

                   return Padding(
                     padding: const EdgeInsets.only(bottom: 24.0),
                     child: Column(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Row(
                           crossAxisAlignment: CrossAxisAlignment.start,
                           children: [
                             Container(
                               width: 24, height: 24,
                               alignment: Alignment.center,
                               decoration: BoxDecoration(
                                 color: isCorrect ? AppTheme.success : AppTheme.error,
                                 shape: BoxShape.circle,
                               ),
                               child: Icon(isCorrect ? Icons.check : Icons.close, size: 16, color: Colors.white),
                             ),
                             const SizedBox(width: 12),
                             Expanded(child: Text(q.text, style: const TextStyle(fontWeight: FontWeight.bold))),
                           ],
                         ),
                         const SizedBox(height: 12),
                         Padding(
                           padding: const EdgeInsets.only(left: 36),
                           child: Column(
                             crossAxisAlignment: CrossAxisAlignment.stretch,
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(16),
                                 decoration: BoxDecoration(
                                   color: isCorrect ? AppTheme.success.withOpacity(0.05) : AppTheme.error.withOpacity(0.05),
                                   borderRadius: BorderRadius.circular(12),
                                   border: Border.all(color: isCorrect ? AppTheme.success.withOpacity(0.2) : AppTheme.error.withOpacity(0.2)),
                                 ),
                                 child: RichText(
                                   text: TextSpan(
                                     style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                     children: [
                                       TextSpan(text: 'Your Answer: ', style: TextStyle(fontWeight: FontWeight.bold, color: isCorrect ? AppTheme.success : AppTheme.error)),
                                       TextSpan(text: userOption.text),
                                     ],
                                   ),
                                 ),
                               ),
                               if (!isCorrect)
                                 Container(
                                   margin: const EdgeInsets.only(top: 8),
                                   padding: const EdgeInsets.all(16),
                                   decoration: BoxDecoration(
                                     color: AppTheme.success.withOpacity(0.05),
                                     borderRadius: BorderRadius.circular(12),
                                     border: Border.all(color: AppTheme.success.withOpacity(0.2)),
                                   ),
                                   child: RichText(
                                     text: TextSpan(
                                       style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                                       children: [
                                         const TextSpan(text: 'Correct Answer: ', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.success)),
                                         TextSpan(text: correctOption.text),
                                       ],
                                     ),
                                   ),
                                 ),
                                 
                               const SizedBox(height: 12),
                               Container(
                                 padding: const EdgeInsets.all(16),
                                 decoration: BoxDecoration(
                                   color: Theme.of(context).colorScheme.surface,
                                   borderRadius: BorderRadius.circular(12),
                                   border: Border.all(color: Colors.grey.withOpacity(0.2)),
                                 ),
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     const Row(
                                       children: [
                                         Icon(Icons.auto_awesome, size: 16, color: AppTheme.primary),
                                         SizedBox(width: 8),
                                         Text('AI EXPLANATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                       ],
                                     ),
                                     const SizedBox(height: 8),
                                     Text(q.explanation, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                       ],
                     ),
                   );
                }),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/reading-coach'), // Review Article (just go back)
                  icon: const Icon(Icons.article),
                  label: const Text('Review Article'),
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.remove('last_generated_lesson');
                    if (context.mounted) context.pushReplacement('/reading-coach');
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Another'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
