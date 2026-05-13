import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

enum _ClientStatutCRM { actif, prospect, premium }

class _ClientCRM {
  _ClientCRM({
    required this.id,
    required this.nom,
    required this.entreprise,
    required this.role,
    required this.ville,
    required this.email,
    required this.telephone,
    required this.secteur,
    required this.statut,
    required this.note,
    required this.nbProjets,
    required this.totalDepensesDh,
    required this.initials,
    required this.avatarColor,
    required this.dateAjout,
    required this.online,
    required this.verifie,
    required this.adresse,
    required this.siteWeb,
    required this.projetsTermines,
    required this.projetsEnCours,
    required this.montantProjetsDh,
    required this.nbFactures,
    required this.nbDevis,
    required this.paiementsRecusDh,
    required this.remarquesInternes,
    required this.preferences,
    required this.documents,
  });

  final String id;
  final String nom;
  final String entreprise;
  final String role;
  final String ville;
  final String email;
  final String telephone;
  final String secteur;
  final _ClientStatutCRM statut;
  final double note;
  final int nbProjets;
  final double totalDepensesDh;
  final String initials;
  final Color avatarColor;
  final DateTime dateAjout;
  final bool online;
  final bool verifie;
  final String adresse;
  final String siteWeb;
  final int projetsTermines;
  final int projetsEnCours;
  final double montantProjetsDh;
  final int nbFactures;
  final int nbDevis;
  final double paiementsRecusDh;
  final String remarquesInternes;
  final String preferences;
  final List<String> documents;

  bool get isPremium => statut == _ClientStatutCRM.premium;
}

class _TimelineCRM {
  const _TimelineCRM({required this.icon, required this.color, required this.title, required this.subtitle});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

/// Section « Mes clients » — CRM prestataire NexaMa.
class MesClientsPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const MesClientsPrestatairePage({super.key, this.userData});

  @override
  State<MesClientsPrestatairePage> createState() => _MesClientsPrestatairePageState();
}

class _MesClientsPrestatairePageState extends State<MesClientsPrestatairePage> with SingleTickerProviderStateMixin {
  static const _border = Color(0xFFE8ECF2);
  static const _muted = Color(0xFF64748B);
  static const _surface = Color(0xFFF8FAFC);

  final _searchCtrl = TextEditingController();
  late List<_ClientCRM> _clients;
  String _ville = 'Toutes';
  String _secteur = 'Tous';
  _ClientStatutCRM? _statutFiltre;
  String _budget = 'Tous';
  late AnimationController _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 850))..forward();
    _clients = _seedClients();
  }

  List<_ClientCRM> _seedClients() {
    return [
      _ClientCRM(
        id: 'c1',
        nom: 'Ahmed Benali',
        entreprise: 'Ahmed Startup',
        role: 'CEO — EcomTech',
        ville: 'Casablanca',
        email: 'ahmed@ecomtech.ma',
        telephone: '+212 6 11 22 33 44',
        secteur: 'E-commerce',
        statut: _ClientStatutCRM.actif,
        note: 4.9,
        nbProjets: 6,
        totalDepensesDh: 32000,
        initials: 'AB',
        avatarColor: const Color(0xFF1565C0),
        dateAjout: DateTime(2024, 11, 3),
        online: true,
        verifie: true,
        adresse: 'Boulevard Zerktouni, Casablanca',
        siteWeb: 'https://ecomtech.ma',
        projetsTermines: 5,
        projetsEnCours: 1,
        montantProjetsDh: 45000,
        nbFactures: 8,
        nbDevis: 12,
        paiementsRecusDh: 28500,
        remarquesInternes: 'Priorité aux livrables avant le 15 de chaque mois. Contact préféré : matin.',
        preferences: 'Communication WhatsApp + e-mail récap hebdo.',
        documents: const ['contrat_prestation_2024.pdf', 'cahier_des_charges_v2.pdf', 'annexe_securite.pdf'],
      ),
      _ClientCRM(
        id: 'c2',
        nom: 'Sara El Amrani',
        entreprise: 'Sara Digital',
        role: 'Agence marketing',
        ville: 'Rabat',
        email: 'contact@saradigital.ma',
        telephone: '+212 6 55 66 77 88',
        secteur: 'Marketing',
        statut: _ClientStatutCRM.premium,
        note: 4.8,
        nbProjets: 3,
        totalDepensesDh: 18500,
        initials: 'SD',
        avatarColor: const Color(0xFF7B1FA2),
        dateAjout: DateTime(2025, 1, 12),
        online: false,
        verifie: true,
        adresse: 'Avenue Allal Ben Abdellah, Rabat',
        siteWeb: 'https://saradigital.ma',
        projetsTermines: 2,
        projetsEnCours: 1,
        montantProjetsDh: 22000,
        nbFactures: 4,
        nbDevis: 6,
        paiementsRecusDh: 16200,
        remarquesInternes: 'Client premium — accès prioritaire support.',
        preferences: 'Réunions en visio, mercredis après-midi.',
        documents: const ['contrat_cadre.pdf', 'brand_guidelines.pdf'],
      ),
      _ClientCRM(
        id: 'c3',
        nom: 'Youssef Tazi',
        entreprise: 'Youssef Market',
        role: 'Startup FoodTech',
        ville: 'Marrakech',
        email: 'youssef@youssefmarket.com',
        telephone: '+212 6 99 00 11 22',
        secteur: 'FoodTech',
        statut: _ClientStatutCRM.actif,
        note: 5.0,
        nbProjets: 10,
        totalDepensesDh: 78000,
        initials: 'YT',
        avatarColor: const Color(0xFF00897B),
        dateAjout: DateTime(2024, 6, 20),
        online: true,
        verifie: true,
        adresse: 'Zone industrielle Sidi Ghanem, Marrakech',
        siteWeb: 'https://youssefmarket.com',
        projetsTermines: 8,
        projetsEnCours: 2,
        montantProjetsDh: 95000,
        nbFactures: 14,
        nbDevis: 18,
        paiementsRecusDh: 71200,
        remarquesInternes: 'Roadmap mobile Q3 validée. Sensibilité aux délais logistiques.',
        preferences: 'Slack + e-mail pour les décisions.',
        documents: const ['nda_signed.pdf', 'cahier_fonctionnel.pdf', 'api_specs.pdf'],
      ),
      _ClientCRM(
        id: 'c4',
        nom: 'Karim Idrissi',
        entreprise: 'Atlas Logistique',
        role: 'DSI',
        ville: 'Casablanca',
        email: 'k.idrissi@atlaslog.ma',
        telephone: '+212 5 22 11 00 99',
        secteur: 'Logistique',
        statut: _ClientStatutCRM.prospect,
        note: 4.5,
        nbProjets: 1,
        totalDepensesDh: 4200,
        initials: 'KI',
        avatarColor: const Color(0xFF5C6BC0),
        dateAjout: DateTime(2025, 4, 2),
        online: false,
        verifie: false,
        adresse: 'Ain Sebaa, Casablanca',
        siteWeb: 'https://atlaslog.ma',
        projetsTermines: 0,
        projetsEnCours: 1,
        montantProjetsDh: 12000,
        nbFactures: 1,
        nbDevis: 3,
        paiementsRecusDh: 4200,
        remarquesInternes: 'Prospect chaud — relance devis semaine prochaine.',
        preferences: 'Appels téléphoniques plutôt que messages.',
        documents: const ['proposition_technique.pdf'],
      ),
    ];
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(m, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 88),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String _fmtDh(double v) {
    final s = v.round().abs().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  List<_ClientCRM> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _clients.where((c) {
      if (q.isNotEmpty && !'${c.nom} ${c.entreprise} ${c.email} ${c.secteur}'.toLowerCase().contains(q)) return false;
      if (_ville != 'Toutes' && c.ville != _ville) return false;
      if (_secteur != 'Tous' && c.secteur != _secteur) return false;
      if (_statutFiltre != null && c.statut != _statutFiltre) return false;
      if (_budget != 'Tous') {
        final t = c.totalDepensesDh;
        if (_budget == '< 10k DH' && t >= 10000) return false;
        if (_budget == '10k – 30k DH' && (t < 10000 || t > 30000)) return false;
        if (_budget == '> 30k DH' && t <= 30000) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 960;
        final cols = c.maxWidth >= 1200 ? 3 : (c.maxWidth >= 720 ? 2 : 1);
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                opacity: CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(_headerAnim),
                  child: _buildHeader(wide),
                ),
              ),
              const SizedBox(height: 22),
              _buildStats(wide),
              const SizedBox(height: 20),
              _buildRelationChart(wide),
              const SizedBox(height: 20),
              _buildFilters(wide),
              const SizedBox(height: 20),
              _buildClientGrid(cols),
              const SizedBox(height: 24),
              _buildActivity(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool wide) {
    Widget addBtn = FilledButton.icon(
      onPressed: _sheetAjouterClient,
      style: FilledButton.styleFrom(
        backgroundColor: NexaColors.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      icon: const Icon(Icons.person_add_alt_1_outlined, size: 20),
      label: Text('Ajouter un client', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
    );
    Widget excelBtn = OutlinedButton.icon(
      onPressed: () => _toast('Export Excel — fichier généré'),
      style: OutlinedButton.styleFrom(
        foregroundColor: NexaColors.darkNavy,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.table_chart_outlined, size: 20),
      label: Text('Export Excel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    );
    Widget filtreBtn = OutlinedButton.icon(
      onPressed: _dialogFiltresAvances,
      style: OutlinedButton.styleFrom(
        foregroundColor: NexaColors.darkNavy,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.tune_rounded, size: 20),
      label: Text('Filtrer', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    );

    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes Clients', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: NexaColors.darkNavy, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text(
          'Gérez vos relations clients, projets et interactions.',
          style: GoogleFonts.inter(fontSize: 14.5, color: _muted, height: 1.4, fontWeight: FontWeight.w500),
        ),
      ],
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: title),
          addBtn,
          const SizedBox(width: 10),
          excelBtn,
          const SizedBox(width: 8),
          filtreBtn,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        title,
        const SizedBox(height: 14),
        Wrap(spacing: 8, runSpacing: 10, children: [addBtn, excelBtn, filtreBtn]),
      ],
    );
  }

  Widget _buildStats(bool wide) {
    Widget card(String label, String value, IconData icon, Color ac, int seed) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 550 + seed * 80),
        curve: Curves.easeOutCubic,
        builder: (context, t, ch) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: ch)),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: NexaShadows.card),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(color: ac.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: ac, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: _muted, fontWeight: FontWeight.w600)),
                    Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
                  ],
                ),
              ),
              _miniSpark(seed),
            ],
          ),
        ),
      );
    }

    final row = [
      card('Clients actifs', '48', Icons.groups_2_outlined, const Color(0xFF1565C0), 0),
      card('Nouveaux clients', '12', Icons.person_add_alt_outlined, NexaColors.primaryGreen, 1),
      card('Clients premium', '8', Icons.workspace_premium_outlined, const Color(0xFFF59E0B), 2),
      card('Taux satisfaction', '96%', Icons.sentiment_satisfied_alt_outlined, const Color(0xFF00897B), 3),
    ];
    if (!wide) {
      return Column(children: [for (var i = 0; i < row.length; i++) ...[if (i > 0) const SizedBox(height: 12), row[i]]]);
    }
    return Row(children: [for (var i = 0; i < row.length; i++) ...[if (i > 0) const SizedBox(width: 14), Expanded(child: row[i])]]);
  }

  Widget _miniSpark(int seed) {
    final rnd = math.Random(seed);
    final spots = List.generate(7, (i) => FlSpot(i.toDouble(), 0.35 + rnd.nextDouble() * 0.6));
    return SizedBox(
      height: 40,
      width: 72,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              color: NexaColors.primaryGreen.withValues(alpha: 0.75),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [NexaColors.primaryGreen.withValues(alpha: 0.18), NexaColors.primaryGreen.withValues(alpha: 0.02)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelationChart(bool wide) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: NexaShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.hub_outlined, color: NexaColors.primaryGreen.withValues(alpha: 0.9), size: 22),
              const SizedBox(width: 8),
              Text('Relation client — engagement', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Interactions cumulées (12 derniers mois)', style: GoogleFonts.inter(fontSize: 12, color: _muted)),
          SizedBox(
            height: wide ? 140 : 120,
            child: LineChart(
              LineChartData(
                minY: 0,
                maxY: 100,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (_) => FlLine(color: _border, strokeWidth: 1)),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 25, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: GoogleFonts.inter(fontSize: 9, color: _muted)))),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        const mois = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                        final i = v.toInt();
                        if (i < 0 || i >= mois.length) return const SizedBox.shrink();
                        return Padding(padding: const EdgeInsets.only(top: 6), child: Text(mois[i], style: GoogleFonts.inter(fontSize: 10, color: _muted, fontWeight: FontWeight.w600)));
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 22),
                      FlSpot(1, 28),
                      FlSpot(2, 35),
                      FlSpot(3, 42),
                      FlSpot(4, 48),
                      FlSpot(5, 55),
                      FlSpot(6, 62),
                      FlSpot(7, 58),
                      FlSpot(8, 70),
                      FlSpot(9, 78),
                      FlSpot(10, 85),
                      FlSpot(11, 92),
                    ],
                    isCurved: true,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    color: NexaColors.darkNavy.withValues(alpha: 0.85),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [NexaColors.darkNavy.withValues(alpha: 0.12), NexaColors.darkNavy.withValues(alpha: 0.02)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 15),
                      FlSpot(1, 22),
                      FlSpot(2, 30),
                      FlSpot(3, 38),
                      FlSpot(4, 45),
                      FlSpot(5, 52),
                      FlSpot(6, 60),
                      FlSpot(7, 55),
                      FlSpot(8, 68),
                      FlSpot(9, 72),
                      FlSpot(10, 80),
                      FlSpot(11, 88),
                    ],
                    isCurved: true,
                    barWidth: 2.5,
                    dotData: const FlDotData(show: false),
                    color: NexaColors.primaryGreen,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters(bool wide) {
    final search = TextField(
      controller: _searchCtrl,
      onChanged: (_) => setState(() {}),
      decoration: _inputDec('Recherche client…', Icons.search_rounded),
    );
    final ville = DropdownButtonFormField<String>(
      value: _ville,
      decoration: _inputDec('Ville', Icons.location_on_outlined),
      items: const [
        DropdownMenuItem(value: 'Toutes', child: Text('Toutes les villes')),
        DropdownMenuItem(value: 'Casablanca', child: Text('Casablanca')),
        DropdownMenuItem(value: 'Rabat', child: Text('Rabat')),
        DropdownMenuItem(value: 'Marrakech', child: Text('Marrakech')),
      ],
      onChanged: (v) => setState(() => _ville = v ?? 'Toutes'),
    );
    final secteur = DropdownButtonFormField<String>(
      value: _secteur,
      decoration: _inputDec('Secteur', Icons.category_outlined),
      items: const [
        DropdownMenuItem(value: 'Tous', child: Text('Tous secteurs')),
        DropdownMenuItem(value: 'E-commerce', child: Text('E-commerce')),
        DropdownMenuItem(value: 'Marketing', child: Text('Marketing')),
        DropdownMenuItem(value: 'FoodTech', child: Text('FoodTech')),
        DropdownMenuItem(value: 'Logistique', child: Text('Logistique')),
      ],
      onChanged: (v) => setState(() => _secteur = v ?? 'Tous'),
    );
    final statut = DropdownButtonFormField<_ClientStatutCRM?>(
      value: _statutFiltre,
      decoration: _inputDec('Statut', Icons.flag_outlined),
      items: const [
        DropdownMenuItem(value: null, child: Text('Tous statuts')),
        DropdownMenuItem(value: _ClientStatutCRM.actif, child: Text('Actif')),
        DropdownMenuItem(value: _ClientStatutCRM.prospect, child: Text('Prospect')),
        DropdownMenuItem(value: _ClientStatutCRM.premium, child: Text('Premium')),
      ],
      onChanged: (v) => setState(() => _statutFiltre = v),
    );
    final budget = DropdownButtonFormField<String>(
      value: _budget,
      decoration: _inputDec('Budget', Icons.payments_outlined),
      items: const [
        DropdownMenuItem(value: 'Tous', child: Text('Tous budgets')),
        DropdownMenuItem(value: '< 10k DH', child: Text('< 10 000 DH')),
        DropdownMenuItem(value: '10k – 30k DH', child: Text('10k – 30k DH')),
        DropdownMenuItem(value: '> 30k DH', child: Text('> 30 000 DH')),
      ],
      onChanged: (v) => setState(() => _budget = v ?? 'Tous'),
    );

    if (wide) {
      return Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: NexaShadows.card),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(flex: 2, child: search),
            const SizedBox(width: 10),
            Expanded(child: ville),
            const SizedBox(width: 10),
            Expanded(child: secteur),
            const SizedBox(width: 10),
            Expanded(child: statut),
            const SizedBox(width: 10),
            Expanded(child: budget),
            const SizedBox(width: 8),
            FilledButton.tonalIcon(
              onPressed: () => _toast('Filtre date d’ajout'),
              icon: const Icon(Icons.event_outlined, size: 20),
              label: Text('Date ajout', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 6),
            OutlinedButton.icon(onPressed: _dialogFiltresAvances, icon: const Icon(Icons.filter_list_rounded), label: Text('Avancés', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: NexaShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: 10),
          ville,
          const SizedBox(height: 10),
          secteur,
          const SizedBox(height: 10),
          statut,
          const SizedBox(height: 10),
          budget,
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              FilledButton.tonalIcon(onPressed: () => _toast('Date d’ajout'), icon: const Icon(Icons.event_outlined), label: const Text('Date ajout')),
              OutlinedButton.icon(onPressed: _dialogFiltresAvances, icon: const Icon(Icons.filter_list_rounded), label: const Text('Avancés')),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: NexaColors.primaryGreen.withValues(alpha: 0.55), width: 1.3)),
    );
  }

  Widget _buildClientGrid(int cols) {
    final list = _filtered;
    if (list.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border)),
        child: Center(child: Text('Aucun client ne correspond aux filtres.', style: GoogleFonts.inter(color: _muted))),
      );
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: cols == 1 ? 0.88 : (cols == 2 ? 0.82 : 0.75),
      ),
      itemCount: list.length,
      itemBuilder: (context, i) => _clientCard(list[i], i),
    );
  }

  Widget _clientCard(_ClientCRM c, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, t, ch) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: ch)),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: NexaShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: c.avatarColor,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: c.avatarColor.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3))],
                      ),
                      child: Text(c.initials, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                    ),
                    if (c.online)
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(color: const Color(0xFF22C55E), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(child: Text(c.nom, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: NexaColors.darkNavy))),
                          if (c.verifie) ...[const SizedBox(width: 4), Icon(Icons.verified_rounded, size: 18, color: NexaColors.primaryGreen)],
                          if (c.isPremium) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [const Color(0xFFFFD54F).withValues(alpha: 0.9), const Color(0xFFFFA000).withValues(alpha: 0.85)]),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text('PREMIUM', style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w900, color: const Color(0xFF5D4037))),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(c.entreprise, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                      Text(c.role, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 11.5, color: _muted)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(children: [const Icon(Icons.place_outlined, size: 15, color: _muted), const SizedBox(width: 4), Expanded(child: Text('${c.ville}, Maroc', style: GoogleFonts.inter(fontSize: 12.5, color: _muted)))]),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.email_outlined, size: 15, color: _muted), const SizedBox(width: 4), Expanded(child: Text(c.email, maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569))))]),
            const SizedBox(height: 4),
            Row(children: [const Icon(Icons.phone_outlined, size: 15, color: _muted), const SizedBox(width: 4), Text(c.telephone, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF475569)))]),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _chip(c.secteur, const Color(0xFFE8EAF6), NexaColors.darkNavy),
                _chip(_labelStatut(c.statut), _statutColor(c.statut).withValues(alpha: 0.15), _statutColor(c.statut)),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.star_rounded, color: NexaColors.starGold, size: 20),
                Text(' ${c.note.toStringAsFixed(1)}', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15)),
                const Spacer(),
                Text('${c.nbProjets} projets', style: GoogleFonts.inter(fontSize: 12, color: _muted, fontWeight: FontWeight.w600)),
              ],
            ),
            if (c.totalDepensesDh > 0) ...[
              const SizedBox(height: 4),
              Text('${_fmtDh(c.totalDepensesDh)} DH dépensés', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700, color: NexaColors.primaryGreen)),
            ],
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(onPressed: () => _openProfil(c), style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy, side: const BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)), child: Text('Voir profil', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12))),
                FilledButton.tonal(onPressed: () => _toast('Message à ${c.nom}'), style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE8F5E9)), child: Text('Message', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12))),
                TextButton(onPressed: () => _toast('Nouveau devis pour ${c.entreprise}'), child: Text('Nouveau devis', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: NexaColors.primaryGreen))),
                TextButton(onPressed: () => _toast('Projets de ${c.entreprise}'), child: Text('Voir projets', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12, color: NexaColors.darkNavy))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _labelStatut(_ClientStatutCRM s) {
    return switch (s) {
      _ClientStatutCRM.actif => 'Actif',
      _ClientStatutCRM.prospect => 'Prospect',
      _ClientStatutCRM.premium => 'Premium',
    };
  }

  Color _statutColor(_ClientStatutCRM s) {
    return switch (s) {
      _ClientStatutCRM.actif => NexaColors.primaryGreen,
      _ClientStatutCRM.prospect => const Color(0xFF64748B),
      _ClientStatutCRM.premium => const Color(0xFFB45309),
    };
  }

  Widget _chip(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(text, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: fg)),
    );
  }

  void _openProfil(_ClientCRM c) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
          child: _ClientProfilSheet(client: c, onClose: () => Navigator.pop(ctx)),
        ),
      ),
    );
  }

  void _sheetAjouterClient() {
    final nom = TextEditingController();
    final ent = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Ajouter un client', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(controller: nom, decoration: _inputDec('Nom complet', Icons.person_outline)),
                const SizedBox(height: 10),
                TextField(controller: ent, decoration: _inputDec('Entreprise', Icons.business_outlined)),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {
                    if (nom.text.isEmpty || ent.text.isEmpty) {
                      _toast('Remplissez nom et entreprise');
                      return;
                    }
                    final id = 'c${DateTime.now().millisecondsSinceEpoch}';
                    setState(() {
                      _clients.insert(
                        0,
                        _ClientCRM(
                          id: id,
                          nom: nom.text,
                          entreprise: ent.text,
                          role: 'Contact',
                          ville: 'Casablanca',
                          email: 'contact@${ent.text.toLowerCase().replaceAll(' ', '')}.ma',
                          telephone: '+212 6 00 00 00 00',
                          secteur: 'Général',
                          statut: _ClientStatutCRM.prospect,
                          note: 0,
                          nbProjets: 0,
                          totalDepensesDh: 0,
                          initials: nom.text.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join().toUpperCase(),
                          avatarColor: Color.fromARGB(255, 40 + nom.text.hashCode % 100, 100 + ent.text.hashCode % 80, 150 + nom.text.hashCode % 70),
                          dateAjout: DateTime.now(),
                          online: false,
                          verifie: false,
                          adresse: '—',
                          siteWeb: '—',
                          projetsTermines: 0,
                          projetsEnCours: 0,
                          montantProjetsDh: 0,
                          nbFactures: 0,
                          nbDevis: 0,
                          paiementsRecusDh: 0,
                          remarquesInternes: 'Nouveau contact.',
                          preferences: '—',
                          documents: const [],
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    _toast('Client ajouté à votre CRM');
                  },
                  style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('Enregistrer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _dialogFiltresAvances() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Filtres avancés', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(value: true, onChanged: (_) {}, title: Text('Clients avec projet en cours', style: GoogleFonts.inter(fontSize: 13))),
            CheckboxListTile(value: false, onChanged: (_) {}, title: Text('Uniquement vérifiés NexaMa', style: GoogleFonts.inter(fontSize: 13))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          FilledButton(onPressed: () { Navigator.pop(ctx); _toast('Préférences enregistrées'); }, child: const Text('Appliquer')),
        ],
      ),
    );
  }

  Widget _buildActivity() {
    const items = <_TimelineCRM>[
      _TimelineCRM(icon: Icons.description_outlined, color: Color(0xFF1565C0), title: 'Nouveau devis envoyé à Ahmed Startup', subtitle: 'Il y a 35 min'),
      _TimelineCRM(icon: Icons.payments_rounded, color: NexaColors.primaryGreen, title: 'Paiement reçu — 12 500 DH', subtitle: 'Hier'),
      _TimelineCRM(icon: Icons.task_alt_rounded, color: Color(0xFF00897B), title: 'Projet terminé — Refonte Sara Digital', subtitle: 'Hier'),
      _TimelineCRM(icon: Icons.chat_bubble_outline_rounded, color: Color(0xFF7B1FA2), title: 'Nouveau message reçu', subtitle: 'Il y a 2 jours'),
      _TimelineCRM(icon: Icons.event_available_outlined, color: Color(0xFF5C6BC0), title: 'Réunion programmée avec Youssef Market', subtitle: 'Dans 3 jours'),
    ];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: NexaShadows.card),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activité récente', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          const SizedBox(height: 18),
          ...List.generate(items.length, (i) {
            final e = items[i];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: e.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                        child: Icon(e.icon, color: e.color, size: 21),
                      ),
                      if (i < items.length - 1) Container(width: 2, height: 32, margin: const EdgeInsets.only(top: 4), color: _border),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: NexaColors.darkNavy)),
                        const SizedBox(height: 3),
                        Text(e.subtitle, style: GoogleFonts.inter(fontSize: 12, color: _muted)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ClientProfilSheet extends StatelessWidget {
  const _ClientProfilSheet({required this.client, required this.onClose});

  final _ClientCRM client;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
          child: Row(
            children: [
              Expanded(child: Text('Profil client', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800))),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: client.avatarColor, borderRadius: BorderRadius.circular(18), boxShadow: NexaShadows.card),
                      child: Text(client.initials, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 26)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(child: Text(client.nom, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800))),
                              if (client.verifie) ...[const SizedBox(width: 6), Icon(Icons.verified_rounded, color: NexaColors.primaryGreen)],
                              if (client.online)
                                Container(
                                  margin: const EdgeInsets.only(left: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle)),
                                      const SizedBox(width: 4),
                                      Text('En ligne', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF166534))),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          Text(client.entreprise, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                          Text(client.role, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _sectionTitle('1. Informations générales'),
                _infoTable([
                  ('E-mail', client.email),
                  ('Téléphone', client.telephone),
                  ('Adresse', client.adresse),
                  ('Secteur', client.secteur),
                  ('Site web', client.siteWeb),
                ]),
                const SizedBox(height: 20),
                _sectionTitle('2. Historique projets'),
                _dataTable(
                  headers: const ['Indicateur', 'Valeur'],
                  rows: [
                    ['Projets terminés', '${client.projetsTermines}'],
                    ['Projets en cours', '${client.projetsEnCours}'],
                    ['Montants cumulés', '${_fmt(client.montantProjetsDh)} DH'],
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle('3. Historique paiements'),
                _dataTable(
                  headers: const ['Type', 'Détail'],
                  rows: [
                    ['Factures', '${client.nbFactures} émises'],
                    ['Devis', '${client.nbDevis} envoyés'],
                    ['Paiements reçus', '${_fmt(client.paiementsRecusDh)} DH'],
                  ],
                ),
                const SizedBox(height: 20),
                _sectionTitle('4. Notes & commentaires'),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8ECF2))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Remarques internes', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF64748B))),
                      const SizedBox(height: 6),
                      Text(client.remarquesInternes, style: GoogleFonts.inter(height: 1.45, fontSize: 13.5)),
                      const SizedBox(height: 12),
                      Text('Préférences client', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: const Color(0xFF64748B))),
                      const SizedBox(height: 6),
                      Text(client.preferences, style: GoogleFonts.inter(height: 1.45, fontSize: 13.5)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _sectionTitle('5. Documents partagés'),
                if (client.documents.isEmpty)
                  Text('Aucun document.', style: GoogleFonts.inter(color: const Color(0xFF94A3B8)))
                else
                  ...client.documents.map((d) => ListTile(
                        leading: const Icon(Icons.picture_as_pdf_outlined, color: Color(0xFFB91C1C)),
                        title: Text(d, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        trailing: const Icon(Icons.download_outlined),
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Téléchargement : $d'))),
                      )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String t) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(t, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
    );
  }

  Widget _infoTable(List<(String, String)> rows) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE8ECF2)), borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: List.generate(rows.length, (i) {
          final r = rows[i];
          final isLast = i == rows.length - 1;
          return Container(
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: isLast ? Colors.transparent : const Color(0xFFE8ECF2)))),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                SizedBox(width: 110, child: Text(r.$1, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 12, color: const Color(0xFF64748B)))),
                Expanded(child: Text(r.$2, style: GoogleFonts.inter(fontSize: 13.5))),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _dataTable({required List<String> headers, required List<List<String>> rows}) {
    return Table(
      border: TableBorder.all(color: const Color(0xFFE8ECF2), borderRadius: BorderRadius.circular(12)),
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
          children: headers.map((h) => Padding(padding: const EdgeInsets.all(10), child: Text(h, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12)))).toList(),
        ),
        ...rows.map((r) => TableRow(children: r.map((c) => Padding(padding: const EdgeInsets.all(10), child: Text(c, style: GoogleFonts.inter(fontSize: 13)))).toList())),
      ],
    );
  }

  String _fmt(double v) {
    return v.round().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ');
  }
}
