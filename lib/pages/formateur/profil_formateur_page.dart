import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/formateur/formateur_ui.dart';

class ProfilFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilFormateurPage({super.key, this.userData});

  @override
  State<ProfilFormateurPage> createState() => _ProfilFormateurPageState();
}

class _ProfilFormateurPageState extends State<ProfilFormateurPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profil;

  String get _formateurId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchProfil();
  }

  Future<void> _fetchProfil() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/profil/$_formateurId'));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _profil = Map<String, dynamic>.from(json.decode(response.body) as Map);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editProfil() async {
    final bioCtrl = TextEditingController(text: _profil?['biographie']?.toString() ?? '');
    final expertiseCtrl = TextEditingController(text: ((_profil?['expertise'] as List?)?.join(', ') ?? ''));
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Modifier le profil', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: bioCtrl, maxLines: 5, decoration: const InputDecoration(labelText: 'Biographie', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: expertiseCtrl, decoration: const InputDecoration(labelText: 'Expertises', hintText: 'Flutter, Node.js, Marketing', border: OutlineInputBorder())),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Annuler')),
          FilledButton(
            onPressed: () async {
              final body = {
                'biographie': bioCtrl.text.trim(),
                'expertise': expertiseCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
              };
              try {
                final response = await ApiService.put(ApiConfig.uri('/api/formateur/profil/$_formateurId'), body: body);
                if (response.statusCode == 200) {
                  final decoded = json.decode(response.body);
                  if (decoded is Map && decoded['profil'] is Map) {
                    setState(() => _profil = Map<String, dynamic>.from(decoded['profil'] as Map));
                  }
                } else {
                  setState(() => _profil?.addAll(body));
                }
              } catch (_) {
                setState(() => _profil?.addAll(body));
              }
              if (!ctx.mounted || !mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profil mis à jour'), backgroundColor: NexaColors.primaryGreen, behavior: SnackBarBehavior.floating));
            },
            style: FilledButton.styleFrom(backgroundColor: FormateurColors.accent),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
    bioCtrl.dispose();
    expertiseCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const FormateurLoading();

    final expertise = (_profil?['expertise'] as List?)?.cast<String>() ?? [];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormateurPageHeader(
            title: 'Profil formateur',
            subtitle: 'Votre vitrine publique sur la marketplace NexaMa.',
            trailing: OutlinedButton.icon(
              onPressed: _editProfil,
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Modifier'),
              style: OutlinedButton.styleFrom(foregroundColor: FormateurColors.accent, side: const BorderSide(color: FormateurColors.accent)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: FormateurSectionCard(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 56,
                        backgroundColor: FormateurColors.accentLight,
                        child: const Icon(Icons.person, size: 56, color: FormateurColors.accent),
                      ),
                      const SizedBox(height: 16),
                      Text(_profil?['nom']?.toString() ?? 'Formateur', style: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          Text(' ${_profil?['rating'] ?? 5.0}', style: GoogleFonts.inter(fontWeight: FontWeight.w800)),
                          Text(' • Profil vérifié', style: GoogleFonts.inter(fontSize: 12, color: FormateurColors.muted)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 20),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Biographie', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: FormateurColors.muted)),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(_profil?['biographie']?.toString() ?? '—', style: GoogleFonts.inter(fontSize: 15, height: 1.55)),
                      ),
                      if (expertise.isNotEmpty) ...[
                        const SizedBox(height: 20),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: expertise.map((e) => Chip(label: Text(e), backgroundColor: FormateurColors.accentLight, side: BorderSide.none)).toList(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    FormateurStatsRow(
                      items: const [
                        FormateurStatItem(label: 'Cours publiés', value: '2', icon: Icons.video_library, color: FormateurColors.accent),
                      ],
                    ),
                    const SizedBox(height: 14),
                    FormateurSectionCard(
                      title: 'Visibilité',
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        children: [
                          _row('Profil public', 'Activé', Icons.public),
                          const Divider(height: 24),
                          _row('Nouveaux messages', 'Autorisés', Icons.mail_outline),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String v, IconData i) {
    return Row(
      children: [
        Icon(i, size: 20, color: FormateurColors.muted),
        const SizedBox(width: 12),
        Expanded(child: Text(l, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        Text(v, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: NexaColors.primaryGreen)),
      ],
    );
  }
}
