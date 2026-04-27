import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../services/visa_service.dart';
import '../../services/pdf_service.dart';
import '../../models/visa_application.dart';
import '../../services/suppliers_service.dart';
import '../../services/booking_service.dart';
import '../../models/general_booking.dart';

class SuppliersManagementScreen extends StatelessWidget {
  const SuppliersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visaService = VisaService();
    final suppliersService = SuppliersService();
    final bookingService = BookingService();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الموردين المركزية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.safarBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddSupplierDialog(context),
        backgroundColor: AppTheme.safarBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([visaService, suppliersService, bookingService]),
        builder: (context, _) {
          final masterSuppliers = suppliersService.suppliers;

          if (masterSuppliers.isEmpty) {
            return const Center(
              child: Text('لم يتم تعريف موردين بعد. أضف موردك الأول!'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: masterSuppliers.length,
            itemBuilder: (context, index) {
              final supplier = masterSuppliers[index];
              
              final supplierVisas = visaService.applications.where((app) => 
                app.supplierName?.trim().toLowerCase() == supplier.name.trim().toLowerCase()
              ).toList();

              final supplierBookings = bookingService.bookings.where((b) =>
                b.supplierName?.trim().toLowerCase() == supplier.name.trim().toLowerCase()
              ).toList();

              double totalDebt = 0;
              for (var v in supplierVisas) totalDebt += v.costPrice ?? 0;
              for (var b in supplierBookings) totalDebt += b.costPrice ?? 0;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: _getCategoryColor(supplier.category).withOpacity(0.1),
                    child: Icon(_getCategoryIcon(supplier.category), color: _getCategoryColor(supplier.category)),
                  ),
                  title: Text(supplier.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('تخصص: ${supplier.category} | حركات: ${supplierVisas.length + supplierBookings.length}'),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('\$${totalDebt.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16)),
                      const Text('إجمالي المطالبات', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                  onTap: () => _showSupplierStatement(context, supplier.name, supplierVisas, supplierBookings, totalDebt),
                  onLongPress: () => _showDeleteConfirm(context, supplier),
                ),
              );
            },
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Flight': return Icons.flight;
      case 'Hotel': return Icons.hotel;
      case 'Car': return Icons.directions_car;
      default: return Icons.credit_card;
    }
  }

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Flight': return Colors.orange;
      case 'Hotel': return Colors.green;
      case 'Car': return Colors.blue;
      default: return Colors.indigo;
    }
  }

  void _showAddSupplierDialog(BuildContext context) {
    final nameCtrl = TextEditingController();
    String category = 'Visa';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('إضافة مورد جديد'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'اسم المورد')),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: category,
                items: ['Visa', 'Flight', 'Hotel', 'Car'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => category = v!),
                decoration: const InputDecoration(labelText: 'التخصص'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.isNotEmpty) {
                  SuppliersService().addSupplier(Supplier(id: '', name: nameCtrl.text, category: category));
                  Navigator.pop(context);
                }
              }, 
              child: const Text('حفظ')
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, Supplier s) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المورد'),
        content: Text('هل أنت متأكد من حذف المورد "${s.name}"؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          TextButton(onPressed: () {
            SuppliersService().deleteSupplier(s.id);
            Navigator.pop(context);
          }, child: const Text('حذف', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showSupplierStatement(BuildContext context, String name, List<VisaApplication> visas, List<GeneralBooking> bookings, double total) {
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
                Text('كشف حساب موحد: $name', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  if (visas.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('التأشيرات:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    ...visas.map((v) => ListTile(
                      title: Text('${v.targetCountry} - ${v.fullName}'),
                      subtitle: Text(DateFormat('yyyy-MM-dd').format(v.submissionDate)),
                      trailing: Text('\$${v.costPrice?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.red)),
                    )),
                  ],
                  if (bookings.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text('الحجوزات الأخرى (طيران/فنادق):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    ),
                    ...bookings.map((b) => ListTile(
                      leading: Icon(_getCategoryIcon(b.type), size: 20),
                      title: Text('${b.type}: ${b.details}'),
                      subtitle: Text('${b.customerName} | ${DateFormat('yyyy-MM-dd').format(b.date)}'),
                      trailing: Text('\$${b.costPrice?.toStringAsFixed(2) ?? '0.00'}', style: const TextStyle(color: Colors.red)),
                    )),
                  ],
                ],
              ),
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي المطالبات المستحقة:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  // Merge both for PDF
                  // Note: In a real app, we'd update PdfService to handle mixed lists
                  PdfService.generateStatementPdf(
                    title: 'Unified Supplier Statement: $name',
                    applications: visas, // Currently PDF only takes Visa list, we could expand it
                    totalRevenue: 0,
                    totalCost: total,
                    netProfit: 0,
                    isSupplierStatement: true,
                  );
                },
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
