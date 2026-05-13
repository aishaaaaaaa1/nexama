import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

/// Dashboard analytique **Statistiques** NexaMa (SaaS e-learning) — style premium violet / blanc.
class StatistiquesPage extends StatefulWidget {
  const StatistiquesPage({super.key, this.userData});

  final Map<String, dynamic>? userData;

  @override
  State<StatistiquesPage> createState() => _StatistiquesPageState();
}

enum _Periode { aujourdhui, j7, j30, m12 }

class _StatistiquesPageState extends State<StatistiquesPage> with SingleTickerProviderStateMixin {
  static const _violet = Color(0xFF7C3AED);
  static const _violetSoft = Color(0xFFEDE9FE);
  static const _border = Color(0xFFE8ECF2);
  static const _muted = Color(0xFF64748B);
  static const _surface = Color(0xFFF8FAFC);

  _Periode _periode = _Periode.j30;
  final _searchCtrl = TextEditingController();
  String _filtreCours = 'Tous les cours';
  String _filtreCategorie = 'Toutes catégories';
  String _tri = 'Par revenus';

  late AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 720))..forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _toast(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m, style: GoogleFonts.inter(fontWeight: FontWeight.w500)), behavior: SnackBarBehavior.floating, margin: const EdgeInsets.fromLTRB(16, 0, 16, 24)),
    );
  }

  String _periodeLabel(_Periode p) {
    switch (p) {
      case _Periode.aujourdhui:
        return "Aujourd'hui";
      case _Periode.j7:
        return '7 jours';
      case _Periode.j30:
        return '30 jours';
      case _Periode.m12:
        return '12 mois';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic),
      child: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth >= 1000;
          final med = c.maxWidth >= 640;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(wide),
              const SizedBox(height: 18),
              _filtersRow(wide, med),
              const SizedBox(height: 18),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _kpiGrid(wide, med),
                      const SizedBox(height: 22),
                      _chartsRow1(wide),
                      const SizedBox(height: 18),
                      _chartsRow2(wide),
                      const SizedBox(height: 22),
                      _sectionFormations(wide),
                      const SizedBox(height: 18),
                      _sectionApprenants(wide),
                      const SizedBox(height: 18),
                      _sectionQuiz(wide),
                      const SizedBox(height: 18),
                      _sectionRevenus(wide),
                      const SizedBox(height: 18),
                      _sectionActivite(),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _header(bool wide) {
    final periodes = SegmentedButton<_Periode>(
      segments: [
        ButtonSegment(value: _Periode.aujourdhui, label: Text("Auj.", style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12))),
        ButtonSegment(value: _Periode.j7, label: Text('7 j', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12))),
        ButtonSegment(value: _Periode.j30, label: Text('30 j', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12))),
        ButtonSegment(value: _Periode.m12, label: Text('12 m', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 12))),
      ],
      selected: {_periode},
      onSelectionChanged: (s) => setState(() => _periode = s.first),
      style: ButtonStyle(visualDensity: VisualDensity.compact, foregroundColor: WidgetStateProperty.resolveWith((st) => st.contains(WidgetState.selected) ? Colors.white : NexaColors.darkNavy)),
    );

    final actions = Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        OutlinedButton.icon(
          onPressed: () => _toast('Export PDF (${_periodeLabel(_periode)}) — démo'),
          icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
          label: Text('Export PDF', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy, side: const BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        ),
        FilledButton.icon(
          onPressed: () => _toast('Téléchargement rapport CSV — démo'),
          icon: const Icon(Icons.download_rounded, size: 20),
          label: Text('Télécharger rapport', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          style: FilledButton.styleFrom(backgroundColor: _violet, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
        ),
      ],
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: EdgeInsets.all(wide ? 24 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.white.withValues(alpha: 0.94), _violetSoft.withValues(alpha: 0.5)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
            boxShadow: [BoxShadow(color: _violet.withValues(alpha: 0.07), blurRadius: 28, offset: const Offset(0, 10))],
          ),
          child: wide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Statistiques', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: NexaColors.darkNavy, letterSpacing: -0.6)),
                          const SizedBox(height: 8),
                          Text('Visualisez performances, formations, apprenants et revenus (${_periodeLabel(_periode)}).', style: GoogleFonts.inter(fontSize: 14, color: _muted, height: 1.45, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 14),
                          periodes,
                        ],
                      ),
                    ),
                    actions,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Statistiques', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w900, color: NexaColors.darkNavy)),
                    const SizedBox(height: 6),
                    Text('Analytics plateforme e-learning NexaMa.', style: GoogleFonts.inter(fontSize: 13, color: _muted)),
                    const SizedBox(height: 12),
                    SingleChildScrollView(scrollDirection: Axis.horizontal, child: periodes),
                    const SizedBox(height: 14),
                    actions,
                  ],
                ),
        ),
      ),
    );
  }

  Widget _filtersRow(bool wide, bool med) {
    final dec = InputDecoration(
      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.9),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _violet, width: 1.3)),
    );

    final search = TextField(
      controller: _searchCtrl,
      onChanged: (_) => setState(() {}),
      decoration: dec.copyWith(hintText: 'Rechercher cours, apprenant…', prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8))),
    );

    Widget dd(String label, String v, List<String> items, void Function(String?) onChanged) {
      return DropdownButtonFormField<String>(
        key: ValueKey<String>('$label-$v'),
        initialValue: v,
        decoration: dec.copyWith(labelText: label),
        items: [for (final x in items) DropdownMenuItem(value: x, child: Text(x, style: GoogleFonts.inter(fontSize: 13)))],
        onChanged: onChanged,
      );
    }

    final row = wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(flex: 2, child: search),
              const SizedBox(width: 10),
              Expanded(child: dd('Cours', _filtreCours, ['Tous les cours', 'Marketing Digital', 'SEO Avancé', 'Leadership'], (x) => setState(() => _filtreCours = x ?? _filtreCours))),
              const SizedBox(width: 10),
              Expanded(child: dd('Catégorie', _filtreCategorie, ['Toutes catégories', 'Business', 'Tech', 'Soft skills'], (x) => setState(() => _filtreCategorie = x ?? _filtreCategorie))),
              const SizedBox(width: 10),
              Expanded(child: dd('Tri', _tri, ['Par revenus', 'Par inscriptions', 'Par note'], (x) => setState(() => _tri = x ?? _tri))),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              search,
              const SizedBox(height: 10),
              if (med)
                Row(
                  children: [
                    Expanded(child: dd('Cours', _filtreCours, ['Tous les cours', 'Marketing Digital', 'SEO Avancé'], (x) => setState(() => _filtreCours = x ?? _filtreCours))),
                    const SizedBox(width: 10),
                    Expanded(child: dd('Tri', _tri, ['Par revenus', 'Par inscriptions'], (x) => setState(() => _tri = x ?? _tri))),
                  ],
                )
              else ...[
                dd('Cours', _filtreCours, ['Tous les cours', 'Marketing Digital', 'SEO Avancé'], (x) => setState(() => _filtreCours = x ?? _filtreCours)),
                const SizedBox(height: 10),
                dd('Tri', _tri, ['Par revenus', 'Par inscriptions'], (x) => setState(() => _tri = x ?? _tri)),
              ],
            ],
          );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))]),
      child: row,
    );
  }

  Widget _kpiGrid(bool wide, bool med) {
    final items = <({String t, String v, String s, IconData i, Color c})>[
      (t: 'Étudiants', v: '2 480', s: '+12 %', i: Icons.groups_2_outlined, c: _violet),
      (t: 'Formations', v: '36', s: '+3', i: Icons.menu_book_outlined, c: const Color(0xFF2563EB)),
      (t: 'Revenus', v: '184 k MAD', s: '+8 %', i: Icons.trending_up_rounded, c: const Color(0xFF059669)),
      (t: 'Taux réussite', v: '91 %', s: '+2 pts', i: Icons.emoji_events_outlined, c: const Color(0xFFD97706)),
      (t: 'Temps moyen', v: '4 h 12', s: 'par parcours', i: Icons.timer_outlined, c: const Color(0xFF6366F1)),
      (t: 'Quiz complétés', v: '1 842', s: '+6 %', i: Icons.quiz_outlined, c: const Color(0xFFEC4899)),
      (t: 'Complétion cours', v: '78 %', s: 'médiane', i: Icons.pie_chart_outline_rounded, c: const Color(0xFF14B8A6)),
      (t: 'Certificats', v: '412', s: 'ce mois', i: Icons.workspace_premium_outlined, c: const Color(0xFF8B5CF6)),
    ];

    final n = wide ? 4 : (med ? 2 : 1);
    return LayoutBuilder(
      builder: (context, c) {
        final gap = 14.0 * (n - 1);
        final cardW = n > 0 ? (c.maxWidth - gap) / n : c.maxWidth;
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: List.generate(items.length, (idx) {
            final e = items[idx];
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 400 + idx * 45),
              curve: Curves.easeOutCubic,
              builder: (context, t, ch) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: ch)),
              child: SizedBox(
                width: cardW.clamp(140, 600),
                child: _kpiCard(e.t, e.v, e.s, e.i, e.c),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _kpiCard(String title, String value, String sub, IconData icon, Color col) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: _border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 6))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: col.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, color: col, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.inter(fontSize: 12.5, color: _muted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w900, color: NexaColors.darkNavy)),
                  Text(sub, style: GoogleFonts.inter(fontSize: 12, color: col, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartsRow1(bool wide) {
    final chart = SizedBox(
      height: 240,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20, getDrawingHorizontalLine: (_) => FlLine(color: _border, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36, getTitlesWidget: (v, m) => Text('${v.toInt()}k', style: GoogleFonts.inter(fontSize: 10, color: _muted)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('M${v.toInt() + 1}', style: GoogleFonts.inter(fontSize: 10, color: _muted)))),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: const [FlSpot(0, 12), FlSpot(1, 18), FlSpot(2, 15), FlSpot(3, 22), FlSpot(4, 28), FlSpot(5, 24), FlSpot(6, 32)],
              isCurved: true,
              barWidth: 3,
              color: _violet,
              belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [_violet.withValues(alpha: 0.25), _violet.withValues(alpha: 0.02)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
              dotData: const FlDotData(show: true),
            ),
          ],
        ),
      ),
    );

    final bar = SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: _border, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: GoogleFonts.inter(fontSize: 10, color: _muted)))),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('S${v.toInt() + 1}', style: GoogleFonts.inter(fontSize: 10, color: _muted)))),
          ),
          barGroups: List.generate(
            7,
            (i) => BarChartGroupData(
              x: i,
              barRods: [BarChartRodData(toY: [18, 24, 20, 32, 28, 35, 30][i].toDouble(), width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)), color: const Color(0xFF6366F1))],
            ),
          ),
        ),
      ),
    );

    return wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _chartCard('Évolution des revenus (k MAD)', 'Tendance ${_periodeLabel(_periode)}', chart)),
              const SizedBox(width: 16),
              Expanded(child: _chartCard('Croissance des étudiants', 'Nouveaux comptes actifs', bar)),
            ],
          )
        : Column(children: [_chartCard('Évolution des revenus (k MAD)', 'Tendance', chart), const SizedBox(height: 16), _chartCard('Croissance des étudiants', 'Inscriptions', bar)]);
  }

  Widget _chartsRow2(bool wide) {
    final line2 = SizedBox(
      height: 220,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true, drawVerticalLine: false, getDrawingHorizontalLine: (_) => FlLine(color: _border, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          titlesData: const FlTitlesData(show: false),
          lineBarsData: [
            LineChartBarData(spots: const [FlSpot(0, 3), FlSpot(1, 5), FlSpot(2, 4), FlSpot(3, 7), FlSpot(4, 6), FlSpot(5, 9)], isCurved: true, color: const Color(0xFF14B8A6), barWidth: 2.5, dotData: const FlDotData(show: false)),
            LineChartBarData(spots: const [FlSpot(0, 2), FlSpot(1, 4), FlSpot(2, 5), FlSpot(3, 4), FlSpot(4, 6), FlSpot(5, 8)], isCurved: true, color: _violet.withValues(alpha: 0.7), barWidth: 2.5, dotData: const FlDotData(show: false)),
          ],
        ),
      ),
    );

    final pie = SizedBox(
      height: 220,
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 48,
          sections: [
            PieChartSectionData(value: 38, color: _violet, title: '38%', radius: 52, titleStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
            PieChartSectionData(value: 28, color: const Color(0xFF6366F1), title: '28%', radius: 48, titleStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
            PieChartSectionData(value: 22, color: const Color(0xFF14B8A6), title: '22%', radius: 44, titleStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11)),
            PieChartSectionData(value: 12, color: const Color(0xFFF59E0B), title: '12%', radius: 40, titleStyle: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10)),
          ],
        ),
      ),
    );

    return wide
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _chartCard('Activité & progression', 'Sessions vs progression modules', line2)),
              const SizedBox(width: 16),
              Expanded(flex: 2, child: _chartCard('Répartition du temps', 'Heures par type d’activité', pie)),
            ],
          )
        : Column(children: [_chartCard('Activité & progression', 'Multi-courbes', line2), const SizedBox(height: 16), _chartCard('Répartition du temps', 'Donut', pie)]);
  }

  Widget _chartCard(String title, String subtitle, Widget child) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 6))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: _muted)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _sectionFormations(bool wide) {
    return _sectionShell(
      'Performance des formations',
      'Popularité, notes et revenus par cours.',
      Column(
        children: [
          _dataTable(const ['Formation', 'Inscriptions', 'Note', 'Revenus', 'Progression'], [
            ['Marketing Digital', '420', '4.9', '62 k MAD', '82 %'],
            ['SEO Avancé', '310', '4.8', '41 k MAD', '76 %'],
            ['Leadership', '198', '4.7', '28 k MAD', '71 %'],
          ]),
        ],
      ),
    );
  }

  Widget _sectionApprenants(bool wide) {
    final stats = [
      ('Plus actifs', '128', Icons.local_fire_department_outlined, const Color(0xFFEA580C)),
      ('Nouveaux (30 j)', '186', Icons.person_add_alt_1_outlined, _violet),
      ('Engagement', '64 %', Icons.bolt_outlined, const Color(0xFF059669)),
      ('Temps / session', '24 min', Icons.schedule_outlined, const Color(0xFF6366F1)),
    ];
    return _sectionShell(
      'Apprenants',
      'Engagement et activité récente.',
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          for (final s in stats)
            SizedBox(
              width: wide ? 220 : 280,
              child: _miniStat(s.$1, s.$2, s.$3, s.$4),
            ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Row(
        children: [
          Icon(icon, color: c, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: _muted, fontWeight: FontWeight.w600)),
                Text(value, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w900, color: NexaColors.darkNavy)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionQuiz(bool wide) {
    return _sectionShell(
      'Quiz & évaluations',
      'Scores, difficulté et réussite globale.',
      Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _badge('Quiz passés', '1 842'),
              _badge('Score moyen', '78 %'),
              _badge('Réussite globale', '89 %'),
              _badge('Plus difficile', 'Audit technique'),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(value: 0.78, minHeight: 10, backgroundColor: _surface, color: _violet),
          ),
          const SizedBox(height: 8),
          Text('Performance moyenne des étudiants sur la période', style: GoogleFonts.inter(fontSize: 12, color: _muted)),
        ],
      ),
    );
  }

  Widget _badge(String k, String v) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(gradient: LinearGradient(colors: [_violet.withValues(alpha: 0.12), _violetSoft]), borderRadius: BorderRadius.circular(12), border: Border.all(color: _violet.withValues(alpha: 0.25))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$k : ', style: GoogleFonts.inter(fontSize: 12, color: _muted, fontWeight: FontWeight.w600)),
          Text(v, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w900, color: NexaColors.darkNavy)),
        ],
      ),
    );
  }

  Widget _sectionRevenus(bool wide) {
    return _sectionShell(
      'Revenus',
      'Journalier, abonnements et objectifs.',
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: _miniStat('Aujourd’hui', '4 200 MAD', Icons.today_outlined, _violet)),
              const SizedBox(width: 12),
              Expanded(child: _miniStat('Abonnements actifs', '312', Icons.subscriptions_outlined, const Color(0xFF059669))),
              const SizedBox(width: 12),
              Expanded(child: _miniStat('Objectif mois', '72 %', Icons.flag_outlined, const Color(0xFFD97706))),
              const SizedBox(width: 12),
              Expanded(child: _miniStat('Croissance', '+14 %', Icons.show_chart, const Color(0xFF2563EB))),
            ],
          ),
          const SizedBox(height: 14),
          _dataTable(const ['Paiement', 'Montant', 'Statut', 'Date'], [
            ['Abonnement Pro', '499 MAD', 'Payé', '11 Mai'],
            ['Pack cours SEO', '1 200 MAD', 'Payé', '10 Mai'],
            ['Live premium', '350 MAD', 'En cours', '09 Mai'],
          ]),
        ],
      ),
    );
  }

  Widget _sectionActivite() {
    const events = [
      ('Inscription', 'Yasmine · SEO Avancé', 'Il y a 12 min', Icons.person_add_alt_1_outlined, Color(0xFF2563EB)),
      ('Paiement', 'Pack Marketing — 899 MAD', 'Il y a 1 h', Icons.payments_outlined, Color(0xFF059669)),
      ('Certificat', 'Omar · Leadership', 'Il y a 2 h', Icons.workspace_premium_outlined, Color(0xFFD97706)),
      ('Quiz', 'Quiz final — 92 %', 'Il y a 3 h', Icons.quiz_outlined, Color(0xFF7C3AED)),
      ('Système', 'Sauvegarde automatique OK', 'Hier', Icons.cloud_done_outlined, Color(0xFF64748B)),
    ];
    return _sectionShell(
      'Activité récente',
      'Inscriptions, paiements, certificats et alertes.',
      Column(
        children: List.generate(events.length, (i) {
          final e = events[i];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: e.$5.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(e.$4, color: e.$5, size: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.$1, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13)),
                      Text(e.$2, style: GoogleFonts.inter(fontSize: 13, color: NexaColors.darkNavy)),
                      Text(e.$3, style: GoogleFonts.inter(fontSize: 11, color: _muted)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _sectionShell(String title, String subtitle, Widget body) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.96), borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 18, offset: const Offset(0, 5))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w900, color: NexaColors.darkNavy)),
          Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: _muted, height: 1.35)),
          const SizedBox(height: 16),
          body,
        ],
      ),
    );
  }

  Widget _dataTable(List<String> headers, List<List<String>> rows) {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(color: _surface, borderRadius: BorderRadius.vertical(top: Radius.circular(13))),
            child: Row(
              children: [for (var i = 0; i < headers.length; i++) Expanded(flex: i == 0 ? 2 : 1, child: Text(headers[i], style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: _muted)))],
            ),
          ),
          for (final r in rows)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [for (var i = 0; i < r.length; i++) Expanded(flex: i == 0 ? 2 : 1, child: Text(r[i], style: GoogleFonts.inter(fontSize: 13, fontWeight: i == 0 ? FontWeight.w700 : FontWeight.w500, color: i == 0 ? NexaColors.darkNavy : _muted)))],
              ),
            ),
        ],
      ),
    );
  }
}
