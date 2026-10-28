import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../../../data/models/sale_record.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';

class ReceiptPdfService {
  ReceiptPdfService._();

  static Future<Uint8List> generateReceiptPdf(SaleRecord sale) async {
    final pdf = pw.Document();

    final fontRegular = await PdfGoogleFonts.plusJakartaSansRegular();
    final fontBold = await PdfGoogleFonts.plusJakartaSansBold();
    final fontHeading = await PdfGoogleFonts.epilogueBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(12),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              // Stall Brand Header
              pw.Text(
                AppConstants.appName.toUpperCase(),
                style: pw.TextStyle(
                  font: fontHeading,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                AppConstants.appSecondaryTagline,
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 9,
                  color: PdfColors.grey700,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                DateFormatter.formatReceipt(sale.timestamp),
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
              pw.SizedBox(height: 8),

              // Token Box
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(width: 1),
                  borderRadius: const pw.BorderRadius.all(
                    pw.Radius.circular(6),
                  ),
                ),
                child: pw.Column(
                  children: [
                    pw.Text(
                      'TOKEN NUMBER',
                      style: pw.TextStyle(font: fontRegular, fontSize: 8),
                    ),
                    pw.Text(
                      '#${sale.tokenNumber}',
                      style: pw.TextStyle(
                        font: fontHeading,
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              pw.Divider(thickness: 0.8),

              // Bill Meta
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Bill: ${sale.billNumber}',
                    style: pw.TextStyle(font: fontBold, fontSize: 9),
                  ),
                  pw.Text(
                    'Cust: ${sale.customerName}',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9),
                  ),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Pay: ${sale.paymentMethod == "cash" ? "Cash" : "PhonePe UPI"}',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9),
                  ),
                  pw.Text(
                    'Status: VERIFIED',
                    style: pw.TextStyle(font: fontBold, fontSize: 9),
                  ),
                ],
              ),

              pw.Divider(thickness: 0.8),

              // Itemized List
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'ITEM & QTY',
                    style: pw.TextStyle(font: fontBold, fontSize: 8),
                  ),
                  pw.Text(
                    'AMOUNT',
                    style: pw.TextStyle(font: fontBold, fontSize: 8),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),

              ...sale.items.map((item) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Expanded(
                        child: pw.Text(
                          '${item.productName} x${item.quantity}',
                          style: pw.TextStyle(font: fontRegular, fontSize: 9),
                        ),
                      ),
                      pw.Text(
                        CurrencyFormatter.format(item.lineTotal),
                        style: pw.TextStyle(font: fontBold, fontSize: 9),
                      ),
                    ],
                  ),
                );
              }),

              pw.Divider(thickness: 0.8),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Subtotal',
                    style: pw.TextStyle(font: fontRegular, fontSize: 9),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(sale.subtotal),
                    style: pw.TextStyle(font: fontRegular, fontSize: 9),
                  ),
                ],
              ),
              if (sale.discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Discount',
                      style: pw.TextStyle(font: fontRegular, fontSize: 9),
                    ),
                    pw.Text(
                      '-${CurrencyFormatter.format(sale.discount)}',
                      style: pw.TextStyle(font: fontRegular, fontSize: 9),
                    ),
                  ],
                ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'GRAND TOTAL',
                    style: pw.TextStyle(
                      font: fontHeading,
                      fontSize: 11,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    CurrencyFormatter.format(sale.grandTotal),
                    style: pw.TextStyle(
                      font: fontHeading,
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              if (sale.paymentMethod == 'cash' &&
                  sale.amountReceived != null) ...[
                pw.SizedBox(height: 2),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Cash Tendered',
                      style: pw.TextStyle(font: fontRegular, fontSize: 8),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(sale.amountReceived!),
                      style: pw.TextStyle(font: fontRegular, fontSize: 8),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Change Returned',
                      style: pw.TextStyle(font: fontRegular, fontSize: 8),
                    ),
                    pw.Text(
                      CurrencyFormatter.format(sale.changeReturned ?? 0.0),
                      style: pw.TextStyle(font: fontRegular, fontSize: 8),
                    ),
                  ],
                ),
              ],

              pw.SizedBox(height: 12),
              pw.Text(
                'Thank you for snacking with us!',
                style: pw.TextStyle(font: fontBold, fontSize: 9),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'FSSAI Lic: ${AppConstants.defaultFssaiLic}',
                style: pw.TextStyle(
                  font: fontRegular,
                  fontSize: 7,
                  color: PdfColors.grey700,
                ),
              ),
            ],
          );
        },
      ),
    );

    return await pdf.save();
  }

  static Future<void> printReceipt(SaleRecord sale) async {
    final pdfBytes = await generateReceiptPdf(sale);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Receipt_${sale.billNumber}',
    );
  }

  static Future<void> shareReceiptPdf(SaleRecord sale) async {
    final pdfBytes = await generateReceiptPdf(sale);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: 'Receipt_${sale.billNumber}.pdf',
    );
  }
}
