import 'package:flutter/material.dart';
import '../models/conversation_detail.dart';
import '../services/wisdom_service.dart';
import 'package:timeago/timeago.dart' as timeago; // 時間表記用。ここではUI例示なので使わなくても良いですが残しています。

class ConversationDetailScreen extends StatefulWidget {
  final int conversationId;

  const ConversationDetailScreen({
    super.key,
    required this.conversationId,
  });

  @override
  State<ConversationDetailScreen> createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  final WisdomService _service = WisdomService();
  ConversationDetail? _detail;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadConversationDetail();
    // 日本語の相対時間表示セット(必要なければ不要)
    timeago.setLocaleMessages('ja', timeago.JaMessages());
  }

  Future<void> _loadConversationDetail() async {
    try {
      final detail = await _service.getConversationDetail(widget.conversationId);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'データの読み込みに失敗しました';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildMessageItem(Message message) {
    final isAI = message.role == 'ai';

    return Row(
      mainAxisAlignment: isAI ? MainAxisAlignment.start : MainAxisAlignment.end,
      children: [
        if (isAI)
          Container(
            margin: const EdgeInsets.only(right: 8),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.purple[100],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.school,
              color: Colors.white,
              size: 20,
            ),
          ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isAI ? Colors.purple[50] : Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              message.content,
              style: TextStyle(
                color: Colors.grey[800],
              ),
            ),
          ),
        ),
        if (!isAI)
          Container(
            margin: const EdgeInsets.only(left: 8),
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 20,
            ),
          ),
      ],
    );
  }

  // コメント表示用のUIパーツ（ダミー）
  Widget _buildCommentItem({
    required String username,
    required String timeAgo,
    required String content,
    required int likeCount,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // アイコン部分（ダミーユーザーアイコン）
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.grey,
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          // コメント本文エリア
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ユーザー名と時間
                Row(
                  children: [
                    Text(
                      '@$username',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timeAgo,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(content),
                const SizedBox(height: 4),
                Row(
                  children: [
                    InkWell(
                      onTap: () {
                        // UIのみ。いいね処理はなし
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.favorite_border,
                            size: 16,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$likeCount',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        // UIのみ。返信処理はなし
                      },
                      child: Row(
                        children: const [
                          Icon(
                            Icons.reply,
                            size: 16,
                            color: Colors.grey,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '返信',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadConversationDetail,
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    if (_detail == null) {
      return const Scaffold(
        body: Center(
          child: Text('会話が見つかりませんでした'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_detail!.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 会話の基本情報
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Row(
              children: [
                Text(
                  '@${_detail!.username}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite,
                  size: 16,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '${_detail!.likeCount}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // 要約セクション
          if (_detail!.summary != null) ...[
            const SizedBox(height: 16),
            const Text(
              '要約',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(_detail!.summary!),
          ],

          // メッセージ履歴
          const SizedBox(height: 24),
          const Text(
            '対話履歴',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...(_detail!.messages.map((message) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: _buildMessageItem(message),
          ))),

          // コメント欄（ダミー）
          const SizedBox(height: 24),
          const Text(
            'コメント',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // ダミーコメントを２、３個表示
          _buildCommentItem(
            username: '鈴木 一郎',
            timeAgo: '5分前',
            content: '質問のやりとりがとても参考になりました！',
            likeCount: 3,
          ),
          _buildCommentItem(
            username: '山田 太郎',
            timeAgo: '10分前',
            content: '〇〇の公式の導出がわからなかったのですが、どうやりました？',
            likeCount: 10,
          ),
        ],
      ),
    );
  }
}