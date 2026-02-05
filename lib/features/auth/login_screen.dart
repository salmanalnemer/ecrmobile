import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../home/home_screen.dart';
import '../../screens/auth/register_screen.dart'; // ✅ إضافة صحيحة

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nationalIdController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool _isObscure = true;

  static const Color myGold = Color(0xFFD3C03E);
  static const Color myRed = Color(0xFFCC1B1B);

  @override
  void dispose() {
    nationalIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (nationalIdController.text.trim().isEmpty ||
        passwordController.text.isEmpty) {
      _msg('يرجى إدخال البيانات المطلوبة');
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await ApiService.login(
        nationalId: nationalIdController.text.trim(),
        password: passwordController.text,
      );

      final fullName = res['data']?['user']?['full_name'] ?? 'مستخدم';

      if (!mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(fullName: fullName),
          ),
        );
      });
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          m,
          textAlign: TextAlign.right,
          style: const TextStyle(fontFamily: 'Tajawal'),
        ),
        backgroundColor: myRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFFBFBFB),
        body: Stack(
          children: [
            Positioned(
              top: -100,
              right: -100,
              child: CircleAvatar(
                radius: 150,
                backgroundColor: myGold.withOpacity(0.05),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 40),

                        const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF2D2D2D),
                            fontFamily: 'Tajawal',
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'أهلاً بك، يرجى إدخال بياناتك للمتابعة',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 15),
                        ),

                        const SizedBox(height: 50),

                        _buildInputWrapper(
                          child: TextField(
                            controller: nationalIdController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.right,
                            decoration: _inputDecoration(
                              'رقم الهوية / الإقامة',
                              Icons.badge_outlined,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        _buildInputWrapper(
                          child: TextField(
                            controller: passwordController,
                            obscureText: _isObscure,
                            textAlign: TextAlign.right,
                            decoration: _inputDecoration(
                              'كلمة المرور',
                              Icons.lock_open_rounded,
                              isPass: true,
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'نسيت كلمة المرور؟',
                              style: TextStyle(
                                color: myGold,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        _buildLoginButton(),

                        const SizedBox(height: 16),

                        // ✅ زر إنشاء حساب
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            'إنشاء حساب جديد',
                            style: TextStyle(
                              fontSize: 16,
                              color: myRed,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),
                        const Text(
                          'نظام الدخول الموحد © 2026',
                          style:
                              TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: myGold.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: const Icon(
            Icons.shield_outlined,
            size: 70,
            color: myRed,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          height: 5,
          width: 40,
          decoration: BoxDecoration(
            color: myGold,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ],
    );
  }

  Widget _buildInputWrapper({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: child,
    );
  }

  InputDecoration _inputDecoration(
    String hint,
    IconData icon, {
    bool isPass = false,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: myGold, size: 22),
      suffixIcon: isPass
          ? IconButton(
              icon: Icon(
                _isObscure
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: Colors.grey[400],
              ),
              onPressed: () =>
                  setState(() => _isObscure = !_isObscure),
            )
          : null,
      border: InputBorder.none,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(
          colors: [myRed, Color(0xFF8B1212)],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: myRed.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 25,
                height: 25,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'دخول',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
