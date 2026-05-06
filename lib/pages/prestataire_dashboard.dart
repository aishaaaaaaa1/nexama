import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/chatbot_widget.dart';
import 'login_page.dart';
import 'prestataire/services_page.dart';
import 'prestataire/commandes_page.dart';
import 'prestataire/revenus_page.dart';
import 'prestataire/pipeline_page.dart';
import 'prestataire/portfolio_page.dart';
import 'prestataire/profil_public_page.dart';
import 'prestataire/propose_service_page.dart';
import 'prestataire/disponibilites_page.dart';
import 'prestataire/avis_evaluations_page.dart';
import 'prestataire/transactions_page.dart';
import 'prestataire/documents_page.dart';
import 'prestataire/parametres_page.dart';
import 'prestataire/marketplace_page.dart';
import 'investisseur/messages_page.dart';
import 'shared/premium_upgrade_page.dart';
import '../widgets/notifications_panel.dart';
import 'shared/support_page.dart';
import 'profile_page.dart';
import 'formateur/quiz_evaluations_page.dart';
import 'formateur/lives_webinaires_page.dart';
import 'formateur/apprenants_page.dart';

class PrestataireDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const PrestataireDashboard({super.key, this.userData});

  @override
  State<PrestataireDashboard> createState() => _PrestataireDashboardState();
}

class _PrestataireDashboardState extends State<PrestataireDashboard> {
  final ScrollController _scrollController = ScrollController();
  int _selectedNav = 0;
  bool _isSidebarCollapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () => setState(() => _selectedNav = 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              decoration: BoxDecoration(
                color: NexaColors.darkNavy,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Besoin d\'aide ?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text('Contactez le support', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
          ),
          Stack(
            children: [
              FloatingActionButton(
                onPressed: () => showChatBot(context),
                backgroundColor: NexaColors.primaryGreen,
                child: const Icon(Icons.smart_toy_outlined, color: Colors.white, size: 28),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          _buildSidebar(),
          // Main Body
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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

  // ────────────── SIDEBAR ──────────────
  Widget _buildSidebar() {
    return AnimatedContainer(
      key: const ValueKey('sidebar_prestataire'),
      duration: const Duration(milliseconds: 300),
      width: _isSidebarCollapsed ? 0 : 250,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Image.asset('assets/images/logo.png', height: 32, errorBuilder: (c, e, s) => const Icon(Icons.error, color: Colors.blue)),
                if (!_isSidebarCollapsed) ...[
                  const SizedBox(width: 12),
                  RichText(text: TextSpan(children: [
                    TextSpan(text: 'Nexa', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 20, fontWeight: FontWeight.w800)),
                    TextSpan(text: 'Ma', style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 20, fontWeight: FontWeight.w800)),
                  ])),
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
                  _buildNavItem(0, Icons.trending_up, 'Tableau de bord'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('SERVICES', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(1, Icons.business_center_outlined, 'Mes commandes'),
                  _buildNavItem(2, Icons.add_circle_outline, 'Nouveau service'),
                  _buildNavItem(3, Icons.inventory_2_outlined, 'Mes services'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('MATCHING', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(4, Icons.handshake_outlined, 'Matching IA'),
                  _buildNavItem(5, Icons.chat_bubble_outline, 'Messages', badge: '5', badgeColor: NexaColors.primaryGreen),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('OUTILS', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(6, Icons.description_outlined, 'Mes devis'),
                  _buildNavItem(7, Icons.receipt_long_outlined, 'Facturation'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('PROJET', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(8, Icons.track_changes_outlined, 'Suivi de projet'),
                  _buildNavItem(9, Icons.event_note_outlined, 'Planning'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('CRM', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(10, Icons.people_outline, 'Mes clients'),
                  _buildNavItem(11, Icons.star_border_outlined, 'Avis clients'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('FINANCES', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(12, Icons.analytics_outlined, 'Statistiques'),
                  _buildNavItem(13, Icons.account_balance_wallet_outlined, 'Revenus'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('APPRENTISSAGE', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(14, Icons.school_outlined, 'Micro-Learning'),
                  _buildNavItem(15, Icons.quiz_outlined, 'Quiz & Évaluations'),
                  _buildNavItem(16, Icons.videocam_outlined, 'Lives & Webinaires'),
                  _buildNavItem(17, Icons.people_alt_outlined, 'Mes apprenants'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('PARAMÈTRES', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(19, Icons.person_outline, 'Mon profil'),
                  _buildNavItem(20, Icons.settings_outlined, 'Configuration'),
                  const SizedBox(height: 16),
                  _buildLogoutItem(),
                ],
              ),
            ),
          ),
          // Support User
          if (!_isSidebarCollapsed)
            InkWell(
              onTap: () => setState(() => _selectedNav = 18),
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
            IconButton(onPressed: () => setState(() => _selectedNav = 18), icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFF64748B))),
        ],
      ),
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

  Widget _buildNavItem(int index, IconData icon, String label, {String? badge, Color? badgeColor}) {
    final isSelected = _selectedNav == index;
    return InkWell(
      onTap: () => setState(() => _selectedNav = index),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFFE8F5E9) : Colors.transparent, borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 20, color: isSelected ? NexaColors.primaryGreen : const Color(0xFF64748B)),
            if (!_isSidebarCollapsed) ...[
              const SizedBox(width: 12),
              Expanded(child: Text(label, style: GoogleFonts.inter(color: isSelected ? NexaColors.primaryGreen : const Color(0xFF475569), fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500))),
              if (badge != null) ...[
                Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
              ]
            ]
          ],
        ),
      ),
    );
  }

  // ────────────── TOPBAR ──────────────
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
              onPressed: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
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
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Color(0xFF64748B)),
            onPressed: () => _showNotifications(context),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage(userData: widget.userData)),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFE2E8F0),
                  child: Icon(Icons.person, color: Color(0xFF64748B), size: 20),
                ),
                const SizedBox(width: 10),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getFirstName(), style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 13, fontWeight: FontWeight.w600)),
                    Text('Prestataire', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11)),
                  ],
                ),
                const SizedBox(width: 8),
                const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 18),
              ],
            ),
          ),
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
      case 1: return MarketplacePrestatairePage(userData: widget.userData);
      case 2: return MesServicesPage(userData: widget.userData);
      case 3: return CommandesPrestatairePage(userData: widget.userData);
      case 4: return MessagesPage(userData: widget.userData);
      case 5: return AvisEvaluationsPage(userData: widget.userData);
      case 6: return PortfolioPage(userData: widget.userData);
      case 7: return DisponibilitesPage(userData: widget.userData);
      case 8: return RevenusPrestatairePage(userData: widget.userData);
      case 9: return TransactionsPrestatairePage(userData: widget.userData);
      case 10: return PipelinePage(userData: widget.userData);
      case 11: return DocumentsPrestatairePage(userData: widget.userData);
      case 12: return ProfilPublicPage(userData: widget.userData);
      case 13: return ParametresPage(userData: widget.userData);
      case 14: return PremiumUpgradePage(userData: widget.userData);
      case 15: return QuizEvaluationsPage(userData: widget.userData);
      case 16: return LivesWebinairesPage(userData: widget.userData);
      case 17: return ApprenantsFormateurPage(userData: widget.userData);
      case 18: return SupportPage(userData: widget.userData);
      default: return _buildMainContent();
    }
  }

  Widget _buildPlaceholderPage(String title, IconData icon, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 24),
          Text(title, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Action à venir'),
          )
        ],
      ),
    );
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
                Text('Bonjour, ${_getFirstName()} 👋', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Voici un aperçu de votre activité sur NexaMa.', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14)),
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
            Expanded(child: _buildKpiCard('Revenus totaux', '24 850 MAD', '↑ 18.6%', Icons.account_balance_wallet_outlined, const Color(0xFFE8F5E9), NexaColors.primaryGreen, "vs avril 2024", highlightText: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Commandes complétées', '36', '↑ 12.5%', Icons.check_circle_outline, const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), "vs avril 2024", highlightText: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Commandes en cours', '8', 'Voir le détail', Icons.loop, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), null, isAction: true, onTap: () => setState(() => _selectedNav = 2))),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Taux de satisfaction', '4.8/5', '↑ 0.3', Icons.star_border, const Color(0xFFFFF7ED), const Color(0xFFF59E0B), "Basé sur 24 avis", highlightText: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Taux de réponse', '98%', 'Très réactif', Icons.chat_bubble_outline, const Color(0xFFE8F5E9), NexaColors.primaryGreen, null)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Statut profil', 'Top Prestataire', 'Voir les avantages', Icons.workspace_premium, const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), null, isAction: true, onTap: () => setState(() => _selectedNav = 13))),
          ],
        ),
        const SizedBox(height: 24),

        // ROW 2: Charts + Activité
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Evolution Chart
            Expanded(
              flex: 5,
              child: _buildCard('Évolution de vos revenus', SizedBox(height: 250, child: _buildLineChart()), action: '6 derniers mois', height: 340),
            ),
            const SizedBox(width: 16),
            // Donut Chart
            Expanded(
              flex: 4,
              child: _buildCard('Répartition des revenus', 
                  Row(
                    children: [
                      Expanded(flex: 3, child: _buildPieChart()),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(NexaColors.primaryGreen, 'Design & Graphisme', '40%'),
                            _buildLegendItem(const Color(0xFF3B82F6), 'Développement Web', '30%'),
                            _buildLegendItem(const Color(0xFFF59E0B), 'Rédaction & Traduction', '15%'),
                            _buildLegendItem(const Color(0xFF8B5CF6), 'Marketing Digital', '10%'),
                            _buildLegendItem(const Color(0xFF94A3B8), 'Autres', '5%'),
                          ],
                        ),
                      )
                    ],
                  ),
                bottomLink: 'Voir le rapport complet →', onBottomTap: () => setState(() => _selectedNav = 7), height: 340
              ),
            ),
            const SizedBox(width: 16),
            // Recent Activity
            Expanded(
              flex: 3,
              child: _buildCard('Activité récente', 
                SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildActivityTimeline(Icons.auto_awesome, const Color(0xFF3B82F6), 'Nouvelle commande reçue\nCréation site web vitrine', 'Il y a 1 heure', valueText: '2 800 MAD', valueColor: NexaColors.primaryGreen),
                      _buildActivityTimeline(Icons.loop, const Color(0xFFF59E0B), 'Commande en cours\nRefonte identité visuelle', 'Il y a 3 heures', valueText: '1 500 MAD', valueColor: const Color(0xFFF59E0B)),
                      _buildActivityTimeline(Icons.star, const Color(0xFF10B981), 'Avis reçu\n⭐⭐⭐⭐⭐ 5/5', 'Il y a 5 heures'),
                      _buildActivityTimeline(Icons.account_balance_wallet, const Color(0xFF10B981), 'Paiement reçu\nCommande #CMD-1024', 'Il y a 6 heures', valueText: '3 200 MAD', valueColor: NexaColors.primaryGreen, isLast: true),
                    ]
                  ),
                ),
                actionText: 'Tout voir', height: 340
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ROW 3: Commandes, Dispo, Statistiques
        Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(
               flex: 6,
               child: _buildCard('Commandes en cours', 
                 Column(
                   children: [
                     _buildListHeaderRow(),
                     _buildOrderRow('#CMD-1025', 'GreenTech Solutions', 'Développement site web', '3 500 MAD', 'En cours', const Color(0xFF3B82F6), '20 Mai 2024'),
                     _buildOrderRow('#CMD-1024', 'StartUp Maroc', 'Design application mobile', '4 200 MAD', 'En cours', const Color(0xFF3B82F6), '18 Mai 2024'),
                     _buildOrderRow('#CMD-1023', 'BuildMorocco', 'Rédaction contenu SEO', '1 200 MAD', 'En cours', const Color(0xFF3B82F6), '17 Mai 2024'),
                     _buildOrderRow('#CMD-1022', 'EduConnect', 'Création logo & charte', '800 MAD', 'En attente', const Color(0xFFF59E0B), '16 Mai 2024', isLast: true),
                   ]
                 ),
                 actionText: 'Voir toutes',
                 onActionTap: () => setState(() => _selectedNav = 2),
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               flex: 2,
               child: _buildCard('Disponibilité', 
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text('Statut actuel', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                     const SizedBox(height: 8),
                     Row(
                       children: [
                         Container(width: 8, height: 8, decoration: const BoxDecoration(color: NexaColors.primaryGreen, shape: BoxShape.circle)),
                         const SizedBox(width: 8),
                         const Text('Disponible', style: TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                       ],
                     ),
                     const SizedBox(height: 24),
                     const Text('Prochaine disponibilité', style: TextStyle(color: Color(0xFF64748B), fontSize: 11)),
                     const SizedBox(height: 8),
                     Row(
                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                       children: [
                         const Text('Aujourd\'hui, 14:00', style: TextStyle(color: NexaColors.darkNavy, fontWeight: FontWeight.bold, fontSize: 14)),
                         Icon(Icons.calendar_month, color: NexaColors.primaryGreen.withOpacity(0.3), size: 30)
                       ],
                     ),
                     const Spacer(),
                     SizedBox(
                       width: double.infinity,
                       child: ElevatedButton(
                         onPressed: () {},
                         style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
                         child: const Text('Modifier ma disponibilité', style: TextStyle(color: Colors.white, fontSize: 12)),
                       ),
                     )
                   ]
                 ),
                 height: 300,
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               flex: 2,
               child: _buildCard('Statistiques rapides', 
                 Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     _buildStatRow(Icons.visibility_outlined, 'Vues de profil', '1 245', '+ 22%'),
                     const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Color(0xFFE2E8F0))),
                     _buildStatRow(Icons.chat_bubble_outline, 'Demandes reçues', '56', '+ 15%'),
                     const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Color(0xFFE2E8F0))),
                     _buildStatRow(Icons.trending_up, 'Taux de conversion', '28%', '+ 8%'),
                     const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Divider(height: 1, color: Color(0xFFE2E8F0))),
                     _buildStatRow(Icons.people_outline, 'Clients récurrents', '12', '+ 20%'),
                   ]
                 ),
                 action: '6 derniers mois',
                 height: 300,
               ),
             ),
           ],
        ),
        const SizedBox(height: 24),

        // ROW 4: Services populaires
        _buildCard('Mes services populaires', 
          Row(
            children: [
              Expanded(child: _buildServiceInfoBox(Icons.laptop_mac, const Color(0xFF3B82F6), 'Création de site web vitrine', 'À partir de 2 500 MAD', '4.9', '18 avis', '32 commandes')),
              const SizedBox(width: 16),
              Expanded(child: _buildServiceInfoBox(Icons.design_services, const Color(0xFFEC4899), 'Design logo & identité visuelle', 'À partir de 800 MAD', '4.8', '15 avis', '28 commandes')),
              const SizedBox(width: 16),
              Expanded(child: _buildServiceInfoBox(Icons.summarize, NexaColors.primaryGreen, 'Rédaction contenu SEO', 'À partir de 300 MAD / 500 mots', '4.7', '12 avis', '21 commandes')),
              const SizedBox(width: 16),
              Expanded(child: _buildServiceInfoBox(Icons.smartphone, const Color(0xFF8B5CF6), 'Community Management', 'À partir de 1 200 MAD / mois', '4.9', '10 avis', '16 commandes', isLastBox: true)),
            ],
          ),
          actionText: 'Voir tous mes services'
        ),
      ],
    ));
  }

  // ────────────── COMPONENTS ──────────────

  Widget _buildCard(String title, Widget content, {String? actionText, String? action, String? bottomLink, double? height, VoidCallback? onActionTap, VoidCallback? onBottomTap}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              if (action != null)
                InkWell(onTap: onActionTap, child: Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(6)), child: Row(children: [Text(action, style: const TextStyle(fontSize: 12)), const Icon(Icons.keyboard_arrow_down, size: 16)])))
              else if (actionText != null)
                InkWell(onTap: onActionTap, child: Text(actionText, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600))),
            ],
          ),
          const SizedBox(height: 20),
          if (height != null) Expanded(child: content) else content,
          if (bottomLink != null)
            Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.only(top: 16), child: InkWell(onTap: onBottomTap, child: Text(bottomLink, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600))))),
        ],
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, String changeText, IconData icon, Color bgColor, Color iconColor, String? subText, {bool isAction = false, bool highlightText = false, VoidCallback? onTap}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle), child: Icon(icon, color: iconColor, size: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(value, style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 20, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                if (isAction)
                  InkWell(onTap: onTap, child: Text(changeText, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)))
                else if (highlightText)
                  Row(
                    children: [
                      Text(changeText, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  )
                else
                  Text(changeText, style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 12)),
                if (subText != null) ...[
                  const SizedBox(height: 4),
                  Text(subText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildListHeaderRow() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text('Commande', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Client', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text('Service', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Montant', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Statut', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Text('Échéance', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  Widget _buildOrderRow(String id, String client, String service, String montant, String statut, Color statutColor, String echeance, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(border: !isLast ? const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))) : null),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy))),
          Expanded(flex: 2, child: Text(client, style: const TextStyle(color: Color(0xFF475569), fontSize: 13))),
          Expanded(flex: 3, child: Text(service, style: const TextStyle(color: Color(0xFF475569), fontSize: 13))),
          Expanded(flex: 2, child: Text(montant, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy))),
          Expanded(
            flex: 2, 
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                decoration: BoxDecoration(color: statutColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), 
                child: Text(statut, style: TextStyle(color: statutColor, fontSize: 11, fontWeight: FontWeight.bold))
              ),
            )
          ),
          Expanded(flex: 2, child: Text(echeance, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildActivityTimeline(IconData icon, Color color, String title, String time, {String? valueText, Color? valueColor, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 14)),
            if (!isLast) Container(width: 1, height: 35, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(vertical: 4))
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: NexaColors.darkNavy)),
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            ],
          ),
        ),
        if (valueText != null)
          Text(valueText, style: TextStyle(color: valueColor, fontWeight: FontWeight.bold, fontSize: 13))
      ],
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, String diff) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF64748B)),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 13))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: NexaColors.darkNavy)),
        const SizedBox(width: 16),
        SizedBox(width: 40, child: Text(diff, style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _buildServiceInfoBox(IconData icon, Color iconColor, String title, String price, String rating, String reviewsCount, String ordersCount, {bool isLastBox = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: iconColor.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.star, color: Color(0xFFF59E0B), size: 12),
                    const SizedBox(width: 4),
                    Text('$rating ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                    Text('($reviewsCount)', style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 2),
                Text(ordersCount, style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)),
              ],
            ),
          ),
          if (isLastBox) const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 12))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: NexaColors.darkNavy)),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFFF1F5F9), strokeWidth: 1)),
        titlesData: FlTitlesData(
          show: true, topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            const months = ['Déc', 'Jan', 'Fév', 'Mar', 'Avr', 'Mai'];
            if (value.toInt() >= 0 && value.toInt() < months.length) return Padding(padding: const EdgeInsets.only(top: 8), child: Text(months[value.toInt()], style: const TextStyle(color: Color(0xFF64748B), fontSize: 11)));
            return const Text('');
          })),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toInt()}K', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)))),
        ),
        borderData: FlBorderData(show: false), minX: 0, maxX: 5, minY: 0, maxY: 30,
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 5), FlSpot(1, 12), FlSpot(2, 16), FlSpot(3, 15), FlSpot(4, 20), FlSpot(5, 24.85)],
            isCurved: false, color: NexaColors.primaryGreen, barWidth: 3,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => index == 5 ? FlDotCirclePainter(radius: 6, color: NexaColors.primaryGreen, strokeWidth: 2, strokeColor: Colors.white) : FlDotCirclePainter(radius: 4, color: NexaColors.primaryGreen, strokeWidth: 2, strokeColor: Colors.white)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [NexaColors.primaryGreen.withValues(alpha: 0.2), NexaColors.primaryGreen.withValues(alpha: 0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(getTooltipItems: (spots) => spots.map((s) => LineTooltipItem('24 850 MAD', const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))).toList()),
        ),
      ),
    );
  }

  Widget _buildPieChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0, centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(color: NexaColors.primaryGreen, value: 40, title: '', radius: 25),
                PieChartSectionData(color: const Color(0xFF3B82F6), value: 30, title: '', radius: 25),
                PieChartSectionData(color: const Color(0xFFF59E0B), value: 15, title: '', radius: 25),
                PieChartSectionData(color: const Color(0xFF8B5CF6), value: 10, title: '', radius: 25),
                PieChartSectionData(color: const Color(0xFF94A3B8), value: 5, title: '', radius: 25),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('24 850', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('MAD', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }

  String _getFirstName() {
    final name = widget.userData?['nom_complet'] as String? ?? 'Sara Benali';
    return name.trim().split(' ').first;
  }
}
