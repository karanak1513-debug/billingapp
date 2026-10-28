import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/models/sale_record.dart';
import '../../../data/repositories/repository_provider.dart';

enum HistoryDateFilter { today, yesterday, week, custom }

class HistoryFilterState {
  final HistoryDateFilter dateFilter;
  final DateTime? customStartDate;
  final DateTime? customEndDate;
  final String searchQuery;

  const HistoryFilterState({
    this.dateFilter = HistoryDateFilter.today,
    this.customStartDate,
    this.customEndDate,
    this.searchQuery = '',
  });

  HistoryFilterState copyWith({
    HistoryDateFilter? dateFilter,
    DateTime? customStartDate,
    DateTime? customEndDate,
    String? searchQuery,
  }) {
    return HistoryFilterState(
      dateFilter: dateFilter ?? this.dateFilter,
      customStartDate: customStartDate ?? this.customStartDate,
      customEndDate: customEndDate ?? this.customEndDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HistoryFilterNotifier extends Notifier<HistoryFilterState> {
  @override
  HistoryFilterState build() => const HistoryFilterState();

  void setFilter(HistoryDateFilter filter) {
    state = state.copyWith(dateFilter: filter);
  }

  void setCustomRange(DateTime start, DateTime end) {
    state = state.copyWith(
      dateFilter: HistoryDateFilter.custom,
      customStartDate: start,
      customEndDate: end,
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }
}

final historyFilterProvider =
    NotifierProvider<HistoryFilterNotifier, HistoryFilterState>(
      HistoryFilterNotifier.new,
    );

final salesHistoryProvider = FutureProvider<List<SaleRecord>>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  final filter = ref.watch(historyFilterProvider);

  DateTime? start;
  DateTime? end;
  final now = DateTime.now();

  switch (filter.dateFilter) {
    case HistoryDateFilter.today:
      start = DateTime(now.year, now.month, now.day);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case HistoryDateFilter.yesterday:
      final yesterday = now.subtract(const Duration(days: 1));
      start = DateTime(yesterday.year, yesterday.month, yesterday.day);
      end = DateTime(
        yesterday.year,
        yesterday.month,
        yesterday.day,
        23,
        59,
        59,
      );
      break;
    case HistoryDateFilter.week:
      start = now.subtract(const Duration(days: 7));
      end = now;
      break;
    case HistoryDateFilter.custom:
      start = filter.customStartDate;
      end = filter.customEndDate;
      break;
  }

  return await repo.getSales(
    startDate: start,
    endDate: end,
    searchQuery: filter.searchQuery,
  );
});

class HistoryMetrics {
  final double totalSales;
  final int totalOrders;
  final double avgTicket;
  final double cashTotal;
  final double upiTotal;

  const HistoryMetrics({
    required this.totalSales,
    required this.totalOrders,
    required this.avgTicket,
    required this.cashTotal,
    required this.upiTotal,
  });
}

final historyMetricsProvider = Provider<HistoryMetrics>((ref) {
  final salesAsync = ref.watch(salesHistoryProvider);
  return salesAsync.maybeWhen(
    data: (sales) {
      if (sales.isEmpty) {
        return const HistoryMetrics(
          totalSales: 0.0,
          totalOrders: 0,
          avgTicket: 0.0,
          cashTotal: 0.0,
          upiTotal: 0.0,
        );
      }

      double total = 0.0;
      double cash = 0.0;
      double upi = 0.0;

      for (final s in sales) {
        total += s.grandTotal;
        if (s.paymentMethod == 'cash') {
          cash += s.grandTotal;
        } else {
          upi += s.grandTotal;
        }
      }

      final avg = total / sales.length;
      return HistoryMetrics(
        totalSales: total,
        totalOrders: sales.length,
        avgTicket: avg,
        cashTotal: cash,
        upiTotal: upi,
      );
    },
    orElse: () => const HistoryMetrics(
      totalSales: 0.0,
      totalOrders: 0,
      avgTicket: 0.0,
      cashTotal: 0.0,
      upiTotal: 0.0,
    ),
  );
});
