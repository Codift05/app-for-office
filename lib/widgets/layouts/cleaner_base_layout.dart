import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../navigation/cleaner_bottom_nav_bar.dart';
import '../../screens/cleaner/cleaner_home_screen.dart';
import '../../screens/cleaner/my_tasks_screen.dart';
import '../../screens/cleaner/pending_reports_list_screen.dart';
import '../../screens/cleaner/cleaner_inventory_screen.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          child,
          // Floating navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CleanerBottomNavBar(
              currentIndex: currentNavIndex,
              onTap: (index) => _onBottomNavTap(context, index),
            ),
          ),
          // FAB with fixed position
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: Center(
                child: floatingActionButton ?? _buildDefaultFAB(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultFAB(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showQuickActions(context),
      backgroundColor: AppTheme.primary,
      elevation: 8,
      child: const Icon(Icons.add, color: Colors.white, size: 28),
    );
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aksi Cepat',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildQuickActionButton(
              context: context,
              icon: Icons.inventory_2,
              label: 'Inventaris Alat',
              color: Colors.blue,
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CleanerInventoryScreen(),
                  ),
                );
              },
            ),
            _buildQuickActionButton(
              context: context,
              icon: Icons.task_alt,
              label: 'Tugas Saya',
              color: Colors.purple,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyTasksScreen()),
                );
              },
            ),
            _buildQuickActionButton(
              context: context,
              icon: Icons.inbox,
              label: 'Laporan Masuk',
              color: Colors.orange,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PendingReportsListScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: color, size: 16),
              ],
            ),
          ),
        ),
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

    Widget? targetScreen;
    switch (index) {
      case 0: // Beranda
        targetScreen = const CleanerHomeScreen();
        break;
      case 1: // Tugas
        targetScreen = const MyTasksScreen();
        break;
      case 2: // Laporan
        targetScreen = const PendingReportsListScreen();
        break;
      case 3: // Inventaris
        targetScreen = const CleanerInventoryScreen();
        break;
    }

    if (targetScreen != null) {
      // If coming from a screen not in navbar (currentNavIndex = -1),
      // pop first then replace
      if (currentNavIndex == -1) {
        Navigator.pop(context);
      }
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
