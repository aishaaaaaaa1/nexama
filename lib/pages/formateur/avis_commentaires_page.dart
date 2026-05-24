import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/formateur/formateur_ui.dart';

class AvisCommentairesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const AvisCommentairesPage({super.key, this.userData});

  @override
  State<AvisCommentairesPage> createState() => _AvisCommentairesPageState();
}

class _AvisCommentairesPageState extends State<AvisCommentairesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _avis = [];
  int _minStars = 0;

  String get _formateurId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchAvis();
  }

  Future<void> _fetchAvis() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/avis/$_formateurId'));
      if (response.statusCode == 200 && mounted) {
        final raw = json.decode(response.body) as List<dynamic>;
        setState(() {
          _avis = raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  List<Map<String, dynamic>> get _filtered {
    if (_minStars == 0) return _avis;
    return _avis.where((a) => (a['note'] as num?)?.toInt() == _minStars).toList();
  }

  double get _avgNote {
    if (_avis.isEmpty) return 0;
    return _avis.fold<double>(0, (s, a) => s + ((a['note'] as num?)?.toDouble() ?? 0)) / _avis.length;
  }

  Future<void> _replyToAvis(Map<String, dynamic> avis) async {
    final controller = TextEditingController(text: avis['reponse']?.toString() ?? '');
    final reply = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Répondre à ${avis['eleve']}', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: SizedBox(width: 420, child: TextField(controller: controller, maxLines: 4, decoration: const InputDecoration(labelText: 'Votre réponse', border: OutlineInputBorder()))),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Publier')),
        ],
      ),
    );
    controller.dispose();
    if (reply == null || reply.isEmpty || !mounted) return;

    try {
      await ApiService.post(ApiConfig.uri('/api/formateur/avis/$_formateurId/${avis['id']}/reponse'), body: {'reponse': reply});
    } catch (_) {}
    if (!mounted) return;
    setState(() => avis['reponse'] = reply);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Réponse envoyée à ${avis['eleve']}', style: GoogleFonts.inter()), backgroundColor: NexaColors.primaryGreen, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const FormateurLoading();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FormateurPageHeader(
          title: 'Avis & commentaires',
          subtitle: 'Réputation et retours de vos apprenants.',
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [FormateurColors.accent, FormateurColors.accent.withValues(alpha: 0.75)]),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Note moyenne', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                  Text(_avgNote.toStringAsFixed(1), style: GoogleFonts.inter(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
                  Row(children: List.generate(5, (i) => Icon(Icons.star, size: 18, color: i < _avgNote.round() ? Colors.amber : Colors.white30))),
                ],
              ),
              const Spacer(),
              Text('${_avis.length} avis', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            for (final s in [0, 5, 4, 3])
              FormateurChip(label: s == 0 ? 'Tous' : '$s étoiles', selected: _minStars == s, onTap: () => setState(() => _minStars = s)),
          ],
        ),
        const SizedBox(height: 20),
        Expanded(
          child: _filtered.isEmpty
              ? const FormateurEmptyState(icon: Icons.rate_review_outlined, title: 'Aucun avis', message: 'Les commentaires de vos apprenants s’afficheront ici.')
              : ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _buildAvisCard(_filtered[i]),
                ),
        ),
      ],
    );
  }

  Widget _buildAvisCard(Map<String, dynamic> a) {
    final note = (a['note'] as num?)?.toInt() ?? 0;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: FormateurColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(child: Text('${a['eleve'] ?? '?'}'[0])),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${a['eleve']}', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                    Text('${a['date'] ?? 'Récemment'}', style: GoogleFonts.inter(fontSize: 11, color: FormateurColors.muted)),
                  ],
                ),
              ),
              Row(children: List.generate(5, (j) => Icon(Icons.star, size: 16, color: j < note ? Colors.amber : const Color(0xFFE2E8F0)))),
            ],
          ),
          const SizedBox(height: 14),
          Text('${a['texte']}', style: GoogleFonts.inter(fontSize: 14, height: 1.5, color: const Color(0xFF334155))),
          const SizedBox(height: 12),
          if (a['reponse'] != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: FormateurColors.accentLight, borderRadius: BorderRadius.circular(10)),
              child: Text('Votre réponse : ${a['reponse']}', style: GoogleFonts.inter(fontSize: 13, color: NexaColors.darkNavy)),
            ),
            const SizedBox(height: 8),
          ],
          TextButton.icon(
            onPressed: () => _replyToAvis(a),
            icon: const Icon(Icons.reply, size: 18),
            label: Text(a['reponse'] == null ? 'Répondre' : 'Modifier la réponse'),
            style: TextButton.styleFrom(foregroundColor: FormateurColors.accent),
          ),
        ],
      ),
    );
  }
}
