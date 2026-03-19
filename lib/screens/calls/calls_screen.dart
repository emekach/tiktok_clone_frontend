// lib/screens/calls/calls_screen.dart

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../utils/constants.dart';

class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calls',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
              icon: const Icon(Icons.camera_alt_outlined), onPressed: () {}),
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF25D366),
              child: Icon(Icons.link, color: Colors.white),
            ),
            title: Text('Create call link',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Share a link for your WhatsApp call'),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Recent',
                style:
                    TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          ),
          ...List.generate(
              10,
              (index) => ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: CachedNetworkImageProvider(
                        'https://i.pravatar.cc/150?u=call_$index',
                        headers: AppConstants.apiHeaders,
                      ),
                    ),
                    title: Text('Contact ${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(
                      children: [
                        Icon(
                          index % 2 == 0
                              ? Icons.call_received
                              : Icons.call_made,
                          size: 16,
                          color: index % 3 == 0 ? Colors.red : Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text('Today, ${10 + index}:30 AM'),
                      ],
                    ),
                    trailing: Icon(index % 2 == 0 ? Icons.call : Icons.videocam,
                        color: const Color(0xFF075E54)),
                  )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_call),
      ),
    );
  }
}
