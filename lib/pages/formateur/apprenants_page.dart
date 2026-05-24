import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/formateur/formateur_ui.dart';

enum _ApprenantSort { nomAsc, progressionDesc, activiteDesc }
enum _ApprenantFilter { tous, actifs, risque, inactifs }

class ApprenantsFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final void Function(String? conversationId)? onContactLearner;

  const ApprenantsFormateurPage({super.key, this.userData, this.onContactLearner});

  @override
  State<ApprenantsFormateurPage> createState() => ApprenantsFormateurPageState();
}

class ApprenantsFormateurPageState extends State<ApprenantsFormateurPage> {
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _apprenants = [];
  final _search = TextEditingController();
  _ApprenantFilter _filter = _ApprenantFilter.tous;
  _ApprenantSort _sort = _ApprenantSort.nomAsc;
  FormateurListViewMode _viewMode = FormateurListViewMode.cards;

  String get _formateurId => widget.userData?['id']?.toString() ?? 'user_123';

  static List<Map<String, dynamic>> _demoApprenants() => [
        {
          'id': 'a1',
          'conversation_id': 'yassine',
          'nom': 'Yassine Mansouri',
          'email': 'yassine.m@exemple.ma',
          'cours': 'Maîtriser Flutter',
          'progression': 0.85,
          'statut': 'Actif',
          'derniere_activite': 'Il y a 2 heures',
          'quiz_moyen': 88,
          'temps_etude_h': 24,
          'certificat': false,
        },
        {
          'id': 'a2',
          'conversation_id': 'laila',
          'nom': 'Laila Bennani',
          'email': 'laila.b@exemple.ma',
          'cours': 'Marketing Digital',
          'progression': 0.72,
          'statut': 'Actif',
          'derniere_activite': 'Il y a 5 heures',
          'quiz_moyen': 76,
          'temps_etude_h': 18,
          'certificat': true,
        },
        {
          'id': 'a3',
          'conversation_id': 'mehdi',
          'nom': 'Mehdi O.',
          'email': 'mehdi.o@exemple.ma',
          'cours': 'Création de Site Web',
          'progression': 0.40,
          'statut': 'À risque',
          'derniere_activite': 'Il y a 1 jour',
          'quiz_moyen': 62,
          'temps_etude_h': 9,
          'certificat': false,
        },
        {
          'id': 'a4',
          'conversation_id': null,
          'nom': 'Imane K.',
          'email': 'imane.k@exemple.ma',
          'cours': 'Marketing Digital pour PME',
          'progression': 0.75,
          'statut': 'Actif',
          'derniere_activite': 'Il y a 3 heures',
          'quiz_moyen': 91,
          'temps_etude_h': 31,
          'certificat': true,
        },
        {
          'id': 'a5',
          'conversation_id': null,
          'nom': 'Khadija A.',
          'email': 'khadija.a@exemple.ma',
          'cours': 'Levée de Fonds & Pitch Deck',
          'progression': 0.90,
          'statut': 'Actif',
          'derniere_activite': 'Il y a 6 heures',
          'quiz_moyen': 94,
          'temps_etude_h': 28,
          'certificat': true,
        },
        {
          'id': 'a6',
          'conversation_id': null,
          'nom': 'Salma R.',
          'email': 'salma.r@exemple.ma',
          'cours': 'Gestion Financière Simplifiée',
          'progression': 0.55,
          'statut': 'Actif',
          'derniere_activite': 'Il y a 1 jour',
          'quiz_moyen': 70,
          'temps_etude_h': 12,
          'certificat': false,
        },
        {
          'id': 'a7',
          'conversation_id': null,
          'nom': 'Amine B.',
          'email': 'amine.b@exemple.ma',
          'cours': 'Marketing Digital pour PME',
          'progression': 0.15,
          'statut': 'Inactif',
          'derniere_activite': 'Il y a 12 jours',
          'quiz_moyen': 45,
          'temps_etude_h': 2,
          'certificat': false,
        },
      ];

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _fetchApprenants();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> refresh() => _fetchApprenants();

  Future<void> _fetchApprenants() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/apprenants/$_formateurId'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final raw = json.decode(response.body) as List<dynamic>;
        setState(() {
          _apprenants = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _apprenants = _demoApprenants();
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _apprenants = _demoApprenants();
          _isLoading = false;
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    var list = _apprenants.where((a) {
      final nom = (a['nom'] ?? '').toString().toLowerCase();
      final cours = (a['cours'] ?? '').toString().toLowerCase();
      if (q.isNotEmpty && !nom.contains(q) && !cours.contains(q)) return false;

      final prog = (a['progression'] as num?)?.toDouble() ?? 0;
      final statut = a['statut']?.toString() ?? '';
      switch (_filter) {
        case _ApprenantFilter.actifs:
          if (prog < 0.5 || statut == 'Inactif') return false;
        case _ApprenantFilter.risque:
          final atRisk = statut == 'À risque' || (prog >= 0.3 && prog < 0.5);
          if (!atRisk) return false;
        case _ApprenantFilter.inactifs:
          if (statut != 'Inactif' && prog >= 0.3) return false;
        case _ApprenantFilter.tous:
          break;
      }
      return true;
    }).toList();

    list = List.from(list);
    switch (_sort) {
      case _ApprenantSort.nomAsc:
        list.sort((a, b) => (a['nom'] ?? '').toString().compareTo((b['nom'] ?? '').toString()));
      case _ApprenantSort.progressionDesc:
        list.sort((a, b) => ((b['progression'] as num?) ?? 0).compareTo((a['progression'] as num?) ?? 0));
      case _ApprenantSort.activiteDesc:
        list.sort((a, b) => ((b['quiz_moyen'] as num?) ?? 0).compareTo((a['quiz_moyen'] as num?) ?? 0));
    }
    return list;
  }

  double get _avgProgress {
    if (_apprenants.isEmpty) return 0;
    return _apprenants.fold<double>(0, (s, a) => s + ((a['progression'] as num?)?.toDouble() ?? 0)) / _apprenants.length;
  }

  int get _actifs => _apprenants.where((a) {
        final p = (a['progression'] as num?)?.toDouble() ?? 0;
        return p >= 0.5 && a['statut'] != 'Inactif';
      }).length;

  int get _aRisque => _apprenants.where((a) => a['statut'] == 'À risque' || (((a['progression'] as num?)?.toDouble() ?? 0) < 0.5 && ((a['progression'] as num?)?.toDouble() ?? 0) >= 0.3)).length;

  void _openDetail(Map<String, dynamic> a) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ApprenantDetailSheet(
        apprenant: a,
        onContact: () {
          Navigator.pop(ctx);
          final convId = a['conversation_id']?.toString();
          widget.onContactLearner?.call(convId);
          if (convId == null && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Aucun fil pour ${a['nom']} — ouvrez Messages.'), behavior: SnackBarBehavior.floating),
            );
          }
        },
        onCertificat: () {
          Navigator.pop(ctx);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(a['certificat'] == true ? 'Certificat déjà délivré.' : 'Certificat en préparation (démo).'),
              behavior: SnackBarBehavior.floating,
              backgroundColor: NexaColors.primaryGreen,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const FormateurLoading();

    if (_error != null) {
      return FormateurEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Chargement impossible',
        message: _error!,
        actionLabel: 'Réessayer',
        onAction: _fetchApprenants,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormateurPageHeader(
          title: 'Mes apprenants',
          subtitle: 'Progression, engagement et contact de vos étudiants.',
          below: FormateurSearchField(controller: _search, hint: 'Nom, cours ou email…'),
        ),
        const SizedBox(height: 20),
        FormateurStatsRow(
          items: [
            FormateurStatItem(label: 'Inscrits', value: '${_apprenants.length}', icon: Icons.people_outline, color: FormateurColors.accent),
            FormateurStatItem(label: 'Progression moy.', value: '${(_avgProgress * 100).round()} %', icon: Icons.trending_up, color: NexaColors.primaryGreen),
            FormateurStatItem(label: 'Actifs', value: '$_actifs', icon: Icons.bolt_outlined, color: Colors.blue),
            FormateurStatItem(label: 'À risque', value: '$_aRisque', icon: Icons.warning_amber_outlined, color: const Color(0xFFF59E0B)),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FormateurChip(label: 'Tous', selected: _filter == _ApprenantFilter.tous, onTap: () => setState(() => _filter = _ApprenantFilter.tous)),
            FormateurChip(label: 'Actifs', selected: _filter == _ApprenantFilter.actifs, onTap: () => setState(() => _filter = _ApprenantFilter.actifs)),
            FormateurChip(label: 'À risque', selected: _filter == _ApprenantFilter.risque, onTap: () => setState(() => _filter = _ApprenantFilter.risque)),
            FormateurChip(label: 'Inactifs', selected: _filter == _ApprenantFilter.inactifs, onTap: () => setState(() => _filter = _ApprenantFilter.inactifs)),
            const SizedBox(width: 8),
            FormateurViewToggle(
              mode: _viewMode,
              onChanged: (m) => setState(() => _viewMode = m),
            ),
            PopupMenuButton<_ApprenantSort>(
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (_) => [
                _sortItem('Nom A-Z', _ApprenantSort.nomAsc),
                _sortItem('Progression', _ApprenantSort.progressionDesc),
                _sortItem('Score quiz', _ApprenantSort.activiteDesc),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(border: Border.all(color: FormateurColors.border), borderRadius: BorderRadius.circular(10), color: Colors.white),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sort, size: 18, color: FormateurColors.muted),
                    const SizedBox(width: 6),
                    Text('Trier', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: FormateurColors.muted)),
                  ],
                ),
              ),
            ),
            IconButton(tooltip: 'Actualiser', onPressed: _fetchApprenants, icon: const Icon(Icons.refresh, color: FormateurColors.muted)),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: RefreshIndicator(
            color: FormateurColors.accent,
            onRefresh: _fetchApprenants,
            child: _filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 260,
                        child: FormateurEmptyState(
                          icon: Icons.people_outline,
                          title: 'Aucun apprenant',
                          message: _apprenants.isEmpty ? 'Les inscriptions à vos cours apparaîtront ici.' : 'Modifiez la recherche ou les filtres.',
                        ),
                      ),
                    ],
                  )
                : _viewMode == FormateurListViewMode.table
                    ? _ApprenantsTableView(
                        apprenants: _filtered,
                        onTap: _openDetail,
                        onContact: (a) {
                          final conv = a['conversation_id']?.toString();
                          widget.onContactLearner?.call(conv);
                        },
                      )
                    : LayoutBuilder(
                        builder: (context, c) {
                          final cols = c.maxWidth > 1000 ? 3 : (c.maxWidth > 650 ? 2 : 1);
                          return GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: cols,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: cols == 1 ? 2.4 : 1.85,
                            ),
                            itemCount: _filtered.length,
                            itemBuilder: (_, i) => _LearnerCard(
                              apprenant: _filtered[i],
                              onTap: () => _openDetail(_filtered[i]),
                              onContact: () {
                                final conv = _filtered[i]['conversation_id']?.toString();
                                widget.onContactLearner?.call(conv);
                              },
                            ),
                          );
                        },
                      ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<_ApprenantSort> _sortItem(String label, _ApprenantSort value) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (_sort == value) const Icon(Icons.check, size: 16, color: FormateurColors.accent),
          if (_sort == value) const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 13)),
        ],
      ),
    );
  }
}

class _LearnerCard extends StatelessWidget {
  final Map<String, dynamic> apprenant;
  final VoidCallback onTap;
  final VoidCallback onContact;

  const _LearnerCard({required this.apprenant, required this.onTap, required this.onContact});

  Color _statutColor(String? statut) {
    switch (statut) {
      case 'Actif':
        return NexaColors.primaryGreen;
      case 'À risque':
        return const Color(0xFFF59E0B);
      case 'Inactif':
        return const Color(0xFF94A3B8);
      default:
        return FormateurColors.muted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final nom = apprenant['nom']?.toString() ?? '?';
    final prog = ((apprenant['progression'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0);
    final statut = apprenant['statut']?.toString() ?? '—';
    final sc = _statutColor(statut);
    final initial = nom.isNotEmpty ? nom[0].toUpperCase() : '?';

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FormateurColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: sc.withValues(alpha: 0.12),
                    child: Text(initial, style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: sc)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nom, style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 15), overflow: TextOverflow.ellipsis),
                        Text(apprenant['cours']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 11, color: FormateurColors.muted), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: sc.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(statut, style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700, color: sc)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _mini(Icons.quiz_outlined, 'Quiz ${apprenant['quiz_moyen'] ?? 0}%'),
                  const SizedBox(width: 12),
                  _mini(Icons.schedule, '${apprenant['temps_etude_h'] ?? 0} h'),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: prog,
                        minHeight: 8,
                        color: sc,
                        backgroundColor: const Color(0xFFF1F5F9),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text('${(prog * 100).round()}%', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(apprenant['derniere_activite']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 10, color: FormateurColors.muted)),
                  const Spacer(),
                  if (apprenant['certificat'] == true)
                    const Icon(Icons.verified, size: 16, color: NexaColors.primaryGreen),
                  IconButton(
                    onPressed: onContact,
                    icon: const Icon(Icons.mail_outline, size: 20, color: FormateurColors.accent),
                    tooltip: 'Contacter',
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mini(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: FormateurColors.muted),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 11, color: FormateurColors.muted)),
      ],
    );
  }
}

class _ApprenantsTableView extends StatelessWidget {
  final List<Map<String, dynamic>> apprenants;
  final void Function(Map<String, dynamic>) onTap;
  final void Function(Map<String, dynamic>) onContact;

  const _ApprenantsTableView({required this.apprenants, required this.onTap, required this.onContact});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: FormateurColors.border),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: Text('Apprenant', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                    Expanded(flex: 3, child: Text('Cours', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                    Expanded(flex: 2, child: Center(child: Text('Progression', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))))),
                    Expanded(flex: 2, child: Center(child: Text('Statut', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8))))),
                    Expanded(flex: 2, child: Text('Activité', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF94A3B8)))),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              for (var i = 0; i < apprenants.length; i++) _TableRow(
                a: apprenants[i],
                isLast: i == apprenants.length - 1,
                onTap: () => onTap(apprenants[i]),
                onContact: () => onContact(apprenants[i]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final Map<String, dynamic> a;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onContact;

  const _TableRow({required this.a, required this.isLast, required this.onTap, required this.onContact});

  @override
  Widget build(BuildContext context) {
    final nom = a['nom']?.toString() ?? '?';
    final prog = ((a['progression'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0);
    final statut = a['statut']?.toString() ?? '—';
    final color = statut == 'Actif'
        ? NexaColors.primaryGreen
        : statut == 'À risque'
            ? const Color(0xFFF59E0B)
            : const Color(0xFF94A3B8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(border: !isLast ? const Border(bottom: BorderSide(color: FormateurColors.border)) : null),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Text(nom[0], style: TextStyle(fontWeight: FontWeight.w800, color: color, fontSize: 12)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(nom, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13), overflow: TextOverflow.ellipsis)),
                  ],
                ),
              ),
              Expanded(flex: 3, child: Text(a['cours']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 12), overflow: TextOverflow.ellipsis)),
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: LinearProgressIndicator(value: prog, minHeight: 6, color: color, backgroundColor: const Color(0xFFE2E8F0))),
                    const SizedBox(width: 6),
                    Text('${(prog * 100).round()}%', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                    child: Text(statut, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                  ),
                ),
              ),
              Expanded(flex: 2, child: Text(a['derniere_activite']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 11, color: FormateurColors.muted))),
              IconButton(onPressed: onContact, icon: const Icon(Icons.mail_outline, size: 20, color: FormateurColors.accent)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ApprenantDetailSheet extends StatelessWidget {
  final Map<String, dynamic> apprenant;
  final VoidCallback onContact;
  final VoidCallback onCertificat;

  const _ApprenantDetailSheet({required this.apprenant, required this.onContact, required this.onCertificat});

  @override
  Widget build(BuildContext context) {
    final nom = apprenant['nom']?.toString() ?? '';
    final prog = ((apprenant['progression'] as num?)?.toDouble() ?? 0).clamp(0.0, 1.0);

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + MediaQuery.paddingOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: FormateurColors.border, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text(nom, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          Text(apprenant['email']?.toString() ?? '', style: GoogleFonts.inter(fontSize: 13, color: FormateurColors.muted)),
          const SizedBox(height: 16),
          _row(Icons.school_outlined, apprenant['cours']?.toString() ?? ''),
          _row(Icons.timeline, 'Progression ${(prog * 100).round()} %'),
          _row(Icons.quiz_outlined, 'Moyenne quiz : ${apprenant['quiz_moyen'] ?? 0} %'),
          _row(Icons.schedule, 'Temps d\'étude : ${apprenant['temps_etude_h'] ?? 0} h'),
          _row(Icons.access_time, apprenant['derniere_activite']?.toString() ?? ''),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onContact,
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Message'),
                  style: OutlinedButton.styleFrom(foregroundColor: FormateurColors.accent, side: const BorderSide(color: FormateurColors.accent)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: onCertificat,
                  icon: Icon(apprenant['certificat'] == true ? Icons.verified : Icons.card_membership_outlined, size: 18),
                  label: Text(apprenant['certificat'] == true ? 'Certifié' : 'Certificat'),
                  style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: FormateurColors.muted),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 14))),
        ],
      ),
    );
  }
}
