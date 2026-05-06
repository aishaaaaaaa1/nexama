import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../login_page.dart';
import 'tabs/admin_overview.dart';
import 'tabs/admin_users.dart';
import 'tabs/admin_moderation.dart';
import 'tabs/admin_finance.dart';
import 'tabs/admin_ai_monitoring.dart';
import 'tabs/admin_audit_log.dart';
import 'tabs/admin_settings.dart';
import '../shared/support_page.dart';

class AdminDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const AdminDashboard({super.key, this.userData});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedNav = 0;
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: _buildSelectedContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar() {
    return AnimatedContainer(
      key: const ValueKey('sidebar_admin'),
      duration: const Duration(milliseconds: 300),
      width: _isSidebarCollapsed ? 0 : 260,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: NexaColors.darkNavy,
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          _buildSidebarHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavGroup('PRINCIPAL', [
                    _buildNavItem(0, Icons.dashboard_outlined, 'Vue d\'ensemble'),
                    _buildNavItem(1, Icons.people_outline, 'Utilisateurs'),
                    _buildNavItem(2, Icons.gavel_outlined, 'Modération'),
                  ]),
                  _buildNavGroup('SUPERVISION', [
                    _buildNavItem(3, Icons.account_balance_wallet_outlined, 'Finance & Escrow'),
                    _buildNavItem(4, Icons.auto_awesome_outlined, 'Monitoring IA'),
                  ]),
                  _buildNavGroup('SYSTÈME', [
                    _buildNavItem(5, Icons.settings_outlined, 'Configuration'),
                    _buildNavItem(6, Icons.history_outlined, 'Journal d\'audit'),
                  ]),
                  _buildNavGroup('SUPPORT', [
                    _buildNavItem(7, Icons.help_outline, 'Centre d\'aide'),
                  ]),
                ],
              ),
            ),
          ),
          _buildSidebarFooter(),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: NexaColors.primaryGreen, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.admin_panel_settings, color: Colors.white, size: 24),
          ),
          if (!_isSidebarCollapsed) ...[
            const SizedBox(width: 12),
            Text('NexaMa ADMIN', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
          ]
        ],
      ),
    );
  }

  Widget _buildNavGroup(String title, List<Widget> items) {
    if (_isSidebarCollapsed) return Column(children: items);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
          child: Text(title, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        ),
        ...items,
      ],
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _selectedNav == index;
    return InkWell(
      onTap: () => setState(() => _selectedNav = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: _isSidebarCollapsed ? 12 : 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border(left: BorderSide(color: NexaColors.primaryGreen, width: 3)) : null,
        ),
        child: Row(
          mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, color: isSelected ? NexaColors.primaryGreen : Colors.white70, size: 20),
            if (!_isSidebarCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: GoogleFonts.inter(color: isSelected ? Colors.white : Colors.white70, fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400))),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (!_isSidebarCollapsed) 
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  const CircleAvatar(radius: 16, backgroundColor: NexaColors.primaryGreen, child: Icon(Icons.person, color: Colors.white, size: 20)),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Super Admin', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        Text('admin@nexama.ma', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => _handleLogout(), icon: const Icon(Icons.logout, color: Colors.white54, size: 18)),
                ],
              ),
            )
          else
            IconButton(onPressed: () => _handleLogout(), icon: const Icon(Icons.logout, color: Colors.white54)),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(_isSidebarCollapsed ? Icons.menu_open : Icons.menu, color: const Color(0xFF64748B)),
              onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
              splashRadius: 24,
            ),
          ),
          const SizedBox(width: 16),
          if (!_isSidebarCollapsed)
            Text('Tableau de Bord Administrateur', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const Spacer(),
          Container(
            width: _isSidebarCollapsed ? 150 : 300,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: _isSidebarCollapsed ? 'Rechercher...' : 'Rechercher un utilisateur, un log...',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          _buildTopBarAction(Icons.notifications_none_outlined, 'Notifications', badge: '5'),
          const SizedBox(width: 20),
          _buildTopBarAction(Icons.security_outlined, 'Santé Système', color: Colors.green),
          const SizedBox(width: 24),
          const VerticalDivider(width: 1, indent: 20, endIndent: 20),
          const SizedBox(width: 24),
          Text(DateTime.now().toString().split(' ')[0], style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildTopBarAction(IconData icon, String tooltip, {String? badge, Color? color}) {
    return Tooltip(
      message: tooltip,
      child: Stack(
        children: [
          Icon(icon, color: color ?? const Color(0xFF64748B), size: 24),
          if (badge != null)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedNav) {
      case 0: return const AdminOverview();
      case 1: return const AdminUsers();
      case 2: return const AdminModeration();
      case 3: return const AdminFinance();
      case 4: return const AdminAiMonitoring();
      case 5: return const AdminSettings();
      case 6: return const AdminAuditLog();
      case 7: return SupportPage(userData: widget.userData);
      default: return const AdminOverview();
    }
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
  }
}
