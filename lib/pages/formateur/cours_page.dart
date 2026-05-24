import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/formateur/formateur_ui.dart';
import 'cours_edit_dialog.dart';

enum _CoursSort { titreAsc, prixDesc, apprenantsDesc, revenusDesc }

class MesCoursPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onCreateCourse;

  const MesCoursPage({super.key, this.userData, this.onCreateCourse});

  @override
  State<MesCoursPage> createState() => MesCoursPageState();
}

class MesCoursPageState extends State<MesCoursPage> {
  bool _isLoading = true;
  bool _actionBusy = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _cours = [];
  final _search = TextEditingController();
  String _filterFormat = 'Tous';
  String _filterStatut = 'Tous';
  _CoursSort _sort = _CoursSort.titreAsc;
  FormateurListViewMode _viewMode = FormateurListViewMode.table;

  String get _formateurId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _search.addListener(() => setState(() {}));
    _fetchCours();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> refresh() => _fetchCours();

  Future<void> _fetchCours() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/cours/$_formateurId'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final raw = json.decode(response.body) as List<dynamic>;
        setState(() {
          _cours = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Impossible de charger vos cours (${response.statusCode}).';
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Connexion au serveur impossible. Vérifiez que le backend est démarré.';
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filtered {
    final q = _search.text.trim().toLowerCase();
    var list = _cours.where((c) {
      final titre = (c['titre'] ?? '').toString().toLowerCase();
      if (q.isNotEmpty && !titre.contains(q)) return false;
      final format = '${c['format_media']}';
      if (_filterFormat == 'Vidéo' && !format.contains('Vidéo')) return false;
      if (_filterFormat == 'PDF' && !format.contains('PDF')) return false;
      final statut = c['statut']?.toString() ?? '';
      if (_filterStatut == 'Publié' && statut != 'Publié') return false;
      if (_filterStatut == 'Brouillon' && statut != 'Brouillon') return false;
      return true;
    }).toList();

    list = List.from(list);
    switch (_sort) {
      case _CoursSort.titreAsc:
        list.sort((a, b) => (a['titre'] ?? '').toString().compareTo((b['titre'] ?? '').toString()));
      case _CoursSort.prixDesc:
        list.sort((a, b) => ((b['prix'] as num?) ?? 0).compareTo((a['prix'] as num?) ?? 0));
      case _CoursSort.apprenantsDesc:
        list.sort((a, b) => ((b['apprenants'] as num?) ?? 0).compareTo((a['apprenants'] as num?) ?? 0));
      case _CoursSort.revenusDesc:
        list.sort((a, b) => ((b['revenus_mad'] as num?) ?? 0).compareTo((a['revenus_mad'] as num?) ?? 0));
    }
    return list;
  }

  int get _publishedCount => _cours.where((c) => c['statut'] == 'Publié').length;

  int get _totalApprenants => _cours.fold(0, (s, c) => s + ((c['apprenants'] as num?)?.toInt() ?? 0));

  int get _totalRevenus => _cours.fold(0, (s, c) => s + ((c['revenus_mad'] as num?)?.toInt() ?? 0));

  double get _avgCompletion {
    if (_cours.isEmpty) return 0;
    return _cours.fold<double>(0, (s, c) => s + ((c['taux_completion'] as num?)?.toDouble() ?? 0)) / _cours.length;
  }

  void _replaceCours(Map<String, dynamic> updated) {
    setState(() {
      final i = _cours.indexWhere((c) => c['id'] == updated['id']);
      if (i >= 0) _cours[i] = updated;
    });
  }

  void _removeCours(String id) {
    setState(() => _cours.removeWhere((c) => c['id'] == id));
  }

  Future<void> _toggleStatut(Map<String, dynamic> cours) async {
    final next = cours['statut'] == 'Publié' ? 'Brouillon' : 'Publié';
    await _updateCours(cours, {'statut': next});
  }

  Future<void> _updateCours(Map<String, dynamic> cours, Map<String, dynamic> body) async {
    setState(() => _actionBusy = true);
    try {
      final response = await ApiService.put(
        ApiConfig.uri('/api/formateur/cours/$_formateurId/${cours['id']}'),
        body: body,
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _replaceCours(Map<String, dynamic>.from(data['cours'] as Map));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message']?.toString() ?? 'Cours mis à jour'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur réseau.'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _confirmDelete(Map<String, dynamic> cours) async {
    final titre = cours['titre']?.toString() ?? 'ce cours';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Supprimer le cours ?', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        content: Text('« $titre » sera définitivement retiré.', style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    setState(() => _actionBusy = true);
    try {
      final response = await ApiService.delete(
        ApiConfig.uri('/api/formateur/cours/$_formateurId/${cours['id']}'),
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        _removeCours(cours['id'].toString());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('« $titre » supprimé.'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la suppression.'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _actionBusy = false);
    }
  }

  Future<void> _openEdit(Map<String, dynamic> cours) async {
    final updated = await CoursEditDialog.show(context, cours: cours, formateurId: _formateurId);
    if (updated != null && mounted) {
      _replaceCours(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cours enregistré.'), behavior: SnackBarBehavior.floating, backgroundColor: NexaColors.primaryGreen),
      );
    }
  }

  void _openManageSheet(Map<String, dynamic> cours) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => _ManageCoursSheet(
        cours: cours,
        busy: _actionBusy,
        onEdit: () {
          Navigator.pop(ctx);
          _openEdit(cours);
        },
        onToggleStatut: () {
          Navigator.pop(ctx);
          _toggleStatut(cours);
        },
        onDelete: () {
          Navigator.pop(ctx);
          _confirmDelete(cours);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const FormateurLoading();

    if (_errorMessage != null) {
      return FormateurEmptyState(
        icon: Icons.cloud_off_outlined,
        title: 'Chargement impossible',
        message: _errorMessage!,
        actionLabel: 'Réessayer',
        onAction: _fetchCours,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormateurPageHeader(
          title: 'Mes cours',
          subtitle: 'Gérez vos formations publiées, tarifs et contenus.',
          trailing: ElevatedButton.icon(
            onPressed: widget.onCreateCourse,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Publier un cours'),
            style: formateurPrimaryStyle(),
          ),
          below: FormateurSearchField(controller: _search, hint: 'Rechercher un cours...'),
        ),
        const SizedBox(height: 20),
        FormateurStatsRow(
          items: [
            FormateurStatItem(
              label: 'Cours publiés',
              value: '$_publishedCount',
              icon: Icons.school_outlined,
              color: FormateurColors.accent,
              hint: '${_cours.length} au total',
            ),
            FormateurStatItem(
              label: 'Apprenants',
              value: '$_totalApprenants',
              icon: Icons.people_outline,
              color: Colors.blue,
            ),
            FormateurStatItem(
              label: 'Revenus cumulés',
              value: '${formatMad(_totalRevenus)} MAD',
              icon: Icons.payments_outlined,
              color: NexaColors.primaryGreen,
            ),
            FormateurStatItem(
              label: 'Complétion moy.',
              value: '${(_avgCompletion * 100).round()}%',
              icon: Icons.trending_up,
              color: const Color(0xFFF59E0B),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ...['Tous', 'Vidéo', 'PDF'].map((f) => FormateurChip(
                  label: f,
                  selected: _filterFormat == f,
                  onTap: () => setState(() => _filterFormat = f),
                )),
            const SizedBox(width: 8),
            ...['Tous', 'Publié', 'Brouillon'].map((f) => FormateurChip(
                  label: f == 'Tous' ? 'Statut : Tous' : f,
                  selected: _filterStatut == f,
                  onTap: () => setState(() => _filterStatut = f),
                )),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            FormateurViewToggle(
              mode: _viewMode,
              onChanged: (m) => setState(() => _viewMode = m),
            ),
            const SizedBox(width: 12),
            PopupMenuButton<_CoursSort>(
              tooltip: 'Trier',
              onSelected: (v) => setState(() => _sort = v),
              itemBuilder: (_) => [
                _sortItem('Titre A-Z', _CoursSort.titreAsc),
                _sortItem('Prix décroissant', _CoursSort.prixDesc),
                _sortItem('Apprenants', _CoursSort.apprenantsDesc),
                _sortItem('Revenus', _CoursSort.revenusDesc),
              ],
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: FormateurColors.border),
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
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
            const Spacer(),
            IconButton(
              tooltip: 'Actualiser',
              onPressed: _actionBusy ? null : _fetchCours,
              icon: const Icon(Icons.refresh, color: FormateurColors.muted),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: RefreshIndicator(
            color: FormateurColors.accent,
            onRefresh: _fetchCours,
            child: _filtered.isEmpty
                ? ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      SizedBox(
                        height: 280,
                        child: FormateurEmptyState(
                          icon: Icons.video_library_outlined,
                          title: _cours.isEmpty ? 'Aucun cours publié' : 'Aucun résultat',
                          message: _cours.isEmpty
                              ? 'Créez votre première formation pour commencer à vendre sur NexaMa.'
                              : 'Modifiez la recherche ou les filtres.',
                          actionLabel: _cours.isEmpty ? 'Créer un cours' : null,
                          onAction: widget.onCreateCourse,
                        ),
                      ),
                    ],
                  )
                : _viewMode == FormateurListViewMode.table
                    ? _CoursTableView(
                        cours: _filtered,
                        onManage: _openManageSheet,
                        onRowTap: _openManageSheet,
                      )
                    : ListView.separated(
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (_, i) => _CourseCard(
                          cours: _filtered[i],
                          onManage: () => _openManageSheet(_filtered[i]),
                          onEdit: () => _openEdit(_filtered[i]),
                          onToggleStatut: () => _toggleStatut(_filtered[i]),
                          onDelete: () => _confirmDelete(_filtered[i]),
                        ),
                      ),
          ),
        ),
      ],
    );
  }

  PopupMenuItem<_CoursSort> _sortItem(String label, _CoursSort value) {
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

class _CoursTableView extends StatelessWidget {
  final List<Map<String, dynamic>> cours;
  final void Function(Map<String, dynamic>) onManage;
  final void Function(Map<String, dynamic>) onRowTap;

  const _CoursTableView({required this.cours, required this.onManage, required this.onRowTap});

  static IconData _iconFor(String? key) {
    switch (key) {
      case 'campaign':
        return Icons.campaign;
      case 'web':
        return Icons.web;
      case 'business':
        return Icons.business;
      case 'account_balance':
        return Icons.account_balance;
      case 'code':
        return Icons.code;
      default:
        return Icons.school_outlined;
    }
  }

  static Color _iconColor(int index) {
    const colors = [Color(0xFF8B5CF6), Color(0xFFF59E0B), Color(0xFF3B82F6), Color(0xFF3B82F6), Color(0xFF8B5CF6)];
    return colors[index % colors.length];
  }

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
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Expanded(flex: 4, child: Text('Cours', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold))),
                    Expanded(flex: 2, child: Center(child: Text('Apprenants', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)))),
                    Expanded(flex: 3, child: Center(child: Text('Complétion', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)))),
                    Expanded(flex: 2, child: Align(alignment: Alignment.centerRight, child: Text('Revenus', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.bold)))),
                    SizedBox(width: 48),
                  ],
                ),
              ),
              for (var i = 0; i < cours.length; i++) _TableRow(
                cours: cours[i],
                icon: _iconFor(cours[i]['icone']?.toString()),
                iconColor: _iconColor(i),
                isLast: i == cours.length - 1,
                onTap: () => onRowTap(cours[i]),
                onManage: () => onManage(cours[i]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TableRow extends StatelessWidget {
  final Map<String, dynamic> cours;
  final IconData icon;
  final Color iconColor;
  final bool isLast;
  final VoidCallback onTap;
  final VoidCallback onManage;

  const _TableRow({
    required this.cours,
    required this.icon,
    required this.iconColor,
    required this.isLast,
    required this.onTap,
    required this.onManage,
  });

  @override
  Widget build(BuildContext context) {
    final statut = cours['statut']?.toString() ?? '—';
    final isPublished = statut == 'Publié';
    final statusColor = isPublished ? NexaColors.primaryGreen : const Color(0xFFF59E0B);
    final rate = (cours['taux_completion'] as num?)?.toDouble() ?? 0;
    final revenus = (cours['revenus_mad'] as num?)?.toInt() ?? 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: !isLast ? const Border(bottom: BorderSide(color: FormateurColors.border)) : null,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cours['titre']?.toString() ?? 'Sans titre',
                            style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                            child: Text(statut, style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(child: Text('${cours['apprenants'] ?? 0}', style: GoogleFonts.inter(color: const Color(0xFF475569), fontSize: 13))),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: rate == 0 ? null : rate,
                          backgroundColor: const Color(0xFFE2E8F0),
                          valueColor: const AlwaysStoppedAnimation(NexaColors.primaryGreen),
                          minHeight: 6,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(rate == 0 ? '--' : '${(rate * 100).toInt()}%', style: GoogleFonts.inter(color: FormateurColors.muted, fontSize: 12)),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Text('${formatMad(revenus)} MAD', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13, color: NexaColors.darkNavy)),
                ),
              ),
              IconButton(
                tooltip: 'Gérer',
                onPressed: onManage,
                icon: const Icon(Icons.more_vert, size: 20, color: FormateurColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Map<String, dynamic> cours;
  final VoidCallback onManage;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatut;
  final VoidCallback onDelete;

  const _CourseCard({
    required this.cours,
    required this.onManage,
    required this.onEdit,
    required this.onToggleStatut,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final format = cours['format_media']?.toString() ?? '—';
    final duree = cours['duree_minutes'] ?? 0;
    final prix = cours['prix'] ?? 0;
    final statut = cours['statut']?.toString() ?? 'Brouillon';
    final isPublished = statut == 'Publié';
    final statusColor = isPublished ? NexaColors.primaryGreen : const Color(0xFFF59E0B);
    final rate = (cours['taux_completion'] as num?)?.toDouble() ?? 0;
    final revenus = (cours['revenus_mad'] as num?)?.toInt() ?? 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: FormateurColors.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: FormateurColors.accentLight, borderRadius: BorderRadius.circular(12)),
                child: Icon(format.contains('Vidéo') ? Icons.play_circle_outline : Icons.picture_as_pdf_outlined, color: FormateurColors.accent, size: 28),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(cours['titre']?.toString() ?? 'Sans titre', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 16, color: NexaColors.darkNavy)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                          child: Text(statut, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 4,
                      children: [
                        _miniTag(Icons.category_outlined, format),
                        _miniTag(Icons.timer_outlined, '$duree min'),
                        _miniTag(Icons.people_outline, '${cours['apprenants'] ?? 0} apprenants'),
                        _miniTag(Icons.trending_up, rate == 0 ? '—' : '${(rate * 100).toInt()}% complétion'),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('$prix MAD', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 18, color: NexaColors.primaryGreen)),
                  Text('${formatMad(revenus)} MAD revenus', style: GoogleFonts.inter(fontSize: 11, color: FormateurColors.muted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onManage,
                icon: const Icon(Icons.tune, size: 16),
                label: const Text('Gérer'),
                style: OutlinedButton.styleFrom(foregroundColor: FormateurColors.accent, side: const BorderSide(color: FormateurColors.accent)),
              ),
              const SizedBox(width: 8),
              TextButton(onPressed: onEdit, child: const Text('Modifier')),
              TextButton(onPressed: onToggleStatut, child: Text(isPublished ? 'Brouillon' : 'Publier')),
              const Spacer(),
              IconButton(
                tooltip: 'Supprimer',
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniTag(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: FormateurColors.muted),
        const SizedBox(width: 4),
        Text(text, style: GoogleFonts.inter(fontSize: 12, color: FormateurColors.muted)),
      ],
    );
  }
}

class _ManageCoursSheet extends StatelessWidget {
  final Map<String, dynamic> cours;
  final bool busy;
  final VoidCallback onEdit;
  final VoidCallback onToggleStatut;
  final VoidCallback onDelete;

  const _ManageCoursSheet({
    required this.cours,
    required this.busy,
    required this.onEdit,
    required this.onToggleStatut,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final statut = cours['statut']?.toString() ?? '';
    final isPublished = statut == 'Publié';

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(width: 40, height: 4, decoration: BoxDecoration(color: FormateurColors.border, borderRadius: BorderRadius.circular(2))),
          ),
          const SizedBox(height: 20),
          Text(cours['titre']?.toString() ?? 'Cours', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
          const SizedBox(height: 8),
          Text(
            '${cours['format_media']} · ${cours['prix']} MAD · ${cours['apprenants'] ?? 0} apprenants',
            style: GoogleFonts.inter(fontSize: 13, color: FormateurColors.muted),
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.edit_outlined, color: FormateurColors.accent),
            title: const Text('Modifier'),
            onTap: busy ? null : onEdit,
          ),
          ListTile(
            leading: Icon(isPublished ? Icons.unpublished_outlined : Icons.publish_outlined, color: FormateurColors.accent),
            title: Text(isPublished ? 'Mettre en brouillon' : 'Publier le cours'),
            onTap: busy ? null : onToggleStatut,
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Color(0xFFDC2626)),
            title: const Text('Supprimer', style: TextStyle(color: Color(0xFFDC2626))),
            onTap: busy ? null : onDelete,
          ),
        ],
      ),
    );
  }
}
