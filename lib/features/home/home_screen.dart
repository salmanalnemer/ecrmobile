import 'dart:async';
import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import 'case_report_screen.dart';
import '../contact/contact_us_screen.dart';
import '../settings/settings_screen.dart';
import '../notifications/notifications_screen.dart'; // صفحة الإشعارات

class HomeScreen extends StatefulWidget {
  final String fullName;
  const HomeScreen({super.key, required this.fullName});

  static const Color primaryRed = Color(0xFFBC1823);
  static const Color darkRed = Color(0xFF8B121A);
  static const Color accentGold = Color(0xFFC5A059);
  static const Color background = Color(0xFFF8F9FB);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool loading = true;
  int activeResponders = 0, totalCases = 0, myRespondedCases = 0;
  int cpr = 0, bleeding = 0, aed = 0, choking = 0, bigSize = 0, support = 0;
  int notificationCount = 0; // عدد الإشعارات
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
    refreshTimer =
        Timer.periodic(const Duration(seconds: 30), (_) => _loadDashboard());
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  void _handleLogout() {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            title: const Text("تنبيه"),
            content: const Text("هل ترغب في تسجيل الخروج من النظام؟"),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("إلغاء")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: HomeScreen.primaryRed),
                onPressed: () => Navigator.of(context)
                    .pushNamedAndRemoveUntil('/login', (route) => false),
                child: const Text("خروج",
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadDashboard() async {
    try {
      final data = await ApiService.fetchDashboardStats();
      if (mounted) {
        setState(() {
          activeResponders = data['active_responders'] ?? 0;
          totalCases = data['total_cases'] ?? 0;
          myRespondedCases = data['my_responded_cases'] ?? 0;

          final services = data['services_stats'] ?? {};
          cpr = services['cpr'] ?? 0;
          bleeding = services['bleeding'] ?? 0;
          aed = services['aed'] ?? 0;
          choking = services['choking'] ?? 0;
          bigSize = services['big_size'] ?? 0;
          support = services['support'] ?? 0;

          loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: HomeScreen.background,
        extendBody: true,
        floatingActionButton: SizedBox(
          height: 65,
          width: 65,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const CaseReportScreen())),
            backgroundColor: HomeScreen.primaryRed,
            elevation: 8,
            shape: const CircleBorder(),
            child: const Icon(Icons.add,
                size: 35, color: Colors.white),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: _buildModernBottomBar(),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(
                    color: HomeScreen.primaryRed))
            : CustomScrollView(
                slivers: [
                  _buildSliverHeader(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20, 25, 20, 100),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle("الإحصائيات المباشرة"),
                          const SizedBox(height: 15),
                          _buildMainStatusCard(),
                          const SizedBox(height: 30),
                          _buildSectionTitle(
                              "تصنيف الخدمات الإسعافية"),
                          const SizedBox(height: 15),
                          _buildServicesGrid(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 170,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
                colors: [HomeScreen.primaryRed, HomeScreen.darkRed]),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(35),
                bottomRight: Radius.circular(35)),
          ),
          child: SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.white24,
                        child: Icon(Icons.person,
                            color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        mainAxisAlignment:
                            MainAxisAlignment.center,
                        children: [
                          const Text('مرحباً بك،',
                              style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14)),
                          Text(widget.fullName,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight:
                                      FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),

                  // 🔔 زر الإشعارات + خروج
                  Row(
                    children: [
                      Stack(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationsScreen(),
                                ),
                              );
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle),
                              child: const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 20),
                            ),
                          ),
                          if (notificationCount > 0)
                            Positioned(
                              right: 5,
                              top: 5,
                              child: Container(
                                padding:
                                    const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle),
                                child: Text(
                                  '$notificationCount',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10),
                                ),
                              ),
                            ),
                        ],
                      ),
                      IconButton(
                        onPressed: _handleLogout,
                        icon: Container(
                          padding:
                              const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                              color: Colors.white24,
                              shape: BoxShape.circle),
                          child: const Icon(Icons.logout,
                              color: Colors.white,
                              size: 20),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10)
          ]),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _statusItem("حالاتي",
              myRespondedCases.toString(),
              Icons.volunteer_activism,
              HomeScreen.primaryRed),
          _statusItem("المستجيبون",
              activeResponders.toString(),
              Icons.people,
              HomeScreen.accentGold),
          _statusItem("الإجمالي",
              totalCases.toString(),
              Icons.analytics,
              Colors.blueGrey),
        ],
      ),
    );
  }

  Widget _statusItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        Text(value,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
                fontSize: 20)),
        Text(label,
            style: const TextStyle(
                fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _buildServicesGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      childAspectRatio: 1.3,
      children: [
        _ServiceCard('إنعاش CPR', cpr, Icons.favorite, Colors.red),
        _ServiceCard('إيقاف نزيف', bleeding, Icons.opacity, Colors.red),
        _ServiceCard('استخدام AED', aed, Icons.flash_on, Colors.orange),
        _ServiceCard('حالات غصة', choking, Icons.air, Colors.blue),
        _ServiceCard('وزن زائد', bigSize, Icons.monitor_weight, Colors.blueGrey),
        _ServiceCard('خدمات مساندة', support, Icons.medical_services, Colors.green),
      ],
    );
  }

  Widget _buildModernBottomBar() {
    return BottomAppBar(
      height: 75,
      notchMargin: 8,
      color: Colors.white,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceAround,
        children: [
          _bottomNavItem(Icons.home, "الرئيسية", true,
              onTap: () {}),
          _bottomNavItem(Icons.chat, "تواصل", false,
              onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const ContactUsScreen()));
          }),
          const SizedBox(width: 40),
          _bottomNavItem(Icons.history, "سجلاتي", false,
              onTap: () {}),
          _bottomNavItem(Icons.settings, "الإعدادات",
              false, onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        const SettingsScreen()));
          }),
        ],
      ),
    );
  }

  Widget _bottomNavItem(
      IconData icon, String label, bool isActive,
      {required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive
                  ? HomeScreen.primaryRed
                  : Colors.grey,
              size: 26),
          Text(label,
              style: TextStyle(
                  color: isActive
                      ? HomeScreen.primaryRed
                      : Colors.grey,
                  fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) =>
      Text(title,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold));
}

class _ServiceCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;

  const _ServiceCard(
      this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border:
              Border.all(color: Colors.grey.shade100)),
      child: Column(
        mainAxisAlignment:
            MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 30),
          Text(value.toString(),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontSize: 20)),
          Text(title,
              style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
