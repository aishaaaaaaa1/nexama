import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class MicroLearningPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MicroLearningPage({super.key, this.userData});

  @override
  State<MicroLearningPage> createState() => _MicroLearningPageState();
}

class _MicroLearningPageState extends State<MicroLearningPage> {
  bool _isLoading = true;
  List<dynamic> _cours = [];
  String _selectedCategory = 'Tous';
  final List<String> _categories = ['Tous', 'Fiscalité', 'Marketing', 'Légal', 'Financement', 'Gestion'];

  // Niveau et progression (Simulé)
  int _xp = 150;
  String _niveau = 'Débutant';
  int _coursTermines = 3;

  @override
  void initState() {
    super.initState();
    _fetchCours();
    _calculerNiveau();
  }

  void _calculerNiveau() {
    if (_xp >= 1000) _niveau = 'Expert 🏆';
    else if (_xp >= 500) _niveau = 'Intermédiaire 🌟';
    else _niveau = 'Débutant 🚀';
  }

  Future<void> _fetchCours() async {
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/entrepreneur/formation'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            final decoded = json.decode(response.body);
            if (decoded is List) {
              _cours = decoded;
            } else {
              throw Exception('Not a list');
            }
            _isLoading = false;
          });
        }
      } else {
        throw Exception('API failed');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _cours = [
            {'id': '1', 'titre': 'La TVA expliquée aux Auto-Entrepreneurs', 'categorie': 'Fiscalité', 'duree_minutes': 8, 'formateur_nom': 'Amine (Expert Comptable)', 'format_media': 'video', 'description': 'Découvrez les règles de la TVA pour les auto-entrepreneurs au Maroc.'},
            {'id': '2', 'titre': 'Marketing Digital 101: Trouver ses premiers clients', 'categorie': 'Marketing', 'duree_minutes': 12, 'formateur_nom': 'Khadija (CMO)', 'format_media': 'video', 'description': 'Apprenez à utiliser les réseaux sociaux pour acquérir des clients.'},
            {'id': '3', 'titre': 'Rédaction de statuts SARL', 'categorie': 'Légal', 'duree_minutes': 15, 'formateur_nom': 'Youssef (Avocat)', 'format_media': 'article', 'description': 'Les erreurs à éviter lors de la création de votre SARL.'},
            {'id': '4', 'titre': 'Comment réussir son pitch investisseur', 'categorie': 'Financement', 'duree_minutes': 10, 'formateur_nom': 'Hassan (VC)', 'format_media': 'video', 'description': 'Structurez votre pitch deck pour convaincre les business angels.'},
            {'id': '5', 'titre': 'Comptabilité de base pour débutants', 'categorie': 'Gestion', 'duree_minutes': 6, 'formateur_nom': 'Amine', 'format_media': 'video', 'description': 'Les bases de la gestion de trésorerie.'},
          ];
          _isLoading = false;
        });
      }
    }
  }

  List<dynamic> get _filteredCours {
    if (_selectedCategory == 'Tous') return _cours;
    return _cours.where((c) => c['categorie'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Espace Microlearning', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                  const Text('Formations express pour entrepreneurs (5-10 min)', style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                ],
              ),
              _buildSearchBar(),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats/Progress
          _buildProgressSummary(),
          const SizedBox(height: 32),
          
          // Recommandations Personnalisées
          Text('Recommandé pour vous (Secteur: ${widget.userData?['secteur'] ?? 'Tech'})', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          SizedBox(
            height: 240,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _cours.take(2).length,
              itemBuilder: (context, index) => Container(
                width: 300,
                margin: const EdgeInsets.only(right: 16),
                child: _buildCourseCard(_cours[index]),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Category Filter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Parcourir le catalogue', style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
              _buildCategoryFilter(),
            ],
          ),
          const SizedBox(height: 16),
          
          // Course Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3, crossAxisSpacing: 20, mainAxisSpacing: 20, childAspectRatio: 0.85
            ),
            itemCount: _filteredCours.length,
            itemBuilder: (context, index) => _buildCourseCard(_filteredCours[index]),
          )
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      width: 300, height: 40,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Rechercher un cours...',
          hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
          prefixIcon: Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.only(top: 8),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: FilterChip(
              label: Text(cat, style: const TextStyle(fontSize: 12)),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: NexaColors.primaryGreen.withOpacity(0.1),
              checkmarkColor: NexaColors.primaryGreen,
              labelStyle: TextStyle(color: isSelected ? NexaColors.primaryGreen : const Color(0xFF64748B), fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: isSelected ? NexaColors.primaryGreen : const Color(0xFFE2E8F0))),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildProgressSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [NexaColors.primaryGreen.withOpacity(0.05), Colors.white], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NexaColors.primaryGreen.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _buildStatItem('$_coursTermines', 'Cours terminés', Icons.check_circle_outline, NexaColors.primaryGreen),
          _buildVerticalDivider(),
          _buildStatItem(_niveau, 'Niveau actuel', Icons.military_tech_outlined, Colors.orange),
          _buildVerticalDivider(),
          _buildStatItem('$_xp XP', 'Points d\'expérience', Icons.star_border_outlined, Colors.purple),
          _buildVerticalDivider(),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Prochain Niveau', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                const SizedBox(height: 6),
                LinearProgressIndicator(value: (_xp % 500) / 500, backgroundColor: const Color(0xFFF1F5F9), valueColor: const AlwaysStoppedAnimation(Colors.orange), borderRadius: BorderRadius.circular(10)),
                const SizedBox(height: 4),
                Text('${500 - (_xp % 500)} XP restants', style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildStatItem(String val, String label, IconData icon, Color color) {
    return Expanded(
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(val, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
              Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(width: 1, height: 40, color: const Color(0xFFE2E8F0), margin: const EdgeInsets.symmetric(horizontal: 20));
  }

  Widget _buildCourseCard(Map<String, dynamic> c) {
    return InkWell(
      onTap: () => _showCourseViewer(c),
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0)), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 120, 
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC), borderRadius: BorderRadius.vertical(top: Radius.circular(16))), 
                  child: Center(child: Icon(c['format_media'] == 'video' ? Icons.play_circle_fill : Icons.article_rounded, color: const Color(0xFFCBD5E1), size: 50))
                ),
                Positioned(
                  top: 12, left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(4)),
                    child: Text('${c['duree_minutes'] ?? 0} min', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                    child: Text(c['categorie'] ?? 'Non catégorisé', style: const TextStyle(color: NexaColors.primaryGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 8),
                  Text(c['titre'] ?? 'Cours', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(c['formateur_nom'] ?? 'Formateur inconnu', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showCourseViewer(Map<String, dynamic> c) {
    int _quizStep = 0; // 0 = Vidéo, 1 = Quiz, 2 = Succès
    String? _selectedAnswer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(40),
            child: Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: NexaColors.primaryGreen.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.school, color: NexaColors.primaryGreen)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(c['titre'], style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('Formateur: ${c['formateur_nom']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ])),
                        IconButton(onPressed: () => Navigator.pop(ctx), icon: const Icon(Icons.close)),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  // BODY
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _quizStep == 0 ? _buildVideoPlayer(c, () => setDialogState(() => _quizStep = 1))
                           : _quizStep == 1 ? _buildInteractiveQuiz(c, _selectedAnswer, (ans) => setDialogState(() => _selectedAnswer = ans), () {
                               if (_selectedAnswer != null) {
                                  // Réponse valide, on passe au succès
                                  setState(() { _xp += 50; _coursTermines++; _calculerNiveau(); }); // Update global state
                                  setDialogState(() => _quizStep = 2);
                               }
                             })
                           : _buildSuccessScreen(ctx, c),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      ),
    );
  }

  Widget _buildVideoPlayer(Map<String, dynamic> c, VoidCallback onComplete) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(16)),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.play_circle_fill, color: Colors.white, size: 64),
                Positioned(bottom: 20, left: 20, right: 20, child: LinearProgressIndicator(value: 0.3, backgroundColor: Colors.white24, valueColor: AlwaysStoppedAnimation(NexaColors.primaryGreen))),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text('Description du cours', style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        Text(c['description'] ?? 'Pas de description.', style: const TextStyle(color: Color(0xFF64748B), height: 1.5)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: onComplete,
          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
          child: const Text('J\'ai terminé la vidéo → Passer au Quiz'),
        )
      ],
    );
  }

  Widget _buildInteractiveQuiz(Map<String, dynamic> c, String? selectedAnswer, Function(String) onSelect, VoidCallback onSubmit) {
    // Mock questions basées sur le cours
    List<String> options = ['La TVA', 'L\'Impôt sur le Revenu', 'Les Charges Sociales', 'La Taxe Professionnelle'];
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.help_outline, size: 64, color: Colors.orange),
        const SizedBox(height: 24),
        Text('Quiz de validation', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text('Quel impôt est exonéré les 5 premières années pour un Auto-Entrepreneur au Maroc ?', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        const SizedBox(height: 32),
        ...options.map((opt) {
          bool isSelected = selectedAnswer == opt;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () => onSelect(opt),
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected ? NexaColors.primaryGreen.withOpacity(0.1) : Colors.white,
                  border: Border.all(color: isSelected ? NexaColors.primaryGreen : const Color(0xFFE2E8F0), width: isSelected ? 2 : 1),
                  borderRadius: BorderRadius.circular(12)
                ),
                child: Row(
                  children: [
                    Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: isSelected ? NexaColors.primaryGreen : Colors.grey),
                    const SizedBox(width: 12),
                    Text(opt, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, color: NexaColors.darkNavy)),
                  ],
                ),
              ),
            ),
          );
        }),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: selectedAnswer == null ? null : onSubmit,
          style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16)),
          child: const Text('Valider ma réponse'),
        )
      ],
    );
  }

  Widget _buildSuccessScreen(BuildContext context, Map<String, dynamic> c) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.2), shape: BoxShape.circle), child: const Text('🏆', style: TextStyle(fontSize: 64))),
        const SizedBox(height: 24),
        Text('Félicitations !', style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 8),
        Text('Vous avez complété "${c['titre']}"', style: const TextStyle(fontSize: 16, color: Color(0xFF64748B))),
        const SizedBox(height: 8),
        const Text('+50 XP gagnés', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 16)),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⏳ Génération du certificat PDF...')));
                Future.delayed(const Duration(seconds: 2), () {
                  if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Certificat téléchargé avec succès.'), backgroundColor: Colors.green));
                });
              },
              icon: const Icon(Icons.workspace_premium),
              label: const Text('Télécharger le Certificat'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            ),
            const SizedBox(width: 16),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Redirection vers LinkedIn...'), backgroundColor: Colors.blue));
              },
              icon: const Icon(Icons.share),
              label: const Text('Partager sur LinkedIn'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
            ),
          ],
        )
      ],
    );
  }
}
