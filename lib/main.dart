import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/themes/app_theme.dart';
import 'features/text_viewer/services/material_service.dart';
import 'features/text_viewer/models/material.dart';
import 'features/text_viewer/screens/text_screen.dart';
import 'features/ai_chat/screens/chat_screen.dart';
import 'features/shared_wisdom/screens/wisdom_screen.dart';
import 'shared/widgets/custom_app_bar.dart';
import 'shared/widgets/custom_bottom_navigation.dart';
import 'shared/widgets/video_player_widget.dart';
import 'shared/widgets/custom_drawer.dart';
import 'shared/widgets/custom_tab_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appTitle,
      theme: AppTheme.lightTheme,
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedIndex = 0;
  final MaterialService _materialService = MaterialService();
  LessonMaterial? _currentVideo;
  List<LessonMaterial>? _currentPdfs;
  bool _isLoading = true;
  bool _hasError = false;
  bool _videoInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadDefaultMaterials();
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _loadDefaultMaterials() async {
    await _loadMaterialsByUnit(1);
  }

  Future<void> _loadMaterialsByUnit(int unitId) async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final materials = await _materialService.getMaterialsByUnit(unitId);
      if (!mounted) return;
      setState(() {
        if (!_videoInitialized) {
          _currentVideo = materials['video'];
          _videoInitialized = true;
        }
        _currentPdfs = materials['pdfs'];
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('教材の読み込みに失敗しました'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _tabController.index != 1
          ? CustomDrawer(
        onUnitSelected: _loadMaterialsByUnit,
        currentUnitId: _currentVideo?.unitId ?? 1,
      )
          : null,
      appBar: CustomAppBar(
        materialTitle: _currentVideo?.title ?? "教材",
        unitName: _currentVideo != null
            ? "第${_currentVideo!.unitId}章 物体の位置、速度、加速度"
            : "物理",
      ),
      body: Column(
        children: [
          CustomTabBar(controller: _tabController),

          if (_tabController.index == 0) ...[
            if (_isLoading)
              const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
                  ),
                ),
              )
            else if (_currentVideo != null)
              VideoPlayerWidget(videoUrl: _currentVideo!.blobUrl)
            else
              const SizedBox(
                height: 200,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 40, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        '動画を読み込めませんでした',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
          ],

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                TextScreen(
                  key: const PageStorageKey('TextScreenKey'),
                  pdfMaterials: _currentPdfs,
                  onRetry: () => _loadMaterialsByUnit(_currentVideo?.unitId ?? 1),
                ),
                ChatScreen(key: const PageStorageKey('ChatScreenKey')),
                WisdomScreen(key: const PageStorageKey('WisdomScreenKey')),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}