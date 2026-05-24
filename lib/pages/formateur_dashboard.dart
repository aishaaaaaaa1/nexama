import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/chatbot_widget.dart';
import 'login_page.dart';
import 'formateur/cours_page.dart';
import 'formateur/creer_cours_page.dart';
import 'formateur/apprenants_page.dart';
import 'formateur/statistiques_formateur_page.dart';
import 'formateur/revenus_page.dart';
import 'formateur/quiz_evaluations_page.dart';
import 'formateur/lives_webinaires_page.dart';
import 'formateur/avis_commentaires_page.dart';
import 'formateur/engagement_page.dart';
import 'formateur/rapports_page.dart';
import 'formateur/profil_formateur_page.dart';
import 'formateur/paiement_page.dart';
import 'prestataire/parametres_page.dart';
import 'formateur/messages_formateur_page.dart';
import '../../widgets/formateur/formateur_ui.dart';
import '../widgets/notifications_panel.dart';
import 'shared/support_page.dart';
import 'profile_page.dart';

class FormateurDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const FormateurDashboard({super.key, this.userData});

  @override
  State<FormateurDashboard> createState() => _FormateurDashboardState();
}

class _FormateurDashboardState extends State<FormateurDashboard> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<MesCoursPageState> _mesCoursKey = GlobalKey<MesCoursPageState>();
  final GlobalKey<MessagesFormateurPageState> _messagesKey = GlobalKey<MessagesFormateurPageState>();
  int _selectedNav = 0;
  int _messagesUnread = 0;
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
            onTap: () => setState(() => _selectedNav = 15),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(right: 12, bottom: 8),
              decoration: BoxDecoration(
                color: NexaColors.darkNavy,
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16), bottomLeft: Radius.circular(16), bottomRight: Radius.circular(4)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))],
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
      key: const ValueKey('sidebar_formateur'),
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
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('ENSEIGNEMENT', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(1, Icons.business_center_outlined, 'Mes cours'),
                  _buildNavItem(2, Icons.add_circle_outline, 'Créer un cours'),
                  _buildNavItem(3, Icons.quiz_outlined, 'Quiz & évaluations'),
                  _buildNavItem(4, Icons.videocam_outlined, 'Lives & Webinaires'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('APPRENANTS', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(5, Icons.people_outline, 'Mes apprenants'),
                  _buildNavItem(
                    6,
                    Icons.chat_bubble_outline,
                    'Messages',
                    badge: _messagesUnread > 0 ? '$_messagesUnread' : null,
                    badgeColor: NexaColors.primaryGreen,
                  ),
                  _buildNavItem(7, Icons.star_border_outlined, 'Avis & commentaires'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('ANALYSES', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(8, Icons.analytics_outlined, 'Statistiques'),
                  _buildNavItem(9, Icons.account_balance_wallet_outlined, 'Revenus'),
                  _buildNavItem(10, Icons.thumb_up_outlined, 'Engagement'),
                  _buildNavItem(11, Icons.article_outlined, 'Rapports'),
                  if (!_isSidebarCollapsed) const Padding(padding: EdgeInsets.only(left: 12, top: 16, bottom: 8), child: Text('PARAMÈTRES', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.bold))),
                  _buildNavItem(12, Icons.person_outline, 'Profil formateur'),
                  _buildNavItem(13, Icons.settings_outlined, 'Configuration'),
                  _buildNavItem(14, Icons.payment_outlined, 'Paiements'),
                  const SizedBox(height: 16),
                  _buildLogoutItem(),
                ],
              ),
            ),
          ),
          // Support User
          if (!_isSidebarCollapsed)
            InkWell(
              onTap: () => setState(() => _selectedNav = 15),
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
            IconButton(onPressed: () => setState(() => _selectedNav = 15), icon: const Icon(Icons.headset_mic_outlined, color: Color(0xFF64748B))),
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
          Container(
            width: 350,
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
                      hintText: _isSidebarCollapsed ? 'Rechercher...' : 'Rechercher un cours, un apprenant...',
                      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: const Text('⌘K', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () => _showNotifications(context),
            child: Stack(
              children: [
                const Icon(Icons.notifications_none, color: Color(0xFF64748B), size: 24),
                Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
              ],
            ),
          ),
          const SizedBox(width: 20),
          InkWell(
            onTap: () => showChatBot(context),
            child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF64748B), size: 22),
          ),
          const SizedBox(width: 24),
          InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => ProfilePage(userData: widget.userData))),
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
                    Text('Formateur', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11)),
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
      case 1: return MesCoursPage(
            key: _mesCoursKey,
            userData: widget.userData,
            onCreateCourse: () => setState(() => _selectedNav = 2),
          );
      case 2: return CreerCoursPage(
            userData: widget.userData,
            onPublished: () => _mesCoursKey.currentState?.refresh(),
          );
      case 3: return QuizEvaluationsPage(userData: widget.userData);
      case 4: return LivesWebinairesPage(userData: widget.userData);
      case 5: return ApprenantsFormateurPage(
            userData: widget.userData,
            onContactLearner: (conversationId) {
              setState(() => _selectedNav = 6);
              if (conversationId != null) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _messagesKey.currentState?.openConversation(conversationId);
                });
              }
            },
          );
      case 6: return MessagesFormateurPage(
            key: _messagesKey,
            userData: widget.userData,
            onUnreadChanged: (n) {
              if (_messagesUnread != n) setState(() => _messagesUnread = n);
            },
          );
      case 7: return AvisCommentairesPage(userData: widget.userData);
      case 8: return StatistiquesFormateurPage(userData: widget.userData);
      case 9: return RevenusFormateurPage(userData: widget.userData);
      case 10: return EngagementPage(userData: widget.userData);
      case 11: return RapportsPage(userData: widget.userData);
      case 12: return ProfilFormateurPage(userData: widget.userData);
      case 13: return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const FormateurPageHeader(
              title: 'Configuration',
              subtitle: 'Notifications, quiz automatiques et préférences de votre espace formateur.',
            ),
            const SizedBox(height: 12),
            Expanded(child: ParametresPage(userData: widget.userData)),
          ],
        );
      case 14: return PaiementFormateurPage(userData: widget.userData);
      case 15: return SupportPage(userData: widget.userData);
      default: return _buildMainContent();
    }
  }

  // ignore: unused_element
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
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            child: const Text('Disponible bientôt'),
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
                Text('Voici un aperçu de votre activité de formateur.', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF64748B)),
                  const SizedBox(width: 8),
                  Text('15 Mai 2024 - 15 Juin 2024', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500)),
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
            Expanded(child: _buildKpiCard('Apprenants actifs', '1 245', '↑ 18.6%', Icons.school_outlined, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), "vs période précédente")),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Inscriptions', '2 856', '↑ 22.4%', Icons.menu_book_outlined, const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), "vs période précédente")),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Heures de visionnage', '3 842', '↑ 15.3%', Icons.play_circle_outline, const Color(0xFFE8F5E9), NexaColors.primaryGreen, "vs période précédente", suffixText: 'h')),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Taux de complétion', '68%', '↑ 6.8%', Icons.star_border, const Color(0xFFFFF7ED), const Color(0xFFF59E0B), "vs période précédente", isWarning: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Revenus totaux', '24 850 MAD', '↑ 20.7%', Icons.account_balance_wallet_outlined, const Color(0xFFE8F5E9), NexaColors.primaryGreen, "vs période précédente")),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Note moyenne', '4.8', 'Basée sur 342 avis', Icons.verified_outlined, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), null, suffixText: '/5', hasStars: true)),
          ],
        ),
        const SizedBox(height: 24),

        // ROW 2: Charts + Activité
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: _buildCard('Évolution des revenus', SizedBox(height: 250, child: _buildLineChart()), action: '6 derniers mois', height: 340, onBottomTap: () => setState(() => _selectedNav = 9)),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 4,
              child: _buildCard('Répartition des revenus par cours', 
                  Row(
                    children: [
                      Expanded(flex: 3, child: _buildCoursePieChart()),
                      Expanded(
                        flex: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(NexaColors.primaryGreen, 'Marketing Digital', '40%'),
                            _buildLegendItem(const Color(0xFF3B82F6), 'Création de Site Web', '25%'),
                            _buildLegendItem(const Color(0xFFF59E0B), 'Levée de Fonds', '15%'),
                            _buildLegendItem(const Color(0xFF8B5CF6), 'Gestion Financière', '10%'),
                            _buildLegendItem(const Color(0xFF94A3B8), 'Autres', '10%'),
                          ],
                        ),
                      )
                    ],
                  ),
                bottomLink: 'Voir le rapport complet →', onBottomTap: () => setState(() => _selectedNav = 11), height: 340
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 3,
              child: _buildCard('Activité récente', 
                Column(
                  children: [
                    _buildActivityTimeline(Icons.person, const Color(0xFF8B5CF6), 'Nouvel apprenant\nAmine B. s\'est inscrit à votre cours', 'Il y a 1 heure', subBoldText: 'Marketing Digital'),
                    _buildActivityTimeline(Icons.star_border, NexaColors.primaryGreen, 'Avis 5 étoiles ⭐⭐⭐⭐⭐\nsur votre cours', 'Il y a 3 heures', subBoldText: 'Création de Site Web'),
                    _buildActivityTimeline(Icons.chat_bubble_outline, const Color(0xFF8B5CF6), 'Nouvelle question\ndans le cours Levée de Fonds', 'Il y a 5 heures'),
                    _buildActivityTimeline(Icons.account_balance_wallet, NexaColors.primaryGreen, 'Paiement reçu\nCommission sur ventes de cours', 'Il y a 6 heures', valueText: '+ 1 250 MAD', valueColor: NexaColors.primaryGreen),
                    _buildActivityTimeline(Icons.videocam_outlined, const Color(0xFF64748B), 'Webinaire terminé\nLive "Stratégie de croissance"', 'Hier, 19:00', isLast: true),
                  ]
                ),
                actionText: 'Tout voir', onActionTap: () => setState(() => _selectedNav = 8), height: 340
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ROW 3: Mes cours, Mes apprenants, Sources trafic
        Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(
               flex: 5,
               child: _buildCard('Mes cours', 
                 Column(
                   children: [
                     _buildCourseListHeader(),
                     _buildCourseRow(Icons.campaign, const Color(0xFF8B5CF6), 'Marketing Digital pour PME', 'Publié', NexaColors.primaryGreen, '562', 0.72, '8 450 MAD'),
                     _buildCourseRow(Icons.web, const Color(0xFFF59E0B), 'Création de Site Web de A à Z', 'Publié', NexaColors.primaryGreen, '432', 0.65, '6 780 MAD'),
                     _buildCourseRow(Icons.business, const Color(0xFF3B82F6), 'Levée de Fonds & Pitch Deck', 'Publié', NexaColors.primaryGreen, '215', 0.58, '4 320 MAD'),
                     _buildCourseRow(Icons.account_balance, const Color(0xFF3B82F6), 'Gestion Financière Simplifiée', 'Brouillon', const Color(0xFFF59E0B), '36', 0.0, '1 100 MAD'),
                     _buildCourseRow(Icons.gavel, const Color(0xFF8B5CF6), 'Droit des Affaires au Maroc', 'Publié', NexaColors.primaryGreen, '156', 0.70, '2 200 MAD', isLast: true),
                     const SizedBox(height: 12),
                     Align(alignment: Alignment.center, child: InkWell(onTap: () => setState(() => _selectedNav = 2), child: const Text('+ Créer un nouveau cours', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.w600, fontSize: 12)))),
                   ]
                 ),
                 actionText: 'Voir tous',
                 onActionTap: () => setState(() => _selectedNav = 1),
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               flex: 3,
               child: _buildCard('Mes apprenants', 
                 Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     _buildStudentRow('Imane K.', 0.75, 'Il y a 2 heures'),
                     _buildStudentRow('Yassine M.', 0.60, 'Il y a 4 heures'),
                     _buildStudentRow('Khadija A.', 0.90, 'Il y a 5 heures'),
                     _buildStudentRow('Mehdi T.', 0.40, 'Il y a 1 jour', isWarningColor: true),
                     _buildStudentRow('Salma R.', 0.85, 'Il y a 1 jour'),
                   ]
                 ),
                 actionText: 'Voir tous',
                 onActionTap: () => setState(() => _selectedNav = 5),
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               flex: 3,
               child: _buildCard('Sources de trafic', 
                 Row(
                   children: [
                     Expanded(flex: 3, child: _buildTrafficPieChart()),
                     Expanded(
                       flex: 4,
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           _buildLegendItem(NexaColors.primaryGreen, 'Recherche organique', '45%'),
                           _buildLegendItem(const Color(0xFF3B82F6), 'Réseaux sociaux', '25%'),
                           _buildLegendItem(const Color(0xFFF59E0B), 'Direct', '15%'),
                           _buildLegendItem(const Color(0xFF8B5CF6), 'Email', '10%'),
                           _buildLegendItem(const Color(0xFF94A3B8), 'Autres', '5%'),
                         ],
                       ),
                     )
                   ],
                 ),
                 actionText: 'Voir le détail',
                 onActionTap: () => setState(() => _selectedNav = 8),
               ),
             ),
           ],
        ),
        const SizedBox(height: 24),

        // ROW 4: Actions rapides
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            children: [
              Text('Actions rapides', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              const SizedBox(width: 32),
              _buildActionButton(Icons.add_circle_outline, 'Créer un cours', color: const Color(0xFF8B5CF6), onTap: () => setState(() => _selectedNav = 2)),
              const SizedBox(width: 16),
              _buildActionButton(Icons.videocam_outlined, 'Programmer un live', color: NexaColors.primaryGreen, onTap: () => setState(() => _selectedNav = 4)),
              const SizedBox(width: 16),
              _buildActionButton(Icons.edit_note, 'Créer un quiz', color: const Color(0xFFF59E0B), onTap: () => setState(() => _selectedNav = 3)),
              const Spacer(),
              _buildActionButton(Icons.account_balance_wallet_outlined, 'Voir mes revenus', color: NexaColors.primaryGreen, bgOverride: const Color(0xFFF1F8F1), onTap: () => setState(() => _selectedNav = 9)),
              const SizedBox(width: 16),
              _buildActionButton(Icons.download_outlined, 'Télécharger rapport', color: const Color(0xFF3B82F6), bgOverride: const Color(0xFFEFF6FF), onTap: () => setState(() => _selectedNav = 11)),
              const SizedBox(width: 16),
              _buildActionButton(
                Icons.chat_bubble_outline,
                _messagesUnread > 0 ? 'Messages ($_messagesUnread)' : 'Messages',
                color: const Color(0xFF8B5CF6),
                bgOverride: const Color(0xFFF5F3FF),
                onTap: () => setState(() => _selectedNav = 6),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  // ────────────── COMPONENTS ──────────────

  Widget _buildCard(String title, Widget content, {String? actionText, String? action, String? bottomLink, double? height, VoidCallback? onActionTap, VoidCallback? onBottomTap}) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4))]),
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

  Widget _buildKpiCard(String title, String value, String changeText, IconData icon, Color bgColor, Color iconColor, String? subText, {String? suffixText, bool hasStars = false, bool isWarning = false}) {
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
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(value, style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 22, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    if (suffixText != null) Text(suffixText, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 6),
                if (hasStars) 
                  const Row(children: [Icon(Icons.star, color: Color(0xFFF59E0B), size: 14), Icon(Icons.star, color: Color(0xFFF59E0B), size: 14), Icon(Icons.star, color: Color(0xFFF59E0B), size: 14), Icon(Icons.star, color: Color(0xFFF59E0B), size: 14), Icon(Icons.star_half, color: Color(0xFFF59E0B), size: 14)])
                else
                  Text(changeText, style: TextStyle(color: isWarning ? const Color(0xFF64748B) : NexaColors.primaryGreen, fontSize: 12)),
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

  Widget _buildActivityTimeline(IconData icon, Color color, String title, String time, {String? valueText, Color? valueColor, String? subBoldText, bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 14)),
            if (!isLast) Container(width: 1, height: 35, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(vertical: 4))
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: NexaColors.darkNavy)),
              if (subBoldText != null) Text(subBoldText, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
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

  Widget _buildCourseListHeader() {
    return const Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('Cours', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
          Expanded(flex: 2, child: Align(alignment: Alignment.center, child: Text('Apprenants', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)))),
          Expanded(flex: 3, child: Align(alignment: Alignment.center, child: Text('Taux de complétion', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)))),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Revenus', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)))),
        ],
      ),
    );
  }

  Widget _buildCourseRow(IconData icon, Color iconColor, String title, String status, Color statusColor, String learners, double completionRate, String revenue, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(border: !isLast ? const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))) : null),
      child: Row(
        children: [
          Expanded(
            flex: 4, 
            child: Row(
              children: [
                Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: iconColor, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)), child: Text(status, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold))),
                    ],
                  ),
                ),
              ],
            )
          ),
          Expanded(flex: 2, child: Align(alignment: Alignment.center, child: Text(learners, style: const TextStyle(color: Color(0xFF475569), fontSize: 13)))),
          Expanded(
            flex: 3, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: completionRate == 0 ? null : completionRate, backgroundColor: const Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation(NexaColors.primaryGreen), minHeight: 6))),
                const SizedBox(width: 8),
                Text(completionRate == 0 ? '--' : '${(completionRate * 100).toInt()}%', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
              ],
            )
          ),
          Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text(revenue, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy)))),
        ],
      ),
    );
  }

  Widget _buildStudentRow(String name, double progress, String time, {bool isWarningColor = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(radius: 14, backgroundColor: const Color(0xFFE2E8F0), child: Text(name[0], style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 12),
          Expanded(flex: 3, child: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: NexaColors.darkNavy))),
          Expanded(
            flex: 3, 
            child: Row(
              children: [
                Text('${(progress * 100).toInt()}%', style: TextStyle(color: isWarningColor ? const Color(0xFFF59E0B) : NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: const Color(0xFFE2E8F0), valueColor: AlwaysStoppedAnimation(isWarningColor ? const Color(0xFFF59E0B) : NexaColors.primaryGreen), minHeight: 4))),
              ],
            )
          ),
          const SizedBox(width: 12),
          Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {required Color color, Color? bgOverride, VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: bgOverride ?? const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
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
          Expanded(child: Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 11), overflow: TextOverflow.ellipsis)),
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
            spots: const [FlSpot(0, 5), FlSpot(1, 10), FlSpot(2, 16), FlSpot(3, 14), FlSpot(4, 18), FlSpot(5, 24.85)],
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

  Widget _buildCoursePieChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0, centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(color: NexaColors.primaryGreen, value: 40, title: '', radius: 30),
                PieChartSectionData(color: const Color(0xFF3B82F6), value: 25, title: '', radius: 30),
                PieChartSectionData(color: const Color(0xFFF59E0B), value: 15, title: '', radius: 30),
                PieChartSectionData(color: const Color(0xFF8B5CF6), value: 10, title: '', radius: 30),
                PieChartSectionData(color: const Color(0xFF94A3B8), value: 10, title: '', radius: 30),
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

  Widget _buildTrafficPieChart() {
    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 0, centerSpaceRadius: 50,
              sections: [
                PieChartSectionData(color: NexaColors.primaryGreen, value: 45, title: '', radius: 20),
                PieChartSectionData(color: const Color(0xFF3B82F6), value: 25, title: '', radius: 20),
                PieChartSectionData(color: const Color(0xFFF59E0B), value: 15, title: '', radius: 20),
                PieChartSectionData(color: const Color(0xFF8B5CF6), value: 10, title: '', radius: 20),
                PieChartSectionData(color: const Color(0xFF94A3B8), value: 5, title: '', radius: 20),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('2 856', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 18, fontWeight: FontWeight.bold)),
              Text('Inscriptions', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 10)),
            ],
          )
        ],
      ),
    );
  }

  String _getFirstName() {
    final name = widget.userData?['nom_complet'] as String? ?? 'Youssef El Amrani';
    return name.trim().split(' ').first;
  }
}
