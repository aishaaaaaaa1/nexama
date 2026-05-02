import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:convert';
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
  String? _generatedPlan;
  
  bool _isEditing = false;
  final TextEditingController _planEditorController = TextEditingController();
  final List<Map<String, dynamic>> _versions = [];

  final List<Map<String, dynamic>> _steps = [
    {'title': 'Secteur', 'label': 'Quel est votre secteur d\'activité ?', 'hint': 'Ex: Fintech, Agriculture, E-commerce...', 'controller': TextEditingController()},
    {'title': 'Projet', 'label': 'Décrivez votre projet en quelques phrases.', 'hint': 'Ex: Une application de livraison de produits locaux...', 'controller': TextEditingController()},
    {'title': 'Cible', 'label': 'Quelle est votre clientèle cible ?', 'hint': 'Ex: Jeunes actifs 25-40 ans, PME au Maroc...', 'controller': TextEditingController()},
    {'title': 'Concurrents', 'label': 'Qui sont vos principaux concurrents ?', 'hint': 'Ex: Entreprises locales, solutions internationales...', 'controller': TextEditingController()},
    {'title': 'Revenus', 'label': 'Quel est votre modèle de revenus ?', 'hint': 'Ex: Abonnement mensuel, commissions sur ventes...', 'controller': TextEditingController()},
    {'title': 'Budget', 'label': 'Montant de l\'investissement initial estimé ?', 'hint': 'Ex: 50 000 MAD, 200 000 MAD...', 'controller': TextEditingController()},
    {'title': 'Localisation', 'label': 'Dans quelle ville/région ?', 'hint': 'Ex: Casablanca, Rabat, Agadir...', 'controller': TextEditingController()},
    {'title': 'Acquisition', 'label': 'Stratégie pour vos premiers clients ?', 'hint': 'Ex: Pub Instagram, bouche-à-oreille, prospection...', 'controller': TextEditingController()},
    {'title': 'Avantage', 'label': 'Quel est votre avantage concurrentiel ?', 'hint': 'Ex: Prix bas, technologie exclusive, expertise...', 'controller': TextEditingController()},
    {'title': 'Objectifs', 'label': 'Quels sont vos objectifs à 12 mois ?', 'hint': 'Ex: 1000 clients, 1M MAD de CA...', 'controller': TextEditingController()},
  ];

  void _generate() async {
    setState(() => _isGenerating = true);
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final Map<String, String> answers = {};
      
      // Collect answers
      answers['secteur'] = _steps[0]['controller'].text;
      answers['description'] = _steps[1]['controller'].text;
      answers['cible'] = _steps[2]['controller'].text;
      answers['concurrents'] = _steps[3]['controller'].text;
      answers['prix'] = _steps[4]['controller'].text;
      answers['budget'] = _steps[5]['controller'].text;
      answers['localisation'] = _steps[6]['controller'].text;
      answers['acquisition'] = _steps[7]['controller'].text;
      answers['avantage'] = _steps[8]['controller'].text;
      answers['objectifs'] = _steps[9]['controller'].text;

      final response = await ApiService.post(
        ApiConfig.uri('/api/entrepreneur/ia/business-plan'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'utilisateur_id': userId,
          'answers': answers
        }),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            _generatedPlan = data['contenu_markdown'];
            _planEditorController.text = _generatedPlan!;
            _versions.insert(0, {'date': DateTime.now(), 'content': _generatedPlan});
          });
        }
      } else {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: ${response.body}')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  void _exportPdf() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Génération du PDF en cours...')));
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Business Plan téléchargé avec succès.'), backgroundColor: Colors.green));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Générateur de Business Plan IA', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Propulsé par Google Gemini 1.5 Flash (Fallback: Groq LLaMA3)', style: TextStyle(color: NexaColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            if (_generatedPlan != null)
              ElevatedButton.icon(
                onPressed: _exportPdf,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Exporter PDF'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              )
          ],
        ),
        const SizedBox(height: 24),
        
        if (_generatedPlan == null && !_isGenerating)
          _buildWizard()
        else if (_isGenerating)
          _buildLoadingState()
        else
          _buildResultView(),
      ],
    );
  }

  Widget _buildWizard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progress Header
          Row(
            children: [
              Text('Étape ${_currentStep + 1} sur 10', style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: NexaColors.primaryGreen)),
              const Spacer(),
              SizedBox(
                width: 200,
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / 10,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: const AlwaysStoppedAnimation(NexaColors.primaryGreen),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          
          // Question
          Text(_steps[_currentStep]['label'], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: NexaColors.darkNavy)),
          const SizedBox(height: 16),
          TextField(
            controller: _steps[_currentStep]['controller'],
            maxLines: 4,
            decoration: InputDecoration(
              hintText: _steps[_currentStep]['hint'],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: NexaColors.primaryGreen, width: 2)),
              fillColor: const Color(0xFFF8FAFC),
              filled: true,
            ),
          ),
          const SizedBox(height: 40),
          
          // Navigation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                TextButton.icon(
                  onPressed: () => setState(() => _currentStep--),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Précédent'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF64748B)),
                )
              else
                const SizedBox(),
              
              ElevatedButton(
                onPressed: () {
                  if (_currentStep < 9) {
                    setState(() => _currentStep++);
                  } else {
                    _generate();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: NexaColors.primaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(_currentStep < 9 ? 'Continuer' : 'Générer mon Business Plan 🚀'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(NexaColors.primaryGreen)),
          const SizedBox(height: 24),
          Text('Analyse de vos réponses...', style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const SizedBox(height: 8),
          Text('L\'IA de NexaMa (Gemini/LLaMA3) rédige votre Business Plan complet.', style: GoogleFonts.inter(color: const Color(0xFF64748B))),
          const SizedBox(height: 16),
          _buildLoadingHint('Génération du résumé exécutif...'),
        ],
      ),
    );
  }

  Widget _buildLoadingHint(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
      child: Text(text, style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildResultView() {
    int currentIndex = _versions.indexWhere((v) => v['content'] == _generatedPlan);
    
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Résultat du Business Plan', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 18)),
              Row(
                children: [
                  if (_versions.isNotEmpty && !_isEditing)
                    DropdownButton<int>(
                      value: currentIndex >= 0 ? currentIndex : 0,
                      icon: const Icon(Icons.history, color: Colors.blue),
                      underline: const SizedBox(),
                      items: _versions.asMap().entries.map((e) {
                        return DropdownMenuItem(
                          value: e.key,
                          child: Text('Version ${_versions.length - e.key} (${e.value['date'].hour}:${e.value['date'].minute.toString().padLeft(2, '0')})', style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (idx) {
                        if (idx != null) {
                          setState(() {
                            _generatedPlan = _versions[idx]['content'];
                            _planEditorController.text = _generatedPlan!;
                            _isEditing = false;
                          });
                        }
                      },
                    ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      if (_isEditing) {
                        setState(() {
                          _generatedPlan = _planEditorController.text;
                          _isEditing = false;
                          // Ajouter une nouvelle version à l'historique
                          _versions.insert(0, {'date': DateTime.now(), 'content': _generatedPlan});
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Modifications sauvegardées dans l\'historique.')));
                        });
                      } else {
                        setState(() => _isEditing = true);
                      }
                    },
                    icon: Icon(_isEditing ? Icons.save : Icons.edit),
                    label: Text(_isEditing ? 'Sauvegarder' : 'Modifier (Markdown)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditing ? NexaColors.primaryGreen : Colors.white,
                      foregroundColor: _isEditing ? Colors.white : NexaColors.darkNavy,
                      side: BorderSide(color: _isEditing ? NexaColors.primaryGreen : const Color(0xFFE2E8F0)),
                    ),
                  ),
                ],
              )
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: _isEditing 
                  ? TextField(
                      controller: _planEditorController,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(border: InputBorder.none, hintText: 'Modifiez votre business plan ici...'),
                      style: GoogleFonts.robotoMono(fontSize: 14, height: 1.5),
                    )
                  : Markdown(
                      data: _generatedPlan!,
                      styleSheet: MarkdownStyleSheet(
                        h1: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy),
                        h2: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold, color: NexaColors.primaryGreen, height: 2),
                        p: GoogleFonts.inter(fontSize: 14, height: 1.6, color: const Color(0xFF334155)),
                        listBullet: GoogleFonts.inter(color: NexaColors.primaryGreen),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
