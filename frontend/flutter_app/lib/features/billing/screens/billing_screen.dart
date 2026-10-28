import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../providers/cart_provider.dart';
import '../widgets/food_item_card.dart';
import '../widgets/sticky_cart_bar.dart';
import '../widgets/cart_bottom_sheet.dart';
import '../../products/providers/products_provider.dart';
import '../../products/screens/product_management_screen.dart';
import '../../../data/repositories/repository_provider.dart';

class BillingScreen extends ConsumerStatefulWidget {
  const BillingScreen({super.key});

  @override
  ConsumerState<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends ConsumerState<BillingScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentToken = 1;
  String _cashierName = AppConstants.defaultCashier;

  @override
  void initState() {
    super.initState();
    _loadShiftMeta();
  }

  Future<void> _loadShiftMeta() async {
    try {
      final repo = ref.read(posRepositoryProvider);
      final token = await repo.getCurrentToken();
      final cashier = await repo.getCashierName();
      if (mounted) {
        setState(() {
          _currentToken = token;
          _cashierName = cashier;
        });
      }
    } catch (e) {
      debugPrint('Warning: Could not load shift meta: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openCartDrawer() {
    CartBottomSheet.show(
      context,
      tokenNumber: _currentToken,
      cashierName: _cashierName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(filteredProductsProvider);
    final allProductsAsync = ref.watch(productsProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);
    final cartState = ref.watch(cartProvider);

    // Calculate dynamic category counts
    final Map<String, int> categoryCounts = {};
    int totalCount = 0;
    allProductsAsync.whenData((all) {
      totalCount = all.length;
      for (final p in all) {
        final cat = p.category.toLowerCase();
        categoryCounts[cat] = (categoryCounts[cat] ?? 0) + 1;
      }
    });

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        toolbarHeight: 70,
        backgroundColor: AppColors.burgundy,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.caramelAccent, width: 1.5),
                image: const DecorationImage(
                  image: AssetImage(AppConstants.imgLogo),
                  fit: BoxFit.cover,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.caramelAccent,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'ACTIVE SHIFT • LIVE',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.caramelFixed,
                          fontSize: 9.5,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  Text(
                    AppConstants.appName,
                    style: AppTypography.headlineMedium.copyWith(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    AppConstants.appTagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.caramelFixed.withValues(alpha: 0.85),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Manage Menu / Products Quick Access
          IconButton(
            tooltip: 'Manage Products & Menu',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductManagementScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.caramelAccent,
              size: 24,
            ),
          ),
          // Quick Cart Icon Button with dynamic badge
          IconButton(
            onPressed: _openCartDrawer,
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  color: AppColors.caramelAccent,
                  size: 26,
                ),
                if (cartState.totalItemCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 5,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.terracotta,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${cartState.totalItemCount}',
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // Cashier Profile Pill
          Padding(
            padding: const EdgeInsets.only(right: 14, left: 4),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.burgundyDark,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                child: Row(
                  children: [
                    // Search Bar
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.creamContainer,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.borderSubtle,
                            width: 0.8,
                          ),
                        ),
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'Search snacks or drinks...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref
                                              .read(
                                                searchQueryProvider.notifier,
                                              )
                                              .setQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                          style: AppTypography.bodyMedium,
                          onChanged: (val) {
                            ref.read(searchQueryProvider.notifier).setQuery(val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Dynamic Category Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildCategoryChip(
                      label: 'All Items',
                      count: totalCount,
                      isSelected: selectedCategory == 'all',
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).setCategory('all');
                      },
                    ),
                    ...categoryCounts.entries.map((entry) {
                      final cat = entry.key;
                      final count = entry.value;
                      String displayLabel;
                      if (cat == 'snacks') {
                        displayLabel = 'Crispy Snacks';
                      } else if (cat == 'drinks' || cat == 'sips') {
                        displayLabel = 'Chilled Drinks';
                      } else {
                        displayLabel = cat.substring(0, 1).toUpperCase() + cat.substring(1);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: _buildCategoryChip(
                          label: displayLabel,
                          count: count,
                          isSelected: selectedCategory.toLowerCase() == cat,
                          onTap: () {
                            ref.read(selectedCategoryProvider.notifier).setCategory(cat);
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),

              // Product Touch Grid
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.burgundy,
                  onRefresh: () async {
                    ref.invalidate(productsProvider);
                    await _loadShiftMeta();
                  },
                  child: productsAsync.when(
                    data: (products) {
                      if (products.isEmpty) {
                        final isFiltering = _searchController.text.isNotEmpty ||
                            selectedCategory != 'all';

                        return ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.45,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        isFiltering
                                            ? Icons.search_off
                                            : Icons.restaurant_menu_rounded,
                                        size: 52,
                                        color: AppColors.textMuted,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        isFiltering
                                            ? 'No matching snacks or drinks found'
                                            : 'No active products in menu',
                                        style: AppTypography.headlineSmall.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        isFiltering
                                            ? 'Try searching with a different keyword or clear filters.'
                                            : 'Tap below to safely restore standard Snacks O\'Clock items.',
                                        style: AppTypography.bodySmall,
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 16),
                                      if (isFiltering)
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.burgundy,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () {
                                            _searchController.clear();
                                            ref.read(searchQueryProvider.notifier).setQuery('');
                                            ref.read(selectedCategoryProvider.notifier).setCategory('all');
                                          },
                                          child: const Text('Clear Filters'),
                                        )
                                      else
                                        ElevatedButton.icon(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.burgundy,
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () async {
                                            await ref.read(posRepositoryProvider).restoreDefaultMenu();
                                            ref.invalidate(productsProvider);
                                          },
                                          icon: const Icon(Icons.restore, size: 16),
                                          label: const Text('Restore Default Menu'),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return GridView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.72,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final qty = cartState.getQuantity(product.id);

                          return FoodItemCard(
                            product: product,
                            quantityInCart: qty,
                            onIncrement: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .addOrIncrement(product);
                            },
                            onDecrement: () {
                              ref
                                  .read(cartProvider.notifier)
                                  .decrement(product.id);
                            },
                          );
                        },
                      );
                    },
                    loading: () => const Center(
                      child: CircularProgressIndicator(color: AppColors.burgundy),
                    ),
                    error: (err, stack) => ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.45,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppColors.errorRed,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Failed to load products',
                                    style: AppTypography.headlineSmall.copyWith(
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$err',
                                    style: AppTypography.bodySmall.copyWith(
                                      color: AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.burgundy,
                                          foregroundColor: Colors.white,
                                        ),
                                        onPressed: () {
                                          ref.invalidate(productsProvider);
                                        },
                                        icon: const Icon(Icons.refresh, size: 16),
                                        label: const Text('Retry'),
                                      ),
                                      const SizedBox(width: 12),
                                      OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: AppColors.burgundy,
                                          side: const BorderSide(color: AppColors.burgundy),
                                        ),
                                        onPressed: () async {
                                          await ref
                                              .read(posRepositoryProvider)
                                              .restoreDefaultMenu();
                                          ref.invalidate(productsProvider);
                                        },
                                        icon: const Icon(Icons.restore, size: 16),
                                        label: const Text('Restore Menu'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Order Bar (Floating above grid)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: StickyCartBar(onTapViewCart: _openCartDrawer),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.burgundy : AppColors.creamContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.burgundy.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppTypography.labelMedium.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.burgundyDark.withValues(alpha: 0.5)
                    : AppColors.creamHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: AppTypography.keypadDigit.copyWith(
                  fontSize: 11,
                  color: isSelected
                      ? AppColors.caramelFixed
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
