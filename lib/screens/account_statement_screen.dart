import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../services/visa_service.dart';
import '../services/user_service.dart';
import '../services/language_service.dart';
import '../services/pdf_service.dart';

class AccountStatementScreen extends StatelessWidget {
  const AccountStatementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final visaService = VisaService();
    final userService = UserService();
    final lang = LanguageService();

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(lang.translate('كشف الحساب', 'Statement of Account'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.safarBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          ListenableBuilder(
            listenable: visaService,
            builder: (context, _) {
              final currentUser = userService.userName;
              final myTransactions = userService.role == UserRole.admin
                  ? visaService.applications
                  : visaService.applications.where((app) => 
                      app.submittedBy == currentUser || app.submittedBy == null
                    ).toList();
              
              if (myTransactions.isEmpty) return const SizedBox.shrink();
              
              return IconButton(
                icon: const Icon(Icons.picture_as_pdf),
                onPressed: () {
                  double rev = 0; double cost = 0;
                  for (var a in myTransactions) {
                    rev += a.price; cost += a.costPrice ?? 0;
                  }
                  PdfService.generateStatementPdf(
                    title: 'Account Statement - $currentUser',
                    applications: myTransactions,
                    totalRevenue: rev,
                    totalCost: cost,
                    netProfit: rev - cost,
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: visaService,
        builder: (context, _) {
          final currentUser = userService.userName;
          // Filter: Admin sees all, User sees only their own
          final myTransactions = userService.role == UserRole.admin
              ? visaService.applications
              : visaService.applications.where((app) => 
                  app.submittedBy == currentUser || app.submittedBy == null
                ).toList();

          if (myTransactions.isEmpty) {
            return Center(
              child: Text(lang.translate('لا توجد حركات مالية مسجلة', 'No financial transactions recorded')),
            );
          }

          // Sort by submission date descending
          myTransactions.sort((a, b) => b.submissionDate.compareTo(a.submissionDate));

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: myTransactions.length,
            itemBuilder: (context, index) {
              final app = myTransactions[index];
              
              String statusLabel = '';
              Color statusColor = Colors.grey;
              bool isNegative = true; // Most are payments out

              if (app.status == 'بانتظار تأكيد الدفع') {
                statusLabel = lang.translate('قيد المراجعة / معلق', 'Pending');
                statusColor = Colors.orange;
              } else if (app.status == 'مرفوض' || app.status == 'تم رفض الدفع') {
                statusLabel = lang.translate('مرفوض', 'Failed');
                statusColor = Colors.red;
                isNegative = false; // Denotes money wasn't taken
              } else {
                statusLabel = lang.translate('مكتمل', 'Completed');
                statusColor = Colors.green;
              }

              return _buildTransactionItem(
                icon: Icons.document_scanner,
                title: '${lang.translate('فيزا', 'Visa')} - ${app.targetCountry}',
                date: DateFormat('MMM dd, yyyy').format(app.submissionDate),
                amount: '\$${app.price.toStringAsFixed(2)}',
                status: statusLabel,
                statusColor: statusColor,
                isNegative: isNegative,
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String date,
    required String amount,
    required String status,
    required Color statusColor,
    required bool isNegative,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.safarBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.safarBlue, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                isNegative ? '-$amount' : amount,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isNegative ? Colors.red : (statusColor == Colors.red ? Colors.grey : Colors.green),
                  decoration: statusColor == Colors.red ? TextDecoration.lineThrough : null, // Strikethrough if failed
                ),
              ),
              const SizedBox(height: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
