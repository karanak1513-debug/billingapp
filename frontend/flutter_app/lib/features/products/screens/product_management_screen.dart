import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/repository_provider.dart';
import '../models/product.dart';
import '../providers/products_provider.dart';
import '../widgets/app_product_image.dart';
import 'product_form_screen.dart';

/// Screen for full product & menu management
class ProductManagementScreen extends ConsumerStatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  ConsumerState<ProductManagementScreen> createState() =>
      _ProductManagementScreenState();
}

class _ProductManagementScreenState
    extends ConsumerState<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reset filters on open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adminSearchQueryProvider.notifier).setQuery('');
      ref.read(adminCategoryFilterProvider.notifier).setCategory('all');
      ref
          .read(adminStatusFilterProvider.notifier)
          .setFilter(ProductStatusFilter.all);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _openProductForm([Product? product]) async {
    final result = await Navigator.push<Product>(
      context,
      MaterialPageRoute(
        builder: (context) => ProductFormScreen(product: product),
      ),
    );

    if (result != null) {
      // Refresh providers
      ref.invalidate(adminProductsProvider);
      ref.invalidate(productsProvider);
      ref.invalidate(categoriesProvider);
    }
  }

  Future<void> _toggleProductActive(Product product, bool newActive) async {
    try {
      final repo = ref.read(posRepositoryProvider);
      await repo.setProductActive(product.id, newActive);

      ref.invalidate(adminProductsProvider);
      ref.invalidate(productsProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newActive
                ? '"${product.name}" is now Available for billing'
                : '"${product.name}" is now Deactivated (hidden from billing)',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor:
              newActive ? AppColors.successGreen : AppColors.textSecondary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    }
  }

  Future<void> _confirmDeleteProduct(Product product) async {
    final repo = ref.read(posRepositoryProvider);
    final hasSales = await repo.isProductReferencedInSales(product.id);

    if (!mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.creamCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              hasSales ? Icons.archive_outlined : Icons.delete_outline,
              color: hasSales ? AppColors.terracotta : AppColors.errorRed,
            ),
            const SizedBox(width: 8),
            Text(
              hasSales ? 'Deactivate Product?' : 'Delete Product?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${product.name}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            Text(
              hasSales
                  ? 'This product is referenced in historical sales records. To protect your sales reports, receipts and audit history, it will be safely deactivated and removed from the active POS menu rather than deleted permanently.'
                  : 'This product has no recorded sales. It will be permanently removed from your catalog.',
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSales ? AppColors.terracotta : AppColors.errorRed,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(hasSales ? 'Deactivate' : 'Delete Permanently'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final wasDeleted = await repo.deleteProductSafely(product.id);
        ref.invalidate(adminProductsProvider);
        ref.invalidate(productsProvider);
        ref.invalidate(categoriesProvider);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              wasDeleted
                  ? 'Product "${product.name}" deleted successfully.'
                  : 'Product "${product.name}" safely deactivated and hidden from billing.',
            ),
            backgroundColor: AppColors.successGreen,
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredProductsAsync = ref.watch(filteredAdminProductsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategory = ref.watch(adminCategoryFilterProvider);
    final selectedStatus = ref.watch(adminStatusFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Manage Products',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Dynamic Menu & Pricing Control',
              style: TextStyle(fontSize: 12, color: AppColors.caramelAccent),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Add New Product',
            icon: const Icon(Icons.add_circle_outline, size: 26),
            onPressed: () => _openProductForm(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () => _openProductForm(),
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Product',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Search Bar & Filter Header
          _buildSearchAndFilters(categoriesAsync, selectedCategory, selectedStatus),

          // Product List
          Expanded(
            child: filteredProductsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.burgundy),
              ),
              error: (err, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: AppColors.errorRed),
                      const SizedBox(height: 12),
                      Text('Error loading products: $err', textAlign: TextAlign.center),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(adminProductsProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              data: (products) {
                if (products.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: AppColors.burgundy,
                  onRefresh: () async {
                    ref.invalidate(adminProductsProvider);
                    ref.invalidate(productsProvider);
                    ref.invalidate(categoriesProvider);
                  },
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
                    itemCount: products.length,
                    separatorBuilder: (ctx, i) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final product = products[index];
                      return _buildProductCard(product);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(
    AsyncValue<List<String>> categoriesAsync,
    String selectedCategory,
    ProductStatusFilter selectedStatus,
  ) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search input
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search products by name or category...',
              prefixIcon: const Icon(Icons.search, color: AppColors.burgundy),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(adminSearchQueryProvider.notifier).setQuery('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: AppColors.creamLow,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.borderSubtle),
              ),
            ),
            onChanged: (val) {
              ref.read(adminSearchQueryProvider.notifier).setQuery(val);
              setState(() {});
            },
          ),
          const SizedBox(height: 10),

          // Status & Category filters
          Row(
            children: [
              // Status segment
              Container(
                decoration: BoxDecoration(
                  color: AppColors.creamLow,
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatusSegment('All', ProductStatusFilter.all, selectedStatus),
                    _buildStatusSegment('Active', ProductStatusFilter.active, selectedStatus),
                    _buildStatusSegment('Inactive', ProductStatusFilter.inactive, selectedStatus),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // Category scrollable chips
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('all', 'All Categories', selectedCategory),
                      ...categoriesAsync.maybeWhen(
                        data: (cats) => cats.map(
                          (c) => _buildCategoryChip(c, c == 'sips' ? 'DRINKS' : c.toUpperCase(), selectedCategory),
                        ),
                        orElse: () => [
                          _buildCategoryChip('snacks', 'SNACKS', selectedCategory),
                          _buildCategoryChip('drinks', 'DRINKS', selectedCategory),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSegment(
    String label,
    ProductStatusFilter filter,
    ProductStatusFilter current,
  ) {
    final isSelected = filter == current;
    return GestureDetector(
      onTap: () => ref.read(adminStatusFilterProvider.notifier).setFilter(filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.burgundy : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String catId, String label, String selectedCat) {
    final isSelected = catId.toLowerCase() == selectedCat.toLowerCase();
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        showCheckmark: false,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppColors.textPrimary,
        ),
        backgroundColor: AppColors.creamLow,
        selectedColor: AppColors.terracotta,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isSelected ? AppColors.terracotta : AppColors.borderSubtle,
          ),
        ),
        onSelected: (_) {
          ref.read(adminCategoryFilterProvider.notifier).setCategory(catId);
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 1,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: product.isActive ? AppColors.borderSubtle : AppColors.borderMedium.withValues(alpha: 0.3),
        ),
      ),
      color: product.isActive ? Colors.white : const Color(0xFFF9F5F3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Image Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 68,
                height: 68,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppProductImage(
                      imagePath: product.imageAsset,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    if (!product.isActive)
                      Container(
                        color: Colors.black.withValues(alpha: 0.45),
                        child: const Center(
                          child: Icon(Icons.visibility_off, color: Colors.white, size: 22),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: product.isActive ? AppColors.textPrimary : AppColors.textMuted,
                            decoration: product.isActive ? null : TextDecoration.lineThrough,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (product.badge != null && product.badge!.isNotEmpty) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.caramelAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            product.badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppColors.terracotta,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.creamWarm,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.burgundy,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '₹${product.sellingPrice.toStringAsFixed(0)} ${product.portion}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: product.isActive ? AppColors.burgundy : AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  if (product.description != null && product.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Actions: Active Switch & Edit Menu
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: product.isActive,
                  activeThumbColor: AppColors.successGreen,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (val) => _toggleProductActive(product, val),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 20, color: AppColors.burgundy),
                      tooltip: 'Edit Product',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () => _openProductForm(product),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, size: 20, color: AppColors.errorRed),
                      tooltip: 'Delete / Deactivate',
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(6),
                      onPressed: () => _confirmDeleteProduct(product),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.caramelAccent),
            const SizedBox(height: 16),
            const Text(
              'No Products Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try clearing search filters or add a new product to your menu.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.burgundy,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => _openProductForm(),
              icon: const Icon(Icons.add),
              label: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
