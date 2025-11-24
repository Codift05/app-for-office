import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../navigation/cleaner_bottom_nav_bar.dart';

/// Modern base layout for cleaner screens with consistent header and bottom navbar
class CleanerBaseLayout extends StatelessWidget {
  final String title;
  final int currentNavIndex;
  final Widget child;
  final List<Widget>? actions;
  final bool showFAB;
  final Widget? floatingActionButton;

  const CleanerBaseLayout({
    super.key,
    required this.title,
    required this.currentNavIndex,
    required this.child,
    this.actions,
    this.showFAB = false,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          child,
          if (isMobile && showFAB)
            Positioned(
              bottom: 36,
              left: 0,
              right: 0,
              child: Center(
                child: floatingActionButton ?? const SizedBox.shrink(),
              ),
            ),
          if (isMobile)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CleanerBottomNavBar(
                currentIndex: currentNavIndex,
                onTap: (index) => _onBottomNavTap(context, index),
              ),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          centerTitle: false,
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: actions,
        ),
      ),
    );
  }

  void _onBottomNavTap(BuildContext context, int index) {
    // Prevent navigation if already on the same page
    if (index == currentNavIndex) return;

    switch (index) {
      case 0: // Beranda
        Navigator.pushReplacementNamed(context, '/cleaner/home');
        break;
      case 1: // Tugas
        Navigator.pushReplacementNamed(context, '/cleaner/tasks');
        break;
      case 2: // Laporan
        Navigator.pushReplacementNamed(context, '/cleaner/reports');
        break;
      case 3: // Inventaris
        Navigator.pushNamed(context, '/inventory');
        break;
    }
  }
}
