// lib/shared/widgets/custom_app_bar.dart
import 'package:flutter/material.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? materialTitle;
  final String? unitName;

  const CustomAppBar({
    super.key,
    this.materialTitle,
    this.unitName,
  });

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _CustomAppBarState extends State<CustomAppBar> {
  bool _isBookmarked = false; // ブックマーク状態を管理

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu,
            color: Colors.black87,
          ),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.unitName ?? "第1章 物体の位置、速度、加速度",
            style: const TextStyle(
              fontSize: 13,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.materialTitle ?? "1. 変位、速度、加速度、等加速度",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            // _isBookmarkedがtrueならIcons.bookmarkを赤色で、
            // falseならIcons.bookmark_borderを紫色で表示
            _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: _isBookmarked ? const Color(0xFFBA1A1A) : Color(0xFFBA1A1A),
          ),
          onPressed: () {
            setState(() {
              _isBookmarked = !_isBookmarked;
            });
          },
        ),
      ],
    );
  }
}