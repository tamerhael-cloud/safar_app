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
    bool isSupplierStatement = false,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title, style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
                pw.Text(DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: isSupplierStatement 
              ? ['Date', 'Client', 'Country', 'Type', 'Cost']
              : ['Date', 'Country', 'Type', 'Price', 'Status'],
            data: applications.map((app) {
              if (isSupplierStatement) {
                return [
                  DateFormat('yyyy-MM-dd').format(app.submissionDate),
                  app.fullName,
                  app.targetCountry,
                  app.visaType,
                  '\$${app.costPrice?.toStringAsFixed(2) ?? '0.00'}',
                ];
              } else {
                return [
                  DateFormat('yyyy-MM-dd').format(app.submissionDate),
                  app.targetCountry,
                  app.visaType,
                  '\$${app.price.toStringAsFixed(2)}',
                  app.status,
                ];
              }
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
                  if (!isSupplierStatement) pw.Text('Total Price: \$${totalRevenue.toStringAsFixed(2)}'),
                  if (isSupplierStatement || netProfit != 0) pw.Text('Total Cost: \$${totalCost.toStringAsFixed(2)}'),
                  if (!isSupplierStatement && netProfit != 0)
                    pw.Text('Net Profit: \$${netProfit.toStringAsFixed(2)}', 
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
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
