// lib/screens/cleaner/cleaner_home_screen.dart
// ✅ REFACTORED: Clean single-page layout (like Employee)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../providers/riverpod/cleaner_providers.dart';
import '../../providers/riverpod/notification_providers.dart';

import '../../widgets/cleaner/stats_card_widget.dart';
import '../../widgets/cleaner/tasks_overview_widget.dart';
import '../../widgets/cleaner/recent_tasks_widget.dart';
import '../../widgets/shared/custom_speed_dial.dart';
import '../../widgets/navigation/cleaner_bottom_nav_bar.dart';

import './pending_reports_list_screen.dart';
import './available_requests_list_screen.dart';
import './my_tasks_screen.dart';
import './create_cleaning_report_screen.dart';
import './cleaner_inventory_screen.dart';

class CleanerHomeScreen extends ConsumerStatefulWidget {
  const CleanerHomeScreen({super.key});

  @override
  ConsumerState<CleanerHomeScreen> createState() => _CleanerHomeScreenState();
}

class _CleanerHomeScreenState extends ConsumerState<CleanerHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final cleanerStats = ref.watch(cleanerStatsProvider);
    final activeReportsAsync = ref.watch(cleanerActiveReportsProvider);
    final assignedRequestsAsync = ref.watch(cleanerAssignedRequestsProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],
      // ==================== BODY ====================
      body: Stack(
        children: [
          // Main content
          RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(cleanerActiveReportsProvider);
              ref.invalidate(cleanerAssignedRequestsProvider);
              ref.invalidate(cleanerStatsProvider);
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: CustomScrollView(
              slivers: [
                // ==================== HEADER ====================
                SliverToBoxAdapter(child: _buildHeader()),

                // ==================== STATS CARDS ====================
                SliverToBoxAdapter(child: _buildStatsCards(cleanerStats)),

                // ==================== TASKS OVERVIEW & RECENT ====================
                SliverToBoxAdapter(
                  child: _buildRecentActivity(
                    activeReportsAsync,
                    assignedRequestsAsync,
                  ),
                ),

                // Bottom padding for navbar
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ],
            ),
          ),
          // Floating navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CleanerBottomNavBar(currentIndex: 0, onTap: _onBottomNavTap),
          ),
          // FAB with fixed position
          Positioned(
            bottom: 36,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: Center(child: _buildSpeedDial()),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAV TAP ====================

  void _onBottomNavTap(int index) {
    if (index == 0) return; // Already on home

    Widget? targetScreen;
    switch (index) {
      case 1:
        targetScreen = const MyTasksScreen();
        break;
      case 2:
        targetScreen = const PendingReportsListScreen();
        break;
      case 3:
        targetScreen = const CleanerInventoryScreen();
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

  // ==================== NOTIFICATION ICON ====================

  Widget _buildNotificationIcon() {
    final unreadCountAsync = ref.watch(unreadNotificationCountProvider);

    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
          onPressed: () => Navigator.pushNamed(context, '/notifications'),
        ),
        unreadCountAsync.when(
          data: (count) {
            if (count > 0) {
              return Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppTheme.error,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    count > 99 ? '99+' : count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = 'Selamat Pagi';
    } else if (hour < 15) {
      greeting = 'Selamat Siang';
    } else if (hour < 18) {
      greeting = 'Selamat Sore';
    } else {
      greeting = 'Selamat Malam';
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _buildNotificationIcon(),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () =>
                    Navigator.pushNamed(context, AppConstants.profileRoute),
                tooltip: 'Profil',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
                tooltip: 'Pengaturan',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            greeting,
            style: const TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            'Petugas Kebersihan',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DateFormatter.fullDate(DateTime.now()),
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ==================== STATS CARDS ====================

  Widget _buildStatsCards(Map<String, int> stats) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: StatsCard(
              icon: Icons.assignment_outlined,
              label: 'Ditugaskan',
              value: (stats['assigned'] ?? 0).toString(),
              color: AppTheme.info,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatsCard(
              icon: Icons.pending_actions_outlined,
              label: 'Proses',
              value: (stats['inProgress'] ?? 0).toString(),
              color: AppTheme.warning,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: StatsCard(
              icon: Icons.check_circle_outline,
              label: 'Selesai',
              value: (stats['completed'] ?? 0).toString(),
              color: AppTheme.success,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== TASKS OVERVIEW & RECENT ====================

  Widget _buildRecentActivity(
    AsyncValue activeReportsAsync,
    AsyncValue assignedRequestsAsync,
  ) {
    return activeReportsAsync.when(
      data: (reports) {
        return assignedRequestsAsync.when(
          data: (requests) {
            return Column(
              children: [
                // Tasks Overview
                TasksOverviewWidget(
                  reports: reports as List<Report>,
                  requests: List.from(requests),
                ),

                // Recent Tasks
                RecentTasksWidget(
                  reports: reports,
                  requests: List.from(requests),
                  onViewAll: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyTasksScreen(),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (e, _) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  // ==================== SPEED DIAL ====================

  Widget _buildSpeedDial() {
    return CustomSpeedDial(
      mainButtonColor: AppTheme.accent,
      actions: [
        // Inventaris Alat (Blue) - NEW!
        SpeedDialAction(
          icon: Icons.inventory_2,
          label: 'Inventaris Alat',
          backgroundColor: Colors.blue,
          onTap: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const CleanerInventoryScreen()),
          ),
        ),

        // Tugas Saya (Purple)
        SpeedDialAction(
          icon: Icons.task_alt,
          label: 'Tugas Saya',
          backgroundColor: SpeedDialColors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const MyTasksScreen()),
          ),
        ),

        // Ambil Permintaan (Green)
        SpeedDialAction(
          icon: Icons.room_service,
          label: 'Ambil Permintaan',
          backgroundColor: SpeedDialColors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AvailableRequestsListScreen(),
            ),
          ),
        ),

        // Laporan Masuk (Orange)
        SpeedDialAction(
          icon: Icons.inbox,
          label: 'Laporan Masuk',
          backgroundColor: SpeedDialColors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PendingReportsListScreen(),
            ),
          ),
        ),

        // Buat Laporan (Blue)
        SpeedDialAction(
          icon: Icons.add,
          label: 'Buat Laporan',
          backgroundColor: SpeedDialColors.blue,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateCleaningReportScreen(),
            ),
          ),
        ),
      ],
    );
  }
}
