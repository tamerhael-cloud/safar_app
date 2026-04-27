import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/visa_application.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

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

    // Load Arabic Font
    pw.Font? arabicFont;
    try {
      final fontData = await rootBundle.load("assets/fonts/Cairo-Regular.ttf");
      arabicFont = pw.Font.ttf(fontData);
    } catch (e) {
      try {
        final response = await http.get(Uri.parse('https://raw.githubusercontent.com/googlefonts/cairo/master/fonts/ttf/Cairo-Regular.ttf'));
        if (response.statusCode == 200) {
          arabicFont = pw.Font.ttf(response.bodyBytes.buffer.asByteData());
        }
      } catch (e2) {
        arabicFont = pw.Font.helvetica();
      }
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(base: arabicFont),
        build: (context) => [
          pw.Directionality(
            textDirection: pw.TextDirection.rtl,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader(title, arabicFont!),
                pw.SizedBox(height: 20),
                _buildTable(applications, isSupplierStatement, arabicFont),
                pw.SizedBox(height: 20),
                pw.Divider(),
                _buildFooter(totalRevenue, totalCost, netProfit, isSupplierStatement, arabicFont),
              ],
            ),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  static pw.Widget _buildHeader(String title, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, font: font),
        ),
        pw.Text(
          DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now()),
          style: pw.TextStyle(fontSize: 10, font: font),
        ),
      ],
    );
  }

  static pw.Widget _buildTable(List<VisaApplication> apps, bool isSupplier, pw.Font font) {
    final headers = isSupplier 
      ? ['التكلفة', 'النوع', 'الدولة', 'العميل', 'التاريخ']
      : ['الحالة', 'السعر', 'النوع', 'الدولة', 'التاريخ'];

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: apps.map((app) {
        return isSupplier
            ? [
                '\$${app.costPrice?.toStringAsFixed(2) ?? '0.00'}',
                app.visaType,
                app.targetCountry,
                app.fullName,
                DateFormat('yyyy-MM-dd').format(app.submissionDate),
              ]
            : [
                app.status,
                '\$${app.price.toStringAsFixed(2)}',
                app.visaType,
                app.targetCountry,
                DateFormat('yyyy-MM-dd').format(app.submissionDate),
              ];
      }).toList(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, font: font, fontSize: 10),
      cellStyle: pw.TextStyle(font: font, fontSize: 9),
      cellAlignment: pw.Alignment.center,
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
    );
  }

  static pw.Widget _buildFooter(double rev, double cost, double profit, bool isSupplier, pw.Font font) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (isSupplier)
          pw.Text(
            'إجمالي التكلفة: \$${cost.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: font),
          )
        else ...[
          pw.Text('إجمالي الإيرادات: \$${rev.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 12)),
          pw.Text('إجمالي التكاليف: \$${cost.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 12)),
          pw.SizedBox(height: 5),
          pw.Text(
            'صافي الربح: \$${profit.toStringAsFixed(2)}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: font),
          ),
        ],
      ],
    );
  }
}
