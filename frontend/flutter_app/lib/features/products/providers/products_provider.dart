import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../../../data/repositories/repository_provider.dart';

/// Active products for billing & POS sales
final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  return await repo.getProducts();
});

/// All products (active & inactive) for management
final adminProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  return await repo.getProductsAdmin();
});

/// Distinct list of categories from DB
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  return await repo.getCategories();
});

class SelectedCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  @override
  set state(String value) => super.state = value;

  void setCategory(String category) => state = category;
}

final selectedCategoryProvider =
    NotifierProvider<SelectedCategoryNotifier, String>(
      SelectedCategoryNotifier.new,
    );

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  @override
  set state(String value) => super.state = value;

  void setQuery(String query) => state = query;
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final filteredProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(productsProvider);
  final category = ref.watch(selectedCategoryProvider);
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    return products.where((p) {
      final matchesCategory = category == 'all' || p.category.toLowerCase() == category.toLowerCase();
      final matchesQuery =
          query.isEmpty || p.name.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  });
});

/// Admin filter state providers
class AdminSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  @override
  set state(String value) => super.state = value;

  void setQuery(String query) => state = query;
}

final adminSearchQueryProvider =
    NotifierProvider<AdminSearchQueryNotifier, String>(
      AdminSearchQueryNotifier.new,
    );

class AdminCategoryFilterNotifier extends Notifier<String> {
  @override
  String build() => 'all';

  @override
  set state(String value) => super.state = value;

  void setCategory(String category) => state = category;
}

final adminCategoryFilterProvider =
    NotifierProvider<AdminCategoryFilterNotifier, String>(
      AdminCategoryFilterNotifier.new,
    );

enum ProductStatusFilter { all, active, inactive }

class AdminStatusFilterNotifier extends Notifier<ProductStatusFilter> {
  @override
  ProductStatusFilter build() => ProductStatusFilter.all;

  @override
  set state(ProductStatusFilter value) => super.state = value;

  void setFilter(ProductStatusFilter filter) => state = filter;
}

final adminStatusFilterProvider =
    NotifierProvider<AdminStatusFilterNotifier, ProductStatusFilter>(
      AdminStatusFilterNotifier.new,
    );

/// Filtered admin products list
final filteredAdminProductsProvider = Provider<AsyncValue<List<Product>>>((ref) {
  final productsAsync = ref.watch(adminProductsProvider);
  final category = ref.watch(adminCategoryFilterProvider);
  final status = ref.watch(adminStatusFilterProvider);
  final query = ref.watch(adminSearchQueryProvider).trim().toLowerCase();

  return productsAsync.whenData((products) {
    return products.where((p) {
      final matchesStatus = switch (status) {
        ProductStatusFilter.all => true,
        ProductStatusFilter.active => p.isActive,
        ProductStatusFilter.inactive => !p.isActive,
      };
      final matchesCategory = category == 'all' || p.category.toLowerCase() == category.toLowerCase();
      final matchesQuery =
          query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query);
      return matchesStatus && matchesCategory && matchesQuery;
    }).toList();
  });
});

