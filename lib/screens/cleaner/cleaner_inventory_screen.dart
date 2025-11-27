// lib/screens/cleaner/cleaner_inventory_screen.dart
// Wrapper for inventory screen with cleaner navbar

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../widgets/layouts/cleaner_base_layout.dart';
import '../../providers/riverpod/inventory_providers.dart';
import '../../providers/riverpod/inventory_selection_provider.dart';
import '../../widgets/inventory/inventory_card.dart';
import '../../widgets/inventory/batch_action_bar.dart';
import '../../core/theme/app_theme.dart';
import '../inventory/inventory_detail_screen.dart';

class CleanerInventoryScreen extends ConsumerStatefulWidget {
  const CleanerInventoryScreen({super.key});

  @override
  ConsumerState<CleanerInventoryScreen> createState() =>
      _CleanerInventoryScreenState();
}

class _CleanerInventoryScreenState
    extends ConsumerState<CleanerInventoryScreen> {
  String _searchQuery = '';
  String? _selectedCategory;
  String _sortBy = 'name';

  @override
  Widget build(BuildContext context) {
    final itemsAsync = ref.watch(allInventoryItemsProvider);
    final isSelectionMode = ref.watch(selectionModeProvider);
    final selectedIds = ref.watch(inventorySelectionProvider);

    return CleanerBaseLayout(
      title: 'Inventaris',
      currentNavIndex: 3,
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: _showSearchDialog,
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Colors.white),
          onPressed: _showFilterDialog,
        ),
      ],
      child: itemsAsync.when(
        data: (items) {
          // Filter items
          var filteredItems = items.where((item) {
            final matchesSearch =
                item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                item.id.toLowerCase().contains(_searchQuery.toLowerCase());
            final matchesCategory =
                _selectedCategory == null || item.category == _selectedCategory;
            return matchesSearch && matchesCategory;
          }).toList();

          // Sort items
          if (_sortBy == 'name') {
            filteredItems.sort((a, b) => a.name.compareTo(b.name));
          } else if (_sortBy == 'stock') {
            filteredItems.sort(
              (a, b) => a.currentStock.compareTo(b.currentStock),
            );
          } else if (_sortBy == 'category') {
            filteredItems.sort((a, b) => a.category.compareTo(b.category));
          }

          if (filteredItems.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Tidak ada item inventaris',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return Stack(
            children: [
              RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(allInventoryItemsProvider);
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
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
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  InventoryDetailScreen(itemId: item.id),
                            ),
                          );
                        }
                      },
                      onLongPress: () {
                        if (!isSelectionMode) {
                          ref.read(selectionModeProvider.notifier).enable();
                          ref
                              .read(inventorySelectionProvider.notifier)
                              .toggleItem(item.id);
                        }
                      },
                    );
                  },
                ),
              ),
              if (isSelectionMode)
                Positioned(
                  bottom: 100,
                  left: 16,
                  right: 16,
                  child: BatchActionBar(
                    allItems: items,
                    onActionComplete: () {
                      ref.invalidate(allInventoryItemsProvider);
                    },
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(allInventoryItemsProvider),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cari Inventaris'),
        content: TextField(
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nama atau kode item...',
            prefixIcon: Icon(Icons.search),
          ),
          onChanged: (value) {
            setState(() => _searchQuery = value);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter & Sort'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Semua Kategori'),
              leading: Radio<String?>(
                value: null,
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Alat Kebersihan'),
              leading: Radio<String?>(
                value: 'Alat Kebersihan',
                groupValue: _selectedCategory,
                onChanged: (value) {
                  setState(() => _selectedCategory = value);
                  Navigator.pop(context);
                },
              ),
            ),
            const Divider(),
            ListTile(
              title: const Text('Sort by Name'),
              leading: Radio<String>(
                value: 'name',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ),
            ListTile(
              title: const Text('Sort by Stock'),
              leading: Radio<String>(
                value: 'stock',
                groupValue: _sortBy,
                onChanged: (value) {
                  setState(() => _sortBy = value!);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
