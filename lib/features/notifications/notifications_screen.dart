import 'dart:async';
import 'package:flutter/material.dart';
import '../../api/api_service.dart';

const Color primaryRed = Color(0xFFBC1823);
const Color background = Color(0xFFF8F9FB);

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List notifications = [];
  bool loading = true;
  Timer? refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadNotifications();

    refreshTimer =
        Timer.periodic(const Duration(seconds: 15), (_) {
      _loadNotifications();
    });
  }

  @override
  void dispose() {
    refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadNotifications() async {
    try {
      final data = await ApiService.fetchNotifications();
      if (mounted) {
        setState(() {
          notifications = data;
          loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    await ApiService.markNotificationRead(id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: background,
        appBar: AppBar(
          backgroundColor: primaryRed,
          title: const Text(
            "الإشعارات",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: loading
            ? const Center(
                child: CircularProgressIndicator(color: primaryRed))
            : notifications.isEmpty
                ? const Center(child: Text("لا توجد إشعارات"))
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      final bool isRead = n['is_read'] == true;

                      return GestureDetector(
                        onTap: () => _markAsRead(n['id']),
                        child: Container(
                          margin:
                              const EdgeInsets.only(bottom: 15),
                          padding:
                              const EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            color: isRead
                                ? Colors.white
                                : Colors.red.shade50,
                            borderRadius:
                                BorderRadius.circular(15),
                            border: Border.all(
                              color: isRead
                                  ? Colors.grey.shade200
                                  : Colors.red.shade200,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding:
                                    const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: primaryRed
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.notifications,
                                  color: primaryRed,
                                ),
                              ),
                              const SizedBox(width: 15),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      n['title'] ?? '',
                                      style: TextStyle(
                                        fontWeight:
                                            FontWeight.bold,
                                        color: isRead
                                            ? Colors.black
                                            : primaryRed,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(n['body'] ?? ''),
                                    const SizedBox(height: 6),
                                    Text(
                                      n['created_at'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color:
                                              Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
