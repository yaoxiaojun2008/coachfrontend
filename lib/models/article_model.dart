class ArticleModel {
  final String id;
  final String title;
  final dynamic content; // String or List<String>
  final String? source;
  final String? level;
  final String? url;
  final String? readTime;
  final String? type;

  ArticleModel({
    required this.id,
    required this.title,
    required this.content,
    this.source,
    this.level,
    this.url,
    this.readTime,
    this.type,
  });

  String get contentAsString {
    if (content is List) {
      return (content as List).join('\n\n');
    }
    return content.toString();
  }
  
  List<String> get contentAsList {
     if (content is List) {
       return List<String>.from(content);
     }
     return content.toString().split('\n\n');
  }

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      content: json['content'],
      source: json['source'],
      level: json['level'],
      url: json['url'],
      readTime: json['readTime'],
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'source': source,
      'level': level,
      'url': url,
      'readTime': readTime,
      'type': type,
    };
  }
}
