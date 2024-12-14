// lib/features/shared_wisdom/screens/wisdom_screen.dart
import 'package:flutter/material.dart';
import '../models/wisdom_post.dart';
import '../widgets/wisdom_list.dart';
import '../services/wisdom_service.dart';

enum SortOption {
  none,
  likeCount,
  createdAt,
}

class WisdomScreen extends StatefulWidget {
  const WisdomScreen({super.key});

  @override
  _WisdomScreenState createState() => _WisdomScreenState();
}

class _WisdomScreenState extends State<WisdomScreen> with AutomaticKeepAliveClientMixin {
  final WisdomService _service = WisdomService();
  List<WisdomPost> _posts = [];
  List<WisdomPost> _filteredPosts = []; // フィルタ後の投稿一覧
  bool _isLoading = true;
  String _errorMessage = '';
  final TextEditingController _searchController = TextEditingController();

  final Set<int> _bookmarkedPostIds = {};
  SortOption _currentSortOption = SortOption.none;
  bool _showBookmarkedOnly = false;

  @override
  bool get wantKeepAlive => true; // 状態保持

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _searchController.addListener(() {
      _applyFiltersAndSorting();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final posts = await _service.getPublicConversations();
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _filteredPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'エラーが発生しました: $e';
        _isLoading = false;
      });
    }
  }

  void _applyFiltersAndSorting() {
    List<WisdomPost> updatedList = [..._posts];

    final query = _searchController.text.toLowerCase();
    if (query.isNotEmpty) {
      updatedList = updatedList.where((post) => post.title.toLowerCase().contains(query)).toList();
    }

    if (_showBookmarkedOnly) {
      updatedList = updatedList.where((post) => _bookmarkedPostIds.contains(post.id)).toList();
    }

    if (_currentSortOption == SortOption.likeCount) {
      updatedList.sort((a, b) => b.likeCount.compareTo(a.likeCount));
    } else if (_currentSortOption == SortOption.createdAt) {
      updatedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    setState(() {
      _filteredPosts = updatedList;
    });
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _currentSortOption = SortOption.none;
      _showBookmarkedOnly = false;
    });
    _applyFiltersAndSorting();
  }

  void _toggleBookmarkFilter() {
    setState(() {
      _showBookmarkedOnly = !_showBookmarkedOnly;
    });
    _applyFiltersAndSorting();
  }

  void _onBookmarkToggle(WisdomPost post) {
    setState(() {
      if (_bookmarkedPostIds.contains(post.id)) {
        _bookmarkedPostIds.remove(post.id);
      } else {
        _bookmarkedPostIds.add(post.id);
      }
    });
    _applyFiltersAndSorting();
  }

  Future<void> _showUnitMenu(BuildContext context) async {
    await showMenu<String>(
      context: context,
      position: const RelativeRect.fromLTRB(200, 200, 0, 0),
      items: const [
        PopupMenuItem(value: '力学', child: Text('力学')),
        PopupMenuItem(value: '波動', child: Text('波動')),
        PopupMenuItem(value: '電磁気', child: Text('電磁気')),
        PopupMenuItem(value: '熱力学', child: Text('熱力学')),
        PopupMenuItem(value: '原子', child: Text('原子')),
      ],
    );
    // 選択結果を変数に受け取っても、今回は特にアクションは行いません。
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin使用時は必要

    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('掲示板'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadPosts,
                child: const Text('再試行'),
              ),
            ],
          ),
        ),
      );
    }

    if (_posts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('掲示板'),
        ),
        body: const Center(
          child: Text('投稿がありません'),
        ),
      );
    }

    final customColor = const Color(0xFF635690);
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(80, 28),
      side: BorderSide(color: customColor),
      foregroundColor: customColor,
      textStyle: const TextStyle(fontSize: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'タイトルで検索',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.grey[300],
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      style: buttonStyle,
                      onPressed: _resetFilters,
                      child: const Text('すべての投稿'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: buttonStyle,
                      onPressed: () => _showUnitMenu(context), // 単元ボタン
                      child: const Text('単元'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: buttonStyle,
                      onPressed: _toggleBookmarkFilter,
                      child: Text(_showBookmarkedOnly ? 'お気に入り☆解除' : 'お気に入り☆'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      style: buttonStyle,
                      onPressed: () async {
                        final selected = await showMenu<SortOption>(
                          context: context,
                          position: const RelativeRect.fromLTRB(200, 200, 0, 0),
                          items: const [
                            PopupMenuItem(
                              value: SortOption.likeCount,
                              child: Text('いいね数の多い順'),
                            ),
                            PopupMenuItem(
                              value: SortOption.createdAt,
                              child: Text('投稿日時の新しい順'),
                            ),
                          ],
                        );
                        if (selected != null) {
                          setState(() {
                            _currentSortOption = selected;
                          });
                          _applyFiltersAndSorting();
                        }
                      },
                      child: const Text('並べ替え'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: WisdomList(
          posts: _filteredPosts,
          bookmarkedPostIds: _bookmarkedPostIds,
          onPostTap: (post) {
            print('Tapped post: ${post.title}');
          },
          onBookmarkToggle: _onBookmarkToggle,
        ),
      ),
    );
  }
}