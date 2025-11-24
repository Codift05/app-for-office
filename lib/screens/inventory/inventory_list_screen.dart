// lib/screens/inventory/inventory_list_screen.dart
// Inventory list screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/inventory_item.dart';
import '../../providers/riverpod/inventory_providers.dart';
import '../../providers/riverpod/inventory_selection_provider.dart';
import '../../widgets/inventory/inventory_card.dart';
import '../../widgets/inventory/batch_action_bar.dart';
import '../../widgets/inventory/inventory_detail_dialog.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive_helper.dart';
import '../../utils/responsive_ui_helper.dart';
import './inventory_detail_screen.dart';

class InventoryListScreen extends ConsumerStatefulWidget {
  const InventoryListScreen({super.key});

  @override
  ConsumerState<InventoryListScreen> createState() =>
      _InventoryListScreenState();
}

class _InventoryListScreenState extends ConsumerState<InventoryListScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  StockStatus? _selectedStatus;
  String _sortBy = 'name'; // 'name', 'stock', 'category'

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(allInventoryItemsProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(inventorySelectionProvider);
    final isInDialog = ResponsiveHelper.isDesktop(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(120),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: !isInDialog,
          leading: isSelectionMode
              ? IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    ref.read(selectionModeProvider.notifier).disable();
                  },
                )
              : (isInDialog
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      )),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5FD8A5), Color(0xFF5FC8E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSelectionMode)
                      Row(
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              '${selectedIds.length} item dipilih',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              itemsAsync.whenData((items) {
                                final filtered = _filterItems(items);
                                ref
                                    .read(inventorySelectionProvider.notifier)
                                    .selectAll(
                                      filtered.map((e) => e.id).toList(),
                                    );
                              });
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: const Text('Pilih Semua'),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.inventory_2,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Semua Inventaris',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 24,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Kelola dan pantau semua item',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (!isSelectionMode)
                            PopupMenuButton<String>(
                              icon: const Icon(
                                Icons.more_vert,
                                color: Colors.white,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'select',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.checklist,
                                        size: 20,
                                        color: AppTheme.primary,
                                      ),
                                      SizedBox(width: 12),
                                      Text('Mode Pilih'),
                                    ],
                                  ),
                                ),
                                const PopupMenuDivider(),
                                CheckedPopupMenuItem(
                                  value: 'sort_name',
                                  checked: _sortBy == 'name',
                                  child: const Text('Urutkan: Nama A-Z'),
                                ),
                                CheckedPopupMenuItem(
                                  value: 'sort_stock',
                                  checked: _sortBy == 'stock',
                                  child: const Text('Urutkan: Stok Terendah'),
                                ),
                                CheckedPopupMenuItem(
                                  value: 'sort_category',
                                  checked: _sortBy == 'category',
                                  child: const Text('Urutkan: Kategori'),
                                ),
                              ],
                              onSelected: (value) {
                                if (value == 'select') {
                                  ref
                                      .read(selectionModeProvider.notifier)
                                      .enable();
                                } else if (value == 'sort_name') {
                                  setState(() => _sortBy = 'name');
                                } else if (value == 'sort_stock') {
                                  setState(() => _sortBy = 'stock');
                                } else if (value == 'sort_category') {
                                  setState(() => _sortBy = 'category');
                                }
                              },
                            ),
                          if (isInDialog && !isSelectionMode)
                            IconButton(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.white,
                              ),
                              onPressed: () => Navigator.pop(context),
                              tooltip: 'Tutup',
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildModernSearchAndFilter(),
          const SizedBox(height: 12),
          Expanded(
            child: itemsAsync.when(
              data: (items) {
                final filtered = _filterItems(items);

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(allInventoryItemsProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final isSelected = selectedIds.contains(item.id);

                      return InventoryCard(
                        item: item,
                        isSelectionMode: isSelectionMode,
                        isSelected: isSelected,
                        onTap: () {
                          if (isSelectionMode) {
                            ref
                                .read(inventorySelectionProvider.notifier)
                                .toggleItem(item.id);
                          } else {
                            ResponsiveUIHelper.showDetailView(
                              context: context,
                              mobileScreen: InventoryDetailScreen(
                                itemId: item.id,
                              ),
                              webDialog: InventoryDetailDialog(item: item),
                            );
                          }
                        },
                        onLongPress: () {
                          if (!isSelectionMode) {
                            ref.read(selectionModeProvider.notifier).enable();
                            ref
                                .read(inventorySelectionProvider.notifier)
                                .selectItem(item.id);
                          }
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text('Error: $error'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: itemsAsync.maybeWhen(
        data: (items) => BatchActionBar(
          allItems: items,
          onActionComplete: () {
            ref.invalidate(allInventoryItemsProvider);
          },
        ),
        orElse: () => const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildModernSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Search Bar
          Container(
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
              decoration: InputDecoration(
                hintText: 'Cari item inventaris...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.grey),
                        onPressed: () => setState(() => _searchQuery = ''),
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
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Pills
          Row(
            children: [
              // Category Filter
              Expanded(
                child: _buildFilterChip(
                  icon: Icons.category_outlined,
                  label: _getCategoryLabel(),
                  isActive: _selectedCategory != null,
                  onTap: () => _showCategoryFilter(),
                ),
              ),
              const SizedBox(width: 8),
              // Status Filter
              Expanded(
                child: _buildFilterChip(
                  icon: Icons.inventory_outlined,
                  label: _getStatusLabel(),
                  isActive: _selectedStatus != null,
                  onTap: () => _showStatusFilter(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive ? Colors.white : AppTheme.primary,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isActive) ...[
              const SizedBox(width: 4),
              const Icon(Icons.close, size: 16, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }

  String _getCategoryLabel() {
    if (_selectedCategory == null) return 'Kategori';
    switch (_selectedCategory) {
      case 'alat':
        return 'Alat';
      case 'consumable':
        return 'Bahan';
      case 'ppe':
        return 'APD';
      default:
        return 'Kategori';
    }
  }

  String _getStatusLabel() {
    if (_selectedStatus == null) return 'Status';
    switch (_selectedStatus) {
      case StockStatus.inStock:
        return 'Tersedia';
      case StockStatus.lowStock:
        return 'Rendah';
      case StockStatus.outOfStock:
        return 'Habis';
      default:
        return 'Status';
    }
  }

  void _showCategoryFilter() {
    if (_selectedCategory != null) {
      setState(() => _selectedCategory = null);
      return;
    }

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
              const Text(
                'Pilih Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildCategoryOption(
                'alat',
                'Alat Kebersihan',
                Icons.cleaning_services,
                Colors.blue,
              ),
              _buildCategoryOption(
                'consumable',
                'Bahan Habis Pakai',
                Icons.water_drop,
                Colors.orange,
              ),
              _buildCategoryOption(
                'ppe',
                'Alat Pelindung Diri',
                Icons.security,
                Colors.green,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showStatusFilter() {
    if (_selectedStatus != null) {
      setState(() => _selectedStatus = null);
      return;
    }

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
              const Text(
                'Pilih Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildStatusOption(
                StockStatus.inStock,
                'Stok Cukup',
                Icons.check_circle,
                AppTheme.success,
              ),
              _buildStatusOption(
                StockStatus.lowStock,
                'Stok Rendah',
                Icons.warning,
                AppTheme.warning,
              ),
              _buildStatusOption(
                StockStatus.outOfStock,
                'Habis',
                Icons.cancel,
                AppTheme.error,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        setState(() => _selectedCategory = value);
        Navigator.pop(context);
      },
    );
  }

  Widget _buildStatusOption(
    StockStatus value,
    String label,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      onTap: () {
        setState(() => _selectedStatus = value);
        Navigator.pop(context);
      },
    );
  }

  List<InventoryItem> _filterItems(List<InventoryItem> items) {
    var filtered = items.where((item) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          item.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory =
          _selectedCategory == null || item.category == _selectedCategory;
      final matchesStatus =
          _selectedStatus == null || item.status == _selectedStatus;
      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();

    // Apply sorting
    switch (_sortBy) {
      case 'name':
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'stock':
        filtered.sort((a, b) => a.currentStock.compareTo(b.currentStock));
        break;
      case 'category':
        filtered.sort((a, b) => a.category.compareTo(b.category));
        break;
    }

    return filtered;
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text('Tidak ada item', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
