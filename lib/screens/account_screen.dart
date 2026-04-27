import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/language_service.dart';
import 'account_statement_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import 'settings_screen.dart';
import 'user_payment_methods_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService();
    final lang = LanguageService();
    
    return ListenableBuilder(
      listenable: lang,
      builder: (context, _) => Scaffold(
        backgroundColor: AppTheme.backgroundGrey,
        body: SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(user, lang),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatRow(lang),
                    const SizedBox(height: 24),
                    if (user.role == UserRole.admin) ...[
                      _buildAdminPanelCard(context, lang),
                      const SizedBox(height: 24),
                    ],
                    _buildActionGrid(context, lang),
                    const SizedBox(height: 24),
                    _buildUserPaymentMethodsCard(context, lang),
                    const SizedBox(height: 24),
                    _buildAccountStatementCard(context, lang),
                    const SizedBox(height: 24),
                    _buildLogoutButton(context, lang),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserService user, LanguageService lang) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        color: AppTheme.safarBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(
              user.role == UserRole.admin ? Icons.admin_panel_settings : Icons.person, 
              size: 50, 
              color: AppTheme.safarBlue
            ),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.userName ?? 'Tamer Alhamadi',
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      user.role == UserRole.admin ? Icons.verified : Icons.diamond, 
                      color: user.role == UserRole.admin ? Colors.blue.shade200 : Colors.amber, 
                      size: 16
                    ),
                    const SizedBox(width: 4),
                    Text(
                      user.role == UserRole.admin 
                        ? lang.translate('مسؤول', 'Administrator') 
                        : lang.translate('عضو فضي', 'Silver Member'), 
                      style: const TextStyle(color: Colors.white, fontSize: 12)
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(LanguageService lang) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('12', lang.translate('رحلاتي', 'My Trips')),
          _buildDivider(),
          _buildStatItem('450', lang.translate('نقاطي', 'Trip Coins')),
          _buildDivider(),
          _buildStatItem('3', lang.translate('كوبونات', 'Coupons')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.safarBlue)),
        Text(label, style: const TextStyle(color: AppTheme.textGrey, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 30, color: Colors.grey.shade200);
  }

  Widget _buildAdminPanelCard(BuildContext context, LanguageService lang) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AdminDashboardScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.05),
          border: Border.all(color: AppTheme.safarBlue.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.dashboard_customize, color: AppTheme.safarBlue, size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.translate('لوحة تحكم المسؤول', 'Admin Dashboard'), style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(lang.translate('إدارة الرحلات والفنادق والحجوزات', 'Manage flights, hotels, and bookings'), style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid(BuildContext context, LanguageService lang) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      children: [
        _buildGridItem(Icons.book_online, lang.translate('حجوزاتي', 'Bookings')),
        _buildGridItem(Icons.favorite_border, lang.translate('المفضلة', 'Favorites')),
        _buildGridItem(Icons.card_giftcard, lang.translate('العروض', 'Promos')),
        _buildGridItem(Icons.support_agent, lang.translate('الدعم', 'Support')),
        _buildGridItem(Icons.settings_outlined, lang.translate('الإعدادات', 'Settings'), onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
        }),
        _buildGridItem(Icons.feedback_outlined, lang.translate('آراء', 'Feedback')),
      ],
    );
  }

  Widget _buildGridItem(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.safarBlue),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildUserPaymentMethodsCard(BuildContext context, LanguageService lang) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const UserPaymentMethodsScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.safarBlue.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            const Icon(Icons.payment, color: AppTheme.safarBlue, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.translate('طرق وحسابات الدفع', 'Payment Methods'), style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
                Text(lang.translate('عرض حسابات الدفع المتاحة', 'View available payment accounts'), style: const TextStyle(color: AppTheme.textGrey, fontSize: 11)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppTheme.textGrey),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountStatementCard(BuildContext context, LanguageService lang) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountStatementScreen()));
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF2193b0), Color(0xFF6dd5ed)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_balance_wallet, color: Colors.white, size: 30),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.translate('كشف الحساب', 'Statement of Account'), style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                Text(lang.translate('عرض المعاملات والسجل', 'View transactions & history'), style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, LanguageService lang) {
    return OutlinedButton(
      onPressed: () {
        UserService().logout();
      },
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Colors.redAccent),
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(lang.translate('تسجيل الخروج', 'Log Out'), style: const TextStyle(color: Colors.redAccent)),
    );
  }
}
