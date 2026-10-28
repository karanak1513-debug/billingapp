import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/sale_record.dart';
import '../providers/history_provider.dart';
import '../services/csv_export_service.dart';
import '../../billing/screens/receipt_screen.dart';
import '../../billing/services/receipt_pdf_service.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickCustomDateRange(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(
        start: now.subtract(const Duration(days: 7)),
        end: now,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
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
      ref
          .read(historyFilterProvider.notifier)
          .setCustomRange(
            picked.start,
            DateTime(
              picked.end.year,
              picked.end.month,
              picked.end.day,
              23,
              59,
              59,
            ),
          );
    }
  }

  void _exportCsv(BuildContext context, List<SaleRecord> sales) {
    if (sales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No sales found for the selected period to export.'),
        ),
      );
      return;
    }
    CsvExportService.exportAndShareCsv(sales);
  }

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(salesHistoryProvider);
    final filterState = ref.watch(historyFilterProvider);
    final metrics = ref.watch(historyMetricsProvider);

    return Scaffold(
      backgroundColor: AppColors.creamBg,
      appBar: AppBar(
        backgroundColor: AppColors.burgundy,
        title: Text(
          'Sales History & Audit',
          style: AppTypography.headlineMedium.copyWith(color: Colors.white),
        ),
        actions: [
          salesAsync.maybeWhen(
            data: (sales) => IconButton(
              icon: const Icon(Icons.download, color: Colors.white),
              tooltip: 'Export CSV',
              onPressed: () => _exportCsv(context, sales),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(salesHistoryProvider);
        },
        color: AppColors.burgundy,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sync Status Banner & Quick CSV Export
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.creamHigh,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.terracotta,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Sync Status: SQLite Offline Native',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  salesAsync.maybeWhen(
                    data: (sales) => ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.burgundy,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        minimumSize: const Size(0, 32),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => _exportCsv(context, sales),
                      icon: const Icon(Icons.download, size: 14),
                      label: Text(
                        'EXPORT CSV',
                        style: AppTypography.labelSmall.copyWith(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    orElse: () => const SizedBox.shrink(),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Search & Date Filter Controls
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.creamLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle, width: 0.8),
                ),
                child: Column(
                  children: [
                    // Search Bar
                    Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search Bill #, Karan, Walk-in...',
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.cancel, size: 16),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(historyFilterProvider.notifier)
                                        .setSearchQuery('');
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
                          ref
                              .read(historyFilterProvider.notifier)
                              .setSearchQuery(val);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            label: 'Today',
                            isSelected:
                                filterState.dateFilter ==
                                HistoryDateFilter.today,
                            onTap: () {
                              ref
                                  .read(historyFilterProvider.notifier)
                                  .setFilter(HistoryDateFilter.today);
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            label: 'Yesterday',
                            isSelected:
                                filterState.dateFilter ==
                                HistoryDateFilter.yesterday,
                            onTap: () {
                              ref
                                  .read(historyFilterProvider.notifier)
                                  .setFilter(HistoryDateFilter.yesterday);
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            label: 'This Fest / Week',
                            isSelected:
                                filterState.dateFilter ==
                                HistoryDateFilter.week,
                            onTap: () {
                              ref
                                  .read(historyFilterProvider.notifier)
                                  .setFilter(HistoryDateFilter.week);
                            },
                          ),
                          const SizedBox(width: 6),
                          _buildFilterChip(
                            label: 'Custom Range',
                            icon: Icons.calendar_today,
                            isSelected:
                                filterState.dateFilter ==
                                HistoryDateFilter.custom,
                            onTap: () => _pickCustomDateRange(context),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // KPI Card Strip
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.burgundy,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.burgundyDark.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildMetricCol(
                        title: 'TOTAL SALES',
                        value: CurrencyFormatter.format(metrics.totalSales),
                        subtitle: 'Selected Period',
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: _buildMetricCol(
                        title: 'ORDERS',
                        value: '${metrics.totalOrders}',
                        subtitle: 'Completed',
                      ),
                    ),
                    Container(width: 1, height: 40, color: Colors.white24),
                    Expanded(
                      child: _buildMetricCol(
                        title: 'AVG TICKET',
                        value: CurrencyFormatter.format(metrics.avgTicket),
                        subtitle: 'Per Bill',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Historical Bills Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'AUDIT TRAIL & RECEIPTS (${salesAsync.value?.length ?? 0})',
                    style: AppTypography.labelSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    'Auto-synced',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.terracotta,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Bills Stream
              salesAsync.when(
                data: (sales) {
                  if (sales.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            size: 48,
                            color: AppColors.borderMedium,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No sales recorded for this period',
                            style: AppTypography.headlineSmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'New completed orders will appear here automatically',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: sales.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final sale = sales[index];
                      return _buildSaleCard(context, sale);
                    },
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(color: AppColors.burgundy),
                  ),
                ),
                error: (err, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 16,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 44,
                          color: AppColors.errorRed,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error loading sales history',
                          style: AppTypography.headlineSmall.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$err',
                          style: AppTypography.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.burgundy,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            ref.invalidate(salesHistoryProvider);
                          },
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.burgundy : AppColors.creamCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.burgundy : AppColors.borderSubtle,
            width: 0.8,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 13,
                color: isSelected ? Colors.white : AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: isSelected ? Colors.white : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCol({
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.caramelFixed,
            fontSize: 9,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTypography.priceMedium.copyWith(
            color: Colors.white,
            fontSize: 17,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          subtitle,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white54,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  Widget _buildSaleCard(BuildContext context, SaleRecord sale) {
    final isUpi = sale.paymentMethod == 'phonepe_upi';
    final itemsSummary = sale.items
        .map((i) => '${i.productName} x${i.quantity}')
        .join(', ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.creamCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle, width: 0.8),
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
          // Top row: Bill #, Status, Amount, Payment method
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    '#${sale.billNumber}',
                    style: AppTypography.headlineSmall.copyWith(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.creamHigh,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified,
                          size: 12,
                          color: AppColors.terracotta,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Paid',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.terracottaDark,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(sale.grandTotal),
                    style: AppTypography.priceMedium.copyWith(
                      color: AppColors.burgundy,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    isUpi ? 'PhonePe UPI' : 'Cash Counter',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.terracotta,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Date & Customer
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.schedule,
                size: 13,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 4),
              Text(
                '${DateFormatter.formatRelative(sale.timestamp)} • Customer: ',
                style: AppTypography.bodySmall.copyWith(fontSize: 11),
              ),
              Text(
                sale.customerName,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Meta sub-badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.creamLow,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isUpi ? Icons.account_balance_wallet : Icons.payments,
                      size: 13,
                      color: AppColors.terracotta,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isUpi ? AppConstants.merchantUpiVpa : 'Till Cash Box',
                      style: AppTypography.labelSmall.copyWith(fontSize: 10),
                    ),
                  ],
                ),
                Text(
                  '${sale.totalItemsCount} items',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Items summary
          Text(
            itemsSummary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),

          // Action buttons: Digital Receipt & Reprint
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  backgroundColor: AppColors.creamContainer,
                  foregroundColor: AppColors.textPrimary,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReceiptScreen(saleRecord: sale),
                    ),
                  );
                },
                icon: const Icon(Icons.visibility, size: 14),
                label: Text(
                  'Digital Receipt',
                  style: AppTypography.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.terracotta,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => ReceiptPdfService.printReceipt(sale),
                icon: const Icon(Icons.print, size: 14),
                label: Text(
                  'Reprint',
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
