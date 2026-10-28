import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/sale_record.dart';
import '../../dashboard/providers/navigation_provider.dart';
import '../../settings/screens/settings_screen.dart';
import '../providers/reports_provider.dart';

/// Shift & Margin Reports Screen
/// Redesigned for clean visual hierarchy, responsive layout, accurate data labeling,
/// and smooth scrolling without overlapping widgets.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  final TextEditingController _countedCashController = TextEditingController();
  bool _showReconcileDrawer = false;
  String? _reconcileFeedback;
  Color? _reconcileFeedbackColor;

  @override
  void dispose() {
    _countedCashController.dispose();
    super.dispose();
  }

  void _verifyPhysicalCash(double expectedCash) {
    final entered = double.tryParse(_countedCashController.text.trim()) ?? 0.0;
    final diff = entered - expectedCash;

    setState(() {
      if (diff == 0) {
        _reconcileFeedback = 'Drawer is perfectly balanced! Difference: ₹0';
        _reconcileFeedbackColor = AppColors.successGreen;
      } else if (diff > 0) {
        _reconcileFeedback =
            'Surplus detected in drawer: +${CurrencyFormatter.format(diff)}';
        _reconcileFeedbackColor = AppColors.terracotta;
      } else {
        _reconcileFeedback =
            'Shortage detected in drawer: -${CurrencyFormatter.format(diff.abs())}';
        _reconcileFeedbackColor = AppColors.errorRed;
      }
    });
  }

  Future<void> _selectCustomDateRange() async {
    final currentRange = ref.read(customDateRangeProvider);
    final now = DateTime.now();

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: now,
      initialDateRange: currentRange ??
          DateTimeRange(
            start: now.subtract(const Duration(days: 6)),
            end: now,
          ),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.burgundy,
              onPrimary: Colors.white,
              surface: AppColors.creamCard,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      ref.read(customDateRangeProvider.notifier).setRange(picked);
      ref.read(selectedReportPeriodProvider.notifier).setPeriod(ReportPeriod.custom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final period = ref.watch(selectedReportPeriodProvider);
    final customRange = ref.watch(customDateRangeProvider);
    final reportAsync = ref.watch(shiftReportProvider);

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Shift & Margin Reports',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Financial Intelligence & Shift Audit',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.caramelAccent,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range_outlined, color: Colors.white),
            tooltip: 'Custom Date Range',
            onPressed: _selectCustomDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.tune_outlined, color: Colors.white),
            tooltip: 'Stall Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh Reports',
            onPressed: () => ref.invalidate(shiftReportProvider),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Compact Date & Shift Filter Bar
            _buildDateFilterBar(period, customRange),

            // Scrollable Report Dashboard
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async => ref.invalidate(shiftReportProvider),
                color: AppColors.burgundy,
                child: reportAsync.when(
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
                          Text('Error loading reports: $err', textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.burgundy),
                            onPressed: () => ref.invalidate(shiftReportProvider),
                            child: const Text('Retry', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  data: (data) => _buildReportContent(data),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterBar(ReportPeriod period, DateTimeRange? customRange) {
    String customLabel = 'Custom Range';
    if (customRange != null) {
      final df = DateFormat('d MMM');
      customLabel = '${df.format(customRange.start)} - ${df.format(customRange.end)}';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: AppColors.borderSubtle, width: 0.8),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            _buildFilterChip(
              label: 'Today',
              isLive: true,
              isSelected: period == ReportPeriod.today,
              onTap: () {
                ref.read(selectedReportPeriodProvider.notifier).setPeriod(ReportPeriod.today);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'This Week',
              isSelected: period == ReportPeriod.thisWeek,
              onTap: () {
                ref.read(selectedReportPeriodProvider.notifier).setPeriod(ReportPeriod.thisWeek);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'This Month',
              isSelected: period == ReportPeriod.thisMonth,
              onTap: () {
                ref.read(selectedReportPeriodProvider.notifier).setPeriod(ReportPeriod.thisMonth);
              },
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: customLabel,
              icon: Icons.calendar_month_outlined,
              isSelected: period == ReportPeriod.custom,
              onTap: () {
                _selectCustomDateRange();
              },
            ),
            const SizedBox(width: 10),
            Container(
              height: 24,
              width: 1,
              color: AppColors.borderSubtle,
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.creamContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.successGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'TILL #1 • ACTIVE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w800,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
    bool isLive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.burgundy : AppColors.creamLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.burgundy : AppColors.borderSubtle,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLive) ...[
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.caramelAccent : AppColors.successGreen,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
            ],
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportContent(Map<String, dynamic> data) {
    final grossSales = (data['gross_sales'] as num?)?.toDouble() ?? 0.0;
    final totalBills = (data['total_bills'] as int?) ?? 0;
    final totalItems = (data['total_items'] as int?) ?? 0;
    final totalCogs = (data['total_cogs'] as num?)?.toDouble() ?? 0.0;
    final netProfit = (data['net_profit'] as num?)?.toDouble() ?? 0.0;
    final totalExpenses = (data['total_expenses'] as num?)?.toDouble() ?? 0.0;
    final cashCollection = (data['cash_collection'] as num?)?.toDouble() ?? 0.0;
    final upiCollection = (data['upi_collection'] as num?)?.toDouble() ?? 0.0;
    final openingFloat = (data['opening_float'] as num?)?.toDouble() ?? 1500.0;
    final expectedCashInBox = (data['expected_cash_in_box'] as num?)?.toDouble() ?? (openingFloat + cashCollection - totalExpenses);

    final leaderboard = (data['leaderboard'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final recentSales = (data['recent_sales'] as List?)?.cast<SaleRecord>() ?? [];

    final marginPercent = grossSales > 0 ? ((netProfit / grossSales) * 100) : 0.0;
    final cogsPercent = grossSales > 0 ? ((totalCogs / grossSales) * 100) : 0.0;

    // Single coherent scroll view with generous bottom padding so the BottomNavigationBar never overlaps content!
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
      children: [
        // 1. CASH AND UPI SUMMARY SECTION (Responsive, non-overlapping)
        _buildCashAndUpiSummarySection(
          cashCollection: cashCollection,
          openingFloat: openingFloat,
          totalExpenses: totalExpenses,
          expectedCashInBox: expectedCashInBox,
          upiCollection: upiCollection,
        ),
        const SizedBox(height: 16),

        // 2. FINANCIAL PERFORMANCE KEY METRICS (2x2 Grid)
        _buildFinancialKpiGrid(
          grossSales: grossSales,
          totalBills: totalBills,
          totalItems: totalItems,
          netProfit: netProfit,
          marginPercent: marginPercent,
          totalCogs: totalCogs,
          cogsPercent: cogsPercent,
          totalExpenses: totalExpenses,
        ),
        const SizedBox(height: 16),

        // If no sales exist for this period, show a clear empty state banner
        if (totalBills == 0) ...[
          _buildEmptySalesBanner(),
          const SizedBox(height: 16),
        ],

        // 3. PAYMENT METHOD BREAKDOWN (Cash vs PhonePe UPI)
        if (grossSales > 0) ...[
          _buildPaymentMethodBreakdownCard(
            cashCollection: cashCollection,
            upiCollection: upiCollection,
            grossSales: grossSales,
          ),
          const SizedBox(height: 16),

          // 4. COGS & MARGIN SPLIT VISUALIZATION
          _buildMarginDistributionCard(
            netProfit: netProfit,
            marginPercent: marginPercent,
            totalCogs: totalCogs,
            cogsPercent: cogsPercent,
            totalExpenses: totalExpenses,
            grossSales: grossSales,
          ),
          const SizedBox(height: 16),
        ],

        // 5. CASH DRAWER AUDIT & RECONCILIATION ACCORDION
        _buildDrawerReconciliationCard(
          openingFloat: openingFloat,
          cashCollection: cashCollection,
          totalExpenses: totalExpenses,
          expectedCashInBox: expectedCashInBox,
        ),
        const SizedBox(height: 16),

        // 6. BEST-SELLING PRODUCTS LEADERBOARD
        _buildLeaderboardSection(leaderboard),
        const SizedBox(height: 16),

        // 7. RECENT TRANSACTIONS IN PERIOD
        _buildRecentTransactionsSection(recentSales),
        const SizedBox(height: 24),
      ],
    );
  }

  /// Two responsive summary cards for Cash in Drawer and PhonePe/UPI
  Widget _buildCashAndUpiSummarySection({
    required double cashCollection,
    required double openingFloat,
    required double totalExpenses,
    required double expectedCashInBox,
    required double upiCollection,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If screen width is very small (<320), stack cards vertically; otherwise side-by-side
        final isNarrow = constraints.maxWidth < 320;

        final cashCard = _buildSummaryPillCard(
          title: 'Cash in Drawer',
          amount: expectedCashInBox,
          icon: Icons.payments_rounded,
          iconBg: AppColors.creamContainer,
          iconColor: AppColors.terracotta,
          badgeText: 'Cash In Till',
          badgeColor: AppColors.terracotta,
          description:
              'Float: ${CurrencyFormatter.formatCompact(openingFloat)} • Cash: ${CurrencyFormatter.formatCompact(cashCollection)} • Exp: -${CurrencyFormatter.formatCompact(totalExpenses)}',
        );

        final upiCard = _buildSummaryPillCard(
          title: 'PhonePe / UPI',
          amount: upiCollection,
          icon: Icons.qr_code_2_rounded,
          iconBg: AppColors.phonePePurpleLight,
          iconColor: AppColors.phonePePurple,
          badgeText: 'UPI Verified',
          badgeColor: AppColors.phonePePurple,
          description: 'Recorded PhonePe, GPay & QR app collections',
        );

        if (isNarrow) {
          return Column(
            children: [
              cashCard,
              const SizedBox(height: 10),
              upiCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: cashCard),
            const SizedBox(width: 12),
            Expanded(child: upiCard),
          ],
        );
      },
    );
  }

  Widget _buildSummaryPillCard({
    required String title,
    required double amount,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String badgeText,
    required Color badgeColor,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.borderSubtle,
          width: 0.9,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badgeText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: badgeColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            CurrencyFormatter.format(amount),
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: AppColors.burgundy,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: const TextStyle(
              fontSize: 10.5,
              color: AppColors.textMuted,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// 2x2 Financial KPI Grid
  Widget _buildFinancialKpiGrid({
    required double grossSales,
    required int totalBills,
    required int totalItems,
    required double netProfit,
    required double marginPercent,
    required double totalCogs,
    required double cogsPercent,
    required double totalExpenses,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.analytics_outlined, size: 16, color: AppColors.terracotta),
            const SizedBox(width: 6),
            Text(
              'FINANCIAL PERFORMANCE',
              style: AppTypography.labelSmall.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.terracotta,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Gross Sales',
                value: CurrencyFormatter.format(grossSales),
                subtitle: '$totalBills orders • $totalItems items',
                icon: Icons.receipt_long_rounded,
                iconColor: AppColors.burgundy,
                iconBg: AppColors.creamHigh,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Est. Net Profit',
                value: CurrencyFormatter.format(netProfit),
                subtitle: '${marginPercent.toStringAsFixed(1)}% profit margin',
                icon: Icons.trending_up_rounded,
                iconColor: AppColors.caramelAccent,
                iconBg: AppColors.burgundy,
                isHighlight: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                title: 'Food Cost (COGS)',
                value: CurrencyFormatter.format(totalCogs),
                subtitle: '${cogsPercent.toStringAsFixed(1)}% of gross sales',
                icon: Icons.inventory_2_outlined,
                iconColor: AppColors.terracotta,
                iconBg: AppColors.creamContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricTile(
                title: 'Stall Expenses',
                value: CurrencyFormatter.format(totalExpenses),
                subtitle: 'Recorded shift costs',
                icon: Icons.account_balance_wallet_outlined,
                iconColor: AppColors.textSecondary,
                iconBg: AppColors.creamLow,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool isHighlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isHighlight ? AppColors.creamHighest : AppColors.creamCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlight ? AppColors.burgundy : AppColors.borderSubtle,
          width: isHighlight ? 1.2 : 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isHighlight ? AppColors.burgundy : AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Payment Method Breakdown Card (Cash vs PhonePe UPI)
  Widget _buildPaymentMethodBreakdownCard({
    required double cashCollection,
    required double upiCollection,
    required double grossSales,
  }) {
    final cashPercent = grossSales > 0 ? (cashCollection / grossSales * 100) : 0.0;
    final upiPercent = grossSales > 0 ? (upiCollection / grossSales * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pie_chart_outline_rounded, size: 16, color: AppColors.terracotta),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Payment Method Distribution',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Total: ${CurrencyFormatter.format(grossSales)}',
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.burgundy),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Two-tone progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (cashPercent > 0)
                    Expanded(
                      flex: cashPercent.round().clamp(1, 100),
                      child: Container(color: AppColors.terracotta),
                    ),
                  if (upiPercent > 0)
                    Expanded(
                      flex: upiPercent.round().clamp(1, 100),
                      child: Container(color: AppColors.phonePePurple),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Legends
          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.terracotta,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Cash: ${CurrencyFormatter.format(cashCollection)} (${cashPercent.toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.phonePePurple,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'UPI: ${CurrencyFormatter.format(upiCollection)} (${upiPercent.toStringAsFixed(0)}%)',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// COGS & Margin Split Card
  Widget _buildMarginDistributionCard({
    required double netProfit,
    required double marginPercent,
    required double totalCogs,
    required double cogsPercent,
    required double totalExpenses,
    required double grossSales,
  }) {
    final expPercent = grossSales > 0 ? (totalExpenses / grossSales * 100) : 0.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.donut_small_rounded, size: 16, color: AppColors.burgundy),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'COGS & Margin Split',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${marginPercent.toStringAsFixed(0)}% Net Margin',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.successGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Three-segment bar: Profit, COGS, Expenses
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (marginPercent > 0)
                    Expanded(
                      flex: marginPercent.round().clamp(1, 100),
                      child: Container(color: AppColors.burgundy),
                    ),
                  if (cogsPercent > 0)
                    Expanded(
                      flex: cogsPercent.round().clamp(1, 100),
                      child: Container(color: AppColors.terracotta),
                    ),
                  if (expPercent > 0)
                    Expanded(
                      flex: expPercent.round().clamp(1, 100),
                      child: Container(color: AppColors.textMuted),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          Wrap(
            spacing: 12,
            runSpacing: 6,
            alignment: WrapAlignment.spaceBetween,
            children: [
              _buildLegendPill('Net Profit', CurrencyFormatter.format(netProfit), AppColors.burgundy),
              _buildLegendPill('COGS Cost', CurrencyFormatter.format(totalCogs), AppColors.terracotta),
              _buildLegendPill('Expenses', CurrencyFormatter.format(totalExpenses), AppColors.textMuted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendPill(String title, String val, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 9.5, color: AppColors.textSecondary)),
            Text(val, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ],
    );
  }

  /// Cash Drawer Balance Accordion & Reconciliation Tool
  Widget _buildDrawerReconciliationCard({
    required double openingFloat,
    required double cashCollection,
    required double totalExpenses,
    required double expectedCashInBox,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: AppColors.burgundy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_clock_outlined, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cash Drawer Balance Audit',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Physical drawer count vs expected cash',
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Drawer math pills
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.creamLow,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: _buildDrawerMathItem('Opening Float', CurrencyFormatter.format(openingFloat), AppColors.textPrimary),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('+', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                ),
                Expanded(
                  child: _buildDrawerMathItem('Cash Sales', CurrencyFormatter.format(cashCollection), AppColors.terracotta),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('-', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                ),
                Expanded(
                  child: _buildDrawerMathItem('Expenses', CurrencyFormatter.format(totalExpenses), AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('EXPECTED IN DRAWER', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                  Text(
                    CurrencyFormatter.format(expectedCashInBox),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.burgundy),
                  ),
                ],
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.burgundy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                onPressed: () {
                  setState(() {
                    _showReconcileDrawer = !_showReconcileDrawer;
                    if (_showReconcileDrawer && _countedCashController.text.isEmpty) {
                      _countedCashController.text = expectedCashInBox.toStringAsFixed(0);
                    }
                  });
                },
                icon: Icon(
                  _showReconcileDrawer ? Icons.keyboard_arrow_up : Icons.verified_outlined,
                  size: 16,
                ),
                label: Text(
                  _showReconcileDrawer ? 'Hide Audit' : 'Reconcile Till',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          // Accordion for manual verification
          if (_showReconcileDrawer) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.creamContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Count Physical Currency in Cash Box',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          child: TextField(
                            controller: _countedCashController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: 'Enter counted ₹ amount',
                              prefixText: '₹ ',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                            ),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.terracotta,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _verifyPhysicalCash(expectedCashInBox),
                        child: const Text('Verify'),
                      ),
                    ],
                  ),
                  if (_reconcileFeedback != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.check_circle_outline, size: 16, color: _reconcileFeedbackColor),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _reconcileFeedback!,
                            style: TextStyle(
                              color: _reconcileFeedbackColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerMathItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 9.5, color: AppColors.textMuted)),
        Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  /// Best-Sellers Leaderboard Section
  Widget _buildLeaderboardSection(List<Map<String, dynamic>> leaderboard) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.military_tech_outlined, size: 18, color: AppColors.terracotta),
            const SizedBox(width: 6),
            const Expanded(
              child: Text(
                'Best-Sellers Leaderboard',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.creamHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${leaderboard.length} Items',
                style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: AppColors.burgundy),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (leaderboard.isEmpty)
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.creamCard,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderSubtle, width: 0.8),
            ),
            alignment: Alignment.center,
            child: const Text(
              'No items sold in this period.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          )
        else
          ...leaderboard.take(5).toList().asMap().entries.map((entry) {
            final rank = entry.key + 1;
            final item = entry.value;
            final productName = item['product_name'] as String? ?? 'Item';
            final quantity = (item['total_quantity'] as num?)?.toInt() ?? 0;
            final revenue = (item['total_revenue'] as num?)?.toDouble() ?? 0.0;

            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.creamCard,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderSubtle, width: 0.7),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: rank == 1 ? AppColors.burgundy : AppColors.creamHigh,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: rank == 1 ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      productName,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '$quantity sold • ${CurrencyFormatter.format(revenue)}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.burgundy,
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  /// Recent Transactions Section
  Widget _buildRecentTransactionsSection(List<SaleRecord> recentSales) {
    if (recentSales.isEmpty) return const SizedBox.shrink();

    final timeFormatter = DateFormat('hh:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.history_rounded, size: 18, color: AppColors.burgundy),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Recent Transactions in Period',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...recentSales.map((sale) {
          final isUpi = sale.paymentMethod == 'phonepe_upi';
          return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.creamCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.borderSubtle, width: 0.7),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isUpi ? AppColors.phonePePurpleLight : AppColors.creamContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isUpi ? Icons.qr_code_2 : Icons.payments_outlined,
                    size: 18,
                    color: isUpi ? AppColors.phonePePurple : AppColors.terracotta,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${sale.billNumber} • ${sale.customerName}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Token #${sale.tokenNumber} • ${timeFormatter.format(sale.timestamp)} • ${sale.totalItemsCount} items',
                        style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                Text(
                  CurrencyFormatter.format(sale.grandTotal),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.burgundy),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  /// Informative Empty State Banner when no sales exist
  Widget _buildEmptySalesBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderSubtle, width: 0.9),
      ),
      child: Column(
        children: [
          const Icon(Icons.receipt_long_outlined, size: 48, color: AppColors.caramelAccent),
          const SizedBox(height: 10),
          const Text(
            'No Sales Recorded For This Period',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'There are no verified transactions during this timeframe. New bills generated on the Billing POS will immediately update this report dashboard.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.burgundy,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            onPressed: () {
              // Switch to Billing POS tab
              ref.read(selectedNavIndexProvider.notifier).state = 0;
            },
            icon: const Icon(Icons.point_of_sale_rounded, size: 16),
            label: const Text('Go to Billing POS'),
          ),
        ],
      ),
    );
  }
}
