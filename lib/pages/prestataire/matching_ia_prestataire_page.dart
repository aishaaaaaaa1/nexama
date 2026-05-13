import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

/// Section « Matching IA » — interface SaaS (contenu principal dashboard prestataire).
class MatchingIAPrestatairePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const MatchingIAPrestatairePage({super.key, this.userData});

  @override
  State<MatchingIAPrestatairePage> createState() => _MatchingIAPrestatairePageState();
}

class _MatchingIAPrestatairePageState extends State<MatchingIAPrestatairePage> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  final _searchCtrl = TextEditingController();
  String _categorie = 'Toutes';
  String _ville = 'Toutes les villes';
  String _budget = 'Tous budgets';
  int _minScoreIa = 80;
  bool _verifiedOnly = false;
  bool _generating = false;

  late final List<_MatchProfile> _allProfiles;
  List<_MatchProfile> _displayed = [];

  static const List<_MatchProfile> _seed = [
    _MatchProfile(
      nom: 'Amine El Idrissi',
      metier: 'Développeur Full-Stack & SaaS',
      ville: 'Rabat',
      categorie: 'Tech',
      tags: ['React', 'Node.js', 'PostgreSQL', 'API'],
      note: 4.9,
      anneesExp: 8,
      disponibilite: 'Sous 48 h',
      budget: '8 000 MAD / projet',
      budgetMAD: 8000,
      score: 92,
      raisons: ['Même ville', 'Expertise correspondante', 'Budget compatible', 'Excellentes évaluations'],
      initials: 'AE',
      verifie: true,
    ),
    _MatchProfile(
      nom: 'Sanaa Benali',
      metier: 'Designer UX/UI & identité de marque',
      ville: 'Casablanca',
      categorie: 'Design',
      tags: ['Figma', 'Design system', 'Branding'],
      note: 4.8,
      anneesExp: 6,
      disponibilite: 'Cette semaine',
      budget: '6 500 MAD / projet',
      budgetMAD: 6500,
      score: 88,
      raisons: ['Même ville', 'Expertise correspondante', 'Budget compatible', 'Excellentes évaluations'],
      initials: 'SB',
      verifie: true,
    ),
    _MatchProfile(
      nom: 'Omar Tazi',
      metier: 'Consultant croissance & levée de fonds',
      ville: 'Marrakech',
      categorie: 'Finance',
      tags: ['Pitch deck', 'Finance', 'Scale-up'],
      note: 4.7,
      anneesExp: 12,
      disponibilite: 'Sur rendez-vous',
      budget: '12 000 MAD / mission',
      budgetMAD: 12000,
      score: 85,
      raisons: ['Expertise correspondante', 'Budget compatible', 'Excellentes évaluations'],
      initials: 'OT',
      verifie: true,
    ),
  ];

  void _onSearchChanged() {
    if (mounted) setState(_applyFilters);
  }

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _allProfiles = List<_MatchProfile>.from(_seed);
    _applyFilters();
    _searchCtrl.addListener(_onSearchChanged);
  }

  void _filterByTag(String tag) {
    setState(() {
      _searchCtrl.text = tag;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();
    _displayed = _allProfiles.where((m) {
      if (q.isNotEmpty) {
        final blob = '${m.nom} ${m.metier} ${m.tags.join(' ')}'.toLowerCase();
        if (!blob.contains(q)) return false;
      }
      if (_categorie != 'Toutes' && m.categorie != _categorie) return false;
      if (_ville != 'Toutes les villes' && m.ville != _ville) return false;
      if (_budget != 'Tous budgets' && !_budgetOk(m.budgetMAD)) return false;
      if (m.score < _minScoreIa) return false;
      if (_verifiedOnly && !m.verifie) return false;
      return true;
    }).toList();
  }

  bool _budgetOk(int mad) {
    switch (_budget) {
      case '< 5 000 MAD':
        return mad < 5000;
      case '5 000 – 15 000 MAD':
        return mad >= 5000 && mad <= 15000;
      case '15 000 – 30 000 MAD':
        return mad >= 15000 && mad <= 30000;
      case '> 30 000 MAD':
        return mad > 30000;
      default:
        return true;
    }
  }

  int get _nouveauxEstime => math.max(_displayed.length * 4, 4);
  int get _discussionEstime => math.max(_displayed.length * 2, 2);
  int get _acceptesEstime => math.min(5, math.max(1, _displayed.length));
  int get _refusesEstime => _displayed.isEmpty ? 0 : 1;

  double get _compatMoyenne {
    if (_displayed.isEmpty) return 0.87;
    final sum = _displayed.fold<int>(0, (a, b) => a + b.score);
    return sum / (_displayed.length * 100);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _searchCtrl.removeListener(_onSearchChanged);
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showSnack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
      ),
    );
  }

  Future<void> _genererNouveauxMatchs() async {
    if (_generating) return;
    setState(() => _generating = true);
    try {
      await Future<void>.delayed(const Duration(milliseconds: 900));
      final rnd = math.Random();
      setState(() {
        _allProfiles.shuffle(rnd);
        for (var i = 0; i < _allProfiles.length; i++) {
          final p = _allProfiles[i];
          _allProfiles[i] = p.copyWith(score: 82 + rnd.nextInt(14));
        }
        _applyFilters();
      });
      if (mounted) _showSnack('${_displayed.length} profils mis à jour par l’IA. Affinez avec les filtres si besoin.');
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _openFiltresAvances() async {
    var minScore = _minScoreIa.toDouble();
    var verified = _verifiedOnly;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Filtres avancés', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Score IA minimum : ${minScore.round()}%', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                  Slider(
                    value: minScore,
                    min: 70,
                    max: 98,
                    divisions: 28,
                    activeColor: NexaColors.primaryGreen,
                    onChanged: (v) => setD(() => minScore = v),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text('Profils vérifiés uniquement', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
                    value: verified,
                    activeThumbColor: NexaColors.primaryGreen,
                    onChanged: (v) => setD(() => verified = v),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler', style: GoogleFonts.inter())),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen),
                child: Text('Appliquer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
              ),
            ],
          );
        },
      ),
    );
    if (ok == true && mounted) {
      setState(() {
        _minScoreIa = minScore.round();
        _verifiedOnly = verified;
        _applyFilters();
      });
      _showSnack('Filtres avancés appliqués.');
    }
  }

  void _openProfil(_MatchProfile p) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        minChildSize: 0.4,
        maxChildSize: 0.92,
        builder: (_, scroll) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: ListView(
              controller: scroll,
              padding: const EdgeInsets.all(24),
              children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(colors: [NexaColors.darkNavy.withValues(alpha: 0.9), NexaColors.darkNavy]),
                      ),
                      alignment: Alignment.center,
                      child: Text(p.initials, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.nom, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800)),
                          Text(p.metier, style: GoogleFonts.inter(color: const Color(0xFF64748B))),
                          Text('${p.ville}, Maroc · ${p.anneesExp} ans d’expérience', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF94A3B8))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Compétences', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: p.tags.map((t) => Chip(label: Text(t))).toList(),
                ),
                const SizedBox(height: 16),
                Text('Budget indicatif', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(p.budget, style: GoogleFonts.inter(color: const Color(0xFF475569))),
                const SizedBox(height: 16),
                Text('Score de compatibilité IA', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text('${p.score}% — recommandation forte pour votre recherche actuelle.', style: GoogleFonts.inter(color: const Color(0xFF475569), height: 1.4)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _openMessage(p);
                  },
                  icon: const Icon(Icons.chat_rounded),
                  label: const Text('Contacter'),
                  style: FilledButton.styleFrom(backgroundColor: NexaColors.darkNavy, minimumSize: const Size(double.infinity, 48)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _openMessage(_MatchProfile p) {
    final ctrl = TextEditingController(text: 'Bonjour ${p.nom.split(' ').first},\n\n');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Message à ${p.nom}', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 420,
          child: TextField(
            controller: ctrl,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: 'Votre message…',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnack('Message envoyé à ${p.nom}.');
            },
            style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen),
            child: const Text('Envoyer'),
          ),
        ],
      ),
    );
  }

  void _openActiviteDetail(String title, String subtitle) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: Text(subtitle, style: GoogleFonts.inter(height: 1.45, color: const Color(0xFF475569))),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Fermer'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final twoCol = w >= 1100;

    return ColoredBox(
      color: const Color(0xFFF4F6F9),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 120),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildFilters(),
                const SizedBox(height: 24),
                if (twoCol)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 300, child: _buildLeftColumn()),
                      const SizedBox(width: 24),
                      Expanded(child: _buildMainColumn()),
                    ],
                  )
                else ...[
                  _buildLeftColumn(),
                  const SizedBox(height: 24),
                  _buildMainColumn(),
                ],
                const SizedBox(height: 32),
                _buildRecentActivity(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Matching IA',
                style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: NexaColors.darkNavy, letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Trouvez les meilleurs partenaires grâce à notre intelligence artificielle.',
                style: GoogleFonts.inter(fontSize: 15, height: 1.45, color: const Color(0xFF64748B)),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ScaleTransition(
          scale: Tween<double>(begin: 1, end: 1.02).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut)),
          child: FilledButton.icon(
            onPressed: _generating ? null : _genererNouveauxMatchs,
            icon: _generating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome_rounded, size: 20),
            label: Text('Générer de nouveaux matchs', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14)),
            style: FilledButton.styleFrom(
              backgroundColor: NexaColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: NexaShadows.card,
      ),
      child: Wrap(
        spacing: 14,
        runSpacing: 14,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          SizedBox(
            width: 320,
            child: TextField(
              controller: _searchCtrl,
              style: GoogleFonts.inter(fontSize: 14),
              onSubmitted: (_) => setState(_applyFilters),
              decoration: InputDecoration(
                hintText: 'Que recherchez-vous aujourd’hui ?',
                hintStyle: GoogleFonts.inter(color: const Color(0xFF94A3B8)),
                prefixIcon: IconButton(
                  icon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                  onPressed: () => setState(_applyFilters),
                ),
                suffixIcon: _searchCtrl.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () {
                          _searchCtrl.clear();
                          setState(_applyFilters);
                        },
                      ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
              ),
            ),
          ),
          _filterChipDropdown('Catégorie', _categorie, ['Toutes', 'Tech', 'Design', 'Marketing', 'Finance'], (v) {
            setState(() {
              _categorie = v;
              _applyFilters();
            });
          }),
          _filterChipDropdown('Localisation', _ville, ['Toutes les villes', 'Casablanca', 'Rabat', 'Marrakech', 'Fès', 'Tanger'], (v) {
            setState(() {
              _ville = v;
              _applyFilters();
            });
          }),
          _filterChipDropdown('Budget', _budget, ['Tous budgets', '< 5 000 MAD', '5 000 – 15 000 MAD', '15 000 – 30 000 MAD', '> 30 000 MAD'], (v) {
            setState(() {
              _budget = v;
              _applyFilters();
            });
          }),
          OutlinedButton.icon(
            onPressed: _openFiltresAvances,
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Text('Filtres avancés', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
            style: OutlinedButton.styleFrom(
              foregroundColor: NexaColors.darkNavy,
              side: const BorderSide(color: Color(0xFFE2E8F0)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterChipDropdown(String label, String value, List<String> options, ValueChanged<String> onPick) {
    return PopupMenuButton<String>(
      onSelected: onPick,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (c) => options.map((e) => PopupMenuItem(value: e, child: Text(e, style: GoogleFonts.inter()))).toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
                Text(value, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: NexaColors.darkNavy)),
              ],
            ),
            const SizedBox(width: 8),
            const Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: Color(0xFF64748B)),
          ],
        ),
      ),
    );
  }

  Widget _buildLeftColumn() {
    return Column(
      children: [
        _summaryCard(),
        const SizedBox(height: 16),
        _compatibilityCard(),
      ],
    );
  }

  Widget _summaryCard() {
    final rows = <({String label, String value, Color color})>[
      (label: 'Nouveaux matchs', value: '$_nouveauxEstime', color: const Color(0xFF2E7D32)),
      (label: 'En discussion', value: '$_discussionEstime', color: const Color(0xFF1565C0)),
      (label: 'Acceptés', value: '$_acceptesEstime', color: const Color(0xFF00897B)),
      (label: 'Refusés', value: '$_refusesEstime', color: const Color(0xFF94A3B8)),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: NexaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Résumé des matchs', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          const SizedBox(height: 18),
          ...rows.map((r) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(r.label, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: r.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                    child: Text(r.value, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: r.color)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _compatibilityCard() {
    final pct = _compatMoyenne;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: NexaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Compatibilité moyenne', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          const SizedBox(height: 20),
          Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) {
                        return CustomPaint(
                          size: const Size(96, 96),
                          painter: _RingPainter(progress: v, color: NexaColors.primaryGreen, track: const Color(0xFFE8ECF2)),
                        );
                      },
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('${(pct * 100).round()}%', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800, color: NexaColors.primaryGreen)),
                        Text('score', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: _miniSparkline()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniSparkline() {
    final heights = [0.35, 0.55, 0.45, 0.7, 0.62, 0.85, 0.78, 0.92];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tendance 7 jours', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8), fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        SizedBox(
          height: 56,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(heights.length, (i) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: heights[i]),
                    duration: Duration(milliseconds: 800 + i * 80),
                    curve: Curves.easeOutCubic,
                    builder: (context, h, _) {
                      return Container(
                        height: 52 * h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [NexaColors.primaryGreen.withValues(alpha: 0.35), NexaColors.primaryGreen.withValues(alpha: 0.9)],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMainColumn() {
    if (_displayed.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE8ECF2)),
          boxShadow: NexaShadows.card,
        ),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text('Aucun profil ne correspond à vos filtres.', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text('Élargissez la localisation, le budget ou réinitialisez la recherche.', textAlign: TextAlign.center, style: GoogleFonts.inter(color: const Color(0xFF64748B))),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () {
                setState(() {
                  _categorie = 'Toutes';
                  _ville = 'Toutes les villes';
                  _budget = 'Tous budgets';
                  _searchCtrl.clear();
                  _minScoreIa = 80;
                  _verifiedOnly = false;
                  _applyFilters();
                });
                _showSnack('Filtres réinitialisés.');
              },
              style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen),
              child: const Text('Réinitialiser les filtres'),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ...List.generate(_displayed.length, (i) {
          final p = _displayed[i];
          return Padding(
            padding: EdgeInsets.only(bottom: i == _displayed.length - 1 ? 0 : 16),
            child: _MatchCardAnimated(
              index: i,
              profile: p,
              onVoirProfil: () => _openProfil(p),
              onEnvoyerMessage: () => _openMessage(p),
              onTagTap: _filterByTag,
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentActivity() {
    const items = <({IconData icon, Color color, String title, String time, String subtitle})>[
      (icon: Icons.auto_awesome_rounded, color: Color(0xFF2E7D32), title: 'Nouveau match trouvé', time: 'Il y a 12 min', subtitle: 'Karim L. — 91 % de compatibilité'),
      (icon: Icons.chat_bubble_outline_rounded, color: Color(0xFF1565C0), title: 'Message reçu', time: 'Il y a 1 h', subtitle: 'Sanaa Benali a répondu à votre invitation'),
      (icon: Icons.check_circle_outline_rounded, color: Color(0xFF00897B), title: 'Match accepté', time: 'Hier', subtitle: 'Projet « Branding Atlas » confirmé avec Amine E.'),
    ];
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECF2)),
        boxShadow: NexaShadows.card,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history_rounded, size: 22, color: NexaColors.darkNavy.withValues(alpha: 0.85)),
              const SizedBox(width: 10),
              Text('Activité de matching récente', style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
            ],
          ),
          const SizedBox(height: 18),
          ...items.map((it) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => _openActiviteDetail(it.title, it.subtitle),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: it.color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                          child: Icon(it.icon, color: it.color, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(it.title, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: NexaColors.darkNavy)),
                                  const Spacer(),
                                  Text(it.time, style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF94A3B8))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(it.subtitle, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B), height: 1.35)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1)),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _MatchProfile {
  final String nom;
  final String metier;
  final String ville;
  final String categorie;
  final List<String> tags;
  final double note;
  final int anneesExp;
  final String disponibilite;
  final String budget;
  final int budgetMAD;
  final int score;
  final List<String> raisons;
  final String initials;
  final bool verifie;

  const _MatchProfile({
    required this.nom,
    required this.metier,
    required this.ville,
    required this.categorie,
    required this.tags,
    required this.note,
    required this.anneesExp,
    required this.disponibilite,
    required this.budget,
    required this.budgetMAD,
    required this.score,
    required this.raisons,
    required this.initials,
    required this.verifie,
  });

  _MatchProfile copyWith({int? score}) {
    return _MatchProfile(
      nom: nom,
      metier: metier,
      ville: ville,
      categorie: categorie,
      tags: tags,
      note: note,
      anneesExp: anneesExp,
      disponibilite: disponibilite,
      budget: budget,
      budgetMAD: budgetMAD,
      score: score ?? this.score,
      raisons: raisons,
      initials: initials,
      verifie: verifie,
    );
  }
}

class _MatchCardAnimated extends StatefulWidget {
  final int index;
  final _MatchProfile profile;
  final VoidCallback onVoirProfil;
  final VoidCallback onEnvoyerMessage;
  final ValueChanged<String> onTagTap;

  const _MatchCardAnimated({
    required this.index,
    required this.profile,
    required this.onVoirProfil,
    required this.onEnvoyerMessage,
    required this.onTagTap,
  });

  @override
  State<_MatchCardAnimated> createState() => _MatchCardAnimatedState();
}

class _MatchCardAnimatedState extends State<_MatchCardAnimated> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.profile;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 500 + widget.index * 90),
      curve: Curves.easeOutCubic,
      builder: (context, t, child) {
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
        );
      },
      child: MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          scale: _hover ? 1.005 : 1,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _hover ? NexaColors.primaryGreen.withValues(alpha: 0.35) : const Color(0xFFE8ECF2)),
              boxShadow: _hover ? NexaShadows.cardHover : NexaShadows.card,
            ),
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onVoirProfil,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(colors: [NexaColors.darkNavy.withValues(alpha: 0.85), NexaColors.darkNavy]),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              p.initials,
                              style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 20),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: InkWell(
                                    onTap: widget.onVoirProfil,
                                    child: Text(p.nom, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                if (p.verifie)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F5E9),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: NexaColors.primaryGreen.withValues(alpha: 0.35)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.verified_rounded, size: 15, color: NexaColors.primaryGreen),
                                        const SizedBox(width: 4),
                                        Text('Vérifié', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: NexaColors.primaryGreen)),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(p.metier, style: GoogleFonts.inter(fontSize: 14, color: const Color(0xFF475569), fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF94A3B8)),
                                const SizedBox(width: 4),
                                Text('${p.ville}, Maroc', style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF64748B))),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: NexaColors.greenGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: NexaColors.primaryGreen.withValues(alpha: 0.35), blurRadius: 12, offset: const Offset(0, 4))],
                        ),
                        child: Column(
                          children: [
                            Text('${p.score}%', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 20)),
                            Text('IA match', style: GoogleFonts.inter(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: p.tags
                        .map(
                          (t) => ActionChip(
                            label: Text(t, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                            onPressed: () => widget.onTagTap(t),
                            backgroundColor: const Color(0xFFF1F5F9),
                            side: BorderSide.none,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  Wrap(
                    spacing: 20,
                    runSpacing: 8,
                    children: [
                      _meta(Icons.star_rounded, NexaColors.starGold, '${p.note}', 'Note'),
                      _meta(Icons.work_history_outlined, const Color(0xFF64748B), '${p.anneesExp} ans', 'Expérience'),
                      _meta(Icons.schedule_rounded, const Color(0xFF00897B), p.disponibilite, 'Dispo.'),
                      _meta(Icons.payments_outlined, NexaColors.darkNavy, p.budget, 'Budget'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE8ECF2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pourquoi ce match ?', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 14, color: NexaColors.darkNavy)),
                        const SizedBox(height: 10),
                        ...p.raisons.map((r) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_rounded, size: 18, color: NexaColors.primaryGreen),
                                const SizedBox(width: 8),
                                Expanded(child: Text(r, style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF475569), height: 1.35))),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: widget.onVoirProfil,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: NexaColors.darkNavy,
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Voir le profil', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: widget.onEnvoyerMessage,
                          style: FilledButton.styleFrom(
                            backgroundColor: NexaColors.darkNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: Text('Envoyer message', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, Color color, String value, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13, color: NexaColors.darkNavy)),
            Text(label, style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
          ],
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;

  _RingPainter({required this.progress, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = size.width / 2 - 6;
    final bg = Paint()..color = track..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    final fg = Paint()..color = color..style = PaintingStyle.stroke..strokeWidth = 8..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, r, bg);
    final sweep = 2 * math.pi * progress;
    canvas.drawArc(Rect.fromCircle(center: c, radius: r), -math.pi / 2, sweep, false, fg);
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.progress != progress;
}
