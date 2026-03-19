// lib/screens/upload/upload_screen.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/feed_provider.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  final _api = ApiService();
  final _descCtrl = TextEditingController();
  final _musicCtrl = TextEditingController();
  File? _videoFile;
  bool _uploading = false;
  double _uploadProgress = 0;
  String? _error;

  @override
  void dispose() {
    _descCtrl.dispose();
    _musicCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final result = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(seconds: 60),
    );
    if (result != null) {
      setState(() {
        _videoFile = File(result.path);
        _error = null;
      });
    }
  }

  Future<void> _upload() async {
    if (_videoFile == null) {
      setState(() => _error = 'Please select a video first');
      return;
    }

    setState(() {
      _uploading = true;
      _error = null;
      _uploadProgress = 0;
    });

    try {
      await _api.uploadVideo(
        filePath: _videoFile!.path,
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        musicName:
            _musicCtrl.text.trim().isEmpty ? null : _musicCtrl.text.trim(),
        onProgress: (sent, total) {
          if (mounted && total > 0) {
            setState(() => _uploadProgress = sent / total);
          }
        },
      );

      if (mounted) {
        context.read<FeedProvider>().loadFeed(refresh: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('🎉 Video uploaded successfully!'),
              backgroundColor: Color(0xFFFF0050),
              behavior: SnackBarBehavior.floating),
        );
        final myUsername = context.read<AuthProvider>().currentUser?.username;
        if (myUsername != null) {
          context.go('/profile/$myUsername');
        } else {
          context.go('/');
        }
      }
    } catch (e) {
      String errorMessage = 'Upload failed. Please try again.';

      if (e is DioException) {
        if (e.response?.statusCode == 413) {
          errorMessage = 'File is too large for the server.';
        } else if (e.type == DioExceptionType.connectionTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          errorMessage = 'Request timed out. Check your internet speed.';
        } else if (e.response?.data != null &&
            e.response?.data['message'] != null) {
          errorMessage = e.response?.data['message'];
        }
      }

      if (mounted) {
        setState(() {
          _uploading = false;
          _error = errorMessage;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Post',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: _uploading ? null : () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _descCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    maxLines: 5,
                    maxLength: 500,
                    enabled: !_uploading,
                    decoration: const InputDecoration(
                      hintText: 'Describe your video...',
                      hintStyle: TextStyle(color: Colors.white38),
                      border: InputBorder.none,
                      counterStyle: TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: _uploading ? null : _pickVideo,
                  child: Container(
                    width: 100,
                    height: 140,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C1C1E),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                          color: _videoFile != null
                              ? const Color(0xFFFF0050)
                              : Colors.white10),
                    ),
                    child: _videoFile != null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle,
                                  color: Color(0xFFFF0050), size: 32),
                              SizedBox(height: 4),
                              Text('Selected',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 12)),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_box_outlined,
                                  color: Colors.white54, size: 32),
                              SizedBox(height: 4),
                              Text('Select',
                                  style: TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                            ],
                          ),
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white12, height: 32),
            _buildOptionTile(
              icon: Icons.music_note,
              label: 'Music',
              child: TextField(
                controller: _musicCtrl,
                enabled: !_uploading,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Original sound',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(height: 48),
            if (_error != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4)),
                child: Text(_error!,
                    style:
                        const TextStyle(color: Colors.redAccent, fontSize: 13)),
              ),
              const SizedBox(height: 16),
            ],
            if (_uploading) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Uploading...',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                  Text('${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(
                          color: Color(0xFFFF0050),
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: _uploadProgress,
                color: const Color(0xFFFF0050),
                backgroundColor: Colors.white12,
                borderRadius: BorderRadius.circular(2),
              ),
              const SizedBox(height: 24),
            ],
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: OutlinedButton(
                      onPressed: _uploading ? null : () => context.pop(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _uploading ? null : _upload,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF0050),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2)),
                        elevation: 0,
                      ),
                      child: _uploading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : const Text('Post',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
      {required IconData icon, required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(width: 24),
          Expanded(child: child),
        ],
      ),
    );
  }
}
