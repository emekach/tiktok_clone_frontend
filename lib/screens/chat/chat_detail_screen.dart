// lib/screens/chat/chat_detail_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/models.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class ChatDetailScreen extends StatefulWidget {
  final String username;
  const ChatDetailScreen({super.key, required this.username});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  final _api = ApiService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  UserModel? _targetUser;
  bool _loading = true;
  bool _isRecording = false;

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    try {
      final data = await _api.getProfile(widget.username);
      if (mounted) {
        setState(() {
          _targetUser = UserModel.fromJson(data['user']);
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _sendText() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.insert(
          0, ChatMessage(text: text, isMe: true, time: DateTime.now()));
      _msgCtrl.clear();
    });
  }

  Future<void> _sendMedia() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _messages.insert(
            0,
            ChatMessage(
                imageFile: File(image.path), isMe: true, time: DateTime.now()));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(
              child: CircularProgressIndicator(color: Color(0xFF075E54))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFECE5DD), // WhatsApp background
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white24,
              backgroundImage: _targetUser?.avatarUrl != null
                  ? CachedNetworkImageProvider(_targetUser!.avatarUrl!,
                      headers: AppConstants.apiHeaders)
                  : null,
              child: _targetUser?.avatarUrl == null
                  ? const Icon(Icons.person, size: 18)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_targetUser?.displayName ?? widget.username,
                      style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const Text('Online',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
                'https://user-images.githubusercontent.com/15075759/28719144-86dc0f70-73b1-11e7-911d-60d70fcded21.png'), // WhatsApp wallpaper
            fit: BoxFit.cover,
            opacity: 0.06,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollCtrl,
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) =>
                    _ChatBubble(message: _messages[index]),
              ),
            ),
            if (_isRecording) _buildRecordingOverlay(),
            _buildInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingOverlay() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.mic, color: Colors.red),
          const SizedBox(width: 12),
          const Expanded(
              child: Text('Recording...',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          TextButton(
              onPressed: () => setState(() => _isRecording = false),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05), blurRadius: 5)
                ],
              ),
              child: Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.emoji_emotions_outlined,
                          color: Colors.grey),
                      onPressed: () {}),
                  Expanded(
                    child: TextField(
                      controller: _msgCtrl,
                      decoration: const InputDecoration(
                          hintText: 'Message', border: InputBorder.none),
                      onChanged: (v) => setState(() {}),
                    ),
                  ),
                  IconButton(
                      icon: const Icon(Icons.attach_file, color: Colors.grey),
                      onPressed: _sendMedia),
                  if (_msgCtrl.text.isEmpty)
                    IconButton(
                        icon: const Icon(Icons.camera_alt, color: Colors.grey),
                        onPressed: () {}),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onLongPressStart: (_) => setState(() => _isRecording = true),
            onLongPressEnd: (_) {
              setState(() {
                _isRecording = false;
                _messages.insert(
                    0,
                    ChatMessage(
                        isVoice: true, isMe: true, time: DateTime.now()));
              });
            },
            onTap: _sendText,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF075E54),
              child: Icon(_msgCtrl.text.isNotEmpty ? Icons.send : Icons.mic,
                  color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String? text;
  final File? imageFile;
  final bool isVoice;
  final bool isMe;
  final DateTime time;
  ChatMessage(
      {this.text,
      this.imageFile,
      this.isVoice = false,
      required this.isMe,
      required this.time});
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const _ChatBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        decoration: BoxDecoration(
          color: message.isMe ? const Color(0xFFE7FFDB) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _buildContent(),
            const SizedBox(height: 2),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                    '${message.time.hour}:${message.time.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                if (message.isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.done_all, size: 14, color: Colors.blue),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (message.imageFile != null)
      return Image.file(message.imageFile!, width: 200);
    if (message.isVoice)
      return const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.play_arrow),
        SizedBox(width: 8),
        Text('Voice message')
      ]);
    return Text(message.text ?? '', style: const TextStyle(fontSize: 15));
  }
}
