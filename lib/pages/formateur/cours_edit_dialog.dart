import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/formateur/formateur_ui.dart';

class CoursEditDialog extends StatefulWidget {
  final Map<String, dynamic> cours;
  final String formateurId;

  const CoursEditDialog({super.key, required this.cours, required this.formateurId});

  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required Map<String, dynamic> cours,
    required String formateurId,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => CoursEditDialog(cours: cours, formateurId: formateurId),
    );
  }

  @override
  State<CoursEditDialog> createState() => _CoursEditDialogState();
}

class _CoursEditDialogState extends State<CoursEditDialog> {
  late final TextEditingController _titre;
  late final TextEditingController _prix;
  late String _format;
  late String _statut;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _titre = TextEditingController(text: widget.cours['titre']?.toString() ?? '');
    _prix = TextEditingController(text: '${widget.cours['prix'] ?? 0}');
    _format = widget.cours['format_media']?.toString() ?? 'Vidéo';
    _statut = widget.cours['statut']?.toString() ?? 'Brouillon';
  }

  @override
  void dispose() {
    _titre.dispose();
    _prix.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_titre.text.trim().isEmpty) return;
    setState(() => _saving = true);
    try {
      final body = {
        'titre': _titre.text.trim(),
        'prix': double.tryParse(_prix.text) ?? 0,
        'format_media': _format,
        'statut': _statut,
      };
      final response = await ApiService.put(
        ApiConfig.uri('/api/formateur/cours/${widget.formateurId}/${widget.cours['id']}'),
        body: body,
      );
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        Navigator.pop(context, Map<String, dynamic>.from(data['cours'] as Map));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour.'), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Impossible de contacter le serveur.'), behavior: SnackBarBehavior.floating),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Modifier le cours', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titre,
              decoration: InputDecoration(
                labelText: 'Titre',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prix,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Prix (MAD)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('format_$_format'),
              initialValue: _format,
              decoration: InputDecoration(
                labelText: 'Format',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: const [
                DropdownMenuItem(value: 'Vidéo', child: Text('Vidéo')),
                DropdownMenuItem(value: 'PDF/Vidéo', child: Text('Mixte PDF + Vidéo')),
                DropdownMenuItem(value: 'PDF', child: Text('PDF')),
              ],
              onChanged: (v) => setState(() => _format = v ?? 'Vidéo'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              key: ValueKey('statut_$_statut'),
              initialValue: _statut,
              decoration: InputDecoration(
                labelText: 'Statut',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              items: const [
                DropdownMenuItem(value: 'Publié', child: Text('Publié')),
                DropdownMenuItem(value: 'Brouillon', child: Text('Brouillon')),
              ],
              onChanged: (v) => setState(() => _statut = v ?? 'Brouillon'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Annuler')),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(backgroundColor: FormateurColors.accent),
          child: _saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
              : const Text('Enregistrer'),
        ),
      ],
    );
  }
}
