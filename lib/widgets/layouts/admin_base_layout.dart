import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../navigation/admin_bottom_nav_bar.dart';
import '../../screens/admin/admin_dashboard_screen.dart';
import '../../screens/admin/all_reports_management_screen.dart';
import '../../screens/admin/all_requests_management_screen.dart';
import '../../screens/admin/cleaner_management_screen.dart';

/// Base layout wrapper for all admin screens with consistent bottom navigation
/// This ensures all admin screens have the same modern UI/UX
class AdminBaseLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final int currentNavIndex;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showFAB;

  const AdminBaseLayout({
    super.key,
    required this.child,
    required this.title,
    required this.currentNavIndex,
    this.actions,
    this.floatingActionButton,
    this.showFAB = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,

      // Modern AppBar with gradient
      appBar: !isDesktop
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.headerGradientStart,
                      AppTheme.headerGradientEnd,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              actions: actions,
            )
          : null,

      // Main content with floating navbar
      body: Stack(
        children: [
          // Main content
          child,
          // Floating navbar for mobile
          if (isMobile)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AdminBottomNavBar(
                currentIndex: currentNavIndex,
                onTap: (index) => _onBottomNavTap(context, index),
              ),
            ),
          // FAB with fixed position for mobile
          if (showFAB && isMobile && floatingActionButton != null)
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(child: floatingActionButton!),
            ),
        ],
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    // Don't navigate if already on the same screen
    if (currentNavIndex == index) return;

    Widget? targetScreen;

    switch (index) {
      case 0: // Dashboard
        targetScreen = const AdminDashboardScreen();
        break;
      case 1: // Laporan
        targetScreen = const AllReportsManagementScreen();
        break;
      case 2: // Permintaan
        targetScreen = const AllRequestsManagementScreen();
        break;
      case 3: // Petugas
        targetScreen = const CleanerManagementScreen();
        break;
    }

    if (targetScreen != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              targetScreen!,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 200),
        ),
      );
    }
  }
}
