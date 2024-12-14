// lib/shared/widgets/custom_drawer.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../features/text_viewer/models/material.dart';
import '../../features/text_viewer/services/material_service.dart';

class CustomDrawer extends StatefulWidget {
  final Function(int) onUnitSelected;
  final int currentUnitId;

  const CustomDrawer({
    super.key,
    required this.onUnitSelected,
    required this.currentUnitId,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  final MaterialService _materialService = MaterialService();
  List<LessonMaterial>? _materials;
  bool _isLoading = true;

  // unitIdごとに状態を保持するための静的マップ
  // unitIdをキーに、{"checked": List<bool>, "bookmarked": List<bool>}のマップを保存
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

  void _saveStates() {
    // 現在の状態を保存
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
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.8, // 幅を画面の80%に拡大
      child: SafeArea(
        child: Column(
          children: [
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
            if (_isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_materials == null || _materials!.isEmpty)
              const Expanded(
                child: Center(
                  child: Text('教材が見つかりません'),
                ),
              )
            else
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _materials!.length,
                  itemBuilder: (context, index) {
                    final material = _materials![index];

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
                                _saveStates(); // 状態変更時に都度保存
                              });
                            },
                            checkColor: Colors.white,
                            activeColor: const Color(0xFF635690),
                          ),
                        ),
                      ),
                      title: Text(
                        material.title,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        _formatDate(material.createdAt),
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: SizedBox(
                        width: 32,
                        height: 32,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            _isBookmarkedList[index] ? Icons.bookmark : Icons.bookmark_border,
                            color: const Color(0xFFBA1A1A),
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _isBookmarkedList[index] = !_isBookmarkedList[index];
                              _saveStates(); // 状態変更時に保存
                            });
                          },
                        ),
                      ),
                      onTap: () {
                        widget.onUnitSelected(material.unitId);
                        _saveStates();
                        Navigator.pop(context);
                      },
                    );
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