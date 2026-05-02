import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class CreerCoursPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const CreerCoursPage({super.key, this.userData});

  @override
  State<CreerCoursPage> createState() => _CreerCoursPageState();
}

class _CreerCoursPageState extends State<CreerCoursPage> {
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  String _categorie = 'IT';
  bool _isSubmitting = false;

  Future<void> _publishCourse() async {
    if (_titreController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.post(
        ApiConfig.uri('/api/formateur/cours/$userId'),
        body: {
          'titre': _titreController.text,
          'description': _descriptionController.text,
          'prix': double.tryParse(_prixController.text) ?? 0.0,
          'categorie': _categorie,
        },
      );

      if (mounted) {
        if (response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cours publié avec succès !')));
          _titreController.clear();
          _descriptionController.clear();
          _prixController.clear();
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Créer un nouveau cours', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _publishCourse,
              icon: _isSubmitting ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Icon(Icons.check),
              label: const Text('Publier le cours'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Informations générales', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              TextField(
                controller: _titreController,
                decoration: const InputDecoration(labelText: 'Titre du cours', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description détaillée', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _prixController,
                      decoration: const InputDecoration(labelText: 'Prix (MAD)', border: OutlineInputBorder()),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _categorie,
                      decoration: const InputDecoration(labelText: 'Catégorie', border: OutlineInputBorder()),
                      items: const [
                        DropdownMenuItem(value: 'IT', child: Text('Développement Web & IT')),
                        DropdownMenuItem(value: 'Design', child: Text('Design & Création')),
                        DropdownMenuItem(value: 'Marketing', child: Text('Marketing Digital')),
                      ],
                      onChanged: (v) => setState(() => _categorie = v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Contenu Média (Simulé)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40),
                decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFCBD5E1), style: BorderStyle.solid)),
                child: Column(
                  children: [
                    const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text('Glissez-déposez la vignette du cours ici', style: GoogleFonts.inter(color: Colors.grey[700])),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: NexaColors.darkNavy),
                      child: const Text('Parcourir les fichiers'),
                    )
                  ],
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
