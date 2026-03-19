// lib/screens/main_shell.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  List<_TabItem> _getTabs() {
    return [
      const _TabItem(
        icon: Icons.chat_bubble_outline_rounded,
        activeIcon: Icons.chat_bubble_rounded,
        label: 'Messages',
        path: '/',
      ),
      const _TabItem(
        icon: Icons.auto_awesome_outlined,
        activeIcon: Icons.auto_awesome_rounded,
        label: 'Updates',
        path: '/updates',
      ),
      const _TabItem(
        icon: Icons.diversity_2_outlined,
        activeIcon: Icons.diversity_2_rounded,
        label: 'Clubs',
        path: '/communities',
      ),
      const _TabItem(
        icon: Icons.phone_in_talk_outlined,
        activeIcon: Icons.phone_in_talk_rounded,
        label: 'Calls',
        path: '/calls',
      ),
    ];
  }

  int _currentIndex(BuildContext context, List<_TabItem> tabs) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < tabs.length; i++) {
      if (location == tabs[i].path ||
          (i != 0 && location.startsWith(tabs[i].path))) {
        return i;
      }
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final tabs = _getTabs();
    final currentIndex = _currentIndex(context, tabs);

    return Scaffold(
      extendBody: true, // Allow body to show behind glass nav
      body: child,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        height: 70,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(35),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: AppConstants.surfaceDark.withOpacity(0.8),
                borderRadius: BorderRadius.circular(35),
                border:
                    Border.all(color: Colors.white.withOpacity(0.1), width: 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(tabs.length, (i) {
                  final tab = tabs[i];
                  final selected = i == currentIndex;

                  return InkWell(
                    onTap: () => context.go(tab.path),
                    borderRadius: BorderRadius.circular(30),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? tab.activeIcon : tab.icon,
                            color: selected
                                ? AppConstants.primaryGold
                                : Colors.white60,
                            size: 26,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tab.label,
                            style: TextStyle(
                              color: selected
                                  ? AppConstants.primaryGold
                                  : Colors.white60,
                              fontSize: 10,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;

  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });
}
