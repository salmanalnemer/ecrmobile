import 'package:flutter/material.dart';
import '../../api/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final nationalIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool isHealthPractitioner = false;
  bool isLoading = false;
  bool _isObscure = true;

  List<Map<String, dynamic>> organizations = [];
  int? selectedOrganizationId;
  bool loadingOrganizations = true;

  // الألوان السيادية المطلوبة
  static const Color myGold = Color(0xFFD3C03E);
  static const Color myRed = Color(0xFFCC1B1B);
  static const Color myGrey = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    _loadOrganizations();
  }

  Future<void> _loadOrganizations() async {
    try {
      final data = await ApiService.fetchOrganizations();
      if (mounted) {
        setState(() {
          organizations = data;
          loadingOrganizations = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loadingOrganizations = false);
      _msg('فشل تحميل الجهات');
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nationalIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // المنطق البرمجي كما هو
  Future<void> _register() async {
    if (fullNameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        nationalIdController.text.trim().isEmpty ||
        passwordController.text.isEmpty ||
        selectedOrganizationId == null) {
      _msg('يرجى تعبئة جميع الحقول المطلوبة');
      return;
    }

    setState(() => isLoading = true);

    try {
      await ApiService.register(
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        nationalId: nationalIdController.text.trim(),
        password: passwordController.text,
        isHealthPractitioner: isHealthPractitioner,
        organizationId: selectedOrganizationId!,
      );

      if (!mounted) return;
      _msgSuccess('تم إنشاء الحساب بنجاح');
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      _msg(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _msg(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: myRed, behavior: SnackBarBehavior.floating),
    );
  }

  void _msgSuccess(String m) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: Colors.green, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text('إنشاء حساب جديد', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          centerTitle: true,
          backgroundColor: myRed,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("معلومات الحساب", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              _buildInput(fullNameController, 'الاسم الكامل كما في الهوية', Icons.person_outline),
              _buildInput(emailController, 'البريد الإلكتروني', Icons.alternate_email, type: TextInputType.emailAddress),
              _buildInput(phoneController, 'رقم الجوال', Icons.phone_android_outlined, type: TextInputType.phone),
              _buildInput(nationalIdController, 'رقم الهوية الوطنية', Icons.badge_outlined, type: TextInputType.number),
              _buildPasswordInput(),
              const SizedBox(height: 20),
              const Text("إختر الجهة أو مواطن أو مقيم", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
              const SizedBox(height: 15),
              _buildDropdown(),
              _buildPractitionerSwitch(),
              const SizedBox(height: 40),
              _buildRegisterButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widgets المحسنة ---

  Widget _buildInput(TextEditingController c, String label, IconData icon, {TextInputType type = TextInputType.text}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: myGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: c,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          prefixIcon: Icon(icon, color: myRed),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: myGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextField(
        controller: passwordController,
        obscureText: _isObscure,
        decoration: InputDecoration(
          labelText: 'كلمة المرور',
          labelStyle: const TextStyle(color: Colors.black54, fontSize: 14),
          prefixIcon: const Icon(Icons.lock_outline, color: myRed),
          suffixIcon: IconButton(
            icon: Icon(_isObscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
            onPressed: () => setState(() => _isObscure = !_isObscure),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: myGrey,
        borderRadius: BorderRadius.circular(15),
      ),
      child: loadingOrganizations
          ? const Center(child: Padding(padding: EdgeInsets.all(10), child: CircularProgressIndicator(strokeWidth: 2)))
          : DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                value: selectedOrganizationId,
                decoration: const InputDecoration(border: InputBorder.none),
                hint: const Text('اختر الجهة التابع لها'),
                items: organizations.map((o) => DropdownMenuItem<int>(
                  value: o['id'],
                  child: Text(o['name'], style: const TextStyle(fontSize: 14)),
                )).toList(),
                onChanged: (v) => setState(() => selectedOrganizationId = v),
              ),
            ),
    );
  }

  Widget _buildPractitionerSwitch() {
    return Container(
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: isHealthPractitioner ? myGold : Colors.transparent),
        borderRadius: BorderRadius.circular(15),
        color: isHealthPractitioner ? myGold.withOpacity(0.05) : Colors.transparent,
      ),
      child: SwitchListTile(
        title: const Text('هل أنت ممارس صحي؟', style: TextStyle(fontWeight: FontWeight.w600)),
        secondary: Icon(Icons.medical_services_outlined, color: isHealthPractitioner ? myGold : Colors.grey),
        value: isHealthPractitioner,
        activeColor: myGold,
        onChanged: (v) => setState(() => isHealthPractitioner = v),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: myRed,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 2,
        ),
        child: isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('إنشاء الحساب الآن', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}