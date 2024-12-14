class WisdomPost {
  final int id;
  final int conversationId;
  final String title;
  final String? summary;
  final int userId;
  final String username;
  final bool understandingFlag;
  final DateTime createdAt;
  final int viewCount;
  final int likeCount;
  final int bookmarkCount;
  final bool isPinned;
  final bool isPublic;
  final bool isToTeacher;
  bool isBookmarked;  // 追加

  WisdomPost({
    required this.id,
    required this.conversationId,
    required this.title,
    this.summary,
    required this.userId,
    required this.username,
    required this.understandingFlag,
    required this.createdAt,
    this.viewCount = 0,
    this.likeCount = 0,
    this.bookmarkCount = 0,
    required this.isPinned,
    required this.isPublic,
    required this.isToTeacher,
    this.isBookmarked = false,  // デフォルトはfalse
  });

  // 既存のfromJsonメソッドに追加
  factory WisdomPost.fromJson(Map<String, dynamic> json) {
    return WisdomPost(
      id: json['conversation_id'],
      conversationId: json['conversation_id'],
      title: json['title'],
      summary: json['summary'],
      userId: json['user_id'],
      username: json['username'],
      understandingFlag: json['understanding_flag'] == 1,
      createdAt: DateTime.parse(json['created_at']),
      viewCount: json['view_count'] ?? 0,
      likeCount: json['like_count'] ?? 0,
      bookmarkCount: json['bookmark_count'] ?? 0,
      isPinned: json['is_pinned'] == 1,
      isPublic: json['is_public'] == 1,
      isToTeacher: json['is_to_teacher'] == 1,
      isBookmarked: false,  // デフォルトはfalse
    );
  }

  // 状態を更新するためのコピーメソッド
  WisdomPost copyWith({bool? isBookmarked}) {
    return WisdomPost(
      id: id,
      conversationId: conversationId,
      title: title,
      summary: summary,
      userId: userId,
      username: username,
      understandingFlag: understandingFlag,
      createdAt: createdAt,
      viewCount: viewCount,
      likeCount: likeCount,
      bookmarkCount: bookmarkCount,
      isPinned: isPinned,
      isPublic: isPublic,
      isToTeacher: isToTeacher,
      isBookmarked: isBookmarked ?? this.isBookmarked,
    );
  }
}