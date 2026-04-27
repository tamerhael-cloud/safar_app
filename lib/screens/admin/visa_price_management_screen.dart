import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/visa_service.dart';
import '../../services/language_service.dart';
import '../../models/visa_pricing.dart';

class VisaPriceManagementScreen extends StatefulWidget {
  const VisaPriceManagementScreen({super.key});

  @override
  State<VisaPriceManagementScreen> createState() => _VisaPriceManagementScreenState();
}

class _VisaPriceManagementScreenState extends State<VisaPriceManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final visaService = VisaService();
    final lang = LanguageService();

    return ListenableBuilder(
      listenable: visaService,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(lang.translate('إدارة رسوم الخدمات', 'Service Fees Management'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: AppTheme.safarBlue,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_location_alt),
              onPressed: () => _showAddCountryDialog(context),
              tooltip: lang.translate('إضافة دولة/جنسية', 'Add Country/Nationality'),
            ),
          ],
        ),
        body: ListView.builder(
          itemCount: visaService.pricingData.length,
          itemBuilder: (context, index) {
            final country = visaService.pricingData[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16), 
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                title: Text(lang.translate(country.nameAr, country.nameEn), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                leading: const Icon(Icons.public, color: AppTheme.safarBlue),
                children: [
                  ...country.types.map((type) => ListTile(
                    title: Text(lang.translate(type.titleAr, type.titleEn)),
                    subtitle: Text('\$${type.price}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit, size: 20, color: Colors.orange), onPressed: () => _showEditPriceDialog(context, type)),
                        IconButton(icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red), onPressed: () {
                          setState(() => country.types.remove(type));
                          VisaService().notifyListenersManual();
                        }),
                      ],
                    ),
                  )),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextButton.icon(
                      onPressed: () => _showAddVisaTypeDialog(context, country),
                      icon: const Icon(Icons.add),
                      label: Text(lang.translate('إضافة نوع تأشيرة جديد', 'Add New Visa Type')),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showAddCountryDialog(BuildContext context) {
    final arController = TextEditingController();
    final enController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة دولة أو جنسية جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: arController, decoration: const InputDecoration(labelText: 'الاسم بالعربي (مثلاً: اليمني إلى مصر)')),
            TextField(controller: enController, decoration: const InputDecoration(labelText: 'الاسم بالإنجليزي')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              if (arController.text.isNotEmpty) {
                VisaService().pricingData.add(CountryVisaData(
                  nameAr: arController.text,
                  nameEn: enController.text.isEmpty ? arController.text : enController.text,
                  types: [],
                ));
                VisaService().notifyListenersManual();
                Navigator.pop(context);
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showAddVisaTypeDialog(BuildContext context, CountryVisaData country) {
    final titleArController = TextEditingController();
    final priceController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إضافة نوع لـ ${country.nameAr}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleArController, decoration: const InputDecoration(labelText: 'نوع الفيزا (مثلاً: مستعجلة)')),
            TextField(controller: priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر (\$)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final price = double.tryParse(priceController.text) ?? 0;
              country.types.add(VisaType(
                titleAr: titleArController.text,
                titleEn: titleArController.text, // Simplified
                price: price,
              ));
              VisaService().notifyListenersManual();
              Navigator.pop(context);
            },
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _showEditPriceDialog(BuildContext context, VisaType type) {
    final controller = TextEditingController(text: type.price.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('تعديل السعر لـ ${type.titleAr}'),
        content: TextField(controller: controller, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'السعر الجديد (\$)')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () {
              final newPrice = double.tryParse(controller.text);
              if (newPrice != null) {
                type.price = newPrice;
                VisaService().notifyListenersManual();
                Navigator.pop(context);
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
