import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/payment_option.dart';

class PaymentService extends ChangeNotifier {
  static final PaymentService _instance = PaymentService._internal();
  factory PaymentService() => _instance;
  PaymentService._internal() {
    _loadOptions();
  }

  final List<PaymentOption> _options = [];
  List<PaymentOption> get options => _options;

  Future<void> _loadOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString('payment_options');
    
    if (data != null) {
      final List<dynamic> decoded = jsonDecode(data);
      _options.clear();
      _options.addAll(decoded.map((item) => PaymentOption.fromMap(item)).toList());
    }

    // Initialize with default values if completely empty
    if (_options.isEmpty) {
      _options.addAll([
        PaymentOption(
          id: 'card_1',
          titleAr: 'البطاقة الائتمانية',
          titleEn: 'Credit Card (Visa/Mastercard)',
          detailsAr: 'لا حاجة لإرفاق صورة، الدفع يتم عبر بوابة إلكترونية',
          detailsEn: 'No image required, payment is via secure gateway.',
          iconType: 'credit_card',
        ),
        PaymentOption(
          id: 'wallet_1',
          titleAr: 'محفظة إلكترونية (جوالي / ام فلوس)',
          titleEn: 'E-Wallet (Jawali / M-Floos)',
          detailsAr: 'حساب محفظة جوالي: 777123456 (باسم: سفريات)\nيرجى تحويل المبلغ المطلوب وإرفاق إيصال الدفع.',
          detailsEn: 'Jawali Wallet: 777123456 (Safar Travel)\nPlease transfer the amount and attach confirmation.',
          iconType: 'wallet',
        ),
        PaymentOption(
          id: 'bank_1',
          titleAr: 'إيداع بنكي / حوالة خارجية',
          titleEn: 'Bank Transfer / Deposit',
          detailsAr: 'بنك التضامن: 123456789 (باسم: سفريات)\nيرجى إيداع المبلغ وإرفاق سند الإيداع أو الحوالة.',
          detailsEn: 'Al-Tadhamon Bank: 123456789 (Name: Safar Travel)\nPlease deposit and attach receipt.',
          iconType: 'bank',
        ),
      ]);
      _saveOptions();
    }
    notifyListeners();
  }

  Future<void> _saveOptions() async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = jsonEncode(_options.map((o) => o.toMap()).toList());
    await prefs.setString('payment_options', encoded);
  }

  void addOption(PaymentOption option) {
    _options.add(option);
    _saveOptions();
    notifyListeners();
  }

  void updateOption(String id, PaymentOption updatedOption) {
    final index = _options.indexWhere((o) => o.id == id);
    if (index != -1) {
      _options[index] = updatedOption;
      _saveOptions();
      notifyListeners();
    }
  }

  void deleteOption(String id) {
    _options.removeWhere((o) => o.id == id);
    _saveOptions();
    notifyListeners();
  }
}

