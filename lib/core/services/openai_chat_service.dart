import 'package:dio/dio.dart';
import '../config/app_config.dart';

/// OpenAI Chat Completions 호출 (키 없으면 [isAvailable] false)
class OpenAiChatService {
  OpenAiChatService({Dio? dio}) : _dio = dio ?? Dio();

  final Dio _dio;

  static bool get isAvailable => AppConfig.hasOpenAiConfig;

  /// 대화 메시지(role: user|assistant|system) 기반 한 번의 응답 텍스트
  Future<String> completeChat(List<Map<String, String>> messages) async {
    if (!isAvailable) {
      throw StateError('OPENAI_API_KEY 가 설정되지 않았습니다.');
    }
    final response = await _dio.post<Map<String, dynamic>>(
      'https://api.openai.com/v1/chat/completions',
      options: Options(
        headers: <String, dynamic>{
          'Authorization': 'Bearer ${AppConfig.resolvedOpenAiApiKey}',
          'Content-Type': 'application/json',
        },
      ),
      data: <String, dynamic>{
        'model': 'gpt-4o-mini',
        'messages': messages,
        'max_tokens': 512,
        'temperature': 0.7,
      },
    );
    final body = response.data;
    if (body == null) {
      throw StateError('OpenAI 응답 본문이 비어 있습니다.');
    }
    final choices = body['choices'];
    if (choices is! List || choices.isEmpty) {
      throw StateError('OpenAI choices 가 없습니다.');
    }
    final first = choices.first;
    if (first is! Map<String, dynamic>) {
      throw StateError('OpenAI choice 형식이 올바르지 않습니다.');
    }
    final message = first['message'];
    if (message is! Map<String, dynamic>) {
      throw StateError('OpenAI message 형식이 올바르지 않습니다.');
    }
    final content = message['content'];
    if (content is! String || content.isEmpty) {
      throw StateError('OpenAI 응답 텍스트가 비어 있습니다.');
    }
    return content.trim();
  }
}
