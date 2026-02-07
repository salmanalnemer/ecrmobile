import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../api/api_service.dart';
import '../contact/contact_us_screen.dart'; 
import '../settings/settings_screen.dart'; 

class CaseReportScreen extends StatefulWidget {
  const CaseReportScreen({super.key});

  static const Color primaryRed = Color(0xFFBC1823);
  static const Color accentGold = Color(0xFFC5A059);
  static const Color background = Color(0xFFF8F9FB);

  @override
  State<CaseReportScreen> createState() => _CaseReportScreenState();
}

class _CaseReportScreenState extends State<CaseReportScreen> {
  final _formKey = GlobalKey<FormState>();

  // الكنترولرز
  final TextEditingController patientNameController = TextEditingController();
  final TextEditingController identityNumberController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();

  final MapController _mapController = MapController();

  String gender = 'male';
  String patientStatus = 'medium';
  String caseType = 'emergency';
  List<String> selectedServices = [];
  bool ambulanceRequested = false;
  String ambulanceCaller = 'self';
  LatLng selectedLocation = const LatLng(24.7136, 46.6753);

  final List<Map<String, String>> servicesList = [
    {'id': 'cpr', 'name': 'الإنعاش القلبي الرئوي'},
    {'id': 'bleeding', 'name': 'إيقاف النزيف'},
    {'id': 'choking', 'name': 'الغصة'},
    {'id': 'aed', 'name': 'استخدام جهاز AED'},
    {'id': 'bigsize', 'name': 'وزن زائد'},
    {'id': 'support', 'name': 'الخدمات الخدمات المساندة واللوجستية'},
  ];

  Future<void> _goToMyLocation() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return;
    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    final latLng = LatLng(pos.latitude, pos.longitude);
    setState(() => selectedLocation = latLng);
    _mapController.move(latLng, 16);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: CaseReportScreen.background,
        appBar: AppBar(
          title: const Text('توثيق حالة جديدة', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0,
          centerTitle: true,
        ),
        bottomNavigationBar: _buildModernBottomBar(),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader('بيانات المريض الأساسية', Icons.person_pin_outlined),
                
                _buildModernTextField(
                  'اسم المريض الكامل', 
                  Icons.person_outline, 
                  patientNameController, 
                  isName: true
                ),

                _buildModernTextField(
                  'رقم الهوية', 
                  Icons.badge_outlined, 
                  identityNumberController, 
                  isNumber: true, 
                  isIdentity: true
                ),

                _buildModernTextField(
                  'رقم الجوال', 
                  Icons.phone_iphone, 
                  phoneNumberController, 
                  isNumber: true, 
                  isPhone: true
                ),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildModernTextField(
                        'العمر', 
                        Icons.cake_outlined, 
                        ageController, 
                        isNumber: true, 
                        isAge: true
                      )
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildModernTextField(
                        'الجنسية', 
                        Icons.public, 
                        nationalityController, 
                        isName: true
                      )
                    ),
                  ],
                ),

                _buildSectionHeader('الجنس', Icons.wc_outlined),
                _buildSegmentedControl(['male', 'female'], ['ذكر', 'أنثى'], gender, (val) => setState(() => gender = val)),

                _buildSectionHeader('تفاصيل الحالة', Icons.medical_information_outlined),
                _buildModernDropdown('نوع الحالة', ['emergency', 'rescue', 'support'], ['حالة إسعافية', 'إنقاذ حالة', 'خدمة مساندة'], caseType, (val) => setState(() => caseType = val!)),
                _buildModernDropdown('درجة الخطورة', ['critical', 'medium', 'simple'], ['خطرة', 'متوسطة', 'بسيطة'], patientStatus, (val) => setState(() => patientStatus = val!)),

                _buildSectionHeader('الخدمات المقدمة', Icons.volunteer_activism_outlined),
                _buildMultiSelectServices(),

                _buildSectionHeader('طلب الإسعاف', Icons.emergency_outlined),
                _buildAmbulanceSwitch(),

                if (ambulanceRequested)
                  _buildModernDropdown('من طلب الإسعاف؟', ['self', 'other'], ['أنا المتصل', 'شخص آخر'], ambulanceCaller, (val) => setState(() => ambulanceCaller = val!)),

                _buildSectionHeader('الموقع الجغرافي', Icons.map_outlined),
                _buildFixedMap(),

                const SizedBox(height: 40),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- المكون الذكي للحقول مع القيود المطلوبة ---
  Widget _buildModernTextField(
    String label,
    IconData icon,
    TextEditingController controller, {
    bool isNumber = false,
    bool isName = false,
    bool isIdentity = false,
    bool isAge = false,
    bool isPhone = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: [
          if (isName) FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s\u0600-\u06FF]')), // يمنع الرموز والأرقام
          if (isNumber) FilteringTextInputFormatter.digitsOnly, // يمنع الحروف والرموز
          if (isIdentity) LengthLimitingTextInputFormatter(10), // هوية 10 أرقام
          if (isPhone) LengthLimitingTextInputFormatter(10), // جوال 10 أرقام
          if (isAge) LengthLimitingTextInputFormatter(3), // عمر 3 أرقام
        ],
        validator: (val) {
          if (val == null || val.isEmpty) return 'هذا الحقل مطلوب';
          if (isIdentity && val.length != 10) return 'يجب إدخال 10 أرقام للهوية';
          return null;
        },
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          prefixIcon: Icon(icon, color: CaseReportScreen.primaryRed, size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Icon(icon, color: CaseReportScreen.primaryRed, size: 20),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildModernDropdown(String label, List<String> values, List<String> names, String current, Function(String?) onChange) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: DropdownButtonFormField<String>(
        value: current,
        decoration: InputDecoration(labelText: label, labelStyle: const TextStyle(color: Colors.grey), border: InputBorder.none),
        items: List.generate(values.length, (i) => DropdownMenuItem(value: values[i], child: Text(names[i]))),
        onChanged: onChange,
      ),
    );
  }

  Widget _buildSegmentedControl(List<String> values, List<String> names, String current, Function(String) onChange) {
    return Row(
      children: List.generate(values.length, (i) {
        final isActive = current == values[i];
        return Expanded(
          child: GestureDetector(
            onTap: () => onChange(values[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: isActive ? CaseReportScreen.primaryRed : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [if (!isActive) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5)],
              ),
              child: Text(names[i], textAlign: TextAlign.center, style: TextStyle(color: isActive ? Colors.white : Colors.black54, fontWeight: FontWeight.bold)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildMultiSelectServices() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: servicesList.map((service) {
        final isSelected = selectedServices.contains(service['id']);
        return FilterChip(
          label: Text(service['name']!, style: TextStyle(fontSize: 12, color: isSelected ? CaseReportScreen.primaryRed : Colors.black87)),
          selected: isSelected,
          onSelected: (val) {
            setState(() => val ? selectedServices.add(service['id']!) : selectedServices.remove(service['id']));
          },
          backgroundColor: Colors.white,
          selectedColor: CaseReportScreen.primaryRed.withOpacity(0.1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          side: BorderSide(color: isSelected ? CaseReportScreen.primaryRed : Colors.grey.shade200),
        );
      }).toList(),
    );
  }

  Widget _buildAmbulanceSwitch() {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10)]),
      child: SwitchListTile(
        title: const Text('هل تم طلب الإسعاف؟', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
        value: ambulanceRequested,
        activeColor: CaseReportScreen.primaryRed,
        onChanged: (val) => setState(() => ambulanceRequested = val),
      ),
    );
  }

  Widget _buildFixedMap() {
    return Container(
      height: 220,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)]),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: selectedLocation,
              initialZoom: 13,
              onTap: (_, latlng) => setState(() => selectedLocation = latlng),
            ),
            children: [
              TileLayer(
                urlTemplate:
                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.ecr.app",
              ),

              MarkerLayer(
                markers: [
                  Marker(point: selectedLocation, width: 40, height: 40, child: const Icon(Icons.location_on, color: CaseReportScreen.primaryRed, size: 35)),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
            child: FloatingActionButton(mini: true, onPressed: _goToMyLocation, backgroundColor: CaseReportScreen.primaryRed, child: const Icon(Icons.my_location, color: Colors.white, size: 20)),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 55,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        gradient: const LinearGradient(colors: [CaseReportScreen.primaryRed, Color(0xFF8B121A)]),
        boxShadow: [BoxShadow(color: CaseReportScreen.primaryRed.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
        onPressed: () async {
          if (!_formKey.currentState!.validate()) return;
          try {
             await ApiService.createCaseReport(payload: {
              'patient_name': patientNameController.text.trim(),
              'identity_number': identityNumberController.text.trim(),
              'phone_number': phoneNumberController.text.trim(),
              'nationality': nationalityController.text.trim(),
              'age': int.parse(ageController.text.trim()),
              'gender': gender,
              'patient_status': patientStatus,
              'case_type': caseType,
              'services': selectedServices,
              'ambulance_requested': ambulanceRequested,
              'ambulance_caller': ambulanceRequested ? ambulanceCaller : null,
              'latitude': selectedLocation.latitude,
              'longitude': selectedLocation.longitude,
            });
            if(mounted) Navigator.pop(context);
          } catch(e) {
            // handle error
          }
        },
        child: const Text('إرسال بيانات التوثيق', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildModernBottomBar() {
    return BottomAppBar(
      height: 70,
      color: Colors.white,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // العودة للرئيسية
          _bottomNavItem(Icons.home_outlined, "الرئيسية", false, onTap: () => Navigator.pop(context)),
          
          // الانتقال لصفحة التواصل
          _bottomNavItem(Icons.chat_bubble_outline, "تواصل", false, onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ContactUsScreen()),
            );
          }),
          
          const SizedBox(width: 40),
          
          _bottomNavItem(Icons.history_rounded, "سجلاتي", true, onTap: () {}),
          _bottomNavItem(
            Icons.settings_outlined,
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

  Widget _bottomNavItem(IconData icon, String label, bool isActive, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isActive ? CaseReportScreen.primaryRed : Colors.grey.shade400, size: 24),
          Text(label, style: TextStyle(color: isActive ? CaseReportScreen.primaryRed : Colors.grey.shade400, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}