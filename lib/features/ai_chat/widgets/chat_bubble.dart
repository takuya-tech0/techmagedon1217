// lib/features/ai_chat/widgets/chat_bubble.dart
import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onRecommendationTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onRecommendationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: message.isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: CircleAvatar(
                    backgroundColor: Colors.purple[100],
                    child: const Icon(
                      Icons.smart_toy,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? Colors.purple[50]
                        : const Color(0xFFFFE4E8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    message.content,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),
              if (message.isUser) ...[],
            ],
          ),
        ),
        if (!message.isUser && message.recommendations.isNotEmpty)
          Align(
            // 親要素で右寄せ
            alignment: Alignment.centerRight, // Columnを右側に配置
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end, // 子要素を右寄せ
              children: message.recommendations.map((recommendation) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0), // 上下の余白
                  child: InkWell(
                    onTap: () => onRecommendationTap(recommendation),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.purple.shade200),
                      ),
                      child: Text(
                        recommendation,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}
