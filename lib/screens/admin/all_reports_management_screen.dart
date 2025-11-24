// lib/screens/admin/all_reports_management_screen.dart
// Management screen untuk semua reports dengan filter, search, dan actions

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/report.dart';
import '../../providers/riverpod/admin_providers.dart';
import '../../providers/riverpod/report_providers.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/layouts/admin_base_layout.dart';
import '../shared/report_detail/report_detail_screen.dart';

class AllReportsManagementScreen extends ConsumerStatefulWidget {
  const AllReportsManagementScreen({super.key});

  @override
  ConsumerState<AllReportsManagementScreen> createState() =>
      _AllReportsManagementScreenState();
}

class _AllReportsManagementScreenState
    extends ConsumerState<AllReportsManagementScreen> {
  // Filter state
  ReportStatus? _filterStatus;
  bool _showUrgentOnly = false;
  String _searchQuery = '';

  // Search controller
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final departmentId = ref.watch(currentUserDepartmentProvider);
    final allReportsAsync = ref.watch(allReportsProvider(departmentId));
    final isMobile = ResponsiveHelper.isMobile(context);

    // For mobile, use modern AdminBaseLayout
    if (isMobile) {
      return AdminBaseLayout(
        title: 'Kelola Laporan',
        currentNavIndex: 1, // Laporan index
        actions: [_buildFilterButton()],
        showFAB: true,
        floatingActionButton: _buildFAB(),
        child: _buildMobileLayout(allReportsAsync),
      );
    }

    // For desktop, keep existing layout with sidebar
    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      body: _buildDesktopLayout(allReportsAsync),
    );
  }

  // ==================== FILTER BUTTON ====================
  Widget _buildFilterButton() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.filter_list, color: Colors.white),
      tooltip: 'Filter',
      onSelected: (value) {
        setState(() {
          if (value == 'urgent') {
            _showUrgentOnly = !_showUrgentOnly;
          } else if (value == 'all') {
            _filterStatus = null;
          } else {
            _filterStatus = ReportStatus.values.firstWhere(
              (s) => s.toFirestore() == value,
            );
          }
        });
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'all',
          child: Row(
            children: [
              Icon(
                Icons.list,
                size: 20,
                color: _filterStatus == null ? AppTheme.primary : Colors.grey,
              ),
              const SizedBox(width: 12),
              const Text('Semua Status'),
            ],
          ),
        ),
        const PopupMenuDivider(),
        ...ReportStatus.values.map((status) {
          return PopupMenuItem(
            value: status.toFirestore(),
            child: Row(
              children: [
                Icon(
                  status.icon,
                  size: 20,
                  color: _filterStatus == status
                      ? AppTheme.primary
                      : status.color,
                ),
                const SizedBox(width: 12),
                Text(status.displayName),
              ],
            ),
          );
        }),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'urgent',
          child: Row(
            children: [
              Icon(
                Icons.warning,
                size: 20,
                color: _showUrgentOnly ? AppTheme.error : Colors.grey,
              ),
              const SizedBox(width: 12),
              const Text('Urgent Saja'),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== DESKTOP LAYOUT ====================
  Widget _buildDesktopLayout(AsyncValue<List<Report>> allReportsAsync) {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'reports_management'),

        // Main Content with Custom Header
        Expanded(
          child: Column(
            children: [
              // Custom Header Bar (Blue Background with Search)
              _buildDesktopHeader(),

              // Scrollable Content
              Expanded(
                child: Column(
                  children: [
                    // Search bar
                    _buildSearchBar(),

                    // Filter chips
                    if (_filterStatus != null || _showUrgentOnly)
                      _buildFilterChips(),

                    // Reports list
                    Expanded(
                      child: allReportsAsync.when(
                        data: (reports) {
                          // Apply filters
                          var filteredReports = reports;

                          // Filter by status
                          if (_filterStatus != null) {
                            filteredReports = filteredReports
                                .where((r) => r.status == _filterStatus)
                                .toList();
                          }

                          // Filter by urgent
                          if (_showUrgentOnly) {
                            filteredReports = filteredReports
                                .where((r) => r.isUrgent)
                                .toList();
                          }

                          // Filter by search query
                          if (_searchQuery.isNotEmpty) {
                            final query = _searchQuery.toLowerCase();
                            filteredReports = filteredReports.where((r) {
                              return r.location.toLowerCase().contains(query) ||
                                  r.title.toLowerCase().contains(query) ||
                                  (r.description?.toLowerCase().contains(
                                        query,
                                      ) ??
                                      false);
                            }).toList();
                          }

                          if (filteredReports.isEmpty) {
                            return EmptyStateWidget.custom(
                              icon: Icons.inbox_outlined,
                              title: 'Tidak ada laporan',
                              subtitle: _searchQuery.isNotEmpty
                                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                                  : 'Belum ada laporan yang sesuai filter',
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              final departmentId = ref.read(
                                currentUserDepartmentProvider,
                              );
                              ref.invalidate(allReportsProvider(departmentId));
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredReports.length,
                              itemBuilder: (context, index) {
                                final report = filteredReports[index];
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.06),
                                        blurRadius: 12,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      onTap: () => _showReportDetail(report),
                                      borderRadius: BorderRadius.circular(16),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Status Icon with gradient
                                            Container(
                                              padding: const EdgeInsets.all(12),
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: [
                                                    report.status.color,
                                                    report.status.color
                                                        .withOpacity(0.7),
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: report.status.color
                                                        .withOpacity(0.3),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: Icon(
                                                report.status.icon,
                                                color: Colors.white,
                                                size: 24,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            // Content
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Title with urgent badge
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          report.location,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                                color: Color(
                                                                  0xFF1A1A1A,
                                                                ),
                                                              ),
                                                        ),
                                                      ),
                                                      if (report.isUrgent)
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 8,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            gradient:
                                                                const LinearGradient(
                                                                  colors: [
                                                                    Color(
                                                                      0xFFFF6B6B,
                                                                    ),
                                                                    Color(
                                                                      0xFFFF5252,
                                                                    ),
                                                                  ],
                                                                ),
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  8,
                                                                ),
                                                            boxShadow: [
                                                              BoxShadow(
                                                                color:
                                                                    const Color(
                                                                      0xFFFF6B6B,
                                                                    ).withOpacity(
                                                                      0.3,
                                                                    ),
                                                                blurRadius: 4,
                                                                offset:
                                                                    const Offset(
                                                                      0,
                                                                      2,
                                                                    ),
                                                              ),
                                                            ],
                                                          ),
                                                          child: const Text(
                                                            'URGENT',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              letterSpacing:
                                                                  0.5,
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  // Username and time
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.person_outline,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Expanded(
                                                        child: Text(
                                                          report.userName,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Colors
                                                                .grey[700],
                                                          ),
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.access_time,
                                                        size: 14,
                                                        color: Colors.grey[600],
                                                      ),
                                                      const SizedBox(width: 4),
                                                      Text(
                                                        DateFormatter.relativeTime(
                                                          report.date,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 12,
                                                          color:
                                                              Colors.grey[600],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Chevron icon
                                            Icon(
                                              Icons.chevron_right,
                                              color: Colors.grey[400],
                                              size: 24,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                        loading: () =>
                            const Center(child: CircularProgressIndicator()),
                        error: (error, stack) => _buildErrorState(error),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  } // ==================== MOBILE LAYOUT ====================

  Widget _buildMobileLayout(AsyncValue<List<Report>> allReportsAsync) {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),

        // Filter chips
        if (_filterStatus != null || _showUrgentOnly) _buildFilterChips(),

        // Reports list
        Expanded(
          child: allReportsAsync.when(
            data: (reports) {
              // Apply filters
              var filteredReports = reports;

              // Filter by status
              if (_filterStatus != null) {
                filteredReports = filteredReports
                    .where((r) => r.status == _filterStatus)
                    .toList();
              }

              // Filter by urgent
              if (_showUrgentOnly) {
                filteredReports = filteredReports
                    .where((r) => r.isUrgent)
                    .toList();
              }

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                filteredReports = filteredReports.where((r) {
                  return r.location.toLowerCase().contains(query) ||
                      r.title.toLowerCase().contains(query) ||
                      (r.description?.toLowerCase().contains(query) ?? false);
                }).toList();
              }

              if (filteredReports.isEmpty) {
                return EmptyStateWidget.custom(
                  icon: Icons.inbox_outlined,
                  title: 'Tidak ada laporan',
                  subtitle: _searchQuery.isNotEmpty
                      ? 'Tidak ada hasil untuk "$_searchQuery"'
                      : 'Belum ada laporan yang sesuai filter',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  final departmentId = ref.read(currentUserDepartmentProvider);
                  ref.invalidate(allReportsProvider(departmentId));
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                  itemCount: filteredReports.length,
                  itemBuilder: (context, index) {
                    final report = filteredReports[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _showReportDetail(report),
                          borderRadius: BorderRadius.circular(16),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Status Icon with gradient
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        report.status.color,
                                        report.status.color.withOpacity(0.7),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: report.status.color.withOpacity(
                                          0.3,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    report.status.icon,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Title with urgent badge
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              report.location,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: Color(0xFF1A1A1A),
                                              ),
                                            ),
                                          ),
                                          if (report.isUrgent)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    Color(0xFFFF6B6B),
                                                    Color(0xFFFF5252),
                                                  ],
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: const Color(
                                                      0xFFFF6B6B,
                                                    ).withOpacity(0.3),
                                                    blurRadius: 4,
                                                    offset: const Offset(0, 2),
                                                  ),
                                                ],
                                              ),
                                              child: const Text(
                                                'URGENT',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      // Username and time
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person_outline,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              report.userName,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: Colors.grey[600],
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            DateFormatter.relativeTime(
                                              report.date,
                                            ),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // Chevron icon
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => _buildErrorState(error),
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
            // Title
            const Text(
              'Kelola Laporan',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Spacer(),

            // Filter button
            IconButton(
              icon: const Icon(
                Icons.filter_list,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                // Show filter menu
              },
              tooltip: 'Filter',
            ),
            const SizedBox(width: 8),

            // Notification Icon (placeholder)
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {},
            ),
            const SizedBox(width: 16),

            // Profile Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SEARCH BAR ====================

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari laporan, lokasi, atau deskripsi...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
      ),
    );
  }

  // ==================== FILTER CHIPS ====================

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (_filterStatus != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _filterStatus!.color,
                    _filterStatus!.color.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _filterStatus!.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_filterStatus!.icon, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    _filterStatus!.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _filterStatus = null),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          if (_showUrgentOnly)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.error, Color(0xFFE06B6B)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.error.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.warning, size: 16, color: Colors.white),
                  const SizedBox(width: 6),
                  const Text(
                    'Urgent',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _showUrgentOnly = false),
                    child: const Icon(
                      Icons.close,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ==================== ERROR STATE ====================

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
          const SizedBox(height: 16),
          Text(
            'Terjadi kesalahan',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final departmentId = ref.read(currentUserDepartmentProvider);
              ref.invalidate(allReportsProvider(departmentId));
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  // ==================== FLOATING ACTION BUTTON ====================
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        // Action untuk membuat laporan baru (jika ada)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur membuat laporan baru')),
        );
      },
      backgroundColor: AppTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // ==================== SHOW REPORT DETAIL ====================

  void _showReportDetail(Report report) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReportDetailScreen(report: report),
      ),
    );
  }
}
