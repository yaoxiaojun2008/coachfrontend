import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers.dart';
import '../core/theme.dart';
import 'bottom_nav.dart';
import 'left_sidebar.dart';
import 'right_sidebar.dart';

class ResponsiveLayout extends ConsumerWidget {
  final Widget child;
  final String currentRoute;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Define breakpoints
    const mobileBreakpoint = 768.0;  // Changed from 600 to 768 for better tablet support
    const tabletBreakpoint = 1024.0; // Changed from 900 to 1024 for better desktop detection
    
    // Determine if we should show desktop layout
    final isDesktop = screenWidth >= tabletBreakpoint;
    final isTablet = screenWidth >= mobileBreakpoint && screenWidth < tabletBreakpoint;
    final isMobile = screenWidth < mobileBreakpoint;

    if (isDesktop) {
      // Desktop layout with left sidebar and right sidebar
      return Scaffold(
        body: Row(
          children: [
            // Left Sidebar (250px width)
            const LeftSidebar(),
            
            // Main Content Area
            Expanded(
              child: Scaffold(
                body: child,
              ),
            ),
            
            // Right Sidebar (320px width) - Only on web/desktop
            const RightSidebar(),
          ],
        ),
      );
    } else {
      // Mobile/Tablet layout with bottom navigation
      return Scaffold(
        extendBody: true,
        body: Stack(
          children: [
            // Main Content
            child,
            
            // Bottom Navigation
            Positioned(
              left: 0, right: 0, bottom: 0,
              child: BottomNav(
                currentRoute: currentRoute,
                onNavigate: (route) {
                  if (route != currentRoute) {
                    context.push(route);
                  }
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}