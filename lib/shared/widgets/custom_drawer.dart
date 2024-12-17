// lib/shared/widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// 既存のモデルをインポート
import '../../features/text_viewer/models/material.dart';
import '../../features/text_viewer/services/material_service.dart';

class CustomDrawer extends StatefulWidget {
  final Function(int) onUnitSelected;
  final int currentUnitId;

  const CustomDrawer({
    Key? key,
    required this.onUnitSelected,
    required this.currentUnitId,
  }) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final MaterialService _materialService = MaterialService();
  List<LessonMaterial>? _materials;
  bool _isLoading = true;

  // unitIdごとに状態を保持するための静的マップ
  static final Map<int, Map<String, List<bool>>> _statesPerUnit = {};

  List<bool> _isCheckedList = [];
  List<bool> _isBookmarkedList = [];

  @override
  void initState() {
    super.initState();
    _loadMaterials();
  }

  Future<void> _loadMaterials() async {
    try {
      final materialsData = await _materialService.getMaterialsByUnit(widget.currentUnitId);
      setState(() {
        if (materialsData['pdfs'] is List<LessonMaterial>) {
          _materials = materialsData['pdfs'];

          // すでにこのunitIdに対する状態が保存されていれば復元
          if (_statesPerUnit.containsKey(widget.currentUnitId)) {
            _isCheckedList = List<bool>.from(_statesPerUnit[widget.currentUnitId]!['checked']!);
            _isBookmarkedList = List<bool>.from(_statesPerUnit[widget.currentUnitId]!['bookmarked']!);
          } else {
            // 初回: 全てfalseで初期化
            _isCheckedList = List<bool>.filled(_materials!.length, false);
            _isBookmarkedList = List<bool>.filled(_materials!.length, false);
          }
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('教材の読み込みに失敗しました')),
        );
      }
    }
  }

  // 状態を保存するメソッド
  void _saveStates() {
    if (_materials != null) {
      _statesPerUnit[widget.currentUnitId] = {
        'checked': List<bool>.from(_isCheckedList),
        'bookmarked': List<bool>.from(_isBookmarkedList),
      };
    }
  }

  String _formatDate(DateTime date) {
    final formatter = DateFormat('HH:mm');
    return formatter.format(date);
  }

  @override
  Widget build(BuildContext context) {
    // 既存の教材数に追加アイテム2つを加える
    int additionalItemsCount = 2;
    int totalItemCount = (_materials?.length ?? 0) + additionalItemsCount;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8, // 幅を画面の80%に拡大
      child: SafeArea(
        child: Column(
          children: [
            // ヘッダー
            Container(
              color: const Color(0xFFFFFFFF),
              height: 56,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      // Drawerを閉じる前に状態を保存
                      _saveStates();
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '講義一覧',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(
              color: Color(0xFFD9D9D9),
              thickness: 1,
              height: 1,
            ),
            // コンテンツ部分
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : _materials == null || _materials!.isEmpty
                  ? const Center(
                child: Text('教材が見つかりません'),
              )
                  : ListView.separated(
                padding: const EdgeInsets.all(16.0),
                itemCount: totalItemCount,
                itemBuilder: (context, index) {
                  if (index < (_materials?.length ?? 0)) {
                    // 既存の教材リストアイテム
                    return ListTile(
                      leading: SizedBox(
                        width: 32,
                        height: 32,
                        child: Transform.scale(
                          scale: 1.5,
                          child: Checkbox(
                            shape: const CircleBorder(),
                            value: _isCheckedList[index],
                            onChanged: (bool? value) {
                              setState(() {
                                _isCheckedList[index] = value ?? false;
                                _saveStates();
                              });
                            },
                            checkColor: Colors.white,
                            activeColor: const Color(0xFF635690),
                          ),
                        ),
                      ),
                      title: const Text(
                        "1. 変位、速度、加速度...", // タイトルを固定
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        "20:44", // サブタイトルを固定
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isBookmarkedList[index] ? Icons.bookmark : Icons.bookmark_border,
                            color: _isBookmarkedList[index] ? const Color(0xFFBA1A1A) : Color(0xFFBA1A1A), // 色の設定
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _isBookmarkedList[index] = !_isBookmarkedList[index];
                              _saveStates(); // 状態を保存
                            });
                          },
                        ),
                      ),
                      onTap: () {
                        _saveStates();
                        Navigator.pop(context);
                      },
                    );
                  } else if (index == (_materials?.length ?? 0)) {
                    // 追加アイテム1
                    return ListTile(
                      leading: SizedBox(
                        width: 32,
                        height: 32,
                        child: Transform.scale(
                          scale: 1.5,
                          child: Checkbox(
                            shape: const CircleBorder(),
                            value: false, // 必要に応じて状態管理を追加
                            onChanged: (bool? value) {
                              setState(() {
                                // 必要に応じて状態を更新
                              });
                            },
                            checkColor: Colors.white,
                            activeColor: const Color(0xFF635690),
                          ),
                        ),
                      ),
                      title: const Text(
                        "2. 自由落下、鉛直投射", // 追加アイテム1のタイトル
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        "14:47", // 追加アイテム1のサブタイトル
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.bookmark_border,
                            color: Color(0xFFBA1A1A),
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              // 必要に応じてブックマーク状態を管理
                            });
                          },
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    );
                  } else if (index == (_materials?.length ?? 0) + 1) {
                    // 追加アイテム2
                    return ListTile(
                      leading: SizedBox(
                        width: 32,
                        height: 32,
                        child: Transform.scale(
                          scale: 1.5,
                          child: Checkbox(
                            shape: const CircleBorder(),
                            value: false, // 必要に応じて状態管理を追加
                            onChanged: (bool? value) {
                              setState(() {
                                // 必要に応じて状態を更新
                              });
                            },
                            checkColor: Colors.white,
                            activeColor: const Color(0xFF635690),
                          ),
                        ),
                      ),
                      title: const Text(
                        "確認テスト", // 追加アイテム2のタイトル
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text(
                        "全3問", // 追加アイテム2のサブタイトル
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.bookmark_border,
                            color: Color(0xFFBA1A1A),
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              // 必要に応じてブックマーク状態を管理
                            });
                          },
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(context);
                      },
                    );
                  } else {
                    // 予期しないインデックスの場合
                    return const SizedBox.shrink();
                  }
                },
                separatorBuilder: (context, index) => const Divider(
                  color: Color(0xFFD9D9D9),
                  thickness: 1,
                  height: 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}