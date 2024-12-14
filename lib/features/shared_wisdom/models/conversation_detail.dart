class ConversationDetail {
  final int conversationId;
  final String title;
  final String? summary;
  final int userId;
  final String username;
  final DateTime createdAt;
  final int viewCount;
  final int likeCount;
  final int bookmarkCount;
  final List<Message> messages;

  ConversationDetail({
    required this.conversationId,
    required this.title,
    this.summary,
    required this.userId,
    required this.username,
    required this.createdAt,
    required this.viewCount,
    required this.likeCount,
    required this.bookmarkCount,
    required this.messages,
  });

  factory ConversationDetail.fromJson(Map<String, dynamic> json) {
    return ConversationDetail(
      conversationId: json['conversation']['conversation_id'],
      title: json['conversation']['title'],
      summary: json['conversation']['summary'],
      userId: json['conversation']['user_id'],
      username: json['conversation']['username'],
      createdAt: DateTime.parse(json['conversation']['created_at']),
      viewCount: json['conversation']['view_count'],
      likeCount: json['conversation']['like_count'],
      bookmarkCount: json['conversation']['bookmark_count'],
      messages: (json['messages'] as List)
          .map((msg) => Message.fromJson(msg))
          .toList(),
    );
  }
}

class Message {
  final int messageId;
  final String content;
  final String role;
  final DateTime createdAt;

  Message({
    required this.messageId,
    required this.content,
    required this.role,
    required this.createdAt,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      messageId: json['message_id'],
      content: json['content'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}