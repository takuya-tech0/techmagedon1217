import 'package:flutter/material.dart';
import '../models/wisdom_post.dart';
import '../services/wisdom_service.dart';
import '../screens/conversation_detail_screen.dart';
import 'package:timeago/timeago.dart' as timeago;

class WisdomList extends StatefulWidget {
  final List<WisdomPost> posts;
  final Function(WisdomPost) onPostTap;
  final Set<int> bookmarkedPostIds;
  final Function(WisdomPost) onBookmarkToggle;

  const WisdomList({
    super.key,
    required this.posts,
    required this.onPostTap,
    required this.bookmarkedPostIds,
    required this.onBookmarkToggle,
  });

  @override
  State<WisdomList> createState() => _WisdomListState();
}

class _WisdomListState extends State<WisdomList> {
  final WisdomService _service = WisdomService();

  String _getTimeAgo(DateTime dateTime) {
    timeago.setLocaleMessages('ja', timeago.JaMessages());
    return timeago.format(dateTime, locale: 'ja');
  }

  Future<void> _handleLikeTap(WisdomPost post) async {
    const userId = 1;
    final success = await _service.toggleLike(post.conversationId, userId);
    if (success && mounted) {
      setState(() {
        final index = widget.posts.indexOf(post);
        if (index != -1) {
          widget.posts[index] = WisdomPost(
            id: post.id,
            conversationId: post.conversationId,
            title: post.title,
            summary: post.summary,
            userId: post.userId,
            username: post.username,
            understandingFlag: post.understandingFlag,
            createdAt: post.createdAt,
            viewCount: post.viewCount,
            likeCount: post.likeCount + 1,
            bookmarkCount: post.bookmarkCount,
            isPinned: post.isPinned,
            isPublic: post.isPublic,
            isToTeacher: post.isToTeacher,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: widget.posts.length,
      itemBuilder: (context, index) {
        final post = widget.posts[index];
        final isBookmarked = widget.bookmarkedPostIds.contains(post.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '@${post.username}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getTimeAgo(post.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            subtitle: Row(
              children: [
                InkWell(
                  onTap: () => _handleLikeTap(post),
                  child: const Icon(
                    Icons.favorite,
                    size: 16,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${post.likeCount}',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
            trailing: InkWell(
              onTap: () => widget.onBookmarkToggle(post),
              child: Icon(
                isBookmarked ? Icons.star : Icons.star_border,
                color: isBookmarked ? Colors.amber : Colors.grey[400],
                size: 24,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConversationDetailScreen(
                    conversationId: post.conversationId,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}