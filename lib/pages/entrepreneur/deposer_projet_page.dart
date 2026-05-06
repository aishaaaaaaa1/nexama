import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class DeposerProjetPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const DeposerProjetPage({super.key, this.userData});

  @override
  State<DeposerProjetPage> createState() => _DeposerProjetPageState();
}

class _DeposerProjetPageState extends State<DeposerProjetPage> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Form Controllers
  final _nomController = TextEditingController();
  final _shortDescController = TextEditingController();
  final _longDescController = TextEditingController();
  final _budgetController = TextEditingController();
  final _villeController = TextEditingController();
  final _equipeProfilsController = TextEditingController();
  final _videoUrlController = TextEditingController();
  
  String _secteur = 'IT & Digital';
  String _stade = 'Amorçage';
  int _equipeTaille = 1;
  String? _pdfName;

  final List<String> _secteurs = ['IT & Digital', 'Agriculture', 'E-commerce', 'Industrie', 'Santé', 'Énergie', 'Autre'];
  final List<String> _stades = ['Idée', 'Amorçage', 'MVP', 'Croissance', 'Expansion'];

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final body = {
        'nom': _nomController.text,
        'description': _shortDescController.text,
        'description_detaillee': _longDescController.text,
        'secteur': _secteur,
        'budget_recherche': double.tryParse(_budgetController.text) ?? 0,
        'stade_evolution': _stade,
        'ville': _villeController.text,
        'equipe_taille': _equipeTaille,
        'equipe_profils': _equipeProfilsController.text,
        'video_url': _videoUrlController.text,
        'pdf_url': _pdfName != null ? 'https://storage.nexama.ma/pitches/$_pdfName' : null,
      };

      final response = await ApiService.post(
        ApiConfig.uri('/api/entrepreneur/projets'),
        body: body,
      );

      if (response.statusCode == 201 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Projet déposé avec succès !'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      } else {
        throw Exception('Erreur lors du dépôt');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Déposer un Projet', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: NexaColors.darkNavy,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildStepIndicator(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
                    ),
                    child: _buildCurrentStepContent(),
                  ),
                ),
              ),
            ),
            _buildBottomActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      color: Colors.white,
      child: Row(
        children: List.generate(5, (index) {
          bool isCompleted = index < _currentStep;
          bool isActive = index == _currentStep;
          return Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCompleted ? NexaColors.primaryGreen : (isActive ? NexaColors.primaryGreen.withOpacity(0.1) : Colors.grey[200]),
                    shape: BoxShape.circle,
                    border: isActive ? Border.all(color: NexaColors.primaryGreen, width: 2) : null,
                  ),
                  child: Center(
                    child: isCompleted 
                      ? const Icon(Icons.check, color: Colors.white, size: 16)
                      : Text('${index + 1}', style: TextStyle(color: isActive ? NexaColors.primaryGreen : Colors.grey, fontWeight: FontWeight.bold)),
                  ),
                ),
                if (index < 4)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isCompleted ? NexaColors.primaryGreen : Colors.grey[200],
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0: return _buildStep1();
      case 1: return _buildStep2();
      case 2: return _buildStep3();
      case 3: return _buildStep4();
      case 4: return _buildStep5();
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Identité du Projet'),
        const SizedBox(height: 24),
        _buildTextField('Nom du projet', _nomController, 'Ex: GreenAgri Tech', Icons.business),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: _buildDropdown('Secteur d\'activité', _secteur, _secteurs, (v) => setState(() => _secteur = v!))),
            const SizedBox(width: 20),
            Expanded(child: _buildTextField('Ville / Région', _villeController, 'Ex: Casablanca', Icons.location_on)),
          ],
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Le Pitch'),
        const SizedBox(height: 24),
        _buildTextField('Pitch court (2-3 lignes)', _shortDescController, 'Résumez votre projet...', Icons.short_text, maxLines: 3),
        const SizedBox(height: 20),
        _buildTextField('Description détaillée', _longDescController, 'Expliquez votre vision, le problème et la solution...', Icons.description, maxLines: 8),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Finances & Stade'),
        const SizedBox(height: 24),
        _buildTextField('Budget recherché (MAD)', _budgetController, 'Ex: 500000', Icons.account_balance_wallet, isNumeric: true),
        const SizedBox(height: 20),
        _buildDropdown('Stade actuel de développement', _stade, _stades, (v) => setState(() => _stade = v!)),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('L\'Équipe'),
        const SizedBox(height: 24),
        Text('Taille de l\'équipe : $_equipeTaille personnes', style: const TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _equipeTaille.toDouble(),
          min: 1, max: 20, divisions: 19,
          activeColor: NexaColors.primaryGreen,
          onChanged: (v) => setState(() => _equipeTaille = v.toInt()),
        ),
        const SizedBox(height: 20),
        _buildTextField('Profils clés', _equipeProfilsController, 'Ex: 1 CEO, 2 Développeurs, 1 Commercial', Icons.people, maxLines: 3),
      ],
    );
  }

  Widget _buildStep5() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Documents & Média'),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.none),
          ),
          child: Column(
            children: [
              const Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(_pdfName ?? 'Téléverser votre Pitch Deck (PDF)', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => setState(() => _pdfName = 'PitchDeck_NexaMa.pdf'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: NexaColors.darkNavy),
                child: const Text('Sélectionner un fichier'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField('Lien Vidéo Pitch (Optionnel)', _videoUrlController, 'Lien YouTube ou Vimeo', Icons.video_library),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.darkNavy));
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, IconData icon, {int maxLines = 1, bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
          validator: (v) => (v == null || v.isEmpty) ? 'Ce champ est requis' : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String value, List<String> items, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            OutlinedButton(onPressed: _prevStep, child: const Text('Précédent'))
          else
            const SizedBox.shrink(),
          
          Row(
            children: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Sauvegarder en brouillon', style: TextStyle(color: Colors.grey))),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _nextStep,
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                child: _isSubmitting 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text(_currentStep == 4 ? 'Soumettre le projet' : 'Suivant'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
