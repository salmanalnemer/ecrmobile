import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../home/case_report_screen.dart'; 
import '../contact/contact_us_screen.dart'; 

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  // الألوان الموحدة كما في الهوم سكرين
  static const Color primaryRed = Color(0xFFBC1823);
  static const Color darkRed = Color(0xFF8B121A);
  static const Color background = Color(0xFFF8F9FB);

  // Controllers
  final nationalIdCtrl = TextEditingController();
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneNumberCtrl = TextEditingController();
  final roleCtrl = TextEditingController();
  final organizationCtrl = TextEditingController();
  final isHealthCtrl = TextEditingController();

  final oldPassCtrl = TextEditingController();
  final newPassCtrl = TextEditingController();
  final confirmPassCtrl = TextEditingController();

  bool loading = true;
  bool editing = false;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    try {
      final data = await ApiService.fetchProfile();
      nationalIdCtrl.text = data["national_id"] ?? "";
      fullNameCtrl.text = data["full_name"] ?? "";
      emailCtrl.text = data["email"] ?? "";
      phoneNumberCtrl.text = data["phone_number"] ?? "";
      roleCtrl.text = data["role"] ?? "";
      organizationCtrl.text = data["organization"]?.toString() ?? "";
      isHealthCtrl.text = data["is_health_practitioner"] == true ? "نعم" : "لا";
    } catch (e) {
      showMsg("فشل تحميل بيانات المستخدم");
    }
    setState(() => loading = false);
  }

  Future<void> updateProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => saving = true);
    try {
      await ApiService.updateProfile(
        fullName: fullNameCtrl.text,
        email: emailCtrl.text,
        phone: phoneNumberCtrl.text,
      );
      showMsg("تم تحديث البيانات بنجاح");
      setState(() => editing = false);
    } catch (e) {
      showMsg("فشل تحديث البيانات");
    }
    setState(() => saving = false);
  }

  Future<void> changePassword() async {
    if (newPassCtrl.text != confirmPassCtrl.text) {
      showMsg("كلمة المرور غير متطابقة");
      return;
    }
    setState(() => saving = true);
    try {
      await ApiService.changePassword(
        oldPassword: oldPassCtrl.text,
        newPassword: newPassCtrl.text,
        confirmPassword: confirmPassCtrl.text,
      );
      showMsg("تم تغيير كلمة المرور");
      oldPassCtrl.clear(); newPassCtrl.clear(); confirmPassCtrl.clear();
    } catch (e) {
      showMsg("فشل تغيير كلمة المرور");
    }
    setState(() => saving = false);
  }

  void showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        extendBody: true,
        appBar: AppBar(
          title: const Text("الإعدادات", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        
        // زر الإضافة المركزي الموحد (+) مخصص لتوثيق الحالات فقط
        floatingActionButton: SizedBox(
          height: 65, width: 65,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseReportScreen())),
            backgroundColor: primaryRed,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 35, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        
        bottomNavigationBar: _buildModernBottomBar(),

        body: loading
            ? const Center(child: CircularProgressIndicator(color: primaryRed))
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader("بيانات المستخدم"),
                      const SizedBox(height: 15),
                      _buildField(nationalIdCtrl, "رقم الهوية", readOnly: true),
                      _buildField(organizationCtrl, "الجهة", readOnly: true),
                      _buildField(isHealthCtrl, "ممارس صحي", readOnly: true),
                      _buildField(fullNameCtrl, "الاسم الكامل", readOnly: !editing),
                      _buildField(emailCtrl, "البريد الإلكتروني", readOnly: !editing),
                      _buildField(phoneNumberCtrl, "رقم الجوال", readOnly: !editing),
                      
                      const SizedBox(height: 20),
                      _buildPrimaryButton(
                        label: editing ? "حفظ التعديلات" : "تعديل البيانات",
                        icon: editing ? Icons.save : Icons.edit,
                        onPressed: saving ? null : (editing ? updateProfile : () => setState(() => editing = true)),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 30),
                        child: Divider(),
                      ),

                      _buildSectionHeader("تغيير كلمة المرور"),
                      const SizedBox(height: 15),
                      _buildField(oldPassCtrl, "كلمة المرور الحالية", obscure: true),
                      _buildField(newPassCtrl, "كلمة المرور الجديدة", obscure: true),
                      _buildField(confirmPassCtrl, "تأكيد كلمة المرور", obscure: true),
                      
                      const SizedBox(height: 20),
                      _buildPrimaryButton(
                        label: "تحديث كلمة المرور",
                        icon: Icons.lock_reset,
                        color: Colors.blueGrey,
                        onPressed: saving ? null : changePassword,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  // ميثود الفوتر الموحد مع تصحيح وجهة زر الرئيسية
  Widget _buildModernBottomBar() {
    return BottomAppBar(
      height: 75, notchMargin: 8, color: Colors.white,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // تم التعديل هنا: عند الضغط على الرئيسية يعود لصفحة الهوم فوراً
          _bottomNavItem(Icons.home, "الرئيسية", false, onTap: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          }),
          
          _bottomNavItem(Icons.chat_bubble_outline, "تواصل", false, onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen()));
          }),
          
          const SizedBox(width: 40), // مساحة للزر المركزي (+)
          
          _bottomNavItem(Icons.history, "سجلاتي", false, onTap: () {}),
          _bottomNavItem(Icons.settings, "الإعدادات", true, onTap: () {}),
        ],
      ),
    );
  }

  Widget _bottomNavItem(IconData icon, String label, bool isActive, {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? primaryRed : Colors.grey, size: 26),
          Text(label, style: TextStyle(color: isActive ? primaryRed : Colors.grey, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label, {bool readOnly = false, bool obscure = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        readOnly: readOnly,
        obscureText: obscure,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: readOnly ? Colors.grey.shade100 : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: darkRed));
  }

  Widget _buildPrimaryButton({required String label, required IconData icon, required VoidCallback? onPressed, Color color = primaryRed}) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }
}