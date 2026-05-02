import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class QuizEvaluationsPage extends StatelessWidget {
  final Map<String, dynamic>? userData;
  const QuizEvaluationsPage({super.key, this.userData});

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
                Text('Quiz & Évaluations', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Gérez les tests de connaissances pour vos cours.', style: TextStyle(color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Nouveau Quiz'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 32),
        _buildQuizCard('Quiz Final : Fondamentaux du Marketing', 'Cours : Marketing Digital', '15 questions', '42 participations', '85% moyenne'),
        const SizedBox(height: 16),
        _buildQuizCard('Auto-évaluation : SEO Technique', 'Cours : SEO Avancé', '10 questions', '28 participations', '72% moyenne'),
      ],
    );
  }

  Widget _buildQuizCard(String title, String course, String questions, String participations, String avg) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.quiz_outlined, color: Color(0xFF8B5CF6), size: 32),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(course, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTag(Icons.help_outline, questions),
                    const SizedBox(width: 16),
                    _buildTag(Icons.people_outline, participations),
                    const SizedBox(width: 16),
                    _buildTag(Icons.trending_up, avg),
                  ],
                )
              ],
            ),
          ),
          const Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
