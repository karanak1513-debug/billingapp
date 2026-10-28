import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../data/models/sale_record.dart';

class CsvExportService {
  CsvExportService._();

  static String generateCsvString(List<SaleRecord> sales) {
    final List<List<dynamic>> rows = [
      [
        'Bill Number',
        'Token Number',
        'Customer Name',
        'Phone Number',
        'Date & Time',
        'Payment Method',
        'Payment Status',
        'Total Items Count',
        'Subtotal (INR)',
        'Discount (INR)',
        'Grand Total (INR)',
        'COGS (INR)',
        'Estimated Profit (INR)',
        'Items Detail',
      ],
    ];

    for (final sale in sales) {
      final itemsSummary = sale.items
          .map((i) => '${i.productName} (x${i.quantity} @ ₹${i.unitPrice})')
          .join('; ');

      rows.add([
        sale.billNumber,
        sale.tokenNumber,
        sale.customerName,
        sale.phoneNumber ?? '',
        sale.timestamp.toIso8601String(),
        sale.paymentMethod,
        sale.paymentStatus,
        sale.totalItemsCount,
        sale.subtotal,
        sale.discount,
        sale.grandTotal,
        sale.totalCost,
        sale.netProfit,
        itemsSummary,
      ]);
    }

    return Csv().encode(rows);
  }

  static Future<void> exportAndShareCsv(List<SaleRecord> sales) async {
    final csvContent = generateCsvString(sales);
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/snacks_oclock_sales_$timestamp.csv');

    await file.writeAsString(csvContent, encoding: utf8);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        subject: "Snacks O'Clock Sales Export",
      ),
    );
  }
}
