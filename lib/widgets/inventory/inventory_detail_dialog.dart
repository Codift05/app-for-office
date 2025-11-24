import 'package:flutter/material.dart';
import '../../models/inventory_item.dart';
import '../../core/utils/date_formatter.dart';

class InventoryDetailDialog extends StatelessWidget {
  final InventoryItem item;

  const InventoryDetailDialog({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Detail Inventory',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),

              // Item Name
              _buildDetailRow('Nama Item', item.name),
              const SizedBox(height: 12),

              // Category
              _buildDetailRow('Kategori', item.category),
              const SizedBox(height: 12),

              // Unit
              _buildDetailRow('Satuan', item.unit),
              const SizedBox(height: 12),

              // Stock
              _buildDetailRow('Stok', '${item.currentStock}'),
              const SizedBox(height: 12),

              // Minimum Stock
              _buildDetailRow('Stok Minimum', '${item.minStock}'),
              const SizedBox(height: 12),

              // Maximum Stock
              _buildDetailRow('Stok Maksimum', '${item.maxStock}'),
              const SizedBox(height: 12),

              // Description
              if (item.description != null && item.description!.isNotEmpty) ...[
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(item.description!, style: const TextStyle(fontSize: 14)),
                const SizedBox(height: 12),
              ],

              // Updated At
              _buildDetailRow(
                'Terakhir Update',
                DateFormatter.fullDateTime(item.updatedAt),
              ),
              const SizedBox(height: 12),

              // Created At
              _buildDetailRow(
                'Dibuat',
                DateFormatter.fullDateTime(item.createdAt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
