import 'article_model.dart';

class LessonModel {
  final ArticleModel article;
  final List<QuestionModel> questions;

  LessonModel({required this.article, required this.questions});

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      article: ArticleModel.fromJson(json['article']),
      questions: (json['questions'] as List)
          .map((e) => QuestionModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'article': article.toJson(),
      'questions': questions.map((e) => e.toJson()).toList(),
    };
  }
}

class QuestionModel {
  final int id;
  final String text;
  final List<QuestionOption> options;
  final int correctId;
  final String explanation;

  QuestionModel({
    required this.id,
    required this.text,
    required this.options,
    required this.correctId,
    required this.explanation,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'],
      text: json['text'],
      options: (json['options'] as List)
          .map((e) => QuestionOption.fromJson(e))
          .toList(),
      correctId: json['correctId'],
      explanation: json['explanation'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options.map((e) => e.toJson()).toList(),
      'correctId': correctId,
      'explanation': explanation,
    };
  }
}

class QuestionOption {
  final int id;
  final String label;
  final String text;

  QuestionOption({required this.id, required this.label, required this.text});

  factory QuestionOption.fromJson(Map<String, dynamic> json) {
    return QuestionOption(
      id: json['id'],
      label: json['label'],
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'text': text,
    };
  }
}
