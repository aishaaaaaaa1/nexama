import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class _Avis {
  _Avis({
    required this.id,
    required this.nom,
    required this.entreprise,
    required this.stars,
    required this.dateLabel,
    required this.projet,
    required this.commentaire,
    required this.verifie,
    required this.initials,
    required this.avatarColor,
    required this.reponsePrestataire,
    required this.dateReponse,
    this.likes = 0,
    this.aRepondu = true,
  });

  final String id;
  final String nom;
  final String entreprise;
  final int stars;
  final String dateLabel;
  final String projet;
  final String commentaire;
  final bool verifie;
  final String initials;
  final Color avatarColor;
  final String reponsePrestataire;
  final String dateReponse;
  int likes;
  final bool aRepondu;
}

class _ActAvis {
  const _ActAvis({required this.icon, required this.color, required this.title, required this.subtitle});

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
}

/// Section « Avis clients » — prestataire NexaMa (style Fiverr / Trustpilot).
class AvisClientsPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const AvisClientsPrestatairePage({super.key, this.userData});

  @override
  State<AvisClientsPrestatairePage> createState() => _AvisClientsPrestatairePageState();
}

class _AvisClientsPrestatairePageState extends State<AvisClientsPrestatairePage> with SingleTickerProviderStateMixin {
  static const _border = Color(0xFFE8ECF2);
  static const _muted = Color(0xFF64748B);
  static const _surface = Color(0xFFF8FAFC);

  final _searchCtrl = TextEditingController();
  late List<_Avis> _avis;
  int? _filtreStars;
  String _filtreClient = 'Tous';
  String _filtreProjet = 'Tous';
  String _statutReponse = 'Tous';
  late AnimationController _headerAnim;

  static const _dist = [180, 50, 12, 4, 2];

  @override
  void initState() {
    super.initState();
    _headerAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 820))..forward();
    _avis = [
      _Avis(
        id: '1',
        nom: 'Ahmed Benali',
        entreprise: 'Ahmed Startup',
        stars: 5,
        dateLabel: '10 Mai 2025',
        projet: 'Plateforme e-commerce',
        commentaire: 'Excellent travail, communication rapide et résultat professionnel.',
        verifie: true,
        initials: 'AB',
        avatarColor: const Color(0xFF1565C0),
        reponsePrestataire: 'Merci beaucoup pour votre confiance. Ce fut un plaisir de travailler avec vous.',
        dateReponse: '11 Mai 2025',
        likes: 24,
      ),
      _Avis(
        id: '2',
        nom: 'Sara El Amrani',
        entreprise: 'Sara Digital',
        stars: 5,
        dateLabel: '3 Mai 2025',
        projet: 'Branding',
        commentaire: 'Très satisfait du design et du respect des délais.',
        verifie: true,
        initials: 'SD',
        avatarColor: const Color(0xFF7B1FA2),
        reponsePrestataire: 'Merci beaucoup pour votre confiance. Ce fut un plaisir de travailler avec vous.',
        dateReponse: '4 Mai 2025',
        likes: 18,
      ),
      _Avis(
        id: '3',
        nom: 'Youssef Tazi',
        entreprise: 'Youssef Market',
        stars: 4,
        dateLabel: '28 Avr. 2025',
        projet: 'Application mobile',
        commentaire: 'Bonne expérience globale et support réactif.',
        verifie: true,
        initials: 'YT',
        avatarColor: const Color(0xFF00897B),
        reponsePrestataire: 'Merci beaucoup pour votre confiance. Ce fut un plaisir de travailler avec vous.',
        dateReponse: '29 Avr. 2025',
        likes: 9,
      ),
      _Avis(
        id: '4',
        nom: 'Lina Idrissi',
        entreprise: 'Atlas Consulting',
        stars: 5,
        dateLabel: '15 Avr. 2025',
        projet: 'Audit technique',
        commentaire: 'Très professionnel, livrables au-delà des attentes.',
        verifie: false,
        initials: 'LI',
        avatarColor: const Color(0xFF5C6BC0),
        reponsePrestataire: 'Merci beaucoup pour votre confiance. Ce fut un plaisir de travailler avec vous.',
        dateReponse: '16 Avr. 2025',
        likes: 6,
        aRepondu: false,
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

  List<_Avis> get _filtered {
    final q = _searchCtrl.text.trim().toLowerCase();
    return _avis.where((a) {
      if (q.isNotEmpty && !'${a.nom} ${a.entreprise} ${a.commentaire} ${a.projet}'.toLowerCase().contains(q)) return false;
      if (_filtreStars != null && a.stars != _filtreStars) return false;
      if (_filtreClient != 'Tous' && a.entreprise != _filtreClient) return false;
      if (_filtreProjet != 'Tous' && a.projet != _filtreProjet) return false;
      if (_statutReponse == 'Répondu' && !a.aRepondu) return false;
      if (_statutReponse == 'En attente' && a.aRepondu) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 960;
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
          _buildDistribution(wide),
          const SizedBox(height: 20),
          _buildFilters(wide),
          const SizedBox(height: 20),
          ..._filtered.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ClientReviewCard(
                    key: ValueKey(e.value.id),
                    avis: e.value,
                    index: e.key,
                    onLike: () => setState(() => e.value.likes++),
                    onRepondre: () => _sheetRepondre(e.value),
                    onToast: _toast,
                  ),
                ),
              ),
          if (_filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border)),
              child: Center(child: Text('Aucun avis ne correspond aux filtres.', style: GoogleFonts.inter(color: _muted))),
            ),
          const SizedBox(height: 8),
          _buildIaCard(wide),
          const SizedBox(height: 20),
          _buildActivity(),
        ],
      ),
    );
  }

  Widget _buildHeader(bool wide) {
    final export = OutlinedButton.icon(
      onPressed: () => _toast('Export des avis (CSV / PDF) en cours…'),
      style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy, side: const BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      icon: const Icon(Icons.ios_share_outlined, size: 20),
      label: Text('Export avis', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    );
    final filtre = OutlinedButton.icon(
      onPressed: _dialogFiltres,
      style: OutlinedButton.styleFrom(foregroundColor: NexaColors.darkNavy, side: const BorderSide(color: _border), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      icon: const Icon(Icons.tune_rounded, size: 20),
      label: Text('Filtrer', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
    );
    final repondre = FilledButton.icon(
      onPressed: () => _toast('Sélectionnez un avis ou utilisez « Répondre » sur une carte'),
      style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
      icon: const Icon(Icons.reply_rounded, size: 20),
      label: Text('Répondre aux avis', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
    );
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Avis Clients', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: NexaColors.darkNavy, letterSpacing: -0.5)),
        const SizedBox(height: 6),
        Text('Consultez les retours et évaluations de vos clients.', style: GoogleFonts.inter(fontSize: 14.5, color: _muted, height: 1.4, fontWeight: FontWeight.w500)),
      ],
    );
    if (wide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: title), export, const SizedBox(width: 8), filtre, const SizedBox(width: 8), repondre],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [title, const SizedBox(height: 14), Wrap(spacing: 8, runSpacing: 10, children: [export, filtre, repondre])],
    );
  }

  Widget _buildStats(bool wide) {
    Widget c(String label, String value, String sub, IconData ic, Color col, int seed) {
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 500 + seed * 90),
        curve: Curves.easeOutCubic,
        builder: (context, t, ch) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: ch)),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: NexaShadows.card),
          child: Row(
            children: [
              Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: col.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: Icon(ic, color: col, size: 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.inter(fontSize: 12.5, color: _muted, fontWeight: FontWeight.w600)),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(value, style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
                        if (sub.isNotEmpty) ...[const SizedBox(width: 4), Padding(padding: const EdgeInsets.only(bottom: 2), child: Text(sub, style: GoogleFonts.inter(fontSize: 14, color: NexaColors.starGold, fontWeight: FontWeight.w700)))],
                      ],
                    ),
                  ],
                ),
              ),
              _miniLine(seed),
            ],
          ),
        ),
      );
    }

    final row = [
      c('Note moyenne', '4.9', '⭐', Icons.star_rounded, NexaColors.starGold, 0),
      c('Avis positifs', '96', '%', Icons.sentiment_very_satisfied_outlined, NexaColors.primaryGreen, 1),
      c('Nombre total avis', '248', '', Icons.rate_review_outlined, const Color(0xFF1565C0), 2),
      c('Taux réponse', '89', '%', Icons.reply_all_outlined, const Color(0xFF00897B), 3),
    ];
    if (!wide) return Column(children: [for (var i = 0; i < row.length; i++) ...[if (i > 0) const SizedBox(height: 12), row[i]]]);
    return Row(children: [for (var i = 0; i < row.length; i++) ...[if (i > 0) const SizedBox(width: 14), Expanded(child: row[i])]]);
  }

  Widget _miniLine(int seed) {
    final rnd = math.Random(seed);
    final spots = List.generate(6, (i) => FlSpot(i.toDouble(), 0.4 + rnd.nextDouble() * 0.55));
    return SizedBox(
      height: 36,
      width: 64,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: 1,
          gridData: const FlGridData(show: false),
          titlesData: const FlTitlesData(show: false),
          borderData: FlBorderData(show: false),
          lineTouchData: const LineTouchData(enabled: false),
          lineBarsData: [
            LineChartBarData(spots: spots, isCurved: true, barWidth: 2, dotData: const FlDotData(show: false), color: NexaColors.primaryGreen.withValues(alpha: 0.75)),
          ],
        ),
      ),
    );
  }

  Widget _buildDistribution(bool wide) {
    final maxC = _dist.reduce(math.max).toDouble();
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: _border), boxShadow: NexaShadows.dashboard),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _starBars(maxC)),
                const SizedBox(width: 28),
                Expanded(flex: 2, child: _satisfactionRing()),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_starBars(maxC), const SizedBox(height: 24), _satisfactionRing()],
            ),
    );
  }

  Widget _starBars(double maxC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Répartition des notes', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        const SizedBox(height: 16),
        for (var i = 0; i < 5; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                SizedBox(width: 88, child: Text('${5 - i} étoiles', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: NexaColors.darkNavy))),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: _dist[i] / maxC),
                      duration: Duration(milliseconds: 700 + i * 100),
                      curve: Curves.easeOutCubic,
                      builder: (context, t, _) => LinearProgressIndicator(value: t, minHeight: 10, backgroundColor: _surface, color: NexaColors.primaryGreen),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(width: 36, child: Text('${_dist[i]}', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13))),
              ],
            ),
          ),
      ],
    );
  }

  Widget _satisfactionRing() {
    const satisfaction = 0.96;
    const confianceIa = 94;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Satisfaction & confiance IA', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        const SizedBox(height: 16),
        SizedBox(
          height: 140,
          width: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 140,
                width: 140,
                child: CircularProgressIndicator(value: satisfaction, strokeWidth: 10, backgroundColor: _surface, color: NexaColors.primaryGreen, strokeCap: StrokeCap.round),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${(satisfaction * 100).round()}%', style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: NexaColors.darkNavy)),
                  Text('Satisfaction', style: GoogleFonts.inter(fontSize: 11, color: _muted, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(gradient: NexaColors.greenGradient, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4))]),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text('Score confiance IA : $confianceIa / 100', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(bool wide) {
    final dec = InputDecoration(
      hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8), fontSize: 13),
      filled: true,
      fillColor: _surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: _border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: NexaColors.primaryGreen.withValues(alpha: 0.55), width: 1.3)),
    );
    final search = TextField(controller: _searchCtrl, onChanged: (_) => setState(() {}), decoration: dec.copyWith(hintText: 'Recherche avis…', prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8))));
    final note = DropdownButtonFormField<int?>(
      initialValue: _filtreStars,
      decoration: dec.copyWith(labelText: 'Note', prefixIcon: const Icon(Icons.star_outline, color: Color(0xFF94A3B8))),
      items: const [
        DropdownMenuItem(value: null, child: Text('Toutes notes')),
        DropdownMenuItem(value: 5, child: Text('5 étoiles')),
        DropdownMenuItem(value: 4, child: Text('4 étoiles')),
        DropdownMenuItem(value: 3, child: Text('3 étoiles')),
      ],
      onChanged: (v) => setState(() => _filtreStars = v),
    );
    final client = DropdownButtonFormField<String>(
      initialValue: _filtreClient,
      decoration: dec.copyWith(labelText: 'Client', prefixIcon: const Icon(Icons.business_outlined, color: Color(0xFF94A3B8))),
      items: [
        const DropdownMenuItem(value: 'Tous', child: Text('Tous clients')),
        ..._avis.map((a) => a.entreprise).toSet().map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ].toList(),
      onChanged: (v) => setState(() => _filtreClient = v ?? 'Tous'),
    );
    final projet = DropdownButtonFormField<String>(
      initialValue: _filtreProjet,
      decoration: dec.copyWith(labelText: 'Projet', prefixIcon: const Icon(Icons.folder_outlined, color: Color(0xFF94A3B8))),
      items: [
        const DropdownMenuItem(value: 'Tous', child: Text('Tous projets')),
        ..._avis.map((a) => a.projet).toSet().map((e) => DropdownMenuItem(value: e, child: Text(e))),
      ].toList(),
      onChanged: (v) => setState(() => _filtreProjet = v ?? 'Tous'),
    );
    final statut = DropdownButtonFormField<String>(
      initialValue: _statutReponse,
      decoration: dec.copyWith(labelText: 'Statut réponse', prefixIcon: const Icon(Icons.mark_chat_read_outlined, color: Color(0xFF94A3B8))),
      items: const [
        DropdownMenuItem(value: 'Tous', child: Text('Tous')),
        DropdownMenuItem(value: 'Répondu', child: Text('Répondu')),
        DropdownMenuItem(value: 'En attente', child: Text('En attente')),
      ],
      onChanged: (v) => setState(() => _statutReponse = v ?? 'Tous'),
    );

    final dateBtn = FilledButton.tonalIcon(
      onPressed: () => _toast('Filtre par date'),
      icon: const Icon(Icons.date_range_outlined, size: 20),
      label: Text('Date', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
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
            Expanded(child: note),
            const SizedBox(width: 10),
            Expanded(child: client),
            const SizedBox(width: 10),
            Expanded(child: projet),
            const SizedBox(width: 10),
            Expanded(child: statut),
            const SizedBox(width: 8),
            dateBtn,
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
          note,
          const SizedBox(height: 10),
          client,
          const SizedBox(height: 10),
          projet,
          const SizedBox(height: 10),
          statut,
          const SizedBox(height: 10),
          dateBtn,
        ],
      ),
    );
  }

  Widget _buildIaCard(bool wide) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [NexaColors.darkNavy.withValues(alpha: 0.04), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
        boxShadow: NexaShadows.card,
      ),
      child: wide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _iaTextBlock()),
                const SizedBox(width: 20),
                // LineChart exige une hauteur finie ; dans un Row sous SingleChildScrollView la contrainte verticale est infinie.
                Expanded(flex: 2, child: SizedBox(height: 220, child: _iaTrendChart())),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_iaTextBlock(), const SizedBox(height: 18), SizedBox(height: 120, child: _iaTrendChart())],
            ),
    );
  }

  Widget _iaTextBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.psychology_outlined, color: NexaColors.primaryGreen, size: 26),
            const SizedBox(width: 8),
            Text('Analyse IA des avis', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(10)),
          child: Text('Satisfaction globale : Excellent', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: const Color(0xFF166534))),
        ),
        const SizedBox(height: 14),
        Text('Points forts', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: NexaColors.darkNavy)),
        const SizedBox(height: 6),
        ...['communication', 'rapidité', 'qualité design'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [Icon(Icons.check_circle_rounded, size: 18, color: NexaColors.primaryGreen), const SizedBox(width: 8), Text(t, style: GoogleFonts.inter(fontSize: 13.5))]))),
        const SizedBox(height: 12),
        Text('Axes d’amélioration', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: NexaColors.darkNavy)),
        const SizedBox(height: 6),
        ...['délai weekends', 'documentation technique'].map((t) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [Icon(Icons.trending_up_rounded, size: 18, color: const Color(0xFFF59E0B)), const SizedBox(width: 8), Text(t, style: GoogleFonts.inter(fontSize: 13.5))]))),
        const SizedBox(height: 12),
        Text('Score confiance IA : 94 / 100', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: _muted, fontSize: 12)),
      ],
    );
  }

  Widget _iaTrendChart() {
    return LineChart(
      LineChartData(
        minY: 80,
        maxY: 100,
        gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5, getDrawingHorizontalLine: (_) => FlLine(color: _border, strokeWidth: 1)),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, interval: 5, getTitlesWidget: (v, m) => Text('${v.toInt()}', style: GoogleFonts.inter(fontSize: 9, color: _muted)))),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) => Text('S${v.toInt() + 1}', style: GoogleFonts.inter(fontSize: 9, color: _muted)))),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: const [FlSpot(0, 88), FlSpot(1, 90), FlSpot(2, 89), FlSpot(3, 92), FlSpot(4, 94), FlSpot(5, 93), FlSpot(6, 95)],
            isCurved: true,
            barWidth: 2.5,
            dotData: const FlDotData(show: true),
            color: NexaColors.primaryGreen,
            belowBarData: BarAreaData(show: true, gradient: LinearGradient(colors: [NexaColors.primaryGreen.withValues(alpha: 0.2), NexaColors.primaryGreen.withValues(alpha: 0.02)], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
          ),
        ],
      ),
    );
  }

  void _sheetRepondre(_Avis a) {
    final ctrl = TextEditingController(text: a.reponsePrestataire);
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Répondre à ${a.nom}', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(controller: ctrl, maxLines: 4, decoration: InputDecoration(hintText: 'Votre réponse…', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  _toast('Réponse publiée');
                },
                style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen, padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text('Publier la réponse', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _dialogFiltres() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Filtres avancés', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text('Combinez recherche, note et statut pour affiner la liste.', style: GoogleFonts.inter(color: _muted)),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK'))],
      ),
    );
  }

  Widget _buildActivity() {
    const items = <_ActAvis>[
      _ActAvis(icon: Icons.fiber_new_rounded, color: Color(0xFF1565C0), title: 'Nouvel avis reçu', subtitle: 'Il y a 1 h'),
      _ActAvis(icon: Icons.reply_rounded, color: NexaColors.primaryGreen, title: 'Réponse envoyée', subtitle: 'Hier'),
      _ActAvis(icon: Icons.star_rate_rounded, color: NexaColors.starGold, title: 'Avis 5 étoiles', subtitle: 'Il y a 2 jours'),
      _ActAvis(icon: Icons.emoji_events_outlined, color: Color(0xFF7B1FA2), title: 'Badge excellence débloqué', subtitle: 'Cette semaine'),
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
                      Container(width: 40, height: 40, decoration: BoxDecoration(color: e.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(e.icon, color: e.color, size: 21)),
                      if (i < items.length - 1) Container(width: 2, height: 28, margin: const EdgeInsets.only(top: 4), color: _border),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
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

class _ClientReviewCard extends StatefulWidget {
  const _ClientReviewCard({
    super.key,
    required this.avis,
    required this.index,
    required this.onLike,
    required this.onRepondre,
    required this.onToast,
  });

  final _Avis avis;
  final int index;
  final VoidCallback onLike;
  final VoidCallback onRepondre;
  final void Function(String) onToast;

  @override
  State<_ClientReviewCard> createState() => _ClientReviewCardState();
}

class _ClientReviewCardState extends State<_ClientReviewCard> {
  static const _border = Color(0xFFE8ECF2);
  static const _muted = Color(0xFF64748B);
  static const _surface = Color(0xFFF8FAFC);
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final a = widget.avis;
    final index = widget.index;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (context, t, ch) => Opacity(opacity: t, child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: ch)),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          scale: _hover ? 1.006 : 1,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {},
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _hover ? NexaColors.primaryGreen.withValues(alpha: 0.35) : _border),
                  boxShadow: _hover ? NexaShadows.cardHover : NexaShadows.card,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: a.avatarColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [BoxShadow(color: a.avatarColor.withValues(alpha: 0.3), blurRadius: 8)],
                          ),
                          child: Text(a.initials, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(child: Text(a.nom, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 17, color: NexaColors.darkNavy))),
                                  if (a.verifie) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(6)),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.verified_rounded, size: 14, color: NexaColors.primaryGreen),
                                          const SizedBox(width: 2),
                                          Text('Vérifié', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: NexaColors.primaryGreen)),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              Text(a.entreprise, style: GoogleFonts.inter(fontSize: 13.5, color: const Color(0xFF475569), fontWeight: FontWeight.w600)),
                              const SizedBox(height: 6),
                              Row(children: [...List.generate(5, (i) => Icon(i < a.stars ? Icons.star_rounded : Icons.star_border_rounded, size: 20, color: NexaColors.starGold))]),
                              const SizedBox(height: 6),
                              Text('Projet : ${a.projet}', style: GoogleFonts.inter(fontSize: 12.5, color: _muted, fontWeight: FontWeight.w600)),
                              Text(a.dateLabel, style: GoogleFonts.inter(fontSize: 11.5, color: _muted)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text('« ${a.commentaire} »', style: GoogleFonts.inter(fontSize: 14.5, height: 1.5, color: const Color(0xFF334155), fontStyle: FontStyle.italic)),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        TextButton.icon(
                          onPressed: widget.onLike,
                          icon: Icon(Icons.thumb_up_alt_outlined, size: 18, color: NexaColors.primaryGreen.withValues(alpha: 0.9)),
                          label: Text('Utile (${a.likes})', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        OutlinedButton.icon(onPressed: widget.onRepondre, icon: const Icon(Icons.reply_rounded, size: 18), label: Text('Répondre', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                        TextButton(onPressed: () => widget.onToast('Signalement transmis au support NexaMa'), child: Text('Signaler', style: GoogleFonts.inter(color: const Color(0xFFB91C1C), fontWeight: FontWeight.w600))),
                        TextButton(onPressed: () => widget.onToast('Ouverture projet : ${a.projet}'), child: Text('Voir projet', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: NexaColors.darkNavy))),
                      ],
                    ),
                    if (a.aRepondu) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('Réponse du prestataire', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12, color: NexaColors.darkNavy)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: NexaColors.primaryGreen.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                                  child: Text('Prestataire', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: NexaColors.primaryGreen)),
                                ),
                                const Spacer(),
                                Text(a.dateReponse, style: GoogleFonts.inter(fontSize: 11, color: _muted)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(a.reponsePrestataire, style: GoogleFonts.inter(fontSize: 13.5, height: 1.45)),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
