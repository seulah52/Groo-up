import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/openai_chat_service.dart';

final openAiChatServiceProvider = Provider<OpenAiChatService>(
  (ref) => OpenAiChatService(),
);
