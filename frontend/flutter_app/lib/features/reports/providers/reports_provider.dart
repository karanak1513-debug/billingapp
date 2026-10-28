import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/repositories/repository_provider.dart';

enum ReportPeriod {
  today,
  thisWeek,
  thisMonth,
  custom,
}

class ReportPeriodNotifier extends Notifier<ReportPeriod> {
  @override
  ReportPeriod build() => ReportPeriod.today;

  @override
  set state(ReportPeriod value) => super.state = value;

  void setPeriod(ReportPeriod period) => state = period;
}

final selectedReportPeriodProvider =
    NotifierProvider<ReportPeriodNotifier, ReportPeriod>(
      ReportPeriodNotifier.new,
    );

class CustomDateRangeNotifier extends Notifier<DateTimeRange?> {
  @override
  DateTimeRange? build() => null;

  @override
  set state(DateTimeRange? value) => super.state = value;

  void setRange(DateTimeRange? range) => state = range;
}

final customDateRangeProvider =
    NotifierProvider<CustomDateRangeNotifier, DateTimeRange?>(
      CustomDateRangeNotifier.new,
    );

final shiftReportProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repo = ref.watch(posRepositoryProvider);
  final period = ref.watch(selectedReportPeriodProvider);
  final customRange = ref.watch(customDateRangeProvider);

  final now = DateTime.now();
  DateTime? start;
  DateTime? end;

  switch (period) {
    case ReportPeriod.today:
      start = DateTime(now.year, now.month, now.day, 0, 0, 0);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      break;
    case ReportPeriod.thisWeek:
      // Current week from Monday to now
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      break;
    case ReportPeriod.thisMonth:
      start = DateTime(now.year, now.month, 1, 0, 0, 0);
      end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      break;
    case ReportPeriod.custom:
      if (customRange != null) {
        start = DateTime(
          customRange.start.year,
          customRange.start.month,
          customRange.start.day,
          0,
          0,
          0,
        );
        end = DateTime(
          customRange.end.year,
          customRange.end.month,
          customRange.end.day,
          23,
          59,
          59,
          999,
        );
      } else {
        start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
      }
      break;
  }

  final report = await repo.getShiftReport(startDate: start, endDate: end);
  final recentSales = await repo.getSales(startDate: start, endDate: end, limit: 5);

  return {
    ...report,
    'start_date': start,
    'end_date': end,
    'recent_sales': recentSales,
  };
});
