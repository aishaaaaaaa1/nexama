import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/chatbot_widget.dart';
import 'login_page.dart';
import 'investisseur/projets_decouvrir.dart';
import 'investisseur/mes_investissements.dart';
import 'investisseur/messages_page.dart';
import 'investisseur/favoris.dart';
import 'investisseur/analyses_rapports.dart';
import 'investisseur/portefeuille.dart';
import 'investisseur/documents.dart';
import 'investisseur/alertes.dart';
import 'investisseur/parametres_page.dart';

import 'shared/premium_upgrade_page.dart';

class InvestisseurDashboard extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const InvestisseurDashboard({super.key, this.userData});

  @override
  State<InvestisseurDashboard> createState() => _InvestisseurDashboardState();
}

class _InvestisseurDashboardState extends State<InvestisseurDashboard> {
  final ScrollController _scrollController = ScrollController();
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFC),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
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
                Text('Discutez avec NexaBot', style: TextStyle(color: Colors.white70, fontSize: 11)),
              ],
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
    return Container(
      width: 250,
      decoration: const BoxDecoration(color: Colors.white, border: Border(right: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', height: 32, errorBuilder: (c, e, s) => const Icon(Icons.error, color: Colors.red)),
                const SizedBox(width: 12),
                RichText(text: TextSpan(children: [
                  TextSpan(text: 'Nexa', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 20, fontWeight: FontWeight.w800)),
                  TextSpan(text: 'Ma', style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 20, fontWeight: FontWeight.w800)),
                ])),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNavItem(0, Icons.trending_up, 'Tableau de bord'),
                  _buildNavItem(1, Icons.explore_outlined, 'Projets à découvrir'),
                  _buildNavItem(2, Icons.star_border_outlined, 'Mes investissements'),
                  _buildNavItem(3, Icons.chat_bubble_outline, 'Messages', badge: '3', badgeColor: NexaColors.primaryGreen),
                  _buildNavItem(4, Icons.favorite_border, 'Favoris'),
                  _buildNavItem(5, Icons.analytics_outlined, 'Analyses & Rapports'),
                  _buildNavItem(6, Icons.account_balance_wallet_outlined, 'Portefeuille'),
                  _buildNavItem(7, Icons.description_outlined, 'Documents'),
                  _buildNavItem(8, Icons.notifications_none_outlined, 'Alertes', badge: '2', badgeColor: Colors.orange),
                  _buildNavItem(9, Icons.settings_outlined, 'Paramètres'),
                  const SizedBox(height: 16),
                  _buildLogoutItem(),
                ],
              ),
            ),
          ),
          // Premium Promo
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF1F8F1), borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Boostez vos\ninvestissements', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 14, fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Accédez à des projets exclusifs et à des analyses avancées.', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11, height: 1.4)),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PremiumUpgradePage(userData: widget.userData)));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NexaColors.primaryGreen,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    child: const Text('Passer au Premium 🚀'),
                  ),
                ),
              ],
            ),
          ),
          // Support User
          const Padding(
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
          children: [
            Icon(icon, size: 20, color: isSelected ? NexaColors.primaryGreen : const Color(0xFF64748B)),
            const SizedBox(width: 12),
            Text(label, style: GoogleFonts.inter(color: isSelected ? NexaColors.primaryGreen : const Color(0xFF475569), fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500)),
            if (badge != null) ...[
              const Spacer(),
              Container(padding: const EdgeInsets.all(5), decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
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
          const Icon(Icons.menu, color: Color(0xFF64748B)),
          const SizedBox(width: 24),
          Container(
            width: 350,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(8)),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Rechercher un projet, entrepreneur...', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)), child: const Text('⌘K', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
              ],
            ),
          ),
          const Spacer(),
          Stack(
            children: [
              const Icon(Icons.notifications_none, color: Color(0xFF64748B), size: 24),
              Positioned(right: 0, top: 0, child: Container(padding: const EdgeInsets.all(3), decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle), child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)))),
            ],
          ),
          const SizedBox(width: 20),
          const Icon(Icons.chat_bubble_outline, color: Color(0xFF64748B), size: 22),
          const SizedBox(width: 24),
          Row(
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
                  Text('Investisseur', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 11)),
                ],
              ),
              const SizedBox(width: 8),
              const Icon(Icons.keyboard_arrow_down, color: Color(0xFF64748B), size: 18),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_selectedNav) {
      case 0:
        return _buildMainContent();
      case 1:
        return ProjetsDecouvrirPage(userData: widget.userData);
      case 2:
        return MesInvestissementsPage(userData: widget.userData);
      case 3:
        return MessagesPage(userData: widget.userData);
      case 4:
        return FavorisPage(userData: widget.userData);
      case 5:
        return AnalysesRapportsPage(userData: widget.userData);
      case 6:
        return PortefeuillePage(userData: widget.userData);
      case 7:
        return DocumentsPage(userData: widget.userData);
      case 8:
        return AlertesPage(userData: widget.userData);
      case 9:
        return ParametresPage(userData: widget.userData);
      default:
        return _buildMainContent();
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
                Text('Bonjour, ${_getFirstName()} 👋', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 26, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('Voici un aperçu de votre activité d\'investissement.', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 14)),
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
            Expanded(child: _buildKpiCard('Projets évalués', '24', '+ 20%', Icons.trending_up, const Color(0xFFE8F5E9), NexaColors.primaryGreen, "vs avril 2024")),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Projets intéressants', '8', '+ 14%', Icons.star_border, const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), "vs avril 2024")),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('En discussion', '5', '+ 25%', Icons.chat_bubble_outline, const Color(0xFFEFF6FF), const Color(0xFF3B82F6), "vs avril 2024")),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Investis', '3', '2,450,000 MAD', Icons.account_balance_wallet_outlined, const Color(0xFFFFF7ED), const Color(0xFFF59E0B), null, isValueSecondary: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Portefeuille total', '5,750,000 MAD', '+ 18.5%', Icons.pie_chart_outline, const Color(0xFFE8F5E9), NexaColors.primaryGreen, "vs avril 2024", bigValue: true)),
            const SizedBox(width: 16),
            Expanded(child: _buildKpiCard('Rendement global', '+12.7%', 'Très bon', Icons.shield_outlined, const Color(0xFFE8F5E9), const Color(0xFF3B82F6), null, isSuccessText: true, showSparkline: true)),
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
              child: _buildCard('Évolution de votre portefeuille', SizedBox(height: 250, child: _buildLineChart()), action: '6 derniers mois', height: 340),
            ),
            const SizedBox(width: 16),
            // Donut Chart
            Expanded(
              flex: 4,
              child: _buildCard('Répartition par secteur', 
                  Row(
                    children: [
                      Expanded(flex: 3, child: _buildPieChart()),
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(NexaColors.primaryGreen, 'Fintech', '30%'),
                            _buildLegendItem(const Color(0xFF3B82F6), 'AgriTech', '25%'),
                            _buildLegendItem(const Color(0xFFF59E0B), 'E-commerce', '20%'),
                            _buildLegendItem(const Color(0xFF8B5CF6), 'SaaS', '15%'),
                            _buildLegendItem(const Color(0xFF94A3B8), 'Autres', '10%'),
                          ],
                        ),
                      )
                    ],
                  ),
                bottomLink: 'Voir le détail →', height: 340
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
                      _buildActivityTimeline(Icons.auto_awesome, const Color(0xFF10B981), 'Nouveau projet correspond à vos critères\nGreenTech Solutions', 'Il y a 1 heure', dotColor: const Color(0xFF10B981)),
                      _buildActivityTimeline(Icons.person, const Color(0xFF3B82F6), 'Mise à jour du projet\nAgriSmart', 'Il y a 3 heures', dotColor: const Color(0xFF3B82F6)),
                      _buildActivityTimeline(Icons.account_balance_wallet, const Color(0xFFF59E0B), 'Réponse entrepreneur\nBuildMorocco', 'Il y a 5 heures', dotColor: const Color(0xFFF59E0B)),
                      _buildActivityTimeline(Icons.chat_bubble, const Color(0xFF8B5CF6), 'Nouveau message\nEduConnect', 'Il y a 6 heures', dotColor: const Color(0xFF8B5CF6), isLast: true),
                    ]
                  ),
                ),
                actionText: 'Tout voir', height: 340
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ROW 3: Filters (Découvrir des projets)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            children: [
              Text('Découvrir des projets', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              const SizedBox(width: 32),
              _buildFilterDropdown('Secteur', 'Tous les secteurs'),
              const SizedBox(width: 16),
              _buildFilterDropdown('Région', 'Toutes les régions'),
              const SizedBox(width: 16),
              _buildFilterDropdown('Stade', 'Tous les stades'),
              const SizedBox(width: 16),
              _buildFilterDropdown('Montant recherché', 'Tous les montants'),
              const SizedBox(width: 16),
              _buildFilterDropdown('TRUST SCORE', 'Min. 60'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE2E8F0)), borderRadius: BorderRadius.circular(8)),
                child: const Row(
                  children: [
                    Icon(Icons.filter_list, size: 16, color: Color(0xFF475569)),
                    SizedBox(width: 8),
                    Text('Plus de filtres', style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 24),

        // ROW 4: Projets recommandés, Pipeline, Geo
        Row(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Expanded(
               flex: 6,
               child: _buildCard('Projets recommandés pour vous', 
                 Column(
                   children: [
                     _buildProjectRow('GreenTech Solutions', 'Fintech', 'Plateforme de gestion ESG pour entreprises', Icons.grid_view_rounded, NexaColors.primaryGreen, 'Casablanca', 'Croissance', '1M - 2M MAD', 85),
                     _buildProjectRow('AgriSmart', 'AgriTech', 'Solutions IoT pour l\'agriculture intelligente', Icons.eco_outlined, const Color(0xFF3B82F6), 'Marrakech', 'Amorçage', '500K - 1M MAD', 78),
                     _buildProjectRow('BuildMorocco', 'SaaS', 'Logiciel collaboratif pour le BTP', Icons.domain, const Color(0xFF3B82F6), 'Rabat', 'Expansion', '2M - 5M MAD', 92),
                     _buildProjectRow('EduConnect', 'EdTech', 'Plateforme e-learning pour les écoles', Icons.school_outlined, const Color(0xFF8B5CF6), 'Fès', 'Croissance', '1M - 3M MAD', 70, isLast: true),
                   ]
                 ),
                 actionText: 'Voir tout',
                 onActionTap: () => setState(() => _selectedNav = 1),
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               flex: 3,
               child: _buildCard('Votre pipeline d\'investissement', 
                 Column(
                   children: [
                     _buildPipelineRow(Icons.visibility_outlined, 'Vu', '12 projets', '+3', NexaColors.primaryGreen),
                     _buildPipelineRow(Icons.star_border, 'Intéressé', '8 projets', '+2', NexaColors.primaryGreen),
                     _buildPipelineRow(Icons.chat_bubble_outline, 'En discussion', '5 projets', '+1', const Color(0xFF3B82F6)),
                     _buildPipelineRow(Icons.description_outlined, 'En due diligence', '2 projets', '-', const Color(0xFF64748B)),
                     _buildPipelineRow(Icons.check_circle_outline, 'Investi', '3 projets', '-', NexaColors.primaryGreen),
                     _buildPipelineRow(Icons.outlined_flag, 'Clôturé', '2 projets', '-', const Color(0xFF64748B)),
                   ]
                 ),
                 actionText: 'Voir tout',
                 onActionTap: () => setState(() => _selectedNav = 2),
               ),
             ),
             const SizedBox(width: 16),
             Expanded(
               flex: 3,
               child: _buildCard('Répartition géographique', 
                 Row(
                   children: [
                     Expanded(flex: 7, child: Container(
                       margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                       decoration: BoxDecoration(
                         color: NexaColors.primaryGreen.withValues(alpha: 0.05),
                         borderRadius: BorderRadius.circular(8),
                       ),
                       child: Stack(
                         alignment: Alignment.center,
                         children: [
                           Icon(Icons.map_outlined, size: 80, color: NexaColors.primaryGreen.withValues(alpha: 0.3)),
                           Positioned(top: 80, right: 60, child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: NexaColors.primaryGreen, shape: BoxShape.circle))),
                           Positioned(top: 110, right: 80, child: Container(width: 6, height: 6, decoration: BoxDecoration(color: NexaColors.primaryGreen.withValues(alpha:0.7), shape: BoxShape.circle))),
                           Positioned(top: 140, right: 90, child: Container(width: 5, height: 5, decoration: BoxDecoration(color: NexaColors.primaryGreen.withValues(alpha:0.5), shape: BoxShape.circle))),
                         ]
                       )
                     )),
                     Expanded(
                       flex: 5,
                       child: Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           _buildLegendItem(NexaColors.primaryGreen, 'Casablanca', '35%'),
                           _buildLegendItem(NexaColors.primaryGreen.withValues(alpha: 0.7), 'Rabat', '20%'),
                           _buildLegendItem(NexaColors.primaryGreen.withValues(alpha: 0.5), 'Marrakech', '15%'),
                           _buildLegendItem(NexaColors.primaryGreen.withValues(alpha: 0.3), 'Fès', '10%'),
                           _buildLegendItem(const Color(0xFFCBD5E1), 'Autres', '20%'),
                         ],
                       ),
                     )
                   ],
                 ),
               ),
             ),
           ],
        ),
        const SizedBox(height: 24),

        // ROW 5: Actions rapides
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Row(
            children: [
              Text('Actions rapides', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              const SizedBox(width: 32),
              _buildActionButton(Icons.search, 'Rechercher un projet', onTap: () => setState(() => _selectedNav = 1)),
              const SizedBox(width: 16),
              _buildActionButton(Icons.track_changes, 'Mes critères d\'investissement', onTap: () => setState(() => _selectedNav = 9)),
              const SizedBox(width: 16),
              _buildActionButton(Icons.folder_outlined, 'Mes documents', onTap: () => setState(() => _selectedNav = 7)),
              const SizedBox(width: 16),
              _buildActionButton(Icons.analytics_outlined, 'Analyse de marché', onTap: () => setState(() => _selectedNav = 5)),
              const Spacer(),
              _buildActionButton(Icons.calculate_outlined, 'Simulation d\'investissement', onTap: () => setState(() => _selectedNav = 5)),
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

  Widget _buildKpiCard(String title, String value, String change, IconData icon, Color bgColor, Color iconColor, String? subText, {bool isValueSecondary = false, bool isSuccessText = false, bool showSparkline = false, bool bigValue = false}) {
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
                Text(title, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Text(value, style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: bigValue ? 20 : 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                if (showSparkline) ...[
                  Text(change, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 20, width: double.infinity,
                    child: LineChart(LineChartData(
                      gridData: FlGridData(show: false), titlesData: FlTitlesData(show: false), borderData: FlBorderData(show: false),
                      minX: 0, maxX: 4, minY: 0, maxY: 10,
                      lineBarsData: [LineChartBarData(spots: const [FlSpot(0, 2), FlSpot(1, 4), FlSpot(2, 3), FlSpot(3, 7), FlSpot(4, 9)], isCurved: true, color: NexaColors.primaryGreen, barWidth: 2, dotData: FlDotData(show: false))]
                    )),
                  )
                ] else ...[
                  if (isValueSecondary)
                    Text(change, style: TextStyle(color: const Color(0xFFF59E0B), fontSize: 13, fontWeight: FontWeight.w700))
                  else
                    Row(
                      children: [
                        Icon(Icons.arrow_upward, size: 14, color: NexaColors.primaryGreen),
                        const SizedBox(width: 4),
                        Text(change, style: TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  if (subText != null) ...[
                    const SizedBox(height: 4),
                    Text(subText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                  ]
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(value, style: const TextStyle(color: NexaColors.darkNavy, fontSize: 13, fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down, size: 16, color: Color(0xFF94A3B8)),
          ],
        )
      ],
    );
  }

  Widget _buildProjectRow(String title, String badge, String subtitle, IconData icon, Color color, String city, String stade, String montant, int score, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(border: !isLast ? const Border(bottom: BorderSide(color: Color(0xFFE2E8F0))) : null),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: NexaColors.darkNavy)),
                    const SizedBox(width: 8),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(4)), child: Text(badge, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          Expanded(flex: 1, child: Row(children: [const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)), const SizedBox(width: 4), Text(city, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))])),
          Expanded(flex: 1, child: Text(stade, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12))),
          Expanded(flex: 1, child: Text(montant, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: NexaColors.darkNavy))),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: score >= 80 ? NexaColors.primaryGreen : (score >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)), width: 2)),
            child: Text(score.toString(), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: score >= 80 ? NexaColors.primaryGreen : (score >= 70 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444)))),
          ),
          const SizedBox(width: 16),
          Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)), child: const Text('Voir le projet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600))),
          const SizedBox(width: 8),
          const Icon(Icons.bookmark_border, color: Color(0xFF94A3B8), size: 20),
        ],
      ),
    );
  }

  Widget _buildPipelineRow(IconData icon, String label, String value, String diff, Color diffColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: diffColor),
          const SizedBox(width: 12),
          Expanded(child: Text(label, style: TextStyle(color: NexaColors.darkNavy, fontSize: 13, fontWeight: diffColor == NexaColors.primaryGreen || diffColor == const Color(0xFF3B82F6) ? FontWeight.w600 : FontWeight.normal))),
          Text(value, style: const TextStyle(fontSize: 13, color: Color(0xFF475569))),
          const Spacer(),
          Text(diff, style: TextStyle(color: diffColor, fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: const Color(0xFF475569)),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTimeline(IconData icon, Color color, String title, String time, {bool isLast = false, Color? dotColor}) {
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
              const SizedBox(height: 2),
              Text(time, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
            ],
          ),
        ),
        if (dotColor != null)
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
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
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 40, getTitlesWidget: (value, meta) => Text('${value.toInt()}M', style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)))),
        ),
        borderData: FlBorderData(show: false), minX: 0, maxX: 5, minY: 0, maxY: 6,
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 1), FlSpot(1, 2.5), FlSpot(2, 2.8), FlSpot(3, 3.8), FlSpot(4, 4.5), FlSpot(5, 5.75)],
            isCurved: false, color: NexaColors.primaryGreen, barWidth: 3,
            dotData: FlDotData(show: true, getDotPainter: (spot, percent, barData, index) => index == 5 ? FlDotCirclePainter(radius: 6, color: NexaColors.primaryGreen, strokeWidth: 2, strokeColor: Colors.white) : FlDotCirclePainter(radius: 4, color: NexaColors.primaryGreen, strokeWidth: 2, strokeColor: Colors.white)),
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [NexaColors.primaryGreen.withValues(alpha: 0.2), NexaColors.primaryGreen.withValues(alpha: 0.0)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
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
            sectionsSpace: 0, centerSpaceRadius: 60,
            sections: [
              PieChartSectionData(color: NexaColors.primaryGreen, value: 30, title: '', radius: 30),
              PieChartSectionData(color: const Color(0xFF3B82F6), value: 25, title: '', radius: 30),
              PieChartSectionData(color: const Color(0xFFF59E0B), value: 20, title: '', radius: 30),
              PieChartSectionData(color: const Color(0xFF8B5CF6), value: 15, title: '', radius: 30),
              PieChartSectionData(color: const Color(0xFF94A3B8), value: 10, title: '', radius: 30),
            ],
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('5,750,000', style: GoogleFonts.inter(color: NexaColors.darkNavy, fontSize: 18, fontWeight: FontWeight.bold)),
            Text('MAD', style: GoogleFonts.inter(color: const Color(0xFF64748B), fontSize: 12)),
          ],
        )
      ],
    );
  }

  String _getFirstName() {
    final name = widget.userData?['nom_complet'] as String? ?? 'Yassine El Amrani';
    return name.trim().split(' ').first;
  }
}
