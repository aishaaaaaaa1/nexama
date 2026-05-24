import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/formateur/formateur_ui.dart';

class CreerCoursPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  final VoidCallback? onPublished;

  const CreerCoursPage({super.key, this.userData, this.onPublished});

  @override
  State<CreerCoursPage> createState() => _CreerCoursPageState();
}

class _CreerCoursPageState extends State<CreerCoursPage> {
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  String _categorie = 'IT';
  String _format = 'Vid\u00e9o';
  bool _isSubmitting = false;
  String? _vignetteName;
  Uint8List? _vignetteBytes;

  @override
  void dispose() {
    _titreController.dispose();
    _descriptionController.dispose();
    _prixController.dispose();
    super.dispose();
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: error ? const Color(0xFFB91C1C) : NexaColors.primaryGreen,
      ),
    );
  }

  double? _parsePrixMAD(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp('mad', caseSensitive: false), '').trim();
    s = s.replaceAll(RegExp(r'\s+'), '');
    s = s.replaceAll(',', '.');
    final match = RegExp(r'(\d+\.?\d*)').firstMatch(s);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  String _messageFromResponse(String body, int status) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] != null) {
        return decoded['error'].toString();
      }
    } catch (_) {}
    return 'Erreur lors de la publication (code $status).';
  }

  Future<String?> _resolveFormateurId() async {
    final stored = await AuthService.getUserData();
    return stored?['id']?.toString() ?? widget.userData?['id']?.toString();
  }

  Future<void> _pickVignette() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['png', 'jpg', 'jpeg', 'webp'],
        allowMultiple: false,
        withData: true,
      );
      if (result == null || result.files.isEmpty) return;

      final file = result.files.single;
      if (file.bytes == null || file.bytes!.isEmpty) {
        _showSnack('Impossible de lire le fichier s\u00e9lectionn\u00e9.', error: true);
        return;
      }

      const maxBytes = 5 * 1024 * 1024;
      if (file.bytes!.length > maxBytes) {
        _showSnack('La vignette ne doit pas d\u00e9passer 5 Mo.', error: true);
        return;
      }

      setState(() {
        _vignetteName = file.name;
        _vignetteBytes = file.bytes;
      });
      _showSnack('Vignette ajout\u00e9e.');
    } catch (_) {
      _showSnack('S\u00e9lection de fichier impossible sur cet appareil.', error: true);
    }
  }

  Future<void> _publishCourse() async {
    FocusScope.of(context).unfocus();

    final titre = _titreController.text.trim();
    if (titre.isEmpty) {
      _showSnack('Le titre est obligatoire.', error: true);
      return;
    }

    final description = _descriptionController.text.trim();
    if (description.isEmpty) {
      _showSnack('La description est obligatoire.', error: true);
      return;
    }

    final prix = _parsePrixMAD(_prixController.text);
    if (prix == null || prix < 0) {
      _showSnack('Prix invalide. Exemple attendu : 299.', error: true);
      return;
    }

    final formateurId = await _resolveFormateurId();
    if (formateurId == null || formateurId.isEmpty) {
      _showSnack('Session introuvable. Veuillez vous reconnecter.', error: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final body = <String, dynamic>{
        'titre': titre,
        'description': description,
        'prix': prix,
        'categorie': _categorie,
        'format_media': _format,
        'statut': 'Publi\u00e9',
      };

      if (_vignetteBytes != null && _vignetteName != null) {
        body['vignette_name'] = _vignetteName;
        body['vignette_data'] = base64Encode(_vignetteBytes!);
      }

      final response = await ApiService.post(
        ApiConfig.uri('/api/formateur/cours/$formateurId'),
        body: body,
      );

      if (!mounted) return;
      if (response.statusCode == 201) {
        _showSnack('Cours publi\u00e9 avec succ\u00e8s !');
        _titreController.clear();
        _descriptionController.clear();
        _prixController.clear();
        setState(() {
          _categorie = 'IT';
          _format = 'Vid\u00e9o';
          _vignetteName = null;
          _vignetteBytes = null;
        });
        widget.onPublished?.call();
      } else {
        _showSnack(_messageFromResponse(response.body, response.statusCode), error: true);
      }
    } catch (_) {
      _showSnack(
        "Impossible de joindre l'API (${ApiConfig.baseUrl}). V\u00e9rifiez que le backend tourne.",
        error: true,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FormateurPageHeader(
            title: 'Cr\u00e9er un cours',
            subtitle: 'Publiez une formation : informations, tarif et m\u00e9dias.',
            trailing: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _publishCourse,
              icon: _isSubmitting
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.publish, size: 18),
              label: const Text('Publier'),
              style: formateurGreenStyle(),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: FormateurSectionCard(
                  title: 'Informations g\u00e9n\u00e9rales',
                  child: Column(
                    children: [
                      TextField(controller: _titreController, decoration: _dec('Titre du cours', 'Ex. Ma\u00eetriser Flutter')),
                      const SizedBox(height: 16),
                      TextField(controller: _descriptionController, maxLines: 5, decoration: _dec('Description', 'Objectifs, public cible, pr\u00e9requis...')),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: TextField(controller: _prixController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: _dec('Prix (MAD)', '299'))),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              key: ValueKey('categorie_$_categorie'),
                              initialValue: _categorie,
                              decoration: _dec('Cat\u00e9gorie', null),
                              items: const [
                                DropdownMenuItem(value: 'IT', child: Text('D\u00e9veloppement & IT')),
                                DropdownMenuItem(value: 'Design', child: Text('Design & Cr\u00e9ation')),
                                DropdownMenuItem(value: 'Marketing', child: Text('Marketing Digital')),
                              ],
                              onChanged: (v) => setState(() => _categorie = v!),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        key: ValueKey('format_$_format'),
                        initialValue: _format,
                        decoration: _dec('Format', null),
                        items: const [
                          DropdownMenuItem(value: 'Vid\u00e9o', child: Text('Vid\u00e9o')),
                          DropdownMenuItem(value: 'PDF/Vid\u00e9o', child: Text('Mixte PDF + Vid\u00e9o')),
                          DropdownMenuItem(value: 'PDF', child: Text('Documents PDF')),
                        ],
                        onChanged: (v) => setState(() => _format = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: FormateurSectionCard(
                  title: 'Vignette & m\u00e9dias',
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      color: FormateurColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: FormateurColors.border, style: BorderStyle.solid),
                    ),
                    child: Column(
                      children: [
                        if (_vignetteBytes != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.memory(_vignetteBytes!, width: double.infinity, height: 150, fit: BoxFit.cover),
                          )
                        else
                          Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        Text(
                          _vignetteName ?? 'Ajoutez une vignette',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(color: FormateurColors.muted, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 4),
                        Text('PNG, JPG, WEBP - 1280x720 recommand\u00e9', style: GoogleFonts.inter(fontSize: 11, color: const Color(0xFF94A3B8))),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: _isSubmitting ? null : _pickVignette,
                          icon: const Icon(Icons.folder_open_outlined, size: 18),
                          label: Text(_vignetteBytes == null ? 'Parcourir' : 'Changer'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label, String? hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: FormateurColors.accent, width: 1.5)),
      );
}
