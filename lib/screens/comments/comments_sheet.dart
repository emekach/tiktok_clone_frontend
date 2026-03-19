// lib/screens/comments/comments_sheet.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';

class CommentsSheet extends StatefulWidget {
  final int videoId;
  const CommentsSheet({super.key, required this.videoId});

  @override
  State<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends State<CommentsSheet> {
  final _api = ApiService();
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  List<CommentModel> _comments = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final data = await _api.getComments(widget.videoId);
      if (mounted) {
        setState(() {
          _comments = (data['data'] as List)
              .map((c) => CommentModel.fromJson(c))
              .toList();
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final data = await _api.addComment(widget.videoId, text);
      _ctrl.clear();
      final newComment = CommentModel.fromJson(data['comment']);
      if (mounted) {
        setState(() {
          _comments.insert(0, newComment);
          _submitting = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Color(0xFF1C1C1E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '${_comments.length} Comments',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
                Positioned(
                  right: 12,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child:
                        const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Comment list
          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFFF0050)))
                : _comments.isEmpty
                    ? const _EmptyComments()
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        itemCount: _comments.length,
                        itemBuilder: (_, i) =>
                            _CommentTile(comment: _comments[i]),
                      ),
          ),

          // Input area
          _buildInput(context),
        ],
      ),
    );
  }

  Widget _buildInput(BuildContext context) {
    final authUser = context.watch<AuthProvider>().currentUser;
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 12,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF121212),
        border: Border(top: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: authUser?.avatarUrl != null
                ? CachedNetworkImageProvider(authUser!.avatarUrl!)
                : null,
            child: authUser?.avatarUrl == null
                ? const Icon(Icons.person, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _ctrl,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: const InputDecoration(
                hintText: 'Add comment...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          GestureDetector(
            onTap: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Color(0xFFFF0050)))
                : const Icon(Icons.send_rounded,
                    color: Color(0xFFFF0050), size: 24),
          ),
        ],
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final CommentModel comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: Colors.white10,
            backgroundImage: comment.user.avatarUrl != null
                ? CachedNetworkImageProvider(comment.user.avatarUrl!)
                : null,
            child: comment.user.avatarUrl == null
                ? const Icon(Icons.person, size: 16, color: Colors.white38)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(comment.user.username,
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                const SizedBox(height: 4),
                Text(comment.content,
                    style: const TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 6),
                Text(_timeAgo(comment.createdAt),
                    style:
                        const TextStyle(color: Colors.white38, fontSize: 11)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            children: [
              Icon(Icons.favorite_border, color: Colors.white38, size: 18),
              SizedBox(height: 2),
              Text('0', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'just now';
  }
}

class _EmptyComments extends StatelessWidget {
  const _EmptyComments();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.white12),
          SizedBox(height: 12),
          Text('No comments yet', style: TextStyle(color: Colors.white38)),
          Text('Be the first to comment',
              style: TextStyle(color: Colors.white24, fontSize: 12)),
        ],
      ),
    );
  }
}
