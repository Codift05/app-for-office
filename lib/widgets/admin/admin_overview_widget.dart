// lib/widgets/admin/admin_overview_widget.dart
// 📊 Admin Overview Widget
// Menampilkan statistik keseluruhan sistem (Reports, Requests, Cleaners)

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/report.dart';
import '../../models/request.dart';

class AdminOverviewWidget extends StatelessWidget {
  final List<Report> reports;
  final List<Request> requests;
  final int totalCleaners;

  const AdminOverviewWidget({
    super.key,
    required this.reports,
    required this.requests,
    required this.totalCleaners,
  });

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStats();

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header dengan System Health
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withOpacity(0.05),
                  Colors.transparent,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.analytics_outlined,
                            color: AppTheme.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Ringkasan Sistem',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _getHealthColor(
                          stats.systemHealth,
                        ).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _getHealthColor(
                            stats.systemHealth,
                          ).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getHealthIcon(stats.systemHealth),
                            size: 16,
                            color: _getHealthColor(stats.systemHealth),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${stats.systemHealth}%',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getHealthColor(stats.systemHealth),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Stats Grid - 3 columns modern cards
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reports Column
                Expanded(
                  child: _buildModernStatsColumn(
                    title: 'Laporan',
                    icon: Icons.description_outlined,
                    iconColor: AppTheme.primary,
                    items: [
                      _StatItem('Total', stats.totalReports, AppTheme.primary),
                      _StatItem(
                        'Pending',
                        stats.reportsPending,
                        AppTheme.warning,
                      ),
                      _StatItem(
                        'Proses',
                        stats.reportsInProgress,
                        AppTheme.info,
                      ),
                      _StatItem(
                        'Verifikasi',
                        stats.reportsNeedVerification,
                        AppTheme.purpleAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // Requests Column
                Expanded(
                  child: _buildModernStatsColumn(
                    title: 'Permintaan',
                    icon: Icons.inbox_outlined,
                    iconColor: AppTheme.secondary,
                    items: [
                      _StatItem(
                        'Total',
                        stats.totalRequests,
                        AppTheme.secondary,
                      ),
                      _StatItem(
                        'Pending',
                        stats.requestsPending,
                        AppTheme.orangeAccent,
                      ),
                      _StatItem(
                        'Aktif',
                        stats.requestsActive,
                        AppTheme.blueAccent,
                      ),
                      _StatItem(
                        'Selesai',
                        stats.requestsCompleted,
                        AppTheme.success,
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 10),

                // System Column
                Expanded(
                  child: _buildModernStatsColumn(
                    title: 'Sistem',
                    icon: Icons.settings_outlined,
                    iconColor: AppTheme.purpleAccent,
                    items: [
                      _StatItem(
                        'Petugas',
                        totalCleaners,
                        AppTheme.purpleAccent,
                      ),
                      _StatItem('Urgent', stats.urgentTotal, AppTheme.error),
                      _StatItem(
                        'Hari Ini',
                        stats.completedToday,
                        AppTheme.secondary,
                      ),
                      _StatItem(
                        'Verified',
                        stats.reportsVerified,
                        AppTheme.success,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getHealthColor(int health) {
    if (health >= 80) return const Color(0xFF4CAF50);
    if (health >= 60) return const Color(0xFFFF9800);
    return const Color(0xFFE53935);
  }

  IconData _getHealthIcon(int health) {
    if (health >= 80) return Icons.check_circle_outline;
    if (health >= 60) return Icons.info_outline;
    return Icons.warning_amber_outlined;
  }

  Widget _buildModernStatsColumn({
    required String title,
    required IconData icon,
    required Color iconColor,
    required List<_StatItem> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: iconColor.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: iconColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey.shade700,
                    letterSpacing: 0.3,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Stats Items
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      item.label,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    constraints: const BoxConstraints(minWidth: 28),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: item.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${item.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: item.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  _AdminStats _calculateStats() {
    // Reports stats
    final totalReports = reports.length;
    final reportsPending = reports
        .where((r) => r.status == ReportStatus.pending)
        .length;
    final reportsInProgress = reports
        .where((r) => r.status == ReportStatus.inProgress)
        .length;
    final reportsNeedVerification = reports
        .where((r) => r.status == ReportStatus.completed)
        .length;
    final reportsVerified = reports
        .where((r) => r.status == ReportStatus.verified)
        .length;
    final reportsUrgent = reports.where((r) => r.isUrgent).length;

    // Requests stats
    final totalRequests = requests.length;
    final requestsPending = requests
        .where((r) => r.status == RequestStatus.pending)
        .length;
    final requestsActive = requests.where((r) => r.status.isActive).length;
    final requestsCompleted = requests
        .where((r) => r.status == RequestStatus.completed)
        .length;
    final requestsUrgent = requests.where((r) => r.isUrgent).length;

    // Today's completions
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final completedToday =
        reports.where((r) {
          return r.completedAt != null &&
              r.completedAt!.isAfter(startOfDay) &&
              r.completedAt!.isBefore(today);
        }).length +
        requests.where((r) {
          return r.completedAt != null &&
              r.completedAt!.isAfter(startOfDay) &&
              r.completedAt!.isBefore(today);
        }).length;

    // Urgent total
    final urgentTotal = reportsUrgent + requestsUrgent;

    // System Health calculation
    // Based on: pending items, verification queue, active tasks distribution
    final totalItems = totalReports + totalRequests;
    final problemItems =
        reportsPending + requestsPending + reportsNeedVerification;
    final systemHealth = totalItems > 0
        ? ((1 - (problemItems / totalItems)) * 100).round()
        : 100;

    return _AdminStats(
      systemHealth: systemHealth.clamp(0, 100),
      totalReports: totalReports,
      reportsPending: reportsPending,
      reportsInProgress: reportsInProgress,
      reportsNeedVerification: reportsNeedVerification,
      reportsVerified: reportsVerified,
      totalRequests: totalRequests,
      requestsPending: requestsPending,
      requestsActive: requestsActive,
      requestsCompleted: requestsCompleted,
      urgentTotal: urgentTotal,
      completedToday: completedToday,
    );
  }
}

// ==================== HELPER CLASSES ====================

class _AdminStats {
  final int systemHealth;
  final int totalReports;
  final int reportsPending;
  final int reportsInProgress;
  final int reportsNeedVerification;
  final int reportsVerified;
  final int totalRequests;
  final int requestsPending;
  final int requestsActive;
  final int requestsCompleted;
  final int urgentTotal;
  final int completedToday;

  const _AdminStats({
    required this.systemHealth,
    required this.totalReports,
    required this.reportsPending,
    required this.reportsInProgress,
    required this.reportsNeedVerification,
    required this.reportsVerified,
    required this.totalRequests,
    required this.requestsPending,
    required this.requestsActive,
    required this.requestsCompleted,
    required this.urgentTotal,
    required this.completedToday,
  });
}

class _StatItem {
  final String label;
  final int value;
  final Color color;

  const _StatItem(this.label, this.value, this.color);
}
