class RecommendedArticleModel {
  final String id;
  final String articleId;
  final String title;
  final String url;
  final String source;
  final String? imageUrl;
  final String type;
  final String level;
  final String snippet;
  final DateTime pulledAt;

  RecommendedArticleModel({
    required this.id,
    required this.articleId,
    required this.title,
    required this.url,
    required this.source,
    this.imageUrl,
    required this.type,
    required this.level,
    required this.snippet,
    required this.pulledAt,
  });

  factory RecommendedArticleModel.fromJson(Map<String, dynamic> json) {
    return RecommendedArticleModel(
      id: json['id'],
      articleId: json['article_id'] ?? '',
      title: json['title'],
      url: json['url'],
      source: json['source'],
      imageUrl: json['image_url'],
      type: json['type'],
      level: json['level'],
      snippet: json['snippet'],
      pulledAt: DateTime.parse(json['pulled_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'title': title,
      'url': url,
      'source': source,
      'image_url': imageUrl,
      'type': type,
      'level': level,
      'snippet': snippet,
      'pulled_at': pulledAt.toIso8601String(),
    };
  }
}
