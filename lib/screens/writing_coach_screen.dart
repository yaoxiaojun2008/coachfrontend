import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../providers.dart';
import '../core/theme.dart';

class WritingCoachScreen extends ConsumerStatefulWidget {
  const WritingCoachScreen({super.key});

  @override
  ConsumerState<WritingCoachScreen> createState() => _WritingCoachScreenState();
}

class _WritingCoachScreenState extends ConsumerState<WritingCoachScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;
  String? _activeTool;
  String _message = '';
  
  // Results cache - store structured data
  Map<String, dynamic> _analysisData = {};
  final Map<String, String> _analyzedVersions = {};

  final List<Map<String, dynamic>> _aiFunctions = [
    {'key': 'Style', 'label': 'Style', 'icon': Icons.style},
    {'key': 'Evaluation', 'label': 'Evaluate', 'icon': Icons.grade},
    {'key': 'Improvement', 'label': 'Improvement', 'icon': Icons.trending_up},
    {'key': 'Refinement', 'label': 'Refiner', 'icon': Icons.auto_fix_high},
    {'key': 'Followup', 'label': 'Followup', 'icon': Icons.chat},
    {'key': 'Sample', 'label': 'Sample', 'icon': Icons.library_books},
    {'key': 'Save', 'label': 'Save', 'icon': Icons.save},
  ];

  @override
  void initState() {
    super.initState();
    // Add listener to rebuild when text changes
    _textController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _handleFileUpload() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt', 'doc', 'docx', 'pdf'],
        allowMultiple: false,
      );

      if (result != null) {
        PlatformFile file = result.files.single;
        
        if (file.size > 1024 * 1024) { // More than 1MB
          setState(() {
            _message = 'File is too large. Please select a file smaller than 1MB.';
          });
          return;
        }
        
        // Read the file content
        String content = '';
        
        // Check if we're on web or mobile/desktop
        if (kIsWeb) {
          // On web, bytes are always available
          if (file.bytes != null) {
            content = utf8.decode(file.bytes!);
          } else {
            setState(() {
              _message = 'Could not read file content';
            });
            return;
          }
        } else {
          // On mobile/desktop, use file path if available
          if (file.path != null) {
            content = await File(file.path!).readAsString();
          } else if (file.bytes != null) {
            // Fallback to bytes if path is not available
            content = utf8.decode(file.bytes!);
          } else {
            setState(() {
              _message = 'Could not read file content';
            });
            return;
          }
        }
        
        // Update the text controller with the file content
        _textController.text = content;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
        
        setState(() {
          _message = 'File uploaded successfully!';
        });
      } else {
        // User canceled the file picker
        setState(() {
          _message = 'File selection was cancelled';
        });
      }
    } catch (e) {
      setState(() {
        _message = 'Error uploading file: $e';
      });
    }
  }

  Future<void> _handleInputComplete() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _message = 'Please write something first!');
      return;
    }

    // Check if we already have analysis for this text
    if (_analysisData.isNotEmpty && _analyzedVersions['full'] == text) {
      setState(() {
        _message = 'Analysis already available. Click any tool to view results!';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _message = 'Analyzing writing and searching for samples...';
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      
      // Call both endpoints concurrently
      final results = await Future.wait([
        aiService.fullAnalyzeWriting(text),
        aiService.getSampleEssays(text),
      ]);
      
      final analysisResponse = results[0];
      final sampleResponse = results[1] as Map<String, dynamic>;
      
      setState(() {
        _analysisData = analysisResponse;
        _analysisData['samples'] = sampleResponse['results'];
        _analyzedVersions['full'] = text;
        _message = 'Analysis complete and samples ready! Click any tool to view.';
      });
    } catch (e) {
      setState(() => _message = 'Error during initialization: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAiAction(String tool) async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      setState(() => _message = 'Please write something first!');
      return;
    }

    if (tool == 'Save') {
      _handleSave();
      return;
    }

    if (tool == 'Sample') {
      // Sample results are now pre-fetched in _handleInputComplete
      if (_analysisData['samples'] == null && _analysisData.isNotEmpty) {
         setState(() => _message = 'No samples were found for this text.');
         return;
      }
      // Continue to show from cache
    }

    // Check if we have analysis data
    if (_analysisData.isEmpty) {
      setState(() => _message = 'Please click "Input Complete" to analyze your writing first!');
      return;
    }

    // Check if the text has changed since last analysis
    if (_analyzedVersions['full'] != text) {
      setState(() => _message = 'Text has changed. Please click "Input Complete" to re-analyze!');
      return;
    }

    setState(() {
      _activeTool = tool;
      _message = '';
    });
  }

  String _formatResult(dynamic result) {
    if (result == null) return "No analysis available.";
    if (result is String) return result;
    return const JsonEncoder.withIndent('  ').convert(result);
  }

  Widget _buildResultContent(String? tool) {
    if (tool == null || _analysisData.isEmpty) {
      return const Text('No analysis available.');
    }

    switch (tool) {
      case 'Style':
        return _buildStyleContent();
      case 'Evaluation':
        return _buildEvaluationContent();
      case 'Improvement':
        return _buildImprovementContent();
      case 'Refinement':
        return _buildRefinementContent();
      case 'Followup':
        return _buildFollowupContent();
      case 'Sample':
        return _buildSampleContent();
      default:
        return Text(_formatResult(_analysisData));
    }
  }

  Widget _buildSampleContent() {
    final samples = _analysisData['samples'] as List<dynamic>?;
    if (samples == null || samples.isEmpty) {
      return const Center(child: Text('No sample essays found.'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Explore Similar Essays:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        ...samples.map((sample) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text('Grade ${sample['grade']}', style: const TextStyle(fontSize: 10, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                  ),
                  Text('Similarity: ${( (sample['similarity'] ?? 0) * 100).toStringAsFixed(1)}%', style: TextStyle(color: Colors.grey[600], fontSize: 10)),
                ],
              ),
              const SizedBox(height: 8),
              Text('Type: ${sample['writing_type']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                sample['essay_text'],
                style: const TextStyle(fontSize: 14, height: 1.5, fontStyle: FontStyle.italic),
              ),
              if (sample['score_rationale'] != null && sample['score_rationale'].toString().isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(),
                ),
                const Text('Rationale:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.green)),
                const SizedBox(height: 4),
                Text(
                  sample['score_rationale'],
                  style: const TextStyle(fontSize: 12),
                ),
              ]
            ],
          ),
        )).toList(),
      ],
    );
  }

  Widget _buildStyleContent() {
    final style = _analysisData['style'];
    if (style == null) return const Text('No style analysis available.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Strengths:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(style['strengths']),
        const SizedBox(height: 16),
        const Text('Areas for Improvement:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(style['areas_for_improvement']),
        const SizedBox(height: 16),
        const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(style['suggestions']),
      ],
    );
  }

  Widget _buildEvaluationContent() {
    final evaluation = _analysisData['evaluate'];
    if (evaluation == null) return const Text('No evaluation available.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Overall Score:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(evaluation['overall_score'] ?? 'N/A'),
        const SizedBox(height: 16),
        const Text('Grammar Accuracy:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(evaluation['grammar_accuracy'] ?? 'N/A'),
        const SizedBox(height: 16),
        const Text('Vocabulary Usage:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(evaluation['vocabulary_usage'] ?? 'N/A'),
        const SizedBox(height: 16),
        const Text('Coherence & Cohesion:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(evaluation['coherence_cohesion'] ?? 'N/A'),
        const SizedBox(height: 16),
        const Text('Task Completion:', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(evaluation['task_completion'] ?? 'N/A'),
      ],
    );
  }

  Widget _buildImprovementContent() {
    final improvement = _analysisData['improvement'];
    if (improvement == null) return const Text('No improvement analysis available.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Key Issues:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(improvement['key_issues']),
        const SizedBox(height: 16),
        const Text('Priority Fixes:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(improvement['priority_fixes']),
      ],
    );
  }

  Widget _buildRefinementContent() {
    final refinement = _analysisData['refiner'];
    if (refinement == null) return const Text('No refinement analysis available.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Word Choices:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(refinement['word_choices']),
        const SizedBox(height: 16),
        const Text('Sentence Structures:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(refinement['sentence_structures']),
        const SizedBox(height: 16),
        const Text('Transitions:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(refinement['transitions']),
      ],
    );
  }

  Widget _buildFollowupContent() {
    final followup = _analysisData['followup'];
    if (followup == null) return const Text('No followup analysis available.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Learning Resources:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(followup['learning_resources']),
        const SizedBox(height: 16),
        const Text('Practice Recommendations:', style: TextStyle(fontWeight: FontWeight.bold)),
        _buildList(followup['practice_recommendations']),
      ],
    );
  }

  Widget _buildList(List<dynamic>? items) {
    if (items == null || items.isEmpty) {
      return const Text('No items available.');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map((item) => Padding(
        padding: const EdgeInsets.only(left: 16, bottom: 8),
        child: Text('• $item'),
      )).toList(),
    );
  }

  Future<void> _handleSave() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
       setState(() => _message = 'Please write something first!');
       return;
    }
    
    setState(() {
      _isLoading = true;
      _message = 'Saving...';
    });

    try {
      final user = ref.read(sessionProvider)?.user;
      if (user == null) {
        // Should force login?
        setState(() => _message = 'You must be logged in to save.');
        return;
      }

      final essayService = ref.read(essayServiceProvider);
      
      // Parse results back to JSON if they are strings, but we stored formatted strings.
      // Ideally we should have stored the raw logic. 
      // For now we just send what we have or null. 
      // The backend expects JSON/Dict for ai_* fields probably?
      // EssayModel expects properties. Api expects plain JSON.
      
      // We'll send empty for now if not analyzed.
      // If we analyzed, we have the STRING version. We can't easily revert to JSON if it was formatted.
      // But _formatResult mostly keeps it string or JSON string.
      // Let's just send the results we have.
      
      await essayService.createEssay({
         'user_id': user.id,
         'content': text,
         // We might need to adjust this to match exact backend expectation
         // validation is loose?
      });

      setState(() {
        _message = 'Essay saved successfully!';
      });
    } catch (e) {
      setState(() => _message = 'Error saving: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Writing Coach', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => context.push('/writing-history'),
            child: const Text('History Review', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      ),
      body: Column(
        children: [
          // Editor
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.withOpacity(0.2)),
              ),
              child: Column(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Start writing your essay here...',
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Upload button - now functional
                      TextButton.icon(
                        onPressed: _handleFileUpload,
                        icon: const Icon(Icons.upload_file),
                        label: const Text('Upload File'),
                      ),
                      const SizedBox(width: 8),
                      // Input Complete Button - always visible, disabled when empty
                      TextButton.icon(
                        onPressed: _textController.text.trim().isEmpty ? null : () => _handleInputComplete(),
                        icon: Icon(
                          Icons.check_circle,
                          color: _textController.text.trim().isEmpty ? Colors.grey : Colors.green,
                        ),
                        label: Text(
                          'Input Complete',
                          style: TextStyle(
                            color: _textController.text.trim().isEmpty ? Colors.grey : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_message.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_message, style: TextStyle(color: _message.contains('Success') || _message.contains('ready') ? Colors.green : (_message.contains('Error') ? Colors.red : Colors.blue))),
                    ),
                ],
              ),
            ),
          ),

          // Tools
          Container(
            height: 100, // Fixed height for tools row
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _aiFunctions.map((func) => _ToolButton(
                label: func['label'],
                icon: func['icon'],
                isActive: _activeTool == func['key'],
                onTap: () => _handleAiAction(func['key']),
              )).toList(),
            ),
          ),

          // Results
          if (_activeTool != null && _analysisData.isNotEmpty)
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                   color: Theme.of(context).colorScheme.surface,
                   borderRadius: BorderRadius.circular(16),
                   border: Border.all(color: Colors.grey.withOpacity(0.2)),
                   boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Result: ${ _aiFunctions.firstWhere((f) => f['key'] == _activeTool)['label'] }', style: const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => setState(() => _activeTool = null),
                        )
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildResultContent(_activeTool),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading)
               const Padding(
                 padding: EdgeInsets.all(20.0),
                 child: Center(child: CircularProgressIndicator()),
               )
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _ToolButton({required this.label, required this.icon, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isActive ? AppTheme.primary.withOpacity(0.1) : Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: isActive ? AppTheme.primary : Colors.grey.withOpacity(0.3)),
            ),
            child: Icon(icon, color: isActive ? AppTheme.primary : Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 10, color: isActive ? AppTheme.primary : Colors.grey)),
        ],
      ),
    );
  }
}