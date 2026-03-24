import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/openai_chat_service.dart';
import '../providers/openai_chat_provider.dart';

class InterviewScreen extends ConsumerStatefulWidget {
  const InterviewScreen({super.key, required this.grooId});

  final String grooId;

  @override
  ConsumerState<InterviewScreen> createState() => _InterviewScreenState();
}

class _InterviewScreenState extends ConsumerState<InterviewScreen> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <Map<String, String>>[];
  bool _isTyping = false;

  String get _systemPrompt => '''
당신은 Groo-up 앱의 "그루" 코치입니다. 사용자의 아이디어(씨앗)를 나무로 키우는 여정을 돕습니다.
(세션 아이디어 참조 id: ${widget.grooId})
한국어로 짧고 따뜻하게 답하세요. 한 번에 2~4문장 정도로, 질문 하나를 포함해 대화를 이어가세요.
사용자가 구체적이지 않으면, 목표·대상·차별점을 물어보세요.''';

  @override
  void dispose() {
    _controller.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('그루와 대화'),
        actions: [
          if (!OpenAiChatService.isAvailable)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '데모 응답',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (_, i) {
                if (i == _messages.length) {
                  return const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text('그루가 생각 중...', style: TextStyle(color: Colors.grey)),
                  );
                }
                final msg = _messages[i];
                final isUser = msg['role'] == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['content'] ?? '',
                      style: TextStyle(color: isUser ? Colors.white : null),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isTyping ? null : _send,
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    _controller.clear();
    setState(() {
      _messages.add({'role': 'user', 'content': text});
      _isTyping = true;
    });
    _scrollToEnd();

    String reply;
    if (OpenAiChatService.isAvailable) {
      try {
        final svc = ref.read(openAiChatServiceProvider);
        final apiMessages = <Map<String, String>>[
          {'role': 'system', 'content': _systemPrompt},
          ..._messages.map((m) => {'role': m['role']!, 'content': m['content']!}),
        ];
        reply = await svc.completeChat(apiMessages);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI 응답 실패: $e')),
          );
        }
        reply = '지금은 연결이 불안정해요. 흥미로운 아이디어네요! 목표를 한 줄로 말해줄 수 있을까요?';
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      reply = '흥미로운 아이디어네요! 누구를 위한 것인지, 그리고 지금 가장 막히는 지점이 무엇인가요?';
    }

    if (!mounted) return;
    setState(() {
      _messages.add({'role': 'assistant', 'content': reply});
      _isTyping = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }
}
