import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';
import '../services/visa_service.dart';

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = LanguageService();
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        appBar: AppBar(
          title: Text(lang.translate('رحلاتي وتأشيراتي', 'Trips & Visas'), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildVisaSection(context, lang),
              const Divider(),
              _buildTripHeader(lang),
              const SizedBox(height: 24),
              _buildRecommendedSection(lang),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVisaSection(BuildContext context, LanguageService lang) {
    return ListenableBuilder(
      listenable: VisaService(),
      builder: (context, _) {
        final apps = VisaService().applications;
        if (apps.isEmpty) return const SizedBox.shrink();

        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lang.translate('تأشيراتي', 'My Visas'),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
              const SizedBox(height: 12),
              ...apps.map((app) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.credit_card, color: AppTheme.safarBlue),
                        const SizedBox(width: 12),
                        Expanded(child: Text('${app.targetCountry} - ${app.visaType}', style: const TextStyle(fontWeight: FontWeight.bold))),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(app.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            app.status,
                            style: TextStyle(color: _getStatusColor(app.status), fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    if (app.status == 'مقبول' && app.approvedVisaFilePath != null) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (app.approvedVisaFilePath!.startsWith('http')) {
                              await launchUrl(Uri.parse(app.approvedVisaFilePath!));
                            } else {
                              await OpenFilex.open(app.approvedVisaFilePath!);
                            }
                          },
                          icon: const Icon(Icons.download),
                          label: Text(lang.translate('عرض التأشيرة الصادرة', 'View Issued Visa')),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
              )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTripHeader(LanguageService lang) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        children: [
          Icon(Icons.luggage_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            lang.translate('لا توجد رحلات قادمة', 'No upcoming trips'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 8),
          Text(
            lang.translate('خطط لرحلتك القادمة الآن!', 'Keep planning and book your next adventure!'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textGrey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
            child: Text(lang.translate('البحث عن وجهات', 'Search for destinations')),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedSection(LanguageService lang) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lang.translate('مقترح لك', 'Recommended for you'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          _buildRecommendedCard(lang, 'دبي، الإمارات', 'Luxury hotels and world-class shopping.', 'From \$180', 'assets/images/hotel_exterior.png'),
          const SizedBox(height: 16),
          _buildRecommendedCard(lang, 'المالديف', 'Breathtaking overwater villas and clear waters.', 'From \$450', 'assets/images/infinity_pool.png'),
        ],
      ),
    );
  }

  Widget _buildRecommendedCard(LanguageService lang, String title, String desc, String price, String img) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Container(height: 180, width: double.infinity, color: AppTheme.safarBlue.withOpacity(0.1), child: const Icon(Icons.image, color: Colors.white, size: 50)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(price, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(desc, style: const TextStyle(color: AppTheme.textGrey, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'مقبول') return Colors.green;
    if (status == 'مرفوض' || status == 'تم رفض الدفع') return Colors.red;
    if (status == 'قيد المعاملة') return Colors.blue;
    if (status == 'بانتظار تأكيد الدفع') return Colors.orange;
    return Colors.orange;
  }
}
