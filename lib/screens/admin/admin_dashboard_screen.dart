// lib/screens/admin/admin_dashboard_screen_responsive.dart
// ✅ MULTI-PLATFORM: Responsive Admin Dashboard (Mobile + Desktop/Web)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';

import '../../providers/riverpod/admin_providers.dart'
    hide currentUserProfileProvider;
import '../../providers/riverpod/auth_providers.dart';
import '../../providers/riverpod/notification_providers.dart';
import '../../providers/riverpod/request_providers.dart';

import '../../widgets/shared/custom_speed_dial.dart';
import '../../widgets/admin/admin_overview_widget.dart';
import '../../widgets/admin/recent_activities_widget.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/navigation/admin_bottom_nav_bar.dart';

// Feature A: Real-time Updates
import '../../services/realtime_service.dart';
import '../../widgets/admin/realtime_indicator_widget.dart';

// Feature B: Advanced Filtering
import '../../widgets/admin/advanced_filter_dialog.dart';

import './all_reports_management_screen.dart';
import './all_requests_management_screen.dart';
import './cleaner_management_screen.dart';
import '../dev/seed_data_screen.dart';

// 🎨 NEW: Modern Dashboard Widgets
import '../../widgets/admin/dashboard/dashboard_stats_grid.dart';
import '../../widgets/admin/dashboard/dashboard_section.dart';
import '../../widgets/admin/charts/weekly_report_chart.dart';
import '../../widgets/admin/cards/top_cleaner_card.dart';
import '../../providers/riverpod/dashboard_stats_provider.dart';
import '../../models/report.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Feature A: Start real-time updates
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(realtimeServiceProvider)
          .startAutoRefresh(
            interval: const Duration(seconds: 30), // 30s interval
          );
    });
  }

  @override
  void dispose() {
    // Stop real-time updates - safe to skip if widget is unmounting
    // The service will auto-cleanup when no longer referenced
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isMobile = ResponsiveHelper.isMobile(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTheme.modernBg,
      body: Stack(
        children: [
          // Main content
          isDesktop ? _buildDesktopLayout() : _buildMobileContent(),
          // Floating navbar for mobile
          if (isMobile)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AdminBottomNavBar(currentIndex: 0, onTap: _onBottomNavTap),
            ),
          // FAB with fixed position for mobile
          if (isMobile)
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

  // Bottom nav tap handler
  void _onBottomNavTap(int index) {
    if (index == 0) return; // Already on Dashboard

    Widget? targetScreen;
    switch (index) {
      case 1:
        targetScreen = const AllReportsManagementScreen();
        break;
      case 2:
        targetScreen = const AllRequestsManagementScreen();
        break;
      case 3:
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

  // ==================== APP BAR ====================

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

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'dashboard'),

        // Main Content with Custom Header
        Expanded(
          child: Column(
            children: [
              // Custom Header Bar (Blue Background with Search)
              _buildDesktopHeader(),
              // Scrollable Content
              Expanded(child: _buildDesktopContent()),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== DESKTOP HEADER (Blue Bar with Search) ====================
  Widget _buildDesktopHeader() {
    return Container(
      height: 70,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            // Search Bar
            Expanded(
              flex: 2,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 400),
                height: 46,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search here...',
                    hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.2),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                  ),
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),

            const Spacer(flex: 3),

            // Live indicator
            const RealtimeIndicatorCompact(),
            const SizedBox(width: 24),

            // Filter button
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const AdvancedFilterDialog(),
              ),
              tooltip: 'Advanced Filters',
            ),
            const SizedBox(width: 8),

            // Notification Icon
            _buildNotificationIcon(),
            const SizedBox(width: 16),

            // Profile Avatar
            GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person, color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopContent() {
    // Use needsVerificationReportsProvider as the main data source
    final allReportsAsync = ref.watch(needsVerificationReportsProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(needsVerificationReportsProvider);
        ref.invalidate(allRequestsProvider);
        ref.invalidate(availableCleanersProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // Modern Header with User Info
          SliverToBoxAdapter(child: _buildModernHeader()),

          // Stats Cards (4 cards horizontal)
          SliverToBoxAdapter(child: _buildModernStats(allReportsAsync)),

          // Main Content - Two Columns
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column (70%) - Progress Overview + Quick Actions
                  Expanded(
                    flex: 70,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Analytics Section
                        _buildAnalyticsSection(
                          reports: allReportsAsync.asData?.value ?? [],
                          requests: [],
                        ),

                        const SizedBox(height: 24),

                        // Quick Actions Section
                        _buildQuickActions(),
                      ],
                    ),
                  ),

                  const SizedBox(width: 24),

                  // Right Column (30%) - Top Cleaner + Recent Reports
                  Expanded(
                    flex: 30,
                    child: Column(
                      children: [
                        // 🎨 NEW: Top Cleaner Performance Card
                        TopCleanerCard(
                          allReports: allReportsAsync.asData?.value ?? [],
                          onViewDetails: () {
                            _navigateToScreen(const CleanerManagementScreen());
                          },
                        ),
                        const SizedBox(height: 24),
                        // Recent Reports
                        _buildRecentReports(allReportsAsync),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileContent() {
    final needsVerificationAsync = ref.watch(needsVerificationReportsProvider);
    final allRequestsAsync = ref.watch(allRequestsProvider);
    final cleanersAsync = ref.watch(availableCleanersProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(needsVerificationReportsProvider);
        ref.invalidate(allRequestsProvider);
        ref.invalidate(availableCleanersProvider);
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: _buildHeader()),

          // Stats Cards (2x2 Grid)
          SliverToBoxAdapter(
            child: _buildMobileStats(
              needsVerificationAsync,
              allRequestsAsync,
              cleanersAsync,
            ),
          ),

          // Overview + Recent Activities + Analytics
          SliverToBoxAdapter(
            child: needsVerificationAsync.when(
              data: (reports) {
                return allRequestsAsync.when(
                  data: (requests) {
                    return cleanersAsync.when(
                      data: (cleaners) {
                        return Column(
                          children: [
                            // Overview
                            AdminOverviewWidget(
                              reports: reports,
                              requests: requests,
                              totalCleaners: cleaners.length,
                            ),

                            // Analytics
                            _buildAnalyticsSection(
                              reports: reports,
                              requests: requests,
                            ),

                            // Recent Activities
                            RecentActivitiesWidget(
                              reports: reports,
                              requests: requests,
                              onViewAll: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const AllReportsManagementScreen(),
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
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => const SizedBox.shrink(),
            ),
          ),

          // Bottom padding for floating navbar
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader() {
    final user = FirebaseAuth.instance.currentUser;
    final userProfileAsync = ref.watch(currentUserProfileProvider);
    final greeting = _getGreeting();

    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.headerGradientStart, AppTheme.headerGradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: isDesktop
            ? null
            : const BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row with notification icon (only for mobile)
          if (!isDesktop)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [_buildNotificationIcon()],
              ),
            ),
          if (!isDesktop) const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    userProfileAsync.when(
                      data: (profile) {
                        final displayName =
                            profile?.displayName ??
                            user?.displayName ??
                            'Admin';
                        // Capitalize first letter if needed
                        final formattedName = displayName.isEmpty
                            ? 'Admin'
                            : displayName[0].toUpperCase() +
                                  displayName.substring(1);
                        return Text(
                          formattedName,
                          style: TextStyle(
                            fontSize: ResponsiveHelper.headingFontSize(context),
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        );
                      },
                      loading: () => const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      error: (e, _) => const Text(
                        'Admin',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DateFormatter.fullDate(DateTime.now()),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Modern profile avatar with border
              GestureDetector(
                onTap: () => _showProfileMenu(context),
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==================== MOBILE STATS (REFINED) ====================
  Widget _buildMobileStats(
    AsyncValue needsVerificationAsync,
    AsyncValue allRequestsAsync,
    AsyncValue cleanersAsync,
  ) {
    return needsVerificationAsync.when(
      data: (reports) {
        final verificationCount = reports
            .where((r) => r.status.name == 'needsVerification')
            .length;
        final pendingCount = reports
            .where((r) => r.status.name == 'pending')
            .length;
        final requestsCount = allRequestsAsync.asData?.value.length ?? 0;
        final cleanersCount = cleanersAsync.asData?.value.length ?? 0;

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.description_outlined,
                      color: AppTheme.primary,
                      label: 'Laporan Masuk',
                      value: verificationCount.toString(),
                      onTap: () =>
                          _navigateToScreen(const AllReportsManagementScreen()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.pending_actions_outlined,
                      color: AppTheme.warning,
                      label: 'Pending',
                      value: pendingCount.toString(),
                      onTap: () =>
                          _navigateToScreen(const AllReportsManagementScreen()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.room_service_outlined,
                      color: AppTheme.info,
                      label: 'Total Permintaan',
                      value: requestsCount.toString(),
                      onTap: () => _navigateToScreen(
                        const AllRequestsManagementScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people_outline,
                      color: AppTheme.success,
                      label: 'Petugas Aktif',
                      value: cleanersCount.toString(),
                      onTap: () =>
                          _navigateToScreen(const CleanerManagementScreen()),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('Error: $e'),
        ),
      ),
    );
  }

  // ==================== MOBILE DRAWER ====================

  // ==================== SPEED DIAL ====================
  Widget _buildSpeedDial() {
    return CustomSpeedDial(
      mainButtonColor: AppTheme.accent,
      actions: [
        SpeedDialAction(
          icon: Icons.verified_user,
          label: 'Verifikasi',
          backgroundColor: SpeedDialColors.red,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllReportsManagementScreen(),
            ),
          ),
        ),
        SpeedDialAction(
          icon: Icons.assignment,
          label: 'Kelola Laporan',
          backgroundColor: SpeedDialColors.orange,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllReportsManagementScreen(),
            ),
          ),
        ),
        SpeedDialAction(
          icon: Icons.room_service,
          label: 'Kelola Permintaan',
          backgroundColor: SpeedDialColors.green,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AllRequestsManagementScreen(),
            ),
          ),
        ),
        SpeedDialAction(
          icon: Icons.people,
          label: 'Kelola Petugas',
          backgroundColor: SpeedDialColors.purple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CleanerManagementScreen(),
            ),
          ),
        ),
        SpeedDialAction(
          icon: Icons.data_object,
          label: 'Generate Data',
          backgroundColor: Colors.deepPurple,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SeedDataScreen()),
          ),
        ),
      ],
    );
  }

  // ==================== NAVIGATION HELPER ====================
  void _navigateToScreen(Widget screen) {
    if (mounted) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
    }
  }

  // ==================== PROFILE MENU ====================
  void _showProfileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.person, color: AppTheme.primary),
                title: const Text(
                  'Profil Saya',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/profile');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.settings, color: AppTheme.primary),
                title: const Text(
                  'Pengaturan',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/settings');
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.error),
                title: const Text(
                  'Keluar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.error,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showLogoutDialog(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== LOGOUT DIALOG ====================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Apakah Anda yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await FirebaseAuth.instance.signOut();
                if (mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal logout: $e'),
                      backgroundColor: AppTheme.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  // ==================== BOTTOM NAV HANDLER ====================

  // ==================== MODERN WEB LAYOUT METHODS ====================

  /// Modern Header with User Info
  Widget _buildModernHeader() {
    final greeting = _getGreeting();
    final now = DateTime.now();

    return Container(
      margin: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar/Icon
          GestureDetector(
            onTap: () => _showProfileMenu(context),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: const Icon(Icons.person, color: Colors.white, size: 32),
            ),
          ),
          const SizedBox(width: 20),
          // Text content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Admin',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      DateFormatter.fullDate(now),
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Active',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 NEW: Modern Stats Cards using DashboardStatsGrid
  Widget _buildModernStats(AsyncValue allReportsAsync) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final stats = ref.watch(dashboardStatsProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: DashboardStatsGrid(stats: stats, isDesktop: isDesktop),
    );
  }

  // ==================== STAT CARD (REFINED) ====================
  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: color,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Quick Actions Section
  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.add,
                  label: 'Create New Report',
                  color: AppTheme.primary,
                  onTap: () => Navigator.pushNamed(context, '/create_report'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.list_alt,
                  label: 'View All Reports',
                  color: AppTheme.info,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllReportsManagementScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.access_time,
                  label: 'Pending Reports',
                  color: AppTheme.warning,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AllReportsManagementScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildQuickActionButton(
                  icon: Icons.data_object,
                  label: 'Generate Sample Data',
                  color: Colors.deepPurple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeedDataScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Recent Reports Section (Right Column)
  Widget _buildRecentReports(AsyncValue allReportsAsync) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.calendar_today, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Recent Reports',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AllReportsManagementScreen(),
                  ),
                ),
                child: const Text('Lihat Semua >'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          allReportsAsync.when(
            data: (reports) {
              if (reports.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.check_circle_outline,
                        size: 64,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Semua sudah ditangani',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                );
              }

              // Show latest 5 reports
              final recentReports = reports.take(5).toList();

              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentReports.length,
                separatorBuilder: (context, index) => const Divider(height: 24),
                itemBuilder: (context, index) {
                  final report = recentReports[index];
                  return _buildRecentReportItem(report);
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error: $e'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentReportItem(dynamic report) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/report_detail', arguments: report);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: report.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                report.status.icon,
                color: report.status.color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    report.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              DateFormatter.relativeTime(report.date),
              style: TextStyle(fontSize: 11, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ANALYTICS SECTION (NEW) ====================
  /// 🎨 NEW: Weekly Report Chart using WeeklyReportChart widget
  Widget _buildAnalyticsSection({
    required List<dynamic> reports,
    required List<dynamic> requests,
  }) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    // Convert dynamic list to List<Report>
    final reportList = reports.whereType<Report>().toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: DashboardSection(
        padding: const EdgeInsets.all(20),
        title: 'Riwayat Laporan Mingguan',
        subtitle: '7 hari terakhir',
        child: Column(
          children: [
            WeeklyReportChart(reports: reportList, isDesktop: isDesktop),
            const SizedBox(height: 16),
            const WeeklyReportChartLegend(),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }
}
