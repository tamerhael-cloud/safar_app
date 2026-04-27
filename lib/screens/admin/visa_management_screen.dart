import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import '../../theme/app_theme.dart';
import '../../services/visa_service.dart';
import '../../models/visa_application.dart';

class VisaManagementScreen extends StatefulWidget {
  const VisaManagementScreen({super.key});

  @override
  State<VisaManagementScreen> createState() => _VisaManagementScreenState();
}

class _VisaManagementScreenState extends State<VisaManagementScreen> {
  late Future<void> _visaFuture;

  @override
  void initState() {
    super.initState();
    _visaFuture = VisaService().refreshApplications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة طلبات التأشيرة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.safarBlue,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _visaFuture = VisaService().refreshApplications();
              });
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _visaFuture,
        builder: (context, snapshot) {
          return ListenableBuilder(
            listenable: VisaService(),
            builder: (context, child) {
              final apps = VisaService().applications;
              if (apps.isEmpty && snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (apps.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, color: Colors.grey, size: 60),
                      SizedBox(height: 16),
                      Text('لا توجد طلبات تأشيرة حالياً', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: apps.length,
                itemBuilder: (context, index) {
                  final app = apps[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: InkWell(
                      onTap: () => _showApplicationDetails(context, app),
                      borderRadius: BorderRadius.circular(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppTheme.safarBlue.withOpacity(0.1),
                              child: const Icon(Icons.person, color: AppTheme.safarBlue),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(app.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text('تقديم إلى: ${app.targetCountry}', style: const TextStyle(color: AppTheme.safarBlue, fontWeight: FontWeight.w600)),
                                  Row(
                                    children: [
                                      Icon(
                                        _getStatusIcon(app.status),
                                        size: 14,
                                        color: _getStatusColor(app.status),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(app.status, style: TextStyle(
                                        fontSize: 12, 
                                        fontWeight: FontWeight.bold,
                                        color: _getStatusColor(app.status),
                                      )),
                                    ],
                                  ),
                                  Text(DateFormat('yyyy-MM-dd').format(app.submissionDate), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    if (status == 'مقبول') return Icons.check_circle;
    if (status == 'مرفوض' || status == 'تم رفض الدفع') return Icons.cancel;
    if (status == 'قيد المعاملة') return Icons.sync;
    if (status == 'بانتظار تأكيد الدفع') return Icons.payment;
    return Icons.pending;
  }

  Color _getStatusColor(String status) {
    if (status == 'مقبول') return Colors.green;
    if (status == 'مرفوض' || status == 'تم رفض الدفع') return Colors.red;
    if (status == 'قيد المعاملة') return Colors.blue;
    if (status == 'بانتظار تأكيد الدفع') return Colors.orange;
    return Colors.orange;
  }

  void _showApplicationDetails(BuildContext context, VisaApplication app) {
    final costController = TextEditingController(text: app.costPrice?.toString() ?? '');
    final supplierController = TextEditingController(text: app.supplierName ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إدارة الطلب والوثائق', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              _buildDetailItem('الاسم الرباعي:', app.fullName),
              _buildDetailItem('مقدم إلى دولة:', app.targetCountry),
              _buildDetailItem('سعر البيع للعميل:', '\$${app.price}'),
              _buildDetailItem('طريقة الدفع:', app.paymentMethod ?? 'غير محدد'),
              _buildDetailItem('الحالة الحالية:', app.status),
              const Divider(),
              const SizedBox(height: 12),
              const Text('بيانات المورد (محاسبية):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: costController,
                      decoration: const InputDecoration(labelText: 'سعر التكلفة (\$)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: supplierController,
                      decoration: const InputDecoration(labelText: 'اسم المورد', border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              if (app.costPrice != null && app.costPrice! > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'صافي الربح المتوقع: \$${(app.price - app.costPrice!).toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 24),
              const Text('الإجراءات المتاحة للأدمن:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 16),
              if (app.status == 'بانتظار تأكيد الدفع') ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          VisaService().updateApplicationStatus(
                            app.id, 
                            'قيد المعاملة',
                            costPrice: double.tryParse(costController.text),
                            supplierName: supplierController.text,
                          );
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('تأكيد الدفع والبدء'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          VisaService().updateApplicationStatus(app.id, 'تم رفض الدفع');
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close),
                        label: const Text('رفض الدفع'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          VisaService().updateApplicationStatus(app.id, 'قيد المعاملة');
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                        child: const Text('قيد المعاملة'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
                          if (result != null) {
                            final file = result.files.first;
                            VisaService().updateApplicationStatus(
                              app.id, 
                              'مقبول', 
                              visaPath: file.path, 
                              visaName: file.name,
                              costPrice: double.tryParse(costController.text),
                              supplierName: supplierController.text,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        child: const Text('موافقة وإرفاق'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          VisaService().updateApplicationStatus(app.id, 'مرفوض');
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        child: const Text('رفض الطلب'),
                      ),
                    ),
                  ],
                ),
              ],
              if (app.passportFilePath != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (app.passportFilePath!.startsWith('http')) {
                        await launchUrl(Uri.parse(app.passportFilePath!));
                      } else {
                        await OpenFilex.open(app.passportFilePath!);
                      }
                    },
                    icon: const Icon(Icons.person_search),
                    label: Text('فتح الجواز للمراجعة: ${app.passportFileName}'),
                  ),
                ),
              if (app.paymentReceiptFilePath != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      if (app.paymentReceiptFilePath!.startsWith('http')) {
                        await launchUrl(Uri.parse(app.paymentReceiptFilePath!));
                      } else {
                        await OpenFilex.open(app.paymentReceiptFilePath!);
                      }
                    },
                    icon: const Icon(Icons.receipt_long, color: Colors.orange),
                    label: Text('فتح إيصال الدفع: ${app.paymentReceiptFileName}'),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 120, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textGrey))),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
