import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

typedef _LiveRow = Map<String, dynamic>;

class LivesWebinairesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const LivesWebinairesPage({super.key, this.userData});

  @override
  State<LivesWebinairesPage> createState() => _LivesWebinairesPageState();
}

class _LivesWebinairesPageState extends State<LivesWebinairesPage> {
  bool _isLoading = true;
  final List<_LiveRow> _lives = [];

  static List<_LiveRow> _seedLives() => [
        {
          'id': 'seed-1',
          'titre': 'Live : Stratégie de croissance',
          'date': '18 Mai 2026',
          'heure': '19:00',
          'inscrits': 42,
        },
        {
          'id': 'seed-2',
          'titre': 'Webinaire — Financement startup',
          'date': '22 Mai 2026',
          'heure': '14:30',
          'inscrits': 28,
        },
      ];

  _LiveRow _normalizeLive(dynamic raw, int index) {
    if (raw is! Map) {
      return {
        'id': 'bad-$index',
        'titre': 'Élément invalide',
        'date': '—',
        'heure': '—',
        'inscrits': 0,
      };
    }
    final m = Map<String, dynamic>.from(raw);
    m.putIfAbsent('id', () => 'srv-$index-${m['titre'] ?? index}');
    m['titre'] = m['titre']?.toString() ?? 'Sans titre';
    m['date'] = m['date']?.toString() ?? '—';
    m['heure'] = m['heure']?.toString() ?? '—';
    final ins = m['inscrits'];
    m['inscrits'] = ins is int ? ins : int.tryParse('$ins') ?? 0;
    return m;
  }

  @override
  void initState() {
    super.initState();
    _fetchLives();
  }

  Future<void> _fetchLives() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/lives/$userId'));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is List) {
          if (decoded.isNotEmpty) {
            setState(() {
              _lives
                ..clear()
                ..addAll(List.generate(decoded.length, (i) => _normalizeLive(decoded[i], i)));
              _isLoading = false;
            });
            return;
          }
          setState(() {
            _lives
              ..clear()
              ..addAll(_seedLives());
            _isLoading = false;
          });
          return;
        }
      }
    } catch (_) {}
    setState(() {
      _lives
        ..clear()
        ..addAll(_seedLives());
      _isLoading = false;
    });
  }

  Future<void> _openProgrammerLive() async {
    final created = await _ProgrammerLiveSheet.show(context);
    if (!mounted || created == null) return;
    setState(() => _lives.insert(0, created));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Live « ${created['titre']} » programmé.', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDelete(_LiveRow live) async {
    final titre = live['titre'] as String? ?? 'ce live';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Supprimer le live ?', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        content: Text('« $titre » sera retiré de la liste.', style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: Text('Supprimer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final id = live['id'];
    setState(() => _lives.removeWhere((e) => e['id'] == id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('« $titre » supprimé.', style: GoogleFonts.inter(fontWeight: FontWeight.w500)), behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _gererLive(_LiveRow live) async {
    final updated = await _GererLiveSheet.show(context, live);
    if (!mounted || updated == null) return;
    setState(() {
      final i = _lives.indexWhere((e) => e['id'] == updated['id']);
      if (i >= 0) _lives[i] = updated;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Live mis à jour.', style: GoogleFonts.inter(fontWeight: FontWeight.w500)), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lives & Webinaires', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Interagissez en direct avec vos apprenants.', style: TextStyle(color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _openProgrammerLive,
              icon: const Icon(Icons.add),
              label: const Text('Programmer un Live'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: _lives.length,
            separatorBuilder: (c, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final live = _lives[index];
              final titre = live['titre'] as String? ?? '';
              final inscrits = live['inscrits'] is int ? live['inscrits'] as int : int.tryParse('${live['inscrits']}') ?? 0;
              return Container(
                key: ValueKey(live['id']),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.live_tv, color: Colors.red),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('${live['date']} à ${live['heure']} • $inscrits inscrits', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Supprimer',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.delete_outline_rounded, size: 22, color: Color(0xFF94A3B8)),
                      style: IconButton.styleFrom(hoverColor: const Color(0xFFFEE2E2), highlightColor: const Color(0xFFFEE2E2)),
                      onPressed: () => _confirmDelete(live),
                    ),
                    const SizedBox(width: 4),
                    ElevatedButton(
                      onPressed: () => _gererLive(live),
                      child: const Text('Gérer'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Dialogue « Programmer un live » — renvoie une ligne pour la liste.
class _ProgrammerLiveSheet extends StatefulWidget {

  static Future<_LiveRow?> show(BuildContext context) {
    return showDialog<_LiveRow>(
      context: context,
      builder: (_) => _ProgrammerLiveSheet(),
    );
  }

  @override
  State<_ProgrammerLiveSheet> createState() => _ProgrammerLiveSheetState();
}

class _ProgrammerLiveSheetState extends State<_ProgrammerLiveSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titre = TextEditingController();
  final _date = TextEditingController(text: '25 Mai 2026');
  final _heure = TextEditingController(text: '18:00');
  int _inscrits = 0;

  @override
  void dispose() {
    _titre.dispose();
    _date.dispose();
    _heure.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(<String, dynamic>{
      'id': 'live-${DateTime.now().millisecondsSinceEpoch}',
      'titre': _titre.text.trim(),
      'date': _date.text.trim(),
      'heure': _heure.text.trim(),
      'inscrits': _inscrits,
    });
  }

  @override
  Widget build(BuildContext context) {
    final dec = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Programmer un live', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(controller: _titre, decoration: dec.copyWith(labelText: 'Titre du live'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _date, decoration: dec.copyWith(labelText: 'Date (ex. 25 Mai 2026)')),
                const SizedBox(height: 12),
                TextFormField(controller: _heure, decoration: dec.copyWith(labelText: 'Heure (ex. 18:00)')),
                const SizedBox(height: 12),
                Text('Inscrits (estimation) : $_inscrits', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                Slider(
                  value: _inscrits.toDouble(),
                  min: 0,
                  max: 200,
                  divisions: 40,
                  label: '$_inscrits',
                  activeColor: NexaColors.primaryGreen,
                  onChanged: (v) => setState(() => _inscrits = (v / 5).round() * 5),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
          child: Text('Programmer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

/// Feuille « Gérer » — met à jour titre, date, heure, inscrits (même id).
class _GererLiveSheet extends StatefulWidget {
  const _GererLiveSheet({required this.initial});

  final _LiveRow initial;

  static Future<_LiveRow?> show(BuildContext context, _LiveRow live) {
    return showDialog<_LiveRow>(
      context: context,
      builder: (_) => _GererLiveSheet(initial: Map<String, dynamic>.from(live)),
    );
  }

  @override
  State<_GererLiveSheet> createState() => _GererLiveSheetState();
}

class _GererLiveSheetState extends State<_GererLiveSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titre;
  late final TextEditingController _date;
  late final TextEditingController _heure;
  late int _inscrits;

  @override
  void initState() {
    super.initState();
    final m = widget.initial;
    _titre = TextEditingController(text: '${m['titre'] ?? ''}');
    _date = TextEditingController(text: '${m['date'] ?? ''}');
    _heure = TextEditingController(text: '${m['heure'] ?? ''}');
    _inscrits = m['inscrits'] is int ? m['inscrits'] as int : int.tryParse('${m['inscrits']}') ?? 0;
  }

  @override
  void dispose() {
    _titre.dispose();
    _date.dispose();
    _heure.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(<String, dynamic>{
      'id': widget.initial['id'],
      'titre': _titre.text.trim(),
      'date': _date.text.trim(),
      'heure': _heure.text.trim(),
      'inscrits': _inscrits,
    });
  }

  @override
  Widget build(BuildContext context) {
    final dec = InputDecoration(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Gérer le live', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(controller: _titre, decoration: dec.copyWith(labelText: 'Titre'), validator: (v) => (v == null || v.trim().isEmpty) ? 'Requis' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _date, decoration: dec.copyWith(labelText: 'Date')),
                const SizedBox(height: 12),
                TextFormField(controller: _heure, decoration: dec.copyWith(labelText: 'Heure')),
                const SizedBox(height: 12),
                Text('Inscrits : $_inscrits', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                Slider(
                  value: _inscrits.clamp(0, 200).toDouble(),
                  min: 0,
                  max: 200,
                  divisions: 40,
                  label: '$_inscrits',
                  activeColor: NexaColors.primaryGreen,
                  onChanged: (v) => setState(() => _inscrits = (v / 5).round() * 5),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
          child: Text('Enregistrer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
