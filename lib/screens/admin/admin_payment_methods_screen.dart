import 'package:flutter/material.dart';
import '../../services/payment_service.dart';
import '../../models/payment_option.dart';
import '../../theme/app_theme.dart';

class AdminPaymentMethodsScreen extends StatefulWidget {
  const AdminPaymentMethodsScreen({super.key});

  @override
  State<AdminPaymentMethodsScreen> createState() => _AdminPaymentMethodsScreenState();
}

class _AdminPaymentMethodsScreenState extends State<AdminPaymentMethodsScreen> {
  final _service = PaymentService();

  IconData _getIconForType(String type) {
    switch (type) {
      case 'credit_card': return Icons.credit_card;
      case 'wallet': return Icons.account_balance_wallet;
      case 'bank': return Icons.account_balance;
      default: return Icons.payment;
    }
  }

  void _showPaymentFormDialog({PaymentOption? option}) {
    final titleArController = TextEditingController(text: option?.titleAr);
    final titleEnController = TextEditingController(text: option?.titleEn);
    final detailsArController = TextEditingController(text: option?.detailsAr);
    final detailsEnController = TextEditingController(text: option?.detailsEn);
    String selectedType = option?.iconType ?? 'bank';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Text(option == null ? 'إضافة طريقة دفع جديدة' : 'تعديل طريقة الدفع'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedType,
                    decoration: const InputDecoration(labelText: 'نوع الحساب/الدفع'),
                    items: const [
                      DropdownMenuItem(value: 'bank', child: Text('حساب بنكي')),
                      DropdownMenuItem(value: 'wallet', child: Text('محفظة إلكترونية')),
                      DropdownMenuItem(value: 'credit_card', child: Text('بطاقة ائتمانية')),
                    ],
                    onChanged: (val) => setDialogState(() => selectedType = val!),
                  ),
                  const SizedBox(height: 12),
                  TextField(controller: titleArController, decoration: const InputDecoration(labelText: 'الاسم بالعربي (مثال: بنك التضامن)')),
                  const SizedBox(height: 12),
                  TextField(controller: titleEnController, decoration: const InputDecoration(labelText: 'الاسم بالإنجليزي')),
                  const SizedBox(height: 12),
                  TextField(controller: detailsArController, maxLines: 3, decoration: const InputDecoration(labelText: 'التفاصيل ورقم الحساب بالعربي')),
                  const SizedBox(height: 12),
                  TextField(controller: detailsEnController, maxLines: 3, decoration: const InputDecoration(labelText: 'التفاصيل والإسم بالإنجليزي')),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () {
                  if (titleArController.text.isEmpty) return;

                  final newOption = PaymentOption(
                    id: option?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                    titleAr: titleArController.text,
                    titleEn: titleEnController.text.isEmpty ? titleArController.text : titleEnController.text,
                    detailsAr: detailsArController.text,
                    detailsEn: detailsEnController.text.isEmpty ? detailsArController.text : detailsEnController.text,
                    iconType: selectedType,
                  );

                  if (option == null) {
                    _service.addOption(newOption);
                  } else {
                    _service.updateOption(newOption.id, newOption);
                  }

                  Navigator.pop(context);
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الطرق وحسابات الدفع', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.safarBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: _service,
        builder: (context, _) {
          final options = _service.options;
          if (options.isEmpty) {
            return const Center(child: Text('لا توجد طرق دفع متاحة. يرجى إضافة طريقة.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(_getIconForType(option.iconType), color: AppTheme.safarBlue, size: 30),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(option.titleAr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
                            onPressed: () => _showPaymentFormDialog(option: option),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _service.deleteOption(option.id),
                          ),
                        ],
                      ),
                      const Divider(),
                      const Text('التفاصيل / رقم الحساب:', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(option.detailsAr, style: const TextStyle(height: 1.4)),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPaymentFormDialog(),
        icon: const Icon(Icons.add),
        label: const Text('إضافة حساب'),
        backgroundColor: AppTheme.safarBlue,
        foregroundColor: Colors.white,
      ),
    );
  }
}
