import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/openai_chat_service.dart';
import '../../../garden/domain/entities/groo_entity.dart';
import '../../../garden/presentation/providers/garden_provider.dart';
import '../providers/interview_groo_provider.dart';
import '../providers/openai_chat_provider.dart';

class InterviewScreen extends ConsumerWidget {
  const InterviewScreen({super.key, required this.grooId});

  final String grooId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grooAsync = ref.watch(interviewGrooProvider(grooId));
    return grooAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('그루와 대화')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: const Text('그루와 대화')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              '아이디어를 불러오지 못했습니다.\n$e',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (groo) => _InterviewChatView(groo: groo),
    );
  }
}

class _InterviewChatView extends ConsumerStatefulWidget {
  const _InterviewChatView({required this.groo});

  final GrooEntity groo;

  @override
  ConsumerState<_InterviewChatView> createState() => _InterviewChatViewState();
}

class _InterviewChatViewState extends ConsumerState<_InterviewChatView> {
  final _controller = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _messages = <Map<String, String>>[];
  bool _isTyping = false;
  late GrooEntity _currentGroo;

  @override
  void initState() {
    super.initState();
    _currentGroo = widget.groo;
  }

  String _systemPromptForGroo() {
    final g = _currentGroo;
    return AiService.buildInterviewSystemPrompt(
      grooId: g.id,
      ideaContent: AiService.buildIdeaContent(g),
      category: g.category,
      growthStageLabel: '${g.growthStage.name} (${g.growthStage.label})',
    );
  }

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
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Center(
              child: Text(
                '완성도 ${_currentGroo.completionRate}%',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_currentGroo.completionRate.clamp(0, 100)) / 100,
                      minHeight: 8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  onPressed: _currentGroo.completionRate >= 100
                      ? () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('사업 제안서 생성 기능은 다음 단계에서 연결됩니다.'),
                            ),
                          );
                        }
                      : null,
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('사업 제안서 생성'),
                ),
              ],
            ),
          ),
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
        final apiMessages = AiService.buildChatMessages(
          systemPrompt: _systemPromptForGroo(),
          history: _messages
              .map((m) => {'role': m['role']!, 'content': m['content']!})
              .toList(),
        );
        reply = await svc.completeChat(apiMessages);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI 응답 실패: $e')),
          );
        }
        reply = AiService.buildOfflineAssistantReply(
          groo: _currentGroo,
          lastUserMessage: text,
        );
      }
    } else {
      await Future<void>.delayed(const Duration(milliseconds: 600));
      reply = AiService.buildOfflineAssistantReply(
        groo: _currentGroo,
        lastUserMessage: text,
      );
    }

    final completionRate = AiService.calculateCompletionRate(
      groo: _currentGroo,
      history: _messages,
    );
    final updateResult = await ref
        .read(gardenRepositoryProvider)
        .updateCompletionRate(_currentGroo.id, completionRate);
    updateResult.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('완성도 업데이트 실패: ${failure.message}')),
          );
        }
      },
      (updatedGroo) {
        _currentGroo = updatedGroo;
      },
    );
    ref.invalidate(interviewGrooProvider(_currentGroo.id));
    ref.invalidate(gardenNotifierProvider);

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
