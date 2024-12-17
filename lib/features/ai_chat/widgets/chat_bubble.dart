import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onRecommendationTap;

  const ChatBubble({
    super.key,
    required this.message,
    required this.onRecommendationTap,
  });

  Widget _buildMessageContent(String content) {
    final lines = content.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.map((line) {
        // ブロック数式の検出 (\[...\] または $$...$$)
        if ((line.trim().startsWith(r'\[') && line.trim().endsWith(r'\]')) ||
            (line.trim().startsWith(r'\$\$') && line.trim().endsWith(r'\$\$'))) {
          final texContent = line.trim()
              .replaceAll(r'\$\$', r'\[')
              .replaceAll(r'\$\$', r'\]');
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Math.tex(
              texContent,
              textStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
              ),
              onErrorFallback: (error) => Text(
                line.trim(),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[800],
                  height: 1.5,
                ),
              ),
            ),
          );
        }
        // インライン数式の検出 (\(...\) または \$...\$)
        else if ((line.contains(r'\(') && line.contains(r'\)')) ||
            (line.contains(r'\$') && line.substring(line.indexOf(r'\$') + 1).contains(r'\$'))) {
          final parts = line.split(RegExp(r'(\\\(.*?\\\)|\\\$.*?\\\$)'));
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Wrap(
              children: parts.map((part) {
                if ((part.startsWith(r'\(') && part.endsWith(r'\)')) ||
                    (part.startsWith(r'\$') && part.endsWith(r'\$'))) {
                  final texContent = part
                      .replaceAll(r'\(', '')
                      .replaceAll(r'\)', '')
                      .replaceAll(r'\$', '');
                  return Math.tex(
                    texContent,
                    textStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                    onErrorFallback: (error) => Text(
                      part,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[800],
                        height: 1.5,
                      ),
                    ),
                  );
                } else {
                  return Text(
                    part,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  );
                }
              }).toList(),
            ),
          );
        }
        // 通常のテキスト
        else {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Text(
              line,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          );
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!message.isUser) ...[
                CircleAvatar(
                  backgroundColor: Colors.purple[100],
                  child: const Icon(
                    Icons.school,
                    color: Colors.purple,
                    size: 20,
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
                  child: _buildMessageContent(message.content),
                ),
              ),
              if (message.isUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.grey[200],
                  child: const Icon(
                    Icons.person,
                    color: Colors.grey,
                    size: 20,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (!message.isUser && message.recommendations.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(
              left: message.isUser ? 0 : 48,
              top: 8,
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: message.recommendations.map((recommendation) {
                return InkWell(
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
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}