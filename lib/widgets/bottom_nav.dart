import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core/theme.dart';

class BottomNav extends StatelessWidget {
  final String currentRoute;
  final Function(String) onNavigate;

  const BottomNav({
    super.key,
    required this.currentRoute,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Slightly taller to accommodate FAB
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.95),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.2))),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavButton(
                icon: Icons.home,
                label: 'Home',
                isActive: currentRoute == '/',
                onTap: () => onNavigate('/'),
              ),
              _NavButton(
                icon: Icons.library_books,
                label: 'Library',
                isActive: currentRoute == '/library',
                onTap: () => onNavigate('/library'),
              ),
              const SizedBox(width: 48), // Spacer for FAB
              _NavButton(
                icon: Icons.analytics,
                label: 'Stats',
                isActive: currentRoute == '/stats',
                onTap: () => onNavigate('/stats'),
              ),
              _NavButton(
                icon: Icons.settings,
                label: 'Settings',
                isActive: currentRoute == '/settings',
                onTap: () => onNavigate('/settings'),
              ),
            ],
          ),
          Positioned(
            top: -20,
            child: GestureDetector(
              onTap: () => onNavigate('/chat'),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.smart_toy, color: Colors.white, size: 30),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTheme.primary : Colors.grey;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
