import 'api_service.dart';

class AiService {
  final ApiService _apiService;

  AiService(this._apiService);

  Future<Map<String, dynamic>> generateReadingLesson(String level, {String? topic}) async {
    final response = await _apiService.client.post(
      '/ai/generate-reading-lesson',
      data: {'level': level, 'topic': topic},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> analyzeWriting(String content) async {
    final response = await _apiService.client.post(
      '/ai/analyze-writing',
      data: {'content': content},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> fullAnalyzeWriting(String writingSample) async {
    final response = await _apiService.client.post(
      '/ai/full-analyze-writing',
      data: {'writing_sample': writingSample},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> chatWithAi(List<Map<String, String>> history) async {
    final response = await _apiService.client.post(
      '/ai/chat',
      data: {'history': history},
    );
    return response.data;
  }

  Future<Map<String, dynamic>> getSampleEssays(String queryText) async {
    final response = await _apiService.client.post(
      '/ai/sample',
      data: {
        'query_text': queryText,
      },
    );
    return response.data;
  }
}
