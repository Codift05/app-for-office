// lib/screens/employee/employee_home_screen.dart
// 🏠 Employee Home Screen - UPDATED: Clean dashboard only
// Search, sort, filter moved to All Reports Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../models/report.dart';
import '../../providers/riverpod/employee_providers.dart';
import '../../widgets/shared/request_overview_widget.dart';
import '../../widgets/shared/recent_requests_widget.dart';
import '../../widgets/shared/custom_speed_dial.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/navigation/employee_bottom_nav_bar.dart';
import '../shared/profile_screen.dart';
import '../shared/settings_screen.dart';
import './all_reports_screen.dart';

class EmployeeHomeScreen extends ConsumerStatefulWidget {
  const EmployeeHomeScreen({super.key});

  @override
  ConsumerState<EmployeeHomeScreen> createState() => _EmployeeHomeScreenState();
}

class _EmployeeHomeScreenState extends ConsumerState<EmployeeHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final reportsAsync = ref.watch(employeeReportsProvider);
    final summary = ref.watch(employeeReportsSummaryProvider);
    final userId = ref.watch(currentEmployeeIdProvider);

    // Debug: print user state
    debugPrint('Employee Home - User ID: $userId');
    debugPrint(
      'Employee Home - Reports State: ${reportsAsync.when(data: (reports) => 'Data: ${reports.length} reports', loading: () => 'Loading...', error: (e, s) => 'Error: $e')}',
    );

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.grey[50],

      // ==================== BODY ====================
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              // Trigger refresh by invalidating the provider
              ref.invalidate(employeeReportsProvider);
              // Wait a bit for the refresh to complete
              await Future.delayed(const Duration(milliseconds: 500));
            },
            child: reportsAsync.when(
              // Loading State - Show skeleton UI
              loading: () => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildStatsCards(summary)),
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),

              // Error State
              error: (error, stack) => CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader()),
                  SliverToBoxAdapter(child: _buildStatsCards(summary)),
                  SliverToBoxAdapter(
                    child: ErrorEmptyState(
                      title: 'Terjadi kesalahan',
                      subtitle: error.toString(),
                      onRetry: () => ref.invalidate(employeeReportsProvider),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 120)),
                ],
              ),

              // Success State
              data: (reports) {
                return CustomScrollView(
                  slivers: [
                    // ==================== HEADER WITH GREETING ====================
                    SliverToBoxAdapter(child: _buildHeader()),

                    // ==================== STATS CARDS ====================
                    SliverToBoxAdapter(child: _buildStatsCards(summary)),

                    // ==================== REQUEST OVERVIEW ====================
                    SliverToBoxAdapter(
                      child: RequestOverviewWidget(reports: reports),
                    ),

                    // ==================== RECENT REQUESTS ====================
                    SliverToBoxAdapter(
                      child: RecentRequestsWidget(
                        reports: reports,
                        onViewAll: () =>
                            Navigator.pushNamed(context, '/all_reports'),
                      ),
                    ),

                    // Bottom padding for navbar
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                );
              },
            ),
          ),
          // Floating navbar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: EmployeeBottomNavBar(
              currentIndex: 0,
              onTap: _onBottomNavTap,
            ),
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
        targetScreen = const AllReportsScreen();
        break;
      case 2:
        targetScreen = const ProfileScreen();
        break;
      case 3:
        targetScreen = const SettingsScreen();
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

  // ==================== HEADER WITH GREETING ====================
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
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
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pushNamed(context, '/notifications'),
                tooltip: 'Notifikasi',
              ),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ),
                tooltip: 'Profil',
              ),
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                ),
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
            user?.displayName ?? 'Budi',
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
  Widget _buildStatsCards(EmployeeReportsSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Terkirim (Pending)
          Expanded(
            child: _buildStatCard(
              icon: Icons.send,
              label: 'Terkirim',
              value: summary.pending,
              color: Colors.orange,
              iconColor: Colors.orange[700]!,
            ),
          ),
          const SizedBox(width: 12),

          // Dikerjakan (In Progress)
          Expanded(
            child: _buildStatCard(
              icon: Icons.autorenew,
              label: 'Dikerjakan',
              value: summary.inProgress,
              color: Colors.blue,
              iconColor: Colors.blue[700]!,
            ),
          ),
          const SizedBox(width: 12),

          // Selesai (Completed)
          Expanded(
            child: _buildStatCard(
              icon: Icons.check_circle,
              label: 'Selesai',
              value: summary.completed,
              color: Colors.green,
              iconColor: Colors.green[700]!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon with circle background
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 8),
          // Value
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          // Label
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ==================== SPEED DIAL ====================
  Widget _buildSpeedDial() {
    final pendingReports = ref.watch(
      employeeReportsByStatusProvider(ReportStatus.pending),
    );

    return CustomSpeedDial(
      mainButtonColor: AppTheme.accent,
      actions: [
        // Semua Laporan (Ungu/Purple)
        SpeedDialAction(
          icon: Icons.view_list,
          label: 'Semua Laporan',
          backgroundColor: SpeedDialColors.purple,
          onTap: () => Navigator.pushNamed(context, '/all_reports'),
        ),

        // Pending (Orange)
        SpeedDialAction(
          icon: Icons.schedule,
          label:
              'Pending${pendingReports.isNotEmpty ? ' (${pendingReports.length})' : ''}',
          backgroundColor: SpeedDialColors.orange,
          onTap: () => Navigator.pushNamed(
            context,
            '/all_reports',
            arguments: {'filterStatus': ReportStatus.pending},
          ),
        ),

        // Minta Layanan (Hijau/Green)
        SpeedDialAction(
          icon: Icons.room_service,
          label: 'Minta Layanan',
          backgroundColor: SpeedDialColors.green,
          onTap: () {
            Navigator.pushNamed(context, '/create_request');
          },
        ),

        // Buat Laporan (Biru/Blue)
        SpeedDialAction(
          icon: Icons.add,
          label: 'Buat Laporan',
          backgroundColor: SpeedDialColors.blue,
          onTap: () => Navigator.pushNamed(context, '/create_report'),
        ),
      ],
    );
  }
}
