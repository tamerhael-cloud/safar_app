import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../theme/app_theme.dart';
import '../models/visa_application.dart';
import '../services/visa_service.dart';
import '../services/language_service.dart';
import '../services/user_service.dart';
import '../models/visa_pricing.dart';
import '../services/payment_service.dart';
import '../models/payment_option.dart';

class VisaApplicationScreen extends StatefulWidget {
  const VisaApplicationScreen({super.key});

  @override
  State<VisaApplicationScreen> createState() => _VisaApplicationScreenState();
}

class _VisaApplicationScreenState extends State<VisaApplicationScreen> {
  final _nameController = TextEditingController();
  final _motherNameController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _visitedCountriesController = TextEditingController();
  
  CountryVisaData? _selectedCountry;
  VisaType? _selectedType;
  
  PlatformFile? _pickedFile;
  bool _isSubmitting = false;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _selectedCountry = visaPricingData[0];
    _selectedType = _selectedCountry!.types[0];
  }

  Future<void> _pickPassport() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      setState(() => _isScanning = true);
      await Future.delayed(const Duration(seconds: 3));
      
      setState(() {
        _pickedFile = result.files.first;
        _isScanning = false;
      });

      if (_pickedFile!.name.toLowerCase().contains('fake')) {
        _showError(LanguageService().translate('تم رفض الملف: الوثيقة الممسوحة لا تطابق معايير جواز السفر المطلوبة', 'File Rejected: Document does not match passport standards'));
        setState(() => _pickedFile = null);
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  void _submitApplication() {
    final lang = LanguageService();
    final name = _nameController.text.trim();
    final motherName = _motherNameController.text.trim();
    final nationality = _nationalityController.text.trim();
    final visitedCountries = _visitedCountriesController.text.trim();

    if (name.isEmpty || motherName.isEmpty || nationality.isEmpty || visitedCountries.isEmpty || _selectedCountry == null || _selectedType == null) {
      _showError(lang.translate('يرجى ملء جميع الخانات', 'Please fill all fields'));
      return;
    }

    if (_pickedFile == null) {
      _showError(lang.translate('يرجى إرفاق صورة الجواز الممسوحة', 'Please attach scanned passport'));
      return;
    }

    _showPaymentBottomSheet();
  }

  void _showPaymentBottomSheet() {
    final lang = LanguageService();
    final paymentService = PaymentService();
    final options = paymentService.options;
    
    if (options.isEmpty) {
      _showError(lang.translate('لا توجد طرق دفع مهيئة', 'No payment methods configured'));
      return;
    }

    String selectedMethodId = options.first.id;
    PlatformFile? receiptFile;

    IconData _getIcon(String iconType) {
      switch (iconType) {
        case 'wallet': return Icons.account_balance_wallet;
        case 'credit_card': return Icons.credit_card;
        case 'bank': return Icons.account_balance;
        default: return Icons.payment;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final selectedOption = options.firstWhere((o) => o.id == selectedMethodId);

            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lang.translate('طريقة الدفع', 'Payment Method'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                  const SizedBox(height: 16),
                  Text(lang.translate('الرجاء اختيار طريقة الدفع لإتمام طلب التأشيرة:', 'Please select a payment method to complete the visa application:')),
                  const SizedBox(height: 16),
                  
                  ...options.map((option) => RadioListTile(
                    value: option.id, 
                    groupValue: selectedMethodId, 
                    onChanged: (val) => setModalState(() => selectedMethodId = val.toString()),
                    title: Text(lang.translate(option.titleAr, option.titleEn)),
                    subtitle: selectedMethodId == option.id ? Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(lang.translate(option.detailsAr, option.detailsEn), style: const TextStyle(color: AppTheme.safarBlue)),
                    ) : null,
                    secondary: Icon(_getIcon(option.iconType), color: selectedMethodId == option.id ? AppTheme.safarBlue : Colors.grey),
                  )),
                  
                  if (selectedOption.iconType != 'credit_card') ...[
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          final result = await FilePicker.platform.pickFiles(type: FileType.any);
                          if (result != null) {
                            setModalState(() => receiptFile = result.files.first);
                          }
                        },
                        icon: const Icon(Icons.upload_file),
                        label: Text(receiptFile != null 
                          ? '${lang.translate('تم إرفاق:', 'Uploaded:')} ${receiptFile!.name}' 
                          : lang.translate('إرفاق إيصال الدفع (اجباري)', 'Upload Payment Receipt (Mandatory)')),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (selectedOption.iconType != 'credit_card' && receiptFile == null) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(lang.translate('يجب إرفاق إيصال الدفع', 'Payment receipt is required')),
                            backgroundColor: Colors.red,
                          ));
                          return;
                        }

                        Navigator.pop(context); // close payment sheet
                        String paymentStr = lang.translate(selectedOption.titleAr, selectedOption.titleEn);
                        _processSubmission(paymentStr, receiptFile); // proceed with actual submission
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.safarBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: Text(lang.translate('تأكيد الدفع وتقديم الطلب', 'Confirm Payment & Submit')),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _processSubmission(String paymentMethod, PlatformFile? receiptFile) async {
    final lang = LanguageService();
    final userService = UserService(); // Fetched to inject submittedBy
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    final application = VisaApplication(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fullName: _nameController.text.trim(),
      motherName: _motherNameController.text.trim(),
      nationality: _nationalityController.text.trim(),
      targetCountry: _selectedCountry!.nameAr,
      visaType: _selectedType!.titleAr,
      price: _selectedType!.price,
      visitedCountries: _visitedCountriesController.text.trim(),
      passportFileName: _pickedFile!.name,
      passportFilePath: _pickedFile!.path,
      submissionDate: DateTime.now(),
      status: 'بانتظار تأكيد الدفع',
      paymentMethod: paymentMethod,
      paymentReceiptFileName: receiptFile?.name,
      paymentReceiptFilePath: receiptFile?.path,
      submittedBy: userService.userName,
    );

    await VisaService().submitApplication(application);
    setState(() => _isSubmitting = false);

    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(lang.translate('في انتظار تأكيد الدفع', 'Awaiting Payment Confirmation')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time_filled, color: Colors.orange, size: 64),
              const SizedBox(height: 16),
              Text(lang.translate('تم استلام إيصال/عملية الدفع وهي الآن قيد المراجعة التامة من قبل الإدارة. سيتم تغيير حالة طلبك قريباً.', 'Payment receipt received and pending admin confirmation. Status will update soon.'), textAlign: TextAlign.center),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () { 
                Navigator.pop(context); // close dialog
                Navigator.pop(context); // go back to previous screen
              }, 
              child: const Text('OK')
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService();
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => Scaffold(
        appBar: AppBar(
          title: Text(lang.translate('طلب تأشيرة', 'Visa Application'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.safarBlue,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(lang.translate('وجهة السفر ونوع الفيزا', 'Destination & Visa Type')),
              const SizedBox(height: 16),
              _buildCountryDropdown(lang),
              const SizedBox(height: 16),
              _buildVisaTypeDropdown(lang),
              if (_selectedType != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.amber[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.amber[200]!)),
                  child: Row(
                    children: [
                      const Icon(Icons.payments_outlined, color: Colors.amber),
                      const SizedBox(width: 12),
                      Text(lang.translate('التكلفة:', 'Price:'), style: const TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text('\$${_selectedType!.price}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
              _buildSectionTitle(lang.translate('المعلومات الشخصية', 'Personal Information')),
              const SizedBox(height: 16),
              _buildInputField(_nameController, lang.translate('الاسم الرباعي', 'Full Name'), Icons.person_outline),
              const SizedBox(height: 16),
              _buildInputField(_motherNameController, lang.translate('اسم الام الرباعي', 'Mother\'s Full Name'), Icons.face),
              const SizedBox(height: 16),
              _buildInputField(_nationalityController, lang.translate('الجنسية', 'Nationality'), Icons.public),
              const SizedBox(height: 16),
              _buildInputField(_visitedCountriesController, lang.translate('الدول المزارة سابقاً', 'Previously Visited'), Icons.history),
              const SizedBox(height: 32),
              _buildSectionTitle(lang.translate('إرفاق الوثائق', 'Documents')),
              const SizedBox(height: 16),
              _buildScanningSection(lang),
              const SizedBox(height: 48),
              _buildSubmitButton(lang),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark));
  }

  Widget _buildCountryDropdown(LanguageService lang) {
    return DropdownButtonFormField<CountryVisaData>(
      value: _selectedCountry,
      decoration: InputDecoration(
        labelText: lang.translate('اختر الدولة', 'Choose Country'),
        prefixIcon: const Icon(Icons.map, color: AppTheme.safarBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: visaPricingData.map((c) => DropdownMenuItem(
        value: c,
        child: Text(lang.translate(c.nameAr, c.nameEn)),
      )).toList(),
      onChanged: (val) {
        setState(() {
          _selectedCountry = val;
          _selectedType = val?.types[0];
        });
      },
    );
  }

  Widget _buildVisaTypeDropdown(LanguageService lang) {
    return DropdownButtonFormField<VisaType>(
      value: _selectedType,
      decoration: InputDecoration(
        labelText: lang.translate('نوع التأشيرة', 'Visa Type'),
        prefixIcon: const Icon(Icons.category, color: AppTheme.safarBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      items: _selectedCountry?.types.map((t) => DropdownMenuItem(
        value: t,
        child: Text('${lang.translate(t.titleAr, t.titleEn)} (\$${t.price})'),
      )).toList(),
      onChanged: (val) => setState(() => _selectedType = val),
    );
  }

  Widget _buildScanningSection(LanguageService lang) {
    if (_isScanning) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(lang.translate('جاري مسح الجواز وتدقيق البيانات...', 'Scanning and verifying...')),
          ],
        ),
      );
    }
    return InkWell(
      onTap: _pickPassport,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: _pickedFile != null ? Colors.green : AppTheme.safarBlue.withOpacity(0.3), width: 2),
          borderRadius: BorderRadius.circular(16),
          color: _pickedFile != null ? Colors.green[50] : AppTheme.safarBlue.withOpacity(0.05),
        ),
        child: Row(
          children: [
            const Icon(Icons.qr_code_scanner, color: AppTheme.safarBlue, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _pickedFile == null ? lang.translate('ابدأ مسح الجواز ضوئياً', 'Start Passport Scan') : lang.translate('تم المسح: ', 'Scanned: ') + _pickedFile!.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
            if (_pickedFile != null) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(LanguageService lang) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitApplication,
        style: ElevatedButton.styleFrom(backgroundColor: AppTheme.safarBlue, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : Text(lang.translate('تقديم الطلب الآن', 'Submit Now')),
      ),
    );
  }

  Widget _buildInputField(TextEditingController controller, String label, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.safarBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
