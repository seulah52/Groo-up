class MessageEntity {
  final String id;
  final String sessionId;
  final String role;    // 'user' | 'assistant'
  final String content;
  final DateTime createdAt;

  const MessageEntity({
    required this.id, required this.sessionId,
    required this.role, required this.content, required this.createdAt,
  });
}
