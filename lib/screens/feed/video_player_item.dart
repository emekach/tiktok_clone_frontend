// lib/screens/feed/video_player_item.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/models.dart';
import '../../utils/constants.dart';
import '../comments/comments_sheet.dart';

class VideoPlayerItem extends StatefulWidget {
  final VideoModel video;
  final bool isActive;
  final bool shouldLoad;
  final VoidCallback onLike;

  const VideoPlayerItem({
    super.key,
    required this.video,
    required this.isActive,
    this.shouldLoad = false,
    required this.onLike,
  });

  @override
  State<VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<VideoPlayerItem>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _initialized = false;
  bool _isError = false;
  bool _showHeart = false;
  late AnimationController _heartAnimCtrl;

  @override
  void initState() {
    super.initState();
    _heartAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    if (widget.isActive || widget.shouldLoad) {
      _initPlayer();
    }
  }

  @override
  void didUpdateWidget(VideoPlayerItem old) {
    super.didUpdateWidget(old);
    if ((widget.isActive || widget.shouldLoad) &&
        !_initialized &&
        _controller == null) {
      _initPlayer();
    }
    if (_initialized && _controller != null) {
      if (widget.isActive && !old.isActive) {
        _controller!.play();
      } else if (!widget.isActive && old.isActive) {
        _controller!.pause();
      }
    }
  }

  Future<void> _initPlayer() async {
    if (_controller != null) return;
    final url = widget.video.videoUrl;
    if (url.isEmpty) return;

    try {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(url),
        httpHeaders: AppConstants.apiHeaders,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      await _controller!.initialize();
      await _controller!.setLooping(true);

      if (mounted) {
        setState(() {
          _initialized = true;
          _isError = false;
        });
        if (widget.isActive) {
          _controller!.play();
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _heartAnimCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_controller != null && _initialized) {
          _controller!.value.isPlaying
              ? _controller!.pause()
              : _controller!.play();
          setState(() {});
        }
      },
      onDoubleTap: _onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_initialized && _controller != null)
            Center(
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: VideoPlayer(_controller!),
              ),
            ),
          if (!_initialized ||
              (_controller != null && !_controller!.value.isPlaying))
            _buildThumbnail(),
          _buildGradientOverlay(),
          if (_initialized &&
              _controller != null &&
              !_controller!.value.isPlaying &&
              !_isError)
            Center(
                child: Icon(Icons.play_arrow,
                    color: Colors.white.withOpacity(0.5), size: 80)),
          if (_showHeart) _buildHeartAnim(),
          _buildSidebar(),
          _buildBottomInfo(),
          if (_initialized && _controller != null) _buildProgressBar(),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    return widget.video.thumbnailUrl != null
        ? CachedNetworkImage(
            imageUrl: widget.video.thumbnailUrl!,
            httpHeaders: AppConstants.apiHeaders,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(color: Colors.black),
            fadeOutDuration: const Duration(milliseconds: 200),
            fadeInDuration: const Duration(milliseconds: 200),
          )
        : Container(color: Colors.black);
  }

  Widget _buildGradientOverlay() {
    return const Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black38,
              Colors.transparent,
              Colors.transparent,
              Colors.black54
            ],
            stops: [0.0, 0.2, 0.7, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: VideoProgressIndicator(
        _controller!,
        allowScrubbing: true,
        colors: const VideoProgressColors(
          playedColor: Colors.white,
          bufferedColor: Colors.white24,
          backgroundColor: Colors.transparent,
        ),
        padding: EdgeInsets.zero,
      ),
    );
  }

  void _onDoubleTap() {
    if (!widget.video.isLiked) widget.onLike();
    setState(() => _showHeart = true);
    _heartAnimCtrl.forward(from: 0).then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) setState(() => _showHeart = false);
      });
    });
  }

  Widget _buildHeartAnim() {
    return Center(
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.2).animate(
          CurvedAnimation(parent: _heartAnimCtrl, curve: Curves.elasticOut),
        ),
        child: const Icon(Icons.favorite, color: Color(0xFFFF0050), size: 100),
      ),
    );
  }

  Widget _buildSidebar() {
    return Positioned(
      right: 12,
      bottom: 100,
      child: Column(
        children: [
          _buildAvatar(),
          const SizedBox(height: 20),
          _ActionButton(
            icon: Icons.favorite,
            color:
                widget.video.isLiked ? const Color(0xFFFF0050) : Colors.white,
            label: _formatCount(widget.video.likesCount),
            onTap: widget.onLike,
          ),
          const SizedBox(height: 16),
          _ActionButton(
            icon: Icons.comment,
            label: _formatCount(widget.video.commentsCount),
            onTap: () => _showComments(context),
          ),
          const SizedBox(height: 16),
          _ActionButton(
            icon: Icons.share,
            label: 'Share',
            onTap: () => Share.share('Check out this video!'),
          ),
          const SizedBox(height: 20),
          _RotatingDisc(
            imageUrl: widget.video.user.avatarUrl,
            isPlaying:
                widget.isActive && (_controller?.value.isPlaying ?? false),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfo() {
    return Positioned(
      left: 12,
      bottom: 25,
      right: 100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.go('/profile/${widget.video.user.username}'),
            child: Text(
              '@${widget.video.user.username}',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.video.description ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 14),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.music_note, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.video.musicName ?? 'Original Sound',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return GestureDetector(
      onTap: () => context.go(
          '/profile/${widget.video.videoUrl.contains('me') ? 'me' : widget.video.user.username}'),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            padding: const EdgeInsets.all(1),
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.grey[800],
              backgroundImage: widget.video.user.avatarUrl != null
                  ? CachedNetworkImageProvider(widget.video.user.avatarUrl!,
                      headers: AppConstants.apiHeaders)
                  : null,
            ),
          ),
          Positioned(
            bottom: -8,
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                  color: Color(0xFFFF0050), shape: BoxShape.circle),
              child: const Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentsSheet(videoId: widget.video.id),
    );
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return n.toString();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  const _ActionButton(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.color = Colors.white});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RotatingDisc extends StatefulWidget {
  final String? imageUrl;
  final bool isPlaying;
  const _RotatingDisc({this.imageUrl, required this.isPlaying});
  @override
  State<_RotatingDisc> createState() => _RotatingDiscState();
}

class _RotatingDiscState extends State<_RotatingDisc>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(vsync: this, duration: const Duration(seconds: 4))
          ..repeat();
    if (!widget.isPlaying) _ctrl.stop();
  }

  @override
  void didUpdateWidget(_RotatingDisc old) {
    super.didUpdateWidget(old);
    if (widget.isPlaying) {
      _ctrl.repeat();
    } else {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(
              colors: [Colors.black, Colors.grey, Colors.black]),
          border: Border.all(color: Colors.grey[900]!, width: 8),
        ),
        child: ClipOval(
          child: widget.imageUrl != null
              ? CachedNetworkImage(
                  imageUrl: widget.imageUrl!,
                  fit: BoxFit.cover,
                  httpHeaders: AppConstants.apiHeaders)
              : Container(
                  color: Colors.black,
                  child: const Icon(Icons.music_note,
                      color: Colors.white, size: 15)),
        ),
      ),
    );
  }
}
