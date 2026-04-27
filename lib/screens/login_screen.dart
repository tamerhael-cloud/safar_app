import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        _usernameController.text = prefs.getString('saved_username') ?? '';
        _passwordController.text = prefs.getString('saved_password') ?? '';
      }
    });
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('remember_me', _rememberMe);
    if (_rememberMe) {
      await prefs.setString('saved_username', _usernameController.text);
      await prefs.setString('saved_password', _passwordController.text);
    } else {
      await prefs.remove('saved_username');
      await prefs.remove('saved_password');
    }
  }

  void _handleAction() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (_isLogin) {
      if (username.isEmpty || password.isEmpty) {
        _showError('يرجى إدخال اسم المستخدم وكلمة المرور');
        return;
      }
      
      debugPrint('Attempting login for: $username');
      setState(() => _isLoading = true);
      final bool success = await UserService().login(username, password);
      setState(() => _isLoading = false);
      
      if (success) {
        debugPrint('Login successful');
        _saveCredentials();
      } else {
        debugPrint('Login failed');
        _showError('اسم المستخدم أو كلمة المرور غير صحيحة');
      }
    } else {
      // Sign Up logic
      final email = _emailController.text.trim();
      final confirm = _confirmPasswordController.text.trim();

      if (username.isEmpty || email.isEmpty || password.isEmpty || confirm.isEmpty) {
        _showError('يرجى ملء كافة الخانات');
        return;
      }
      if (password != confirm) {
        _showError('كلمتا المرور غير متطابقتين');
        return;
      }
      if (!email.contains('@')) {
        _showError('يرجى إدخال بريد إلكتروني صحيح');
        return;
      }

      debugPrint('Attempting registration for: $email');
      setState(() => _isLoading = true);
      final success = await UserService().register(UserAccount(
        email: email,
        username: username,
        password: password,
      ));
      setState(() => _isLoading = false);

      if (success) {
        debugPrint('Registration successful');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الحساب بنجاح!')),
        );
        setState(() => _isLogin = true);
      } else {
        debugPrint('Registration failed');
        _showError('اسم المستخدم أو البريد موجود مسبقاً، أو تعذّر الاتصال بالإنترنت');
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.safarBlue,
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            children: [
              const SizedBox(height: 80),
              const Icon(Icons.travel_explore, size: 80, color: Colors.white),
              const SizedBox(height: 16),
              const Text(
                'SAFAR',
                style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: 4),
              ),
              Text(
                _isLogin ? 'مرحباً بك مجدداً' : 'إنشاء حساب جديد للمسافر',
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              
              _buildTextField(_usernameController, 'اسم المستخدم', Icons.person),
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                _buildTextField(_emailController, 'البريد الإلكتروني', Icons.email),
              ],
              const SizedBox(height: 16),
              _buildTextField(_passwordController, 'كلمة المرور', Icons.lock, isPassword: true),
              if (!_isLogin) ...[
                const SizedBox(height: 16),
                _buildTextField(_confirmPasswordController, 'تأكيد كلمة المرور', Icons.lock_clock, isPassword: true),
              ],
              
              const SizedBox(height: 8),
              if (_isLogin)
                Row(
                  children: [
                    Theme(
                      data: ThemeData(unselectedWidgetColor: Colors.white70),
                      child: Checkbox(
                        value: _rememberMe,
                        onChanged: (value) => setState(() => _rememberMe = value ?? false),
                        activeColor: Colors.white,
                        checkColor: AppTheme.safarBlue,
                      ),
                    ),
                    const Text('تذكرني', style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: _handleAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.safarBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 5,
                  ),
                  child: Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 30),
              const Row(
                children: [
                  Expanded(child: Divider(color: Colors.white24)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text('أو عبر', style: TextStyle(color: Colors.white60, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: Colors.white24)),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildSocialButton(Icons.g_mobiledata, 'Google', Colors.redAccent),
                  const SizedBox(width: 20),
                  _buildSocialButton(Icons.phone, 'الهاتف', Colors.green),
                ],
              ),
              
              const SizedBox(height: 30),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin ? 'ليس لديك حساب؟ سجل الآن' : 'لديك حساب بالفعل؟ سجل دخولك',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
    );
  }

  Widget _buildSocialButton(IconData icon, String label, Color color) {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('تسجيل الدخول عبر $label قيد التفعيل')));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isPassword = false}) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white30),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white),
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
      ),
    );
  }
}
