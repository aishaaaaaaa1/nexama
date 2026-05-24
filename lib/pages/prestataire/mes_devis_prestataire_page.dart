import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

enum _DevisStatut { accepte, enAttente, refuse }

class _Devis {
  _Devis({
    required this.numero,
    required this.client,
    required this.projet,
    required this.date,
    required this.montantDh,
    required this.statut,
    required this.secteur,
    required this.dateLabel,
    this.dateExpiration,
  });

  final String numero;
  final String client;
  final String projet;
  final DateTime date;
  final String dateLabel;
  final double montantDh;
  final _DevisStatut statut;
  final String secteur;
  final DateTime? dateExpiration;
}

class _ActItem {
  const _ActItem({required this.icon, required this.color, required this.title, required this.subtitle});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

/// Section « Mes devis » — dashboard prestataire NexaMa.
class MesDevisPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const MesDevisPrestatairePage({super.key, this.userData});

  @override
  State<MesDevisPrestatairePage> createState() => _MesDevisPrestatairePageState();
}

class _MesDevisPrestatairePageState extends State<MesDevisPrestatairePage> with SingleTickerProviderStateMixin {
  static const _border = Color(0xFFE8ECF2);
  static const _muted = Color(0xFF64748B);

  final _searchCtrl = TextEditingController();
  late List<_Devis> _all;
  _DevisStatut? _filtreStatut;
  String _filtreSecteur = 'Tous';
  late AnimationController _headerAnim;

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _all = [
      _Devis(
        numero: 'DEV-2025-001',
        client: 'Ahmed Startup',
        projet: 'Plateforme e-commerce',
        date: DateTime(2025, 5, 12),
        dateLabel: '12 Mai 2025',
        montantDh: 15000,
        statut: _DevisStatut.accepte,
        secteur: 'E-commerce',
        dateExpiration: DateTime(2025, 6, 12),
      ),
      _Devis(
        numero: 'DEV-2025-002',
        client: 'Sara Digital',
        projet: 'Refonte branding',
        date: DateTime(2025, 5, 8),
        dateLabel: '8 Mai 2025',
        montantDh: 8500,
        statut: _DevisStatut.enAttente,
        secteur: 'Design',
        dateExpiration: DateTime(2025, 6, 1),
      ),
      _Devis(
        numero: 'DEV-2025-003',
        client: 'Youssef Market',
        projet: 'Application mobile',
        date: DateTime(2025, 5, 3),
        dateLabel: '3 Mai 2025',
        montantDh: 22000,
        statut: _DevisStatut.refuse,
        secteur: 'Tech',
        dateExpiration: DateTime(2025, 5, 20),
      ),
      _Devis(
        numero: 'DEV-2025-004',
        client: 'Lina Consulting',
        projet: 'Audit SEO & contenu',
        date: DateTime(2025, 4, 28),
        dateLabel: '28 Avr. 2025',
        montantDh: 6200,
        statut: _DevisStatut.accepte,
        secteur: 'Marketing',
        dateExpiration: DateTime(2025, 5, 28),
      ),
      _Devis(
        numero: 'DEV-2025-005',
        client: 'Atlas Logistique',
        projet: 'Tableau de bord analytique',
        date: DateTime(2025, 4, 15),
        dateLabel: '15 Avr. 2025',
        montantDh: 18500,
        statut: _DevisStatut.enAttente,
        secteur: 'Data',
        dateExpiration: DateTime(2025, 5, 15),
      ),
    ];
  }

  @override
  void dispose() {
    _headerAnim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  String _formatMAD(double v) {
    var s = v.round().abs().toString();
    if (v < 0) s = '-$s';
    final parts = <String>[];
    while (s.length > 3) {
      parts.insert(0, s.substring(s.length - 3));
      s = s.substring(0, s.length - 3);
    }
    if (s.isNotEmpty) parts.insert(0, s);
    return parts.join(' ');
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

  List<_Devis> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _all.where((d) {
      if (q.isNotEmpty && !'${d.client} ${d.projet} ${d.numero}'.toLowerCase().contains(q)) return false;
      if (_filtreStatut != null && d.statut != _filtreStatut) return false;
      if (_filtreSecteur != 'Tous' && d.secteur != _filtreSecteur) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FadeTransition(
                opacity: CurvedAnimation(parent: _headerAnim, curve: Curves.easeOutCubic),
                child: SlideTransition(
                  position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(_headerAnim),
                  child: _buildHeader(wide),
                ),
              ),
              const SizedBox(height: 22),
              _buildStatsRow(wide),
              const SizedBox(height: 16),
              _buildFinanceOverview(wide),
              const SizedBox(height: 22),
              _buildFilters(wide),
              const SizedBox(height: 20),
              _buildTableCard(wide),
              const SizedBox(height: 24),
              _buildActivitySection(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool wide) {
    Widget nouveauBtn = FilledButton.icon(
      onPressed: () => _nouveauDevisSheet(),
      style: FilledButton.styleFrom(
        backgroundColor: NexaColors.primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
      icon: const Icon(Icons.add_rounded, size: 22),
      label: Text('+ Nouveau devis', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
    );
    Widget pdfBtn = OutlinedButton.icon(
      onPressed: () => _toast('Export PDF — génération en cours…'),
      style: OutlinedButton.styleFrom(
        foregroundColor: NexaColors.darkNavy,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
      label: Text('Export PDF', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    );
    Widget excelBtn = OutlinedButton.icon(
      onPressed: () => _toast('Fichier Excel téléchargé (aperçu)'),
      style: OutlinedButton.styleFrom(
        foregroundColor: NexaColors.darkNavy,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.table_chart_outlined, size: 20),
      label: Text('Excel', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    );
    Widget filtreBtn = OutlinedButton.icon(
      onPressed: _filtreAvanceDialog,
      style: OutlinedButton.styleFrom(
        foregroundColor: NexaColors.darkNavy,
        side: const BorderSide(color: _border),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      icon: const Icon(Icons.tune_rounded, size: 20),
      label: Text('Filtrer', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    );

    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mes Devis', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: NexaColors.darkNavy, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text(
          'Gérez, envoyez et suivez tous vos devis professionnels.',
          style: GoogleFonts.inter(fontSize: 14.5, color: _muted, height: 1.4, fontWeight: FontWeight.w500),
        ),
      ],
    );

    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: titleBlock),
          nouveauBtn,
          const SizedBox(width: 10),
          pdfBtn,
          const SizedBox(width: 8),
          excelBtn,
          const SizedBox(width: 8),
          filtreBtn,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        titleBlock,
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [nouveauBtn, pdfBtn, excelBtn, filtreBtn],
        ),
      ],
    );
  }

  Widget _buildStatsRow(bool wide) {
    if (!wide) {
      return Column(
        children: [
          _statCard('Devis envoyés', '128', Icons.send_rounded, const Color(0xFF1565C0), _spark(0)),
          const SizedBox(height: 12),
          _statCard('Acceptés', '82', Icons.check_circle_outline_rounded, NexaColors.primaryGreen, _spark(1)),
          const SizedBox(height: 12),
          _statCard('En attente', '31', Icons.schedule_rounded, const Color(0xFFF59E0B), _spark(2)),
          const SizedBox(height: 12),
          _statCard('Refusés', '15', Icons.cancel_outlined, const Color(0xFFDC2626), _spark(3)),
        ],
      );
    }
    return Row(
      children: [
        Expanded(child: _statCard('Devis envoyés', '128', Icons.send_rounded, const Color(0xFF1565C0), _spark(0))),
        const SizedBox(width: 14),
        Expanded(child: _statCard('Acceptés', '82', Icons.check_circle_outline_rounded, NexaColors.primaryGreen, _spark(1))),
        const SizedBox(width: 14),
        Expanded(child: _statCard('En attente', '31', Icons.schedule_rounded, const Color(0xFFF59E0B), _spark(2))),
        const SizedBox(width: 14),
        Expanded(child: _statCard('Refusés', '15', Icons.cancel_outlined, const Color(0xFFDC2626), _spark(3))),
      ],
    );
  }

  Widget _spark(int seed) {
    final rnd = math.Random(seed);
    final spots = List.generate(8, (i) => FlSpot(i.toDouble(), 0.3 + rnd.nextDouble() * 0.7));
    return SizedBox(
      height: 44,
      width: 90,
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
              barWidth: 2.2,
              dotData: const FlDotData(show: false),
              color: NexaColors.primaryGreen.withValues(alpha: 0.75),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [NexaColors.primaryGreen.withValues(alpha: 0.2), NexaColors.primaryGreen.withValues(alpha: 0.02)],
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

  Widget _statCard(String label, String value, IconData icon, Color accent, Widget spark) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: NexaShadows.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: accent, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.inter(fontSize: 13, color: _muted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
                ],
              ),
            ),
            spark,
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceOverview(bool wide) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) => Opacity(opacity: t, child: child),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: NexaShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.insights_rounded, color: NexaColors.primaryGreen.withValues(alpha: 0.9), size: 22),
                const SizedBox(width: 8),
                Text('Vue financière (aperçu)', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
              ],
            ),
            const SizedBox(height: 4),
            Text('Montants devis acceptés — MAD', style: GoogleFonts.inter(fontSize: 12, color: _muted)),
            SizedBox(
              height: wide ? 160 : 140,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 25, getDrawingHorizontalLine: (_) => FlLine(color: const Color(0xFFE8ECF2), strokeWidth: 1)),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 32, interval: 25, getTitlesWidget: (v, m) => Text('${v.toInt()}k', style: GoogleFonts.inter(fontSize: 10, color: _muted)))),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, m) {
                          const labels = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin'];
                          final i = v.toInt();
                          if (i < 0 || i >= labels.length) return const SizedBox.shrink();
                          return Padding(padding: const EdgeInsets.only(top: 8), child: Text(labels[i], style: GoogleFonts.inter(fontSize: 10, color: _muted, fontWeight: FontWeight.w600)));
                        },
                      ),
                    ),
                  ),
                  barGroups: [
                    for (var i = 0; i < 6; i++)
                      BarChartGroupData(
                        x: i,
                        barRods: [
                          BarChartRodData(
                            toY: [42, 55, 38, 72, 68, 85][i].toDouble(),
                            width: wide ? 18 : 12,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            gradient: NexaColors.greenGradient,
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters(bool wide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: NexaShadows.card,
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => setState(() {}),
                    decoration: _dec('Recherche client ou projet…', Icons.search_rounded),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: _ddStatut()),
                const SizedBox(width: 12),
                Expanded(child: _ddSecteur()),
                const SizedBox(width: 12),
                FilledButton.tonalIcon(
                  onPressed: () => _toast('Filtre date (calendrier)'),
                  icon: const Icon(Icons.date_range_outlined, size: 20),
                  label: Text('Date', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                FilledButton.tonalIcon(
                  onPressed: () => _toast('Filtre montant'),
                  icon: const Icon(Icons.payments_outlined, size: 20),
                  label: Text('Montant', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: _filtreAvanceDialog,
                  icon: const Icon(Icons.filter_list_rounded, size: 20),
                  label: Text('Avancé', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(controller: _searchCtrl, onChanged: (_) => setState(() {}), decoration: _dec('Recherche…', Icons.search_rounded)),
                const SizedBox(height: 10),
                _ddStatut(),
                const SizedBox(height: 10),
                _ddSecteur(),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    FilledButton.tonalIcon(
                      onPressed: () => _toast('Filtre date'),
                      icon: const Icon(Icons.date_range_outlined),
                      label: const Text('Date'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: () => _toast('Filtre montant'),
                      icon: const Icon(Icons.payments_outlined),
                      label: const Text('Montant'),
                    ),
                    OutlinedButton.icon(onPressed: _filtreAvanceDialog, icon: const Icon(Icons.filter_list_rounded), label: const Text('Avancé')),
                  ],
                ),
              ],
            ),
    );
  }

  InputDecoration _dec(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: NexaColors.primaryGreen.withValues(alpha: 0.55), width: 1.4),
      ),
    );
  }

  Widget _ddStatut() {
    return DropdownButtonFormField<_DevisStatut?>(
      initialValue: _filtreStatut,
      decoration: _dec('Statut', Icons.flag_outlined),
      items: [
        DropdownMenuItem(value: null, child: Text('Tous les statuts', style: GoogleFonts.inter(fontSize: 13))),
        DropdownMenuItem(value: _DevisStatut.accepte, child: Text('Accepté', style: GoogleFonts.inter(fontSize: 13))),
        DropdownMenuItem(value: _DevisStatut.enAttente, child: Text('En attente', style: GoogleFonts.inter(fontSize: 13))),
        DropdownMenuItem(value: _DevisStatut.refuse, child: Text('Refusé', style: GoogleFonts.inter(fontSize: 13))),
      ],
      onChanged: (v) => setState(() => _filtreStatut = v),
    );
  }

  Widget _ddSecteur() {
    const secteurs = ['Tous', 'E-commerce', 'Design', 'Tech', 'Marketing', 'Data'];
    return DropdownButtonFormField<String>(
      initialValue: _filtreSecteur,
      decoration: _dec('Secteur', Icons.category_outlined),
      items: secteurs.map((s) => DropdownMenuItem(value: s, child: Text(s, style: GoogleFonts.inter(fontSize: 13)))).toList(),
      onChanged: (v) => setState(() => _filtreSecteur = v ?? 'Tous'),
    );
  }

  Widget _buildTableCard(bool wide) {
    final rows = _filtered;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: NexaShadows.dashboard,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
            child: Row(
              children: [
                Text('Devis récents', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
                const Spacer(),
                Text('${rows.length} résultat(s)', style: GoogleFonts.inter(color: _muted, fontSize: 12.5, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(40),
              child: Center(child: Text('Aucun devis ne correspond aux filtres.', style: GoogleFonts.inter(color: _muted))),
            )
          else
            LayoutBuilder(
              builder: (context, c) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minWidth: math.max(c.maxWidth, 960)),
                    child: Table(
                      columnWidths: const {
                        0: FlexColumnWidth(1.1),
                        1: FlexColumnWidth(1.1),
                        2: FlexColumnWidth(1.3),
                        3: FlexColumnWidth(0.75),
                        4: FlexColumnWidth(0.75),
                        5: FlexColumnWidth(0.85),
                        6: FlexColumnWidth(1.6),
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(color: Color(0xFFF8FAFC)),
                          children: [
                            _th('N° devis'),
                            _th('Client'),
                            _th('Projet'),
                            _th('Date'),
                            _th('Montant'),
                            _th('Statut'),
                            _th('Actions'),
                          ],
                        ),
                        ...rows.map((d) => TableRow(
                              decoration: const BoxDecoration(border: Border(top: BorderSide(color: _border))),
                              children: [
                                _td(d.numero, bold: true),
                                _td(d.client),
                                _td(d.projet),
                                _td(d.dateLabel),
                                _td('${_formatMAD(d.montantDh)} DH'),
                                _tdBadge(d.statut),
                                _tdActions(d),
                              ],
                            )),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _th(String t) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Text(t, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w800, color: _muted, letterSpacing: 0.3)),
    );
  }

  Widget _td(String t, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Text(t, style: GoogleFonts.inter(fontSize: 13.5, fontWeight: bold ? FontWeight.w700 : FontWeight.w500, color: NexaColors.darkNavy)),
    );
  }

  Widget _tdBadge(_DevisStatut s) {
    final (label, bg, fg) = switch (s) {
      _DevisStatut.accepte => ('Accepté', const Color(0xFFDCFCE7), const Color(0xFF166534)),
      _DevisStatut.enAttente => ('En attente', const Color(0xFFFEF3C7), const Color(0xFFB45309)),
      _DevisStatut.refuse => ('Refusé', const Color(0xFFFEE2E2), const Color(0xFFB91C1C)),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
          child: Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
        ),
      ),
    );
  }

  Widget _tdActions(_Devis d) {
    Widget actionIcon(IconData i, String tip, VoidCallback on) {
      return Tooltip(
        message: tip,
        child: InkWell(
          onTap: on,
          borderRadius: BorderRadius.circular(8),
          child: Padding(padding: const EdgeInsets.all(6), child: Icon(i, size: 19, color: const Color(0xFF475569))),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Wrap(
        spacing: 2,
        runSpacing: 2,
        children: [
          actionIcon(Icons.visibility_outlined, 'Voir', () => _openDetail(d)),
          actionIcon(Icons.edit_outlined, 'Modifier', () => _toast('Modifier ${d.numero}')),
          actionIcon(Icons.picture_as_pdf_outlined, 'PDF', () => _toast('Téléchargement PDF ${d.numero}')),
          actionIcon(Icons.send_outlined, 'Envoyer', () => _toast('Devis ${d.numero} renvoyé au client')),
          actionIcon(Icons.delete_outline_rounded, 'Supprimer', () => _confirmDelete(d)),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(_Devis d) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Supprimer le devis ?', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text('${d.numero} — ${d.client}', style: GoogleFonts.inter()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700), child: const Text('Supprimer')),
        ],
      ),
    );
    if (ok == true && mounted) {
      setState(() => _all.removeWhere((x) => x.numero == d.numero));
      _toast('Devis supprimé');
    }
  }

  void _openDetail(_Devis d) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640, maxHeight: 720),
          child: _DevisDetailContent(
            devis: d,
            onClose: () => Navigator.pop(ctx),
            onAccept: () {
              Navigator.pop(ctx);
              _toast('Réponse enregistrée : devis accepté par le client');
            },
            onRefuse: () {
              Navigator.pop(ctx);
              _toast('Réponse enregistrée : devis refusé');
            },
          ),
        ),
      ),
    );
  }

  void _nouveauDevisSheet() {
    final client = TextEditingController();
    final projet = TextEditingController();
    final montant = TextEditingController(text: '10000');
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(22))),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Nouveau devis', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                TextField(controller: client, decoration: _dec('Client', Icons.person_outline)),
                const SizedBox(height: 12),
                TextField(controller: projet, decoration: _dec('Intitulé du projet', Icons.work_outline)),
                const SizedBox(height: 12),
                TextField(controller: montant, keyboardType: TextInputType.number, decoration: _dec('Montant (DH)', Icons.payments_outlined)),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: () {
                    if (client.text.isEmpty || projet.text.isEmpty) {
                      _toast('Renseignez client et projet');
                      return;
                    }
                    final m = double.tryParse(montant.text.replaceAll(' ', '')) ?? 0;
                    final n = 'DEV-2025-${(_all.length + 1).toString().padLeft(3, '0')}';
                    setState(() {
                      _all.insert(
                        0,
                        _Devis(
                          numero: n,
                          client: client.text,
                          projet: projet.text,
                          date: DateTime.now(),
                          dateLabel: "Aujourd'hui",
                          montantDh: m,
                          statut: _DevisStatut.enAttente,
                          secteur: 'Tech',
                          dateExpiration: DateTime.now().add(const Duration(days: 30)),
                        ),
                      );
                    });
                    Navigator.pop(ctx);
                    _toast('Devis $n créé et prêt à envoyer');
                  },
                  style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen, padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Text('Créer le devis', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _filtreAvanceDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Filtres avancés', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(value: true, onChanged: (_) {}, title: Text('Masquer les devis expirés', style: GoogleFonts.inter(fontSize: 13))),
            CheckboxListTile(value: false, onChanged: (_) {}, title: Text('Uniquement TVA applicable', style: GoogleFonts.inter(fontSize: 13))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer')),
          FilledButton(onPressed: () { Navigator.pop(ctx); _toast('Filtres appliqués'); }, child: const Text('Appliquer')),
        ],
      ),
    );
  }

  Widget _buildActivitySection() {
    const events = <_ActItem>[
      _ActItem(icon: Icons.check_circle_rounded, color: Color(0xFF22C55E), title: 'Ahmed Startup a accepté le devis', subtitle: 'Il y a 2 h'),
      _ActItem(icon: Icons.send_rounded, color: Color(0xFF1565C0), title: 'Nouveau devis envoyé — DEV-2025-006', subtitle: 'Hier'),
      _ActItem(icon: Icons.account_balance_wallet_outlined, color: NexaColors.primaryGreen, title: 'Paiement reçu — 8 500 DH', subtitle: 'Hier'),
      _ActItem(icon: Icons.timer_off_outlined, color: Color(0xFF94A3B8), title: 'Devis expiré — DEV-2024-112', subtitle: '3 jours'),
    ];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: NexaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Activité récente', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          const SizedBox(height: 18),
          ...List.generate(events.length, (i) {
            final e = events[i];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + i * 80),
              curve: Curves.easeOutCubic,
              builder: (context, t, _) {
                return Opacity(
                  opacity: t,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(color: e.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
                              child: Icon(e.icon, color: e.color, size: 22),
                            ),
                            if (i < events.length - 1)
                              Container(width: 2, height: 36, margin: const EdgeInsets.only(top: 4), color: const Color(0xFFE8ECF2)),
                          ],
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: NexaColors.darkNavy)),
                              const SizedBox(height: 4),
                              Text(e.subtitle, style: GoogleFonts.inter(fontSize: 12, color: _muted, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

class _DevisDetailContent extends StatelessWidget {
  const _DevisDetailContent({
    required this.devis,
    required this.onClose,
    required this.onAccept,
    required this.onRefuse,
  });

  final _Devis devis;
  final VoidCallback onClose;
  final VoidCallback onAccept;
  final VoidCallback onRefuse;

  @override
  Widget build(BuildContext context) {
    final is001 = devis.numero == 'DEV-2025-001';
    final lignes = is001
        ? const [
            ('Développement Frontend', 1, 8000.0),
            ('Backend API', 1, 5000.0),
            ('UI/UX Design', 1, 2000.0),
          ]
        : [
            ('Prestation principale', 1, devis.montantDh * 0.7),
            ('Accompagnement & tests', 1, devis.montantDh * 0.3),
          ];
    final ht = lignes.fold<double>(0, (s, e) => s + e.$3);
    final tva = ht * 0.2;
    final ttc = ht + tva;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 12, 12),
          child: Row(
            children: [
              Expanded(child: Text('Détail du devis', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800))),
              IconButton(onPressed: onClose, icon: const Icon(Icons.close_rounded)),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset('assets/images/logo.png', height: 28, errorBuilder: (context, err, st) => const Icon(Icons.business, size: 28)),
                              const SizedBox(width: 8),
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: NexaColors.darkNavy),
                                  children: [
                                    const TextSpan(text: 'Nexa'),
                                    TextSpan(text: 'Ma', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: NexaColors.primaryGreen)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text('Prestataire certifié NexaMa', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                          Text('Casablanca, Maroc', style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Client', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))),
                          Text(devis.client, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800)),
                          Text(devis.secteur, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFE8ECF2))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('N° devis', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
                          Text(devis.numero, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Émission', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                          Text(devis.dateLabel, style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text('Expiration', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF64748B))),
                          Text(devis.dateExpiration != null ? '${devis.dateExpiration!.day}/${devis.dateExpiration!.month}/${devis.dateExpiration!.year}' : '—', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Text('Services', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 10),
                Table(
                  border: TableBorder.all(color: const Color(0xFFE8ECF2), borderRadius: BorderRadius.circular(12)),
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
                      children: [
                        _cell('Service', head: true),
                        _cell('Qté', head: true),
                        _cell('Prix', head: true),
                      ],
                    ),
                    ...lignes.map((l) => TableRow(children: [_cell(l.$1), _cell('${l.$2}'), _cell('${_fmtDh(l.$3)} DH')])),
                  ],
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _tot('Sous-total HT', _fmtDh(ht)),
                      _tot('TVA (20 %)', _fmtDh(tva)),
                      const Divider(),
                      _tot('Total TTC', _fmtDh(ttc), bold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text('Conditions', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 8),
                Text(
                  'Ce devis est valable 30 jours à compter de la date d’émission. Les prestations démarrent après acceptation électronique et versement de l’acompte convenu. '
                  'Les tarifs sont exprimés en dirhams marocains (MAD), TVA incluse selon mention. NexaMa agit en qualité d’intermédiaire de confiance entre les parties.',
                  style: GoogleFonts.inter(fontSize: 12.5, height: 1.5, color: const Color(0xFF475569)),
                ),
                const SizedBox(height: 22),
                Text('Signature électronique', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14)),
                const SizedBox(height: 10),
                Container(
                  height: 72,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Text('Espace réservé — signature client', style: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontStyle: FontStyle.italic)),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: FilledButton(
                        onPressed: onAccept,
                        style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen, padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text('Accepter le devis', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onRefuse,
                        style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFFB91C1C), padding: const EdgeInsets.symmetric(vertical: 14)),
                        child: Text('Refuser', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _cell(String t, {bool head = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Text(t, style: GoogleFonts.inter(fontWeight: head ? FontWeight.w800 : FontWeight.w500, fontSize: head ? 12 : 13.5)),
    );
  }

  Widget _tot(String l, String v, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 120, child: Text(l, style: GoogleFonts.inter(color: const Color(0xFF64748B), fontWeight: FontWeight.w600))),
          Text(v, style: GoogleFonts.inter(fontWeight: bold ? FontWeight.w900 : FontWeight.w700, fontSize: bold ? 16 : 14)),
        ],
      ),
    );
  }

  String _fmtDh(double n) {
    final s = n.round().toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(' ');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
