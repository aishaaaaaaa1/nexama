import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class ProposeServicePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProposeServicePage({super.key, this.userData});

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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.post(
        ApiConfig.uri('/api/prestataire/services/$userId'),
        body: {
          'titre': _titreController.text,
          'description': _descriptionController.text,
          'prix_base': double.tryParse(_prixController.text) ?? 0.0,
          'categorie': _categorie,
        },
      );

      if (mounted) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Service publié avec succès !')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors de la publication.')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Une erreur est survenue.')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proposer un nouveau service'), backgroundColor: Colors.white, foregroundColor: NexaColors.darkNavy, elevation: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
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
                    validator: (v) => v!.isEmpty ? 'Champ requis' : null,
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
                    validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _prixController,
                    decoration: const InputDecoration(labelText: 'Prix de base (MAD)', border: OutlineInputBorder(), prefixText: 'MAD '),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
                      child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Publier mon service', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
