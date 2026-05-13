import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class ProposeServicePage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  /// Quand le formulaire est intégré au tableau de bord (sans route), le retour arrière appelle ce callback au lieu de [Navigator.pop].
  final VoidCallback? onPopRequested;

  /// Après publication réussie (201). Si null, on fait [Navigator.pop] avec le service créé.
  final VoidCallback? onPublishSuccess;

  const ProposeServicePage({
    super.key,
    this.userData,
    this.onPopRequested,
    this.onPublishSuccess,
  });

  @override
  State<ProposeServicePage> createState() => _ProposeServicePageState();
}

class _ProposeServicePageState extends State<ProposeServicePage> {
  final _formKey = GlobalKey<FormState>();
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  String _categorie = 'Design';
  bool _isSubmitting = false;

  /// Accepte "500", "1 500", "MAD 500", etc.
  double? _parsePrixMAD(String raw) {
    var s = raw.trim();
    s = s.replaceAll(RegExp('mad', caseSensitive: false), '').trim();
    s = s.replaceAll(RegExp(r'\s+'), '');
    s = s.replaceAll(',', '.');
    final match = RegExp(r'(\d+\.?\d*)').firstMatch(s);
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        backgroundColor: error ? const Color(0xFFB91C1C) : null,
      ),
    );
  }

  String _messageFromResponse(String body, int status) {
    try {
      final m = jsonDecode(body);
      if (m is Map && m['error'] != null) return m['error'].toString();
    } catch (_) {}
    return 'Erreur lors de la publication (code $status).';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('Veuillez remplir correctement tous les champs obligatoires.', error: true);
      return;
    }

    final stored = await AuthService.getUserData();
    final userId = stored?['id']?.toString() ?? widget.userData?['id']?.toString();
    if (userId == null || userId.isEmpty) {
      _showSnack('Session introuvable. Veuillez vous reconnecter.', error: true);
      return;
    }

    final prix = _parsePrixMAD(_prixController.text);
    if (prix == null || prix < 0) {
      _showSnack('Prix invalide. Indiquez un montant en MAD (ex. 500).', error: true);
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService.post(
        ApiConfig.uri('/api/prestataire/services/$userId'),
        body: {
          'titre': _titreController.text.trim(),
          'description': _descriptionController.text.trim(),
          'prix_base': prix,
          'categorie': _categorie,
        },
      );

      if (mounted) {
        if (response.statusCode == 201) {
          _showSnack('Service publié avec succès !');
          Map<String, dynamic>? created;
          try {
            final map = jsonDecode(response.body);
            if (map is Map<String, dynamic> && map['service'] is Map) {
              created = Map<String, dynamic>.from(map['service'] as Map);
            }
          } catch (_) {}
          if (widget.onPublishSuccess != null) {
            widget.onPublishSuccess!();
          } else {
            Navigator.pop(context, created);
          }
        } else {
          final msg = _messageFromResponse(response.body, response.statusCode);
          _showSnack(msg, error: true);
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack(
          "Impossible de joindre l'API (${ApiConfig.baseUrl}). Vérifiez que le backend tourne (port 3000 ou --dart-define=API_BASE_URL=...).",
          error: true,
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposer un nouveau service'),
        backgroundColor: Colors.white,
        foregroundColor: NexaColors.darkNavy,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (widget.onPopRequested != null) {
              widget.onPopRequested!();
            } else {
              Navigator.maybePop(context);
            }
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomPad = MediaQuery.of(context).viewPadding.bottom + 120;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(32, 32, 32, bottomPad),
            child: Center(
              child: Container(
                constraints: const BoxConstraints(maxWidth: 600),
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Détails du service', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _titreController,
                    decoration: const InputDecoration(labelText: 'Titre du service (ex: Création de Logo)', border: OutlineInputBorder()),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _categorie,
                    decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                    items: ['Design', 'IT & Développement', 'Marketing', 'Rédaction', 'Conseil'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                    onChanged: (v) => setState(() => _categorie = v!),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description détaillée', border: OutlineInputBorder()),
                    maxLines: 5,
                    validator: (v) => v == null || v.trim().isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Prix de base (MAD)',
                    style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600, color: NexaColors.darkNavy),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Tapez uniquement le montant (ex. 500 ou 1 500). Pas besoin d’écrire « MAD ».',
                    style: GoogleFonts.inter(fontSize: 12, color: const Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _prixController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                          textInputAction: TextInputAction.done,
                          autocorrect: false,
                          enableSuggestions: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'[0-9.,\s]')),
                          ],
                          decoration: InputDecoration(
                            hintText: '500',
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: const OutlineInputBorder(),
                            enabledBorder: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFFE2E8F0))),
                            focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: NexaColors.primaryGreen, width: 2)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Champ requis';
                            final p = _parsePrixMAD(v);
                            if (p == null || p < 0) return 'Montant invalide';
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 14),
                        child: Text(
                          'MAD',
                          style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: NexaColors.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting
                          ? null
                          : () {
                              FocusScope.of(context).unfocus();
                              _submit();
                            },
                      style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
                      child: _isSubmitting ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Publier mon service', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
