import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../config/api_config.dart';
import 'dart:convert';

class NotificationsPanel extends StatefulWidget {
  final String userId;
  const NotificationsPanel({super.key, required this.userId});

  @override
  State<NotificationsPanel> createState() => _NotificationsPanelState();
}

class _NotificationsPanelState extends State<NotificationsPanel> {
  List<dynamic> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/auth/notifications/${widget.userId}'));
      if (response.statusCode == 200) {
        setState(() {
          _notifications = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 500,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Notifications', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                TextButton(onPressed: () {}, child: Text('Tout marquer lu', style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12))),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notifications.isEmpty
                    ? Center(child: Text('Aucune notification', style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        itemCount: _notifications.length,
                        separatorBuilder: (context, index) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final notif = _notifications[index];
                          return _buildNotificationItem(notif);
                        },
                      ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Center(
              child: Text('Voir tout l\'historique', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(dynamic notif) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: notif['lu'] ? Colors.transparent : NexaColors.primaryGreen.withValues(alpha: 0.05),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _getIconColor(notif['icon']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(_getIconData(notif['icon']), color: _getIconColor(notif['icon']), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(notif['titre'], style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                    Text(notif['date'], style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(notif['message'], style: TextStyle(fontSize: 12, color: Colors.grey[700], height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String icon) {
    switch (icon) {
      case 'waving_hand': return Icons.waving_hand_outlined;
      case 'security': return Icons.security_outlined;
      case 'trending_up': return Icons.trending_up;
      case 'lightbulb': return Icons.lightbulb_outline;
      case 'work_outline': return Icons.work_outline;
      case 'school': return Icons.school_outlined;
      default: return Icons.notifications_outlined;
    }
  }

  Color _getIconColor(String icon) {
    switch (icon) {
      case 'security': return Colors.blue;
      case 'trending_up': return Colors.green;
      case 'lightbulb': return Colors.orange;
      case 'work_outline': return Colors.purple;
      case 'school': return Colors.indigo;
      default: return NexaColors.primaryGreen;
    }
  }
}
