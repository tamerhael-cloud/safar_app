import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/user_service.dart';
import '../../models/user_account.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  void _showEditUserDialog(BuildContext context, UserAccount user) {
    final usernameController = TextEditingController(text: user.username);
    final passwordController = TextEditingController(text: user.password);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('تعديل الحساب: ${user.username}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(labelText: 'اسم المستخدم (User Name)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(labelText: 'كلمة المرور (Password)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), 
              child: const Text('إلغاء')
            ),
            ElevatedButton(
              onPressed: () async {
                if (usernameController.text.trim().isEmpty || passwordController.text.trim().isEmpty) return;
                
                final success = await UserService().updateUserCredentials(
                  user.username, 
                  usernameController.text.trim(), 
                  passwordController.text.trim()
                );
                
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث البيانات بنجاح', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حدث خطأ أثناء التحديث'), backgroundColor: Colors.red));
                }
              }, 
              child: const Text('حفظ')
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الحسابات والمستخدمين', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: AppTheme.safarBlue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListenableBuilder(
        listenable: UserService(),
        builder: (context, child) {
          final users = UserService().registeredUsers;
          if (users.isEmpty) {
            return const Center(
              child: Text('لا يوجد مستخدمون مسجلون حالياً', style: TextStyle(color: Colors.grey)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: user.isAdmin ? Colors.red.shade100 : AppTheme.safarBlue.withOpacity(0.2),
                    child: Icon(user.isAdmin ? Icons.admin_panel_settings : Icons.person, color: user.isAdmin ? Colors.red : AppTheme.safarBlue),
                  ),
                  title: Row(
                    children: [
                      Text(user.username, style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (user.isAdmin) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(8)),
                          child: const Text('Admin', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ]
                    ],
                  ),
                  subtitle: Text('كلمة المرور: ${user.password}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    onPressed: () => _showEditUserDialog(context, user),
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

