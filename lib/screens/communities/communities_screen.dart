// lib/screens/communities/communities_screen.dart

import 'package:flutter/material.dart';

class CommunitiesScreen extends StatelessWidget {
  const CommunitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Communities',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
              icon:
                  const Icon(Icons.camera_alt_outlined, color: Colors.black87),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.black87),
              onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Image.network(
              'https://static.whatsapp.net/rsrc.php/v3/y6/r/wa_communities_home.png',
              height: 150,
              errorBuilder: (context, error, stackTrace) =>
                  const Icon(Icons.groups, size: 100, color: Colors.grey),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: Column(
                children: [
                  Text(
                    'Stay connected with a community',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Communities bring members together in topic-based groups, and make it easy to get admin announcements. Any community you\'re added to will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See example communities >',
                  style: TextStyle(
                      color: Color(0xFF075E54), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF075E54),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                  ),
                  child: const Text('Start your community',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
