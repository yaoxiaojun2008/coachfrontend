import 'dart:convert';

class EssayModel {
  final String id;
  final String userId;
  final String content;
  final String? fileUrl;
  final Map<String, dynamic>? aiStyleAnalysis;
  final Map<String, dynamic>? aiEvaluation;
  final Map<String, dynamic>? aiImprovement;
  final Map<String, dynamic>? aiRefinement;
  final Map<String, dynamic>? aiFollowup;
  final DateTime createdAt;

  EssayModel({
    required this.id,
    required this.userId,
    required this.content,
    this.fileUrl,
    this.aiStyleAnalysis,
    this.aiEvaluation,
    this.aiImprovement,
    this.aiRefinement,
    this.aiFollowup,
    required this.createdAt,
  });

  // Helper method to safely parse JSON fields
  static Map<String, dynamic>? _parseJsonField(dynamic field) {
    if (field == null) return null;
    if (field is Map<String, dynamic>) return field;
    if (field is String) {
      try {
        return jsonDecode(field) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  factory EssayModel.fromJson(Map<String, dynamic> json) {
    return EssayModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      fileUrl: json['file_url']?.toString(),
      aiStyleAnalysis: _parseJsonField(json['ai_style_analysis']),
      aiEvaluation: _parseJsonField(json['ai_evaluation']),
      aiImprovement: _parseJsonField(json['ai_improvement']),
      aiRefinement: _parseJsonField(json['ai_refinement']),
      aiFollowup: _parseJsonField(json['ai_followup']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'file_url': fileUrl,
      'ai_style_analysis': aiStyleAnalysis,
      'ai_evaluation': aiEvaluation,
      'ai_improvement': aiImprovement,
      'ai_refinement': aiRefinement,
      'ai_followup': aiFollowup,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
