import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class BusinessPlanIAPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const BusinessPlanIAPage({super.key, this.userData});

  @override
  State<BusinessPlanIAPage> createState() => _BusinessPlanIAPageState();
}

class _BusinessPlanIAPageState extends State<BusinessPlanIAPage> {
  int _currentStep = 0;
  bool _isGenerating = false;
  Map<String, dynamic>? _currentPlan;
  Map<String, dynamic>? _currentVersion;

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Nom', 'label': 'Nom de votre projet', 'hint': 'Ex: EcoTrans Morocco, FoodieDelivery...', 'controller': TextEditingController()},
    {'title': 'Secteur', 'label': 'Secteur d\'activité', 'hint': 'Ex: Fintech, Agriculture, E-commerce...', 'controller': TextEditingController()},
    {'title': 'Produit', 'label': 'Description du produit/service', 'hint': 'Détaillez ce que vous proposez...', 'controller': TextEditingController()},
    {'title': 'Problème', 'label': 'Quel problème résolvez-vous ?', 'hint': 'Pourquoi vos clients ont-ils besoin de vous ?', 'controller': TextEditingController()},
    {'title': 'Cible', 'label': 'Client cible (Persona)', 'hint': 'Ex: Étudiants, Entreprises de transport...', 'controller': TextEditingController()},
    {'title': 'Modèle', 'label': 'Prix / Modèle de revenu', 'hint': 'Comment allez-vous gagner de l\'argent ?', 'controller': TextEditingController()},
    {'title': 'Concurrents', 'label': 'Concurrents principaux', 'hint': 'Qui sont vos rivaux directs/indirects ?', 'controller': TextEditingController()},
    {'title': 'Avantage', 'label': 'Avantage concurrentiel', 'hint': 'Pourquoi vous et pas eux ?', 'controller': TextEditingController()},
    {'title': 'Budget', 'label': 'Budget initial estimé', 'hint': 'Montant pour démarrer le projet...', 'controller': TextEditingController()},
    {'title': 'Objectif', 'label': 'Objectif sur 1-3 ans', 'hint': 'Ex: Devenir leader régional, 10M MAD CA...', 'controller': TextEditingController()},
  ];

  Future<void> _exportPdf() async {
    if (_currentPlan == null) return;
    try {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération du PDF...')));
      final response = await ApiService.get(ApiConfig.uri('/api/business-plan/${_currentPlan!['id']}/export'));
      if (response.statusCode == 200) {
        final blob = html.Blob([response.bodyBytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', 'BusinessPlan_${_currentPlan!['nom_projet']}.pdf')
          ..click();
        html.Url.revokeObjectUrl(url);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ PDF téléchargé !'), backgroundColor: Colors.green));
      }
    } catch (e) {
      debugPrint('Export error: $e');
    }
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    try {
      final Map<String, String> reponses = {};
      for (int i = 0; i < _steps.length; i++) {
        reponses['q${i+1}'] = _steps[i]['controller'].text;
      }

      final response = await ApiService.post(
        ApiConfig.uri('/api/business-plan/generate'),
        body: {
          'nom_projet': _steps[0]['controller'].text,
          'secteur': _steps[1]['controller'].text,
          'reponses_form': reponses,
        },
      );

      if (response.statusCode == 201 && mounted) {
        final data = json.decode(response.body);
        setState(() {
          _currentPlan = data['plan'];
          _currentVersion = data['version'];
          _isGenerating = false;
        });
      }
    } catch (e) {
      debugPrint('Generation error: $e');
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(),
        const SizedBox(height: 32),
        if (_isGenerating)
          _buildLoadingState()
        else if (_currentVersion != null)
          _buildResultView()
        else
          _buildStepper(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Générateur Business Plan IA', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
            const SizedBox(height: 4),
            Text('Obtenez un plan professionnel complet en 60 secondes.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
        if (_currentVersion != null)
          ElevatedButton.icon(
            onPressed: () => setState(() {
              _currentVersion = null;
              _currentStep = 0;
            }),
            icon: const Icon(Icons.refresh),
            label: const Text('Nouveau Plan'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: NexaColors.darkNavy),
          ),
      ],
    );
  }

  Widget _buildStepper() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Étape ${_currentStep + 1} sur ${_steps.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
              const Spacer(),
              SizedBox(width: 200, child: LinearProgressIndicator(value: (_currentStep + 1) / _steps.length, backgroundColor: Colors.grey[100], valueColor: const AlwaysStoppedAnimation(NexaColors.primaryGreen))),
            ],
          ),
          const SizedBox(height: 40),
          Text(_steps[_currentStep]['label'], style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 16),
          TextField(
            controller: _steps[_currentStep]['controller'],
            maxLines: 4,
            decoration: InputDecoration(
              hintText: _steps[_currentStep]['hint'],
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexaColors.primaryGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                TextButton(onPressed: () => setState(() => _currentStep--), child: const Text('Précédent'))
              else
                const SizedBox(),
              ElevatedButton(
                onPressed: () {
                  if (_currentStep < _steps.length - 1) {
                    setState(() => _currentStep++);
                  } else {
                    _generatePlan();
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Text(_currentStep < _steps.length - 1 ? 'Continuer' : 'Générer mon Business Plan 🚀'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 100),
          const CircularProgressIndicator(color: NexaColors.primaryGreen),
          const SizedBox(height: 24),
          Text('NexaAI rédige votre plan...', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Cela prend environ 30-45 secondes.', style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildResultView() {
    final sections = _currentVersion!['contenu_json'] as Map<String, dynamic>;
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          children: [
            _buildResultActions(),
            const SizedBox(height: 24),
            ...sections.entries.map((e) => _buildSectionCard(e.key, e.value)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit), label: const Text('Modifier')),
        const SizedBox(width: 12),
        ElevatedButton.icon(
          onPressed: _exportPdf,
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Exporter PDF'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
        ),
      ],
    );
  }

  Widget _buildSectionCard(String key, String content) {
    String title = key.toUpperCase();
    if (key == 'resume') title = 'Résumé Exécutif';
    if (key == 'marche') title = 'Étude de Marché';
    if (key == 'swot') title = 'Analyse SWOT';
    if (key == 'modele') title = 'Modèle Économique';
    if (key == 'marketing') title = 'Stratégie Marketing';
    if (key == 'financier') title = 'Prévisions Financières';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
          const Divider(height: 32),
          Text(content, style: const TextStyle(fontSize: 15, height: 1.6, color: Color(0xFF334155))),
        ],
      ),
    );
  }
}
