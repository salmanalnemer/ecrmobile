import 'package:flutter/material.dart';
import '../home/case_report_screen.dart'; 
import '../settings/settings_screen.dart'; 
class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  static const Color primaryRed = Color(0xFFBC1823);
  static const Color darkRed = Color(0xFF8B121A);
  static const Color background = Color(0xFFF8F9FB);

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final messageController = TextEditingController();
  bool sending = false;

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => sending = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => sending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("تم الإرسال بنجاح"), backgroundColor: Colors.green),
      );
      nameController.clear(); emailController.clear(); messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: ContactUsScreen.background,
        extendBody: true,
        appBar: AppBar(
          title: const Text("تواصل معنا", style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () => Navigator.pop(context),
          ),
        ),

        // --- الزر المركزي (+) مخصص فقط لتوثيق الحالة ---
        floatingActionButton: SizedBox(
          height: 65, width: 65,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => const CaseReportScreen()));
            },
            backgroundColor: ContactUsScreen.primaryRed,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, size: 35, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: _buildModernBottomBar(),
        
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.support_agent_rounded, size: 80, color: ContactUsScreen.primaryRed),
                const SizedBox(height: 20),
                const Text("يسعدنا سماع ملاحظاتك", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                _inputField(controller: nameController, label: "الاسم الكامل", icon: Icons.person_outline),
                const SizedBox(height: 15),
                _inputField(controller: emailController, label: "البريد الإلكتروني", icon: Icons.email_outlined),
                const SizedBox(height: 15),
                _inputField(controller: messageController, label: "الرسالة", icon: Icons.message_outlined, maxLines: 4),
                const SizedBox(height: 30),
                _buildSubmitButton(),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernBottomBar() {
    return BottomAppBar(
      height: 75,
      notchMargin: 10,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // --- تم التعديل هنا: زر الهوم يعود للخلف للهوم سكرين ---
          _bottomNavItem(Icons.home_filled, "الرئيسية", false, onTap: () {
            Navigator.pop(context); 
          }),
          
          _bottomNavItem(Icons.chat_bubble, "تواصل", true, onTap: () {}),
          
          const SizedBox(width: 50), // فراغ لزر الزائد (+)
          
          _bottomNavItem(Icons.history, "سجلاتي", false, onTap: () {}),
          _bottomNavItem(
            Icons.settings,
            "الإعدادات",
            false,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),

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
          Icon(icon, color: isActive ? ContactUsScreen.primaryRed : Colors.grey, size: 24),
          Text(label, style: TextStyle(color: isActive ? ContactUsScreen.primaryRed : Colors.grey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity, height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: ContactUsScreen.primaryRed, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        onPressed: sending ? null : _sendMessage,
        child: sending ? const CircularProgressIndicator(color: Colors.white) : const Text("إرسال", style: TextStyle(color: Colors.white, fontSize: 16)),
      ),
    );
  }

  Widget _inputField({required TextEditingController controller, required String label, required IconData icon, int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: ContactUsScreen.primaryRed),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}