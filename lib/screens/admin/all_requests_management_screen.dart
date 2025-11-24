// lib/screens/admin/all_requests_management_screen.dart
// Management screen untuk semua requests dengan assign/reassign cleaner

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../models/request.dart';
import '../../providers/riverpod/request_providers.dart';
import '../../widgets/shared/request_card_widget.dart';
import '../../widgets/shared/empty_state_widget.dart';
import '../../widgets/admin/admin_sidebar.dart';
import '../../widgets/layouts/admin_base_layout.dart';
import '../shared/request_detail/request_detail_screen.dart';

class AllRequestsManagementScreen extends ConsumerStatefulWidget {
  const AllRequestsManagementScreen({super.key});

  @override
  ConsumerState<AllRequestsManagementScreen> createState() =>
      _AllRequestsManagementScreenState();
}

class _AllRequestsManagementScreenState
    extends ConsumerState<AllRequestsManagementScreen> {
  // Filter state
  RequestStatus? _filterStatus;
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
    final allRequestsAsync = ref.watch(allRequestsProvider);
    final isMobile = ResponsiveHelper.isMobile(context);

    // For mobile, use modern AdminBaseLayout
    if (isMobile) {
      return AdminBaseLayout(
        title: 'Kelola Permintaan',
        currentNavIndex: 2, // Permintaan index
        actions: [_buildFilterButton()],
        showFAB: true,
        floatingActionButton: _buildFAB(),
        child: _buildMobileLayout(allRequestsAsync),
      );
    }

    // For desktop, keep existing layout with sidebar
    return Scaffold(
      backgroundColor: AppTheme.modernBg,
      body: _buildDesktopLayout(allRequestsAsync),
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
            _filterStatus = RequestStatus.values.firstWhere(
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
        ...RequestStatus.values.map((status) {
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
  Widget _buildDesktopLayout(AsyncValue<List<Request>> allRequestsAsync) {
    return Row(
      children: [
        // Persistent Sidebar
        const AdminSidebar(currentRoute: 'requests_management'),

        // Main Content with Custom Header
        Expanded(
          child: Column(
            children: [
              // Custom Header Bar (Blue Background)
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

                    // Summary stats
                    _buildSummaryStats(allRequestsAsync),

                    // Requests list
                    Expanded(
                      child: allRequestsAsync.when(
                        data: (requests) {
                          // Apply filters
                          var filteredRequests = requests;

                          // Filter by status
                          if (_filterStatus != null) {
                            filteredRequests = filteredRequests
                                .where((r) => r.status == _filterStatus)
                                .toList();
                          }

                          // Filter by urgent
                          if (_showUrgentOnly) {
                            filteredRequests = filteredRequests
                                .where((r) => r.isUrgent)
                                .toList();
                          }

                          // Filter by search query
                          if (_searchQuery.isNotEmpty) {
                            final query = _searchQuery.toLowerCase();
                            filteredRequests = filteredRequests.where((r) {
                              return r.location.toLowerCase().contains(query) ||
                                  r.description.toLowerCase().contains(query) ||
                                  r.requestedByName.toLowerCase().contains(
                                    query,
                                  );
                            }).toList();
                          }

                          if (filteredRequests.isEmpty) {
                            return EmptyStateWidget.custom(
                              icon: Icons.inbox_outlined,
                              title: 'Tidak ada permintaan',
                              subtitle: _searchQuery.isNotEmpty
                                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                                  : 'Belum ada permintaan yang sesuai filter',
                            );
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              ref.invalidate(allRequestsProvider);
                              await Future.delayed(
                                const Duration(milliseconds: 500),
                              );
                            },
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: filteredRequests.length,
                              itemBuilder: (context, index) {
                                final request = filteredRequests[index];
                                return RequestCardWidget(
                                  request: request,
                                  animationIndex: index,
                                  compact: false,
                                  showAssignee: true,
                                  onTap: () => _showRequestDetail(request),
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
  }

  // ==================== MOBILE LAYOUT ====================
  Widget _buildMobileLayout(AsyncValue<List<Request>> allRequestsAsync) {
    return Column(
      children: [
        // Search bar
        _buildSearchBar(),

        // Filter chips
        if (_filterStatus != null || _showUrgentOnly) _buildFilterChips(),

        // Summary stats
        _buildSummaryStats(allRequestsAsync),

        // Requests list
        Expanded(
          child: allRequestsAsync.when(
            data: (requests) {
              // Apply filters
              var filteredRequests = requests;

              // Filter by status
              if (_filterStatus != null) {
                filteredRequests = filteredRequests
                    .where((r) => r.status == _filterStatus)
                    .toList();
              }

              // Filter by urgent
              if (_showUrgentOnly) {
                filteredRequests = filteredRequests
                    .where((r) => r.isUrgent)
                    .toList();
              }

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                final query = _searchQuery.toLowerCase();
                filteredRequests = filteredRequests.where((r) {
                  return r.location.toLowerCase().contains(query) ||
                      r.description.toLowerCase().contains(query) ||
                      r.requestedByName.toLowerCase().contains(query);
                }).toList();
              }

              if (filteredRequests.isEmpty) {
                return EmptyStateWidget.custom(
                  icon: Icons.inbox_outlined,
                  title: 'Tidak ada permintaan',
                  subtitle: _searchQuery.isNotEmpty
                      ? 'Tidak ada hasil untuk "$_searchQuery"'
                      : 'Belum ada permintaan yang sesuai filter',
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(allRequestsProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filteredRequests.length,
                  itemBuilder: (context, index) {
                    final request = filteredRequests[index];
                    return RequestCardWidget(
                      request: request,
                      animationIndex: index,
                      compact: false,
                      showAssignee: true,
                      onTap: () => _showRequestDetail(request),
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

  // ==================== DESKTOP HEADER (Blue Bar) ====================
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
              'Kelola Permintaan',
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
                // Filter functionality is in the filter chips
              },
              tooltip: 'Filter',
            ),
            const SizedBox(width: 8),

            // Stats button
            IconButton(
              icon: const Icon(
                Icons.analytics_outlined,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () => _showStatsDialog(),
              tooltip: 'Statistik',
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
          hintText: 'Cari lokasi, requester, atau deskripsi...',
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

  // ==================== SUMMARY STATS ====================

  Widget _buildSummaryStats(AsyncValue<List<Request>> requestsAsync) {
    return requestsAsync.when(
      data: (requests) {
        final pending = requests
            .where((r) => r.status == RequestStatus.pending)
            .length;
        final active = requests.where((r) => r.status.isActive).length;
        final completed = requests
            .where((r) => r.status == RequestStatus.completed)
            .length;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.all(16),
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
          child: Row(
            children: [
              _buildStatItem('Pending', pending, AppTheme.warning),
              _buildStatItem('Aktif', active, AppTheme.info),
              _buildStatItem('Selesai', completed, AppTheme.success),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
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
          const Text(
            'Terjadi kesalahan',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => ref.invalidate(allRequestsProvider),
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
        // Action untuk membuat permintaan baru
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fitur membuat permintaan baru')),
        );
      },
      backgroundColor: AppTheme.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  // ==================== SHOW REQUEST DETAIL ====================

  void _showRequestDetail(Request request) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RequestDetailScreen(requestId: request.id),
      ),
    );
  }

  // ==================== SHOW STATS DIALOG ====================

  void _showStatsDialog() {
    final requestsAsync = ref.read(allRequestsProvider);

    requestsAsync.whenData((requests) {
      final total = requests.length;
      final pending = requests
          .where((r) => r.status == RequestStatus.pending)
          .length;
      final assigned = requests
          .where((r) => r.status == RequestStatus.assigned)
          .length;
      final inProgress = requests
          .where((r) => r.status == RequestStatus.inProgress)
          .length;
      final completed = requests
          .where((r) => r.status == RequestStatus.completed)
          .length;
      final cancelled = requests
          .where((r) => r.status == RequestStatus.cancelled)
          .length;
      final urgent = requests.where((r) => r.isUrgent).length;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Statistik Permintaan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatRow('Total Permintaan', total, Colors.grey[700]!),
              const Divider(),
              _buildStatRow('Pending', pending, AppTheme.warning),
              _buildStatRow('Ditugaskan', assigned, AppTheme.secondary),
              _buildStatRow('Dikerjakan', inProgress, AppTheme.info),
              _buildStatRow('Selesai', completed, AppTheme.success),
              _buildStatRow('Dibatalkan', cancelled, AppTheme.error),
              const Divider(),
              _buildStatRow('Urgent', urgent, AppTheme.error),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildStatRow(String label, int value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
