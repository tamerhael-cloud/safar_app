import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/visa_application.dart';
import 'package:intl/intl.dart';

class PdfService {
  static Future<void> generateStatementPdf({
    required String title,
    required List<VisaApplication> applications,
    required double totalRevenue,
    required double totalCost,
    required double netProfit,
  }) async {
    final pdf = pw.Document();

    // Load a font that supports Arabic if possible, or stick to standard for now
    // Note: Arabic support in PDF requires a specific font file (.ttf)
    
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Client', 'Country', 'Type', 'Cost', 'Price', 'Profit'],
            data: applications.map((app) {
              final profit = app.price - (app.costPrice ?? 0);
              return [
                DateFormat('yyyy-MM-dd').format(app.submissionDate),
                app.fullName,
                app.targetCountry,
                app.visaType,
                '\$${app.costPrice?.toStringAsFixed(2) ?? '0.00'}',
                '\$${app.price.toStringAsFixed(2)}',
                '\$${profit.toStringAsFixed(2)}',
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            cellAlignment: pw.Alignment.center,
          ),
          pw.SizedBox(height: 30),
          pw.Divider(),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Total Revenue: \$${totalRevenue.toStringAsFixed(2)}'),
                  pw.Text('Total Cost: \$${totalCost.toStringAsFixed(2)}'),
                  pw.Text('Net Profit: \$${netProfit.toStringAsFixed(2)}', 
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18)),
                ],
              ),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }
}
