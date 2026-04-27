import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/visa_service.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import '../../models/visa_application.dart';
import 'visa_management_screen.dart';
import 'service_management_screen.dart';
import 'users_management_screen.dart';
import '../../services/user_service.dart';
import 'visa_price_management_screen.dart';
import 'admin_payment_methods_screen.dart';
import '../../services/pdf_service.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: VisaService(),
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        appBar: AppBar(
          title: const Text('لوحة تحكم المسؤول', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          backgroundColor: AppTheme.safarBlue,
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            if (VisaService().hasNewNotification)
              Stack(
                children: [
                   IconButton(
                    icon: const Icon(Icons.notifications_active, color: Colors.orange),
                    onPressed: () {
                      VisaService().clearNotification();
                    },
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(6)),
                      child: const Text('!', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (VisaService().hasNewNotification)
                  _buildNotificationAlert(),
                const SizedBox(height: 10),
                _buildStatsOverview(context),
                const SizedBox(height: 30),
                const Text('Management (إدارة الخدمات)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildManagementGrid(context),
                const SizedBox(height: 30),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('آخر طلبات التأشيرة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                    TextButton.icon(
                      onPressed: () {
                        final apps = VisaService().applications;
                        double rev = 0; double cost = 0;
                        for (var a in apps) {
                          if (a.status != 'مرفوض' && a.status != 'تم رفض الدفع') {
                            rev += a.price; cost += a.costPrice ?? 0;
                          }
                        }
                        PdfService.generateStatementPdf(
                          title: 'Safar App - Financial Statement',
                          applications: apps,
                          totalRevenue: rev,
                          totalCost: cost,
                          netProfit: rev - cost,
                        );
                      },
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('تصدير PDF'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildVisaApplicationsList(),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationAlert() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.orange[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.orange[200]!)),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange),
          const SizedBox(width: 12),
          const Expanded(
            child: Text('هناك طلبات فيزا جديدة بانتظار المراجعة!', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          ),
          TextButton(onPressed: () => VisaService().clearNotification(), child: const Text('تجاهل')),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context) {
    final apps = VisaService().applications;
    double totalRevenue = 0;
    double totalCost = 0;
    
    for (var app in apps) {
      if (app.status != 'مرفوض' && app.status != 'تم رفض الدفع') {
        totalRevenue += app.price;
        totalCost += app.costPrice ?? 0;
      }
    }
    double netProfit = totalRevenue - totalCost;

    return ListenableBuilder(
      listenable: UserService(),
      builder: (context, _) => Column(
        children: [
          Row(
            children: [
              _buildStatCard('إجمالي المبيعات', '\$${totalRevenue.toStringAsFixed(0)}', Icons.monetization_on, Colors.green),
              const SizedBox(width: 16),
              _buildStatCard('إجمالي التكاليف', '\$${totalCost.toStringAsFixed(0)}', Icons.account_balance_wallet, Colors.red),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard('صافي الربح', '\$${netProfit.toStringAsFixed(0)}', Icons.trending_up, Colors.orange),
              const SizedBox(width: 16),
              _buildStatCard(
                'المستخدمين', 
                UserService().registeredUsers.length.toString(), 
                Icons.people, 
                Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersManagementScreen())),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, {VoidCallback? onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 30),
              const SizedBox(height: 10),
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManagementGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildManageItem(context, 'التحكم بالرحلات', Icons.flight, Colors.orange, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementScreen(title: 'الرحلات')));
        }),
        _buildManageItem(context, 'حسابات الدفع', Icons.account_balance, Colors.green, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminPaymentMethodsScreen()));
        }),
        _buildManageItem(context, 'إدارة المستخدمين', Icons.group_work, Colors.indigo, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const UsersManagementScreen()));
        }),
        _buildManageItem(context, 'طلبات التأشيرات', Icons.credit_card, Colors.blue, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const VisaManagementScreen()));
        }),
        _buildManageItem(context, 'تعديل الأسعار', Icons.settings_suggest, Colors.teal, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const VisaPriceManagementScreen()));
        }),
        _buildManageItem(context, 'رسوم الخدمة', Icons.percent, Colors.red, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementScreen(title: 'الرسوم')));
        }),
        _buildManageItem(context, 'دردشة الدعم', Icons.chat_bubble, Colors.amber, onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const ServiceManagementScreen(title: 'الدعم')));
        }),
      ],
    );
  }

  Widget _buildManageItem(BuildContext context, String label, IconData icon, Color color, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }

  Widget _buildVisaApplicationsList() {
    final apps = VisaService().applications;
    if (apps.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(child: Text('لا توجد طلبات حالياً', style: TextStyle(color: Colors.grey))),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: apps.length > 5 ? 5 : apps.length,
      itemBuilder: (context, index) {
        final app = apps[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: CircleAvatar(backgroundColor: AppTheme.safarBlue.withOpacity(0.1), child: const Icon(Icons.person, color: AppTheme.safarBlue)),
            title: Text(app.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${app.targetCountry} - ${app.visaType} (\$${app.price})'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: app.status == 'مقبول' ? Colors.green[50] : Colors.orange[50], borderRadius: BorderRadius.circular(12)),
              child: Text(app.status, style: TextStyle(color: app.status == 'مقبول' ? Colors.green : Colors.orange, fontSize: 10, fontWeight: FontWeight.bold)),
            ),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const VisaManagementScreen())),
          ),
        );
      },
    );
  }
}
