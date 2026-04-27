import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/visa_service.dart';
import '../../services/pdf_service.dart';
import '../../models/visa_application.dart';

class SuppliersManagementScreen extends StatelessWidget {
  const SuppliersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visaService = VisaService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموردين', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.safarBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: visaService,
        builder: (context, _) {
          // Get unique suppliers from all visa applications
          final suppliers = visaService.applications
              .where((app) => app.supplierName != null && app.supplierName!.isNotEmpty)
              .map((app) => app.supplierName!)
              .toSet()
              .toList();

          if (suppliers.isEmpty) {
            return const Center(
              child: Text('لا يوجد موردين مسجلين حالياً'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: suppliers.length,
            itemBuilder: (context, index) {
              final supplier = suppliers[index];
              final supplierVisas = visaService.applications.where((app) => app.supplierName == supplier).toList();
              double totalDebt = 0;
              for (var v in supplierVisas) {
                totalDebt += v.costPrice ?? 0;
              }

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.withOpacity(0.1),
                    child: const Icon(Icons.business, color: Colors.indigo),
                  ),
                  title: Text(supplier, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('عدد الطلبات: ${supplierVisas.length}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${totalDebt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                      const Text('إجمالي التكلفة', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  onTap: () => _showSupplierStatement(context, supplier, supplierVisas, totalDebt),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showSupplierStatement(BuildContext context, String name, List<VisaApplication> visas, double total) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('كشف حساب: $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: visas.length,
                itemBuilder: (context, i) {
                  final v = visas[i];
                  return ListTile(
                    title: Text('${v.targetCountry} - ${v.fullName}'),
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(v.submissionDate)),
                    trailing: Text('\$${v.costPrice?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.red)),
                  );
                },
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي المستحق للمورد:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PdfService.generateStatementPdf(
                  title: 'Supplier Statement: $name',
                  applications: visas,
                  totalRevenue: 0,
                  totalCost: total,
                  netProfit: 0,
                  isSupplierStatement: true,
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('تصدير كشف حساب PDF'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
