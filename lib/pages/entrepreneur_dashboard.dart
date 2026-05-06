import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/chatbot_widget.dart';
import 'entrepreneur/factures_page.dart';
import 'entrepreneur/depenses_page.dart';
import 'login_page.dart';
import './entrepreneur/projets_page.dart';
import './entrepreneur/investisseurs_search_page.dart';
import './investisseur/messages_page.dart';
import './entrepreneur/finance/finance_dashboard.dart';
import './entrepreneur/business_plan_ia_page.dart';
import './entrepreneur/tresorerie_page.dart';
import './entrepreneur/comptabilite_page.dart';
import './entrepreneur/rh_page.dart';
import './entrepreneur/stock_page.dart';
import 'entrepreneur/crm_page.dart';
import 'entrepreneur/suivi_projets_page.dart';
import 'entrepreneur/marketplace/marketplace_explorer.dart';
import 'entrepreneur/microlearning_page.dart';
import 'entrepreneur/forum_page.dart';
import 'entrepreneur/simulateur_page.dart';
import 'entrepreneur/base_legale_page.dart';
import 'profile_page.dart';
import 'shared/support_page.dart';
import 'trainer/trainer_dashboard_page.dart';
import '../widgets/notifications_panel.dart';

class EntrepreneurDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const EntrepreneurDashboard({super.key, this.userData});

  @override
  State<EntrepreneurDashboard> createState() => _EntrepreneurDashboardState();
}

class _EntrepreneurDashboardState extends State<EntrepreneurDashboard> {
  final ScrollController _scrollController = ScrollController();
  int _selectedNav = 0;
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showChatBot(context),
        backgroundColor: NexaColors.primaryGreen,
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
      key: const ValueKey('sidebar_container'),
      duration: const Duration(milliseconds: 300),
      width: _isSidebarCollapsed ? 0 : 260,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Image.asset(
                  'assets/images/logo.png',
                  height: 32,
                  errorBuilder: (c, e, s) => const Icon(Icons.error, color: Colors.blue),
                ),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: 'Nexa',
                        style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: 'Ma',
                        style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ]),
                  ),
                ],
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: _isSidebarCollapsed ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  _buildNavItem(0, Icons.space_dashboard_outlined, 'Tableau de bord'),
                  
                  _buildNavSection('Matching Investisseurs', false, Icons.handshake_outlined, [
                    _buildNavItem(1, Icons.folder_outlined, 'Projets'),
                    _buildNavItem(2, Icons.group_outlined, 'Investisseurs'),
                    _buildNavItem(3, Icons.chat_bubble_outline, 'Conversations', badge: '2'),
                  ]),
                  
                  _buildNavSection('Finance', false, Icons.account_balance_outlined, [
                    _buildNavItem(4, Icons.space_dashboard_outlined, 'Tableau de bord financier'),
                    _buildNavItem(5, Icons.receipt_long_outlined, 'Factures'),
                    _buildNavItem(6, Icons.money_off_outlined, 'Dépenses'),
                    _buildNavItem(7, Icons.account_balance_outlined, 'Fiscalité & CNSS'),
                  ]),

                  _buildNavSection('Développement', false, Icons.rocket_launch_outlined, [
                    _buildNavItem(11, Icons.auto_awesome_outlined, 'Business Plan IA'),
                    _buildNavItem(12, Icons.track_changes_outlined, 'Suivi de Projets'),
                    _buildNavItem(13, Icons.storefront_outlined, 'Marketplace'),
                    _buildNavItem(14, Icons.school_outlined, 'Microlearning'),
                    if (widget.userData?['role'] == 'formateur')
                      _buildNavItem(20, Icons.analytics_outlined, 'Dashboard Formateur'),
                    _buildNavItem(17, Icons.calculate_outlined, 'Simulateur'),
                    _buildNavItem(18, Icons.forum_outlined, 'Forum Communautaire'),
                    _buildNavItem(19, Icons.gavel_outlined, 'Base Légale'),
                  ]),

                  _buildNavSection('PARAMÈTRES', false, Icons.settings_suggest_outlined, [
                    _buildNavItem(15, Icons.person_outline, 'Mon profil'),
                    _buildNavItem(21, Icons.headset_mic_outlined, 'Support'),
                    _buildLogoutItem(),
                  ]),
                ],
              ),
            ),
          ),
          
          if (!_isSidebarCollapsed)
            InkWell(
              onTap: () => setState(() => _selectedNav = 21),
              child: const Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Row(
                  children: [
                    Icon(Icons.headset_mic_outlined, color: Color(0xFF64748B), size: 20),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Besoin d\'aide ?', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('Contactez le support', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          if (_isSidebarCollapsed)
            IconButton(onPressed: () => setState(() => _selectedNav = 21), icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFF64748B))),
        ],
      ),
    );
  }

  Widget _buildNavSection(String title, bool isCollapsed, IconData icon, List<Widget> children) {
    if (_isSidebarCollapsed) {
      return Column(children: children);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, size: 16, color: NexaColors.darkNavy), 
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
            Icon(isCollapsed ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up, size: 16, color: const Color(0xFF64748B)),
          ],
        ),
        const SizedBox(height: 8),
        if (!isCollapsed) ...children,
      ],
    );
  }

  Widget _buildLogoutItem() {
    return InkWell(
      onTap: () async {
        await AuthService.logout();
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout, size: 20, color: Colors.redAccent),
            if (!_isSidebarCollapsed) ...[
              const SizedBox(width: 12),
              Text(
                'Déconnexion',
                style: GoogleFonts.inter(
                  color: Colors.redAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label, {String? badge}) {
    final isSelected = _selectedNav == index;
    return InkWell(
      onTap: () => setState(() => _selectedNav = index),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: isSelected ? NexaColors.primaryGreen : const Color(0xFF64748B)),
            if (!_isSidebarCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.inter(
                    color: isSelected ? NexaColors.primaryGreen : const Color(0xFF475569),
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: const BoxDecoration(color: NexaColors.primaryGreen, shape: BoxShape.circle),
                  child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: IconButton(
              icon: Icon(_isSidebarCollapsed ? Icons.menu_open : Icons.menu, color: const Color(0xFF64748B)),
              onPressed: () {
                debugPrint('Toggling sidebar: $_isSidebarCollapsed');
                setState(() => _isSidebarCollapsed = !_isSidebarCollapsed);
              },
              splashRadius: 24,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 350,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: _isSidebarCollapsed ? 'Rechercher...' : 'Rechercher un service, un expert...',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '⌘K',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => _showNotifications(context),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Color(0xFF64748B), size: 24),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: () => setState(() => _selectedNav = 3),
            child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF64748B), size: 22),
          ),
          const SizedBox(width: 24),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'profile') {
                setState(() => _selectedNav = 15);
              } else if (value == 'logout') {
                await AuthService.logout();
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginPage()), (route) => false);
              }
            },
            offset: const Offset(0, 50),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Row(children: [Icon(Icons.person_outline, size: 18), SizedBox(width: 8), Text('Mon profil')])),
              const PopupMenuItem(value: 'settings', child: Row(children: [Icon(Icons.settings_outlined, size: 18), SizedBox(width: 8), Text('Paramètres')])),
              const PopupMenuDivider(),
              const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, size: 18, color: Colors.red), SizedBox(width: 8), Text('Déconnexion', style: TextStyle(color: Colors.red))])),
            ],
            child: Row(
              children: [
                const CircleAvatar(radius: 16, backgroundColor: Color(0xFFE2E8F0), child: Icon(Icons.person, size: 20, color: Color(0xFF64748B))),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getFirstName(), style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text(_getRole(), style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 18),
              ],
            ),
          )
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => Stack(
        children: [
          Positioned(
            top: position.top + 60,
            right: 24,
            child: Material(
              color: Colors.transparent,
              child: NotificationsPanel(userId: widget.userData?['id'] ?? ''),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedNav) {
      case 0: return _buildMainContent();
      case 1: return ProjetsPage(userData: widget.userData);
      case 2: return InvestisseursSearchPage(onContact: () => setState(() => _selectedNav = 3));
      case 3: return MessagesPage(userData: widget.userData);
      case 4: return FinanceDashboard(userData: widget.userData);
      case 5: return FacturesPage(userData: widget.userData);
      case 6: return DepensesPage(userData: widget.userData);
      case 7: return ComptabilitePage(userData: widget.userData);
      case 8: return RHPage(userData: widget.userData);
      case 9: return StockPage(userData: widget.userData);
      case 10: return CRMPage(userData: widget.userData);
      case 11: return BusinessPlanIAPage(userData: widget.userData);
      case 12: return SuiviProjetsPage(userData: widget.userData);
      case 13: return MarketplaceExplorer(userData: widget.userData);
      case 14: return MicrolearningPage(userData: widget.userData);
      case 15: return ProfilePage(userData: widget.userData);
      case 17: return SimulateurPage(userData: widget.userData);
      case 18: return ForumPage(userData: widget.userData);
      case 19: return BaseLegalePage(userData: widget.userData);
      case 20: return TrainerDashboardPage(userData: widget.userData);
      case 21: return SupportPage(userData: widget.userData);
      default: return const Center(child: Text('Page non trouvée', style: TextStyle(color: Colors.grey)));
    }
  }

  // ────────────── MAIN CONTENT ──────────────
  Widget _buildMainContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bonjour, ${_getFirstName()} 👋', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 24, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Voici un aperçu complet de votre activité aujourd\'hui.', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text('15 Mai 2024', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(width: 8),
                  const Icon(Icons.keyboard_arrow_down, size: 16),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        
        // ROW 1: 6 KPIs
        Row(
          children: [
            Expanded(child: _buildKpiCard('Chiffre d\'affaires', '48 650 MAD', '12.5%', true, Icons.trending_up, const Color(0xFFE8F5E9), NexaColors.primaryGreen, "vs avril 2024")),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Bénéfice net', '17 850 MAD', '8.3%', true, Icons.account_balance_wallet_outlined, const Color(0xFFE8F5E9), NexaColors.primaryGreen, "vs avril 2024")),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Factures en attente', '5', '12 450 MAD', null, Icons.receipt_long_outlined, const Color(0xFFFFF7ED), const Color(0xFFF59E0B), null, isValueSecondary: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Dépenses du mois', '21 200 MAD', '3.7%', true, Icons.shopping_cart_outlined, const Color(0xFFFEF2F2), const Color(0xFFEF4444), "vs avril 2024")),
             const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Projets actifs', '7', '3 en retard', null, Icons.business_center_outlined, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), null, isDanger: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Trust Score', '85/100', 'Très bon', null, Icons.shield_outlined, const Color(0xFFE8F5E9), NexaColors.primaryGreen, null, isSuccessText: true, showBar: true)),
          ],
        ),
        const SizedBox(height: 24),

        // ROW 2: Charts + Reminders
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Evolution Chart
            Expanded(
              flex: 12,
              child: _buildCard('Évolution du chiffre d\'affaires', SizedBox(height: 250, child: _buildLineChart()), action: '6 derniers mois', height: 350),
            ),
            const SizedBox(width: 16),
            // Donut Chart
            Expanded(
              flex: 10,
              child: _buildCard('Répartition des revenus', 
                  Row(
                    children: [
                      Expanded(child: _buildPieChart()),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(NexaColors.primaryGreen, 'Prestations de services', '60%'),
                            _buildLegendItem(const Color(0xFF3B82F6), 'Vente de produits', '25%'),
                            _buildLegendItem(const Color(0xFFF59E0B), 'Formations', '10%'),
                            _buildLegendItem(const Color(0xFF94A3B8), 'Autres', '5%'),
                          ],
                        ),
                      )
                    ],
                  ),
                bottomLink: 'Voir le rapport complet →', height: 350
              ),
            ),
            const SizedBox(width: 16),
            // Rappels fiscaux
            Expanded(
              flex: 10,
              child: _buildCard('Rappels fiscaux', 
                Column(
                  children: [
                    _buildReminderRow('Déclaration TVA - T1 2024', 'Échéance : 30 Mai 2024', '15 jours', const Color(0xFFFEF2F2), const Color(0xFFEF4444), Icons.notifications_active_outlined),
                    _buildReminderRow('Paiement IR', 'Échéance : 31 Mai 2024', '16 jours', const Color(0xFFFFF7ED), const Color(0xFFF59E0B), Icons.notifications_active_outlined),
                    _buildReminderRow('Patente professionnelle', 'Échéance : 30 Juin 2024', '46 jours', const Color(0xFFE8F5E9), NexaColors.primaryGreen, Icons.notifications_active_outlined),
                    _buildReminderRow('CNSS - Déclaration', 'Échéance : 10 Juin 2024', '27 jours', const Color(0xFFF1F5F9), const Color(0xFF64748B), Icons.account_balance_outlined),
                  ]
                ),
                actionText: 'Tout voir',
                bottomButton: 'Voir tous les rappels',
                height: 350
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ROW 3: Quick Access
        _buildQuickAccessRow(),
        const SizedBox(height: 24),

        // ROW 4: 4 Equal Columns
        Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(
               child: _buildCard('Matching & Projets', 
                 Column(
                   children: [
                     _buildProjectRow('Projet GreenTech', 'Vu', Icons.visibility_outlined, const Color(0xFF64748B), '12 Mai'),
                     _buildProjectRow('Projet AgriSmart', 'Intéressé', Icons.star_border, NexaColors.primaryGreen, '10 Mai'),
                     _buildProjectRow('Projet BuildMorocco', 'En discussion', Icons.chat_bubble_outline, const Color(0xFF3B82F6), '8 Mai'),
                     _buildProjectRow('Projet EduConnect', 'Clôturé', Icons.check_circle_outline, NexaColors.primaryGreen, '2 Mai'),
                   ]
                 ),
                 actionText: 'Voir tout', bottomLink: 'Voir tous mes projets →',
                 onActionTap: () => setState(() => _selectedNav = 1),
                 onBottomTap: () => setState(() => _selectedNav = 1),
                 height: 320
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: _buildCard('Trésorerie', 
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                           const Text('Solde disponible', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                           Text('32 480 MAD', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 18, fontWeight: FontWeight.bold)),
                         ]),
                         Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                           const Text('Prévision (30 jours)', style: TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                           Text('+ 12 600 MAD', style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 14, fontWeight: FontWeight.bold)),
                         ]),
                       ],
                     ),
                     const SizedBox(height: 16),
                     Expanded(child: _buildBarChart()),
                   ]
                 ),
                 bottomLink: 'Voir la trésorerie →', 
                 onBottomTap: () => setState(() => _selectedNav = 6),
                 height: 320
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: _buildCard('Tâches en cours', 
                 Column(
                   children: [
                     _buildTaskRow('Préparer dossier banque', 'En cours', const Color(0xFF8B5CF6), '60%'),
                     _buildTaskRow('Étude de marché', 'En cours', const Color(0xFFF59E0B), '40%'),
                     _buildTaskRow('Campagne marketing', 'À faire', const Color(0xFF3B82F6), '0%'),
                     _buildTaskRow('Développement MVP', 'À faire', const Color(0xFF3B82F6), '0%'),
                   ]
                 ),
                 actionText: 'Voir tout', bottomLink: 'Voir toutes les tâches →',
                 onActionTap: () => setState(() => _selectedNav = 12),
                 onBottomTap: () => setState(() => _selectedNav = 12),
                 height: 320
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: _buildCard('Activité récente', 
                 Column(
                   children: [
                     _buildActivityTimeline(Icons.check_circle, NexaColors.primaryGreen, 'Facture F-2024-048 payée', 'il y a 2 heures'),
                     _buildActivityTimeline(Icons.add_box, const Color(0xFFEF4444), 'Nouvelle dépense ajoutée', 'il y a 5 heures'),
                     _buildActivityTimeline(Icons.update, const Color(0xFF3B82F6), 'Projet "Site e-commerce" mis à jour', 'il y a 1 jour'),
                     _buildActivityTimeline(Icons.mail, const Color(0xFF8B5CF6), 'Relance facture F-2024-047 envoyée', 'il y a 2 jours'),
                     _buildActivityTimeline(Icons.account_balance, NexaColors.primaryGreen, 'Relevé bancaire importé', 'il y a 2 jours', isLast: true),
                   ]
                 ),
                 actionText: 'Voir tout',
                 height: 320
               ),
             ),
           ],
        ),
        const SizedBox(height: 24),

        // ROW 5: Bottom categorized lists (7 items)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildCategoryBox('Facturation', Icons.receipt_long_outlined, NexaColors.primaryGreen, ['Créer une facture', 'Factures récentes', 'Relances clients', 'Devis & bons'], 4),
              const SizedBox(width: 16),
              _buildCategoryBox('Dépenses', Icons.money_off_outlined, NexaColors.primaryGreen, ['Ajouter une dépense', 'Par catégorie', 'Import relevé bancaire', 'Justificatifs'], 5),
              const SizedBox(width: 16),
              _buildCategoryBox('CRM & Pipeline', Icons.trending_up, const Color(0xFF3B82F6), ['Prospects', 'Devis en cours', 'Commandes', 'Encaissements'], 10),
              const SizedBox(width: 16),
              _buildCategoryBox('Comptabilité', Icons.account_balance_outlined, NexaColors.primaryGreen, ['Journal comptable', 'Bilan & Résultat', 'TVA & Déclarations', 'Export comptable'], 7),
              const SizedBox(width: 16),
              _buildCategoryBox('RH', Icons.people_outline, const Color(0xFF3B82F6), ['Employés', 'Congés & Absences', 'Feuilles de temps', 'Paie'], 8),
              const SizedBox(width: 16),
              _buildCategoryBox('Stock', Icons.inventory_2_outlined, NexaColors.primaryGreen, ['Produits', 'Mouvements', 'Alertes stock', 'Inventaire'], 9),
              const SizedBox(width: 16),
              _buildCategoryBox('Marketplace', Icons.storefront_outlined, const Color(0xFF8B5CF6), ['Mes commandes', 'Mes prestataires', 'Paiements sécurisés', 'Avis & évaluations'], 13),
            ],
          ),
        ),
      ],
    ));
  }

  // ────────────── REUSABLE COMPONENTS ──────────────

  Widget _buildCard(String title, Widget content, {String? action, String? actionText, String? bottomLink, String? bottomButton, double? height, VoidCallback? onActionTap, VoidCallback? onBottomTap}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              if (action != null)
                InkWell(
                  onTap: onActionTap,
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(6)),
                    child: Row(
                      children: [
                        Text(action, style: const TextStyle(fontSize: 12)),
                        const Icon(Icons.keyboard_arrow_down, size: 16),
                      ],
                    ),
                  ),
                )
              else if (actionText != null)
                InkWell(
                  onTap: onActionTap,
                  child: Text(actionText, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600))
                ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(child: content),
          if (bottomLink != null)
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.only(top: 16),
                child: InkWell(
                  onTap: onBottomTap,
                  child: Text(bottomLink, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600))
                ),
              ),
            )
          else if (bottomButton != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: onBottomTap ?? () {},
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                    foregroundColor: NexaColors.darkNavy,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  child: Text(bottomButton, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String change, bool? isPositive, IconData icon, Color bgColor, Color iconColor, String? subText, {bool isValueSecondary = false, bool isDanger = false, bool isSuccessText = false, bool showBar = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(value, style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (showBar) ...[
                  Text(change, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Container(
                    height: 4, width: double.infinity,
                    decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(2)),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(width: 80, decoration: BoxDecoration(color: NexaColors.primaryGreen, borderRadius: BorderRadius.circular(2))),
                    ),
                  )
                ] else ...[
                  if (isPositive != null)
                    Row(
                      children: [
                        Icon(isPositive ? Icons.arrow_upward : Icons.arrow_downward, size: 12, color: isPositive ? NexaColors.primaryGreen : const Color(0xFFEF4444)),
                        const SizedBox(width: 4),
                        Text(change, style: TextStyle(color: isPositive ? NexaColors.primaryGreen : const Color(0xFFEF4444), fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    )
                  else
                    Text(change, style: TextStyle(color: isDanger ? const Color(0xFFEF4444) : (isSuccessText ? NexaColors.primaryGreen : iconColor), fontSize: 11, fontWeight: FontWeight.w600)),
                  if (subText != null) ...[
                    const SizedBox(height: 4),
                    Text(subText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
                  ]
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQuickAccessRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Accès rapide', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildQuickAccessButton(Icons.receipt_outlined, 'Créer une facture', const Color(0xFFE8F5E9), NexaColors.primaryGreen, 4),
            _buildQuickAccessButton(Icons.upload_file_outlined, 'Ajouter une dépense', const Color(0xFFFEF2F2), const Color(0xFFEF4444), 5),
            _buildQuickAccessButton(Icons.post_add_outlined, 'Nouveau projet', const Color(0xFFEFF6FF), const Color(0xFF3B82F6), 1),
            _buildQuickAccessButton(Icons.publish_outlined, 'Importer relevé', const Color(0xFFECFDF5), const Color(0xFF10B981), 6),
            _buildQuickAccessButton(Icons.auto_awesome_outlined, 'Business Plan IA', const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), 11),
            _buildQuickAccessButton(Icons.check_box_outlined, 'Nouvelle tâche', const Color(0xFFFFF7ED), const Color(0xFFF59E0B), 12),
            _buildQuickAccessButton(Icons.person_search_outlined, 'Trouver un prestataire', const Color(0xFFF1F5F9), const Color(0xFF3B82F6), 13),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAccessButton(IconData icon, String label, Color bgColor, Color iconColor, int targetNav) {
    return InkWell(
      onTap: () {
        setState(() => _selectedNav = targetNav);
        if (_scrollController.hasClients) {
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderRow(String title, String subtitle, String days, Color bgColor, Color textColor, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
            child: Icon(icon, color: textColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: NexaColors.darkNavy)),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(4)),
            child: Text(days, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 11)),
          )
        ],
      ),
    );
  }

  Widget _buildProjectRow(String title, String status, IconData icon, Color color, String date) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: NexaColors.darkNavy))),
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
              Text(status, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(width: 16),
          Text(date, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildTaskRow(String title, String status, Color color, String percent) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: NexaColors.darkNavy))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
            child: Text(status, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 16),
          Text(percent, style: const TextStyle(color: NexaColors.darkNavy, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(IconData icon, Color color, String title, String time, {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 12),
            ),
            if (!isLast)
              Container(width: 1, height: 26, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(vertical: 2))
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: NexaColors.darkNavy)),
              Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBox(String title, IconData headerIcon, Color iconColor, List<String> items, int targetNav) {
    return InkWell(
      onTap: () {
        setState(() => _selectedNav = targetNav);
        if (_scrollController.hasClients) {
          _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
        }
      },
      child: Container(
      width: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                child: Icon(headerIcon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy))),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 4, color: Color(0xFFCBD5E1)),
                    const SizedBox(width: 8),
                    Text(item, style: const TextStyle(fontSize: 12, color: Color(0xFF475569))),
                  ],
                ),
              )),
          const SizedBox(height: 8),
          Text('Voir tout →', style: TextStyle(color: NexaColors.primaryGreen, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    ));
  }

  // ────────────── END REUSABLE COMPONENTS ──────────────

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1)),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const months = ['Déc', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai'];
                if (value.toInt() >= 0 && value.toInt() < months.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(months[value.toInt()], style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)));
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}K', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0, maxX: 5, minY: 0, maxY: 60,
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 8), FlSpot(1, 15), FlSpot(2, 25), FlSpot(3, 20), FlSpot(4, 32), FlSpot(5, 48.65)],
            isCurved: true, color: NexaColors.primaryGreen, barWidth: 3, isStrokeCapRound: true,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(radius: 4, color: NexaColors.primaryGreen, strokeWidth: 2, strokeColor: Colors.white)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [NexaColors.primaryGreen.withOpacity(0.2), NexaColors.primaryGreen.withOpacity(0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 0, centerSpaceRadius: 50,
            sections: [
              PieChartSectionData(color: NexaColors.primaryGreen, value: 60, title: '', radius: 20),
              PieChartSectionData(color: const Color(0xFF3B82F6), value: 25, title: '', radius: 20),
              PieChartSectionData(color: const Color(0xFFF59E0B), value: 10, title: '', radius: 20),
              PieChartSectionData(color: const Color(0xFF94A3B8), value: 5, title: '', radius: 20),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('48 650', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('MAD', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10)),
          ],
        )
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 12))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround, maxY: 60,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (double value, TitleMeta meta) {
                const titles = ['Mai', 'Juin', 'Juil', 'Août', 'Sept', 'Oct'];
                return Padding(padding: const EdgeInsets.only(top: 8), child: Text(titles[value.toInt()], style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true, reservedSize: 30,
              getTitlesWidget: (value, meta) => Text('${value.toInt()}K', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10)),
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (value) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 25, color: NexaColors.primaryGreen, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))]),
          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 35, color: NexaColors.primaryGreen, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))]),
          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 20, color: NexaColors.primaryGreen, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))]),
          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 40, color: NexaColors.primaryGreen, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))]),
          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 25, color: NexaColors.primaryGreen, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))]),
          BarChartGroupData(x: 5, barRods: [BarChartRodData(toY: 20, color: NexaColors.primaryGreen, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(2)))]),
        ],
      ),
    );
  }

  String _getFirstName() {
    final name = widget.userData?['nom_complet'] as String? ?? 'Salim B.';
    return name.trim().split(' ').first;
  }

  String _getRole() {
    final role = widget.userData?['role']?.toString();
    if (role == null || role.isEmpty) return 'Entrepreneur';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }
}
