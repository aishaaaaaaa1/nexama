import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'dart:html' as html;
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class CoursePlayerPage extends StatefulWidget {
  final String courseId;
  final Map<String, dynamic>? userData;

  const CoursePlayerPage({super.key, required this.courseId, this.userData});

  @override
  State<CoursePlayerPage> createState() => _CoursePlayerPageState();
}

class _CoursePlayerPageState extends State<CoursePlayerPage> {
  Map<String, dynamic>? _course;
  dynamic _currentLesson;
  bool _isLoading = true;
  Map<String, dynamic> _progress = {};

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    setState(() => _isLoading = true);
    try {
      final res = await ApiService.get(ApiConfig.uri('/api/courses/${widget.courseId}'));
      final progressRes = await ApiService.get(ApiConfig.uri('/api/courses/${widget.courseId}/progress'));
      
      if (res.statusCode == 200) {
        setState(() {
          _course = json.decode(res.body);
          _progress = json.decode(progressRes.body);
          // Sélectionner la première leçon par défaut
          if (_course!['chapitres'].isNotEmpty && _course!['chapitres'][0]['lecons'].isNotEmpty) {
            _currentLesson = _course!['chapitres'][0]['lecons'][0];
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Load course error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markLessonComplete(String lessonId) async {
    try {
      await ApiService.post(ApiConfig.uri('/api/courses/lessons/$lessonId/complete'));
      _loadCourseData(); // Refresh progress
    } catch (e) {
      debugPrint('Complete lesson error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_course == null) return const Scaffold(body: Center(child: Text('Cours introuvable')));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(_course!['titre'], style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          Center(child: Text('Progression : ${_progress['percent']}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
          const SizedBox(width: 20),
          if (_progress['isFinished'] == true)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () => _downloadCertificate(),
                icon: const Icon(Icons.workspace_premium),
                label: const Text('Certificat'),
                style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
              ),
            ),
        ],
      ),
      body: Row(
        children: [
          // Content Area
          Expanded(flex: 3, child: _buildLessonContent()),
          // Sidebar
          Container(
            width: 350,
            decoration: const BoxDecoration(border: Border(left: BorderSide(color: Color(0xFFE2E8F0)))),
            child: _buildLessonList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent() {
    if (_currentLesson == null) return const Center(child: Text('Sélectionnez une leçon'));

    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Player Placeholder (Simulation Vidéo)
          if (_currentLesson['type'] == 'video')
            Container(
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
              child: const Center(child: Icon(Icons.play_circle_fill, color: Colors.white, size: 80)),
            )
          else if (_currentLesson['type'] == 'quiz')
            _buildQuizView()
          else
            Container(
              height: 450,
              width: double.infinity,
              decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
              child: Center(child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_currentLesson['type'] == 'podcast' ? Icons.mic : Icons.image, size: 64, color: NexaColors.primaryGreen),
                  const SizedBox(height: 16),
                  Text('Contenu ${_currentLesson['type']} prêt à l\'écoute/lecture', style: const TextStyle(color: Colors.grey)),
                ],
              )),
            ),
          
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_currentLesson['titre'], style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(_currentLesson['description'] ?? 'Pas de description.', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              if (_currentLesson['type'] != 'quiz')
                ElevatedButton(
                  onPressed: () => _markLessonComplete(_currentLesson['id']),
                  style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  child: const Text('Terminer la leçon'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuizView() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(16), border: Border.all(color: NexaColors.primaryGreen.withOpacity(0.3))),
      child: Column(
        children: [
          const Icon(Icons.quiz, size: 48, color: NexaColors.primaryGreen),
          const SizedBox(height: 24),
          Text('Quiz Interactif', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          const Text('Répondez correctement pour valider cette étape.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 40),
          // Simulation d'une question
          _buildQuizOption("Quelle est la durée maximale d'un stage au Maroc ?"),
          _buildQuizOption("6 mois", isCorrect: true),
          _buildQuizOption("1 an"),
          _buildQuizOption("3 mois"),
        ],
      ),
    );
  }

  Widget _buildQuizOption(String text, {bool isCorrect = false}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      child: OutlinedButton(
        onPressed: () {
          if (isCorrect) {
            _markLessonComplete(_currentLesson['id']);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bravo ! Quiz réussi.'), backgroundColor: Colors.green));
          } else {
             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mauvaise réponse, réessayez.'), backgroundColor: Colors.red));
          }
        },
        style: OutlinedButton.styleFrom(padding: const EdgeInsets.all(20), side: const BorderSide(color: Color(0xFFE2E8F0))),
        child: Text(text, style: const TextStyle(color: NexaColors.darkNavy)),
      ),
    );
  }

  Widget _buildLessonList() {
    return ListView.builder(
      itemCount: _course!['chapitres'].length,
      itemBuilder: (ctx, i) {
        final ch = _course!['chapitres'][i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFF8FAFC),
              child: Text('Chapitre ${i + 1} : ${ch['titre']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
            ),
            ...ch['lecons'].map<Widget>((lecon) {
              final isSelected = _currentLesson?['id'] == lecon['id'];
              final isComplete = (lecon['progressions'] as List).any((p) => p['complete'] == true);
              
              return ListTile(
                selected: isSelected,
                selectedTileColor: NexaColors.primaryGreen.withOpacity(0.05),
                leading: Icon(
                  isComplete ? Icons.check_circle : _getLessonIcon(lecon['type']),
                  color: isComplete ? NexaColors.primaryGreen : Colors.grey,
                  size: 20,
                ),
                title: Text(lecon['titre'], style: TextStyle(fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text('${lecon['duree']} min', style: const TextStyle(fontSize: 11)),
                onTap: () => setState(() => _currentLesson = lecon),
              );
            }).toList(),
          ],
        );
      },
    );
  }

  IconData _getLessonIcon(String type) {
    switch (type) {
      case 'video': return Icons.play_circle_outline;
      case 'podcast': return Icons.mic_none;
      case 'infographie': return Icons.image_outlined;
      case 'quiz': return Icons.quiz_outlined;
      default: return Icons.article_outlined;
    }
  }

  void _downloadCertificate() {
     final url = ApiConfig.uri('/api/courses/${widget.courseId}/certificate').toString();
     html.window.open(url, '_blank');
  }
}
