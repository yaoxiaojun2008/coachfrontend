import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';
import '../providers.dart';

class LeftSidebar extends ConsumerWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final currentRoute = GoRouterState.of(context).uri.path;

    // Navigation items matching bottom nav
    final navItems = [
      {
        'route': '/',
        'icon': Icons.home,
        'label': 'Home',
      },
      {
        'route': '/reading-coach',
        'icon': Icons.menu_book,
        'label': 'Reading Coach',
      },
      {
        'route': '/writing-coach',
        'icon': Icons.edit,
        'label': 'Writing Coach',
      },
      {
        'route': '/chat',
        'icon': Icons.chat,
        'label': 'Chat',
      },
      {
        'route': '/recommended-feed',
        'icon': Icons.explore,
        'label': 'Explore',
      },
    ];

    return Container(
      width: 280, // Increased width for better content spacing
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(2, 0),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header/Logo Section
          Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'DAWNASTRA AI',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      const Text(
                        'LEARNING HUB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // User Info Section
          if (user != null)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (user.email != null)
                          Text(
                            user.email!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: navItems.map((item) {
                final isActive = currentRoute == item['route'];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: ListTile(
                    leading: Icon(
                      item['icon'] as IconData,
                      color: isActive ? AppTheme.primary : Colors.grey[600],
                      size: 24,
                    ),
                    title: Text(
                      item['label'] as String,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? AppTheme.primary : Colors.black,
                      ),
                    ),
                    selected: isActive,
                    selectedColor: AppTheme.primary,
                    selectedTileColor: AppTheme.primary.withOpacity(0.1),
                    hoverColor: AppTheme.primary.withOpacity(0.05),
                    onTap: () {
                      if (currentRoute != item['route']) {
                        context.push(item['route'] as String);
                      }
                    },
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                );
              }).toList(),
            ),
          ),

          // Footer Actions
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.settings,
                    color: Colors.grey,
                    size: 24,
                  ),
                  title: const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    // Handle settings navigation
                  },
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 24,
                  ),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.red,
                    ),
                  ),
                  onTap: () {
                    // Handle logout
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}