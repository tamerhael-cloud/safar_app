import 'package:flutter/material.dart';
import '../services/payment_service.dart';
import '../models/payment_option.dart';
import '../theme/app_theme.dart';

class UserPaymentMethodsScreen extends StatelessWidget {
  const UserPaymentMethodsScreen({super.key});

  IconData _getIconForType(String type) {
    switch (type) {
      case 'credit_card': return Icons.credit_card;
      case 'wallet': return Icons.account_balance_wallet;
      case 'bank': return Icons.account_balance;
      default: return Icons.payment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paymentService = PaymentService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('طرق وحسابات الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.safarBlue,
        foregroundColor: Colors.white,
      ),
      body: ListenableBuilder(
        listenable: paymentService,
        builder: (context, _) {
          final options = paymentService.options;
          if (options.isEmpty) {
            return const Center(child: Text('لا توجد طرق دفع متاحة حالياً.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final option = options[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.safarBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(_getIconForType(option.iconType), color: AppTheme.safarBlue),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option.titleAr,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          option.detailsAr,
                          style: const TextStyle(height: 1.5, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
