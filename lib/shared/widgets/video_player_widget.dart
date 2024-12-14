import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({
    super.key,
    required this.videoUrl,
  });

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> with AutomaticKeepAliveClientMixin {
  late VideoPlayerController _controller;
  bool _isPlaying = false;
  final bool _hideControls = false;

  @override
  bool get wantKeepAlive => true; // 状態保持を有効化

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    await _controller.initialize();
    // コントローラ初期化後、デフォルトで再生を開始したい場合は以下
    // _controller.play();
    // _isPlaying = true;
    setState(() {});
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _goFullScreen() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullScreenVideoPlayerPage(
          controller: _controller,
        ),
      ),
    );
    setState(() {});
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    // 状態保持する場合、ウィジェット破棄時にdisposeすると再生成時にまた読み込みが必要になる
    //もしアプリ要件上、画面から完全に離れたとき（Stateがdisposeされるとき）だけ終了したいならここでdispose可
    //だがタブ切り替え程度でdisposeさせないために、あえてdisposeしない設計もあり得ます。

    // super.dispose(); // 通常は呼ぶべきですが、コントローラを使い回したい場合はdisposeしないことも検討してください。
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // AutomaticKeepAliveClientMixin使用時には必要

    if (!_controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _togglePlayPause();
      },
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          ),
          if (!_hideControls)
            Positioned(
              bottom: 16.0,
              left: 16.0,
              right: 16.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                    ),
                    iconSize: 24,
                  ),
                  Expanded(
                    child: Slider(
                      value: _controller.value.position.inSeconds.toDouble(),
                      max: _controller.value.duration.inSeconds.toDouble(),
                      onChanged: (value) {
                        setState(() {
                          _controller.seekTo(Duration(seconds: value.toInt()));
                        });
                      },
                      activeColor: Colors.red,
                      inactiveColor: Colors.white24,
                    ),
                  ),
                  Text(
                    "${formatDuration(_controller.value.position)} / ${formatDuration(_controller.value.duration)}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  IconButton(
                    onPressed: _goFullScreen,
                    icon: const Icon(
                      Icons.fullscreen,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class FullScreenVideoPlayerPage extends StatefulWidget {
  final VideoPlayerController controller;

  const FullScreenVideoPlayerPage({
    super.key,
    required this.controller,
  });

  @override
  _FullScreenVideoPlayerPageState createState() => _FullScreenVideoPlayerPageState();
}

class _FullScreenVideoPlayerPageState extends State<FullScreenVideoPlayerPage> {
  late VideoPlayerController _controller;
  bool _hideControls = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _isPlaying = _controller.value.isPlaying;
    _controller.addListener(_videoListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_videoListener);
    super.dispose();
  }

  void _videoListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
      _isPlaying = !_isPlaying;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _hideControls = !_hideControls;
          });
        },
        child: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? GestureDetector(
                onTap: _togglePlayPause,
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              )
                  : const CircularProgressIndicator(),
            ),
            if (!_hideControls)
              Positioned(
                top: 40,
                left: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                ),
              ),
            if (_controller.value.isInitialized && !_hideControls)
              Positioned(
                bottom: 30,
                left: 20,
                right: 20,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(
                        _isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      formatDuration(_controller.value.position),
                      style: const TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: Slider(
                        value: _controller.value.position.inSeconds.toDouble(),
                        max: _controller.value.duration.inSeconds.toDouble(),
                        onChanged: (value) {
                          setState(() {
                            _controller.seekTo(Duration(seconds: value.toInt()));
                          });
                        },
                        activeColor: Colors.red,
                        inactiveColor: Colors.white54,
                      ),
                    ),
                    Text(
                      formatDuration(_controller.value.duration),
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.fullscreen_exit,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}