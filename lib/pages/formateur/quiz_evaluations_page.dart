import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class _QuizItem {
  const _QuizItem({
    required this.id,
    required this.titre,
    required this.coursLabel,
    required this.questionsLabel,
    required this.participationsLabel,
    required this.moyenneLabel,
  });

  final String id;
  final String titre;
  final String coursLabel;
  final String questionsLabel;
  final String participationsLabel;
  final String moyenneLabel;
}

class QuizEvaluationsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const QuizEvaluationsPage({super.key, this.userData});

  @override
  State<QuizEvaluationsPage> createState() => _QuizEvaluationsPageState();
}

class _QuizEvaluationsPageState extends State<QuizEvaluationsPage> {
  late final List<_QuizItem> _quizzes;

  @override
  void initState() {
    super.initState();
    _quizzes = [
      const _QuizItem(
        id: 'seed-1',
        titre: 'Quiz Final : Fondamentaux du Marketing',
        coursLabel: 'Cours : Marketing Digital',
        questionsLabel: '15 questions',
        participationsLabel: '42 participations',
        moyenneLabel: '85% moyenne',
      ),
      const _QuizItem(
        id: 'seed-2',
        titre: 'Auto-évaluation : SEO Technique',
        coursLabel: 'Cours : SEO Avancé',
        questionsLabel: '10 questions',
        participationsLabel: '28 participations',
        moyenneLabel: '72% moyenne',
      ),
    ];
  }

  Future<void> _openNouveauQuiz() async {
    final created = await _CreerQuizAlertDialog.show(context);
    if (!mounted || created == null) return;
    setState(() => _quizzes.insert(0, created));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Quiz « ${created.titre} » ajouté à la liste.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _confirmDeleteQuiz(_QuizItem q) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Supprimer le quiz ?', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        content: Text('« ${q.titre} » sera retiré de la liste.', style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('Annuler', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFDC2626), foregroundColor: Colors.white),
            child: Text('Supprimer', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _quizzes.removeWhere((e) => e.id == q.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('« ${q.titre} » supprimé.', style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        behavior: SnackBarBehavior.floating,
      ),
    );
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
                Text('Quiz & Évaluations', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Gérez les tests de connaissances pour vos cours.', style: TextStyle(color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: _openNouveauQuiz,
              icon: const Icon(Icons.add),
              label: const Text('Nouveau Quiz'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: _quizzes.length,
            separatorBuilder: (context, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) => _buildQuizCard(_quizzes[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildQuizCard(_QuizItem q) {
    return Container(
      key: ValueKey(q.id),
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
                Text(q.titre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(q.coursLabel, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildTag(Icons.help_outline, q.questionsLabel),
                    const SizedBox(width: 16),
                    _buildTag(Icons.people_outline, q.participationsLabel),
                    const SizedBox(width: 16),
                    _buildTag(Icons.trending_up, q.moyenneLabel),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Supprimer',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.delete_outline_rounded, size: 22, color: Color(0xFF94A3B8)),
            style: IconButton.styleFrom(
              hoverColor: const Color(0xFFFEE2E2),
              highlightColor: const Color(0xFFFEE2E2),
            ),
            onPressed: () => _confirmDeleteQuiz(q),
          ),
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

/// Formulaire « Nouveau quiz » — renvoie un [_QuizItem] à afficher dans la liste.
///
/// [StatefulWidget] **sans** constructeur `const` (évite erreurs hot reload sur les dialogs).
/// Si l’IDE affiche encore « Const class cannot… » après un gros refactor, faire un
/// **hot restart** (`R` dans le terminal Flutter), pas seulement un hot reload (`r`).
class _CreerQuizAlertDialog extends StatefulWidget {
  static Future<_QuizItem?> show(BuildContext context) {
    return showDialog<_QuizItem>(
      context: context,
      builder: (_) => _CreerQuizAlertDialog(),
    );
  }

  @override
  State<_CreerQuizAlertDialog> createState() => _CreerQuizAlertDialogState();
}

class _CreerQuizAlertDialogState extends State<_CreerQuizAlertDialog> {
  final _titre = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _cours = 'Marketing Digital';
  int _nbQuestions = 10;

  static const _coursOptions = [
    'Marketing Digital',
    'SEO Avancé',
    'Entrepreneuriat',
    'Finance pour créateurs',
  ];

  @override
  void dispose() {
    _titre.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final titre = _titre.text.trim();
    final item = _QuizItem(
      id: 'quiz-${DateTime.now().millisecondsSinceEpoch}',
      titre: titre,
      coursLabel: 'Cours : $_cours',
      questionsLabel: '$_nbQuestions questions',
      participationsLabel: '0 participations',
      moyenneLabel: '— moyenne',
    );
    Navigator.of(context).pop(item);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('Nouveau quiz', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titre,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: 'Titre du quiz',
                    hintText: 'Ex. Quiz final — module 3',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Indiquez un titre';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _cours,
                  decoration: InputDecoration(
                    labelText: 'Cours associé',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: [for (final c in _coursOptions) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (v) => setState(() => _cours = v ?? _coursOptions.first),
                ),
                const SizedBox(height: 16),
                Text('Nombre de questions : $_nbQuestions', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: const Color(0xFF475569))),
                Slider(
                  value: _nbQuestions.toDouble(),
                  min: 5,
                  max: 30,
                  divisions: 5,
                  label: '$_nbQuestions',
                  activeColor: const Color(0xFF8B5CF6),
                  onChanged: (v) => setState(() => _nbQuestions = (5 * ((v - 5) / 5).round() + 5).clamp(5, 30).toInt()),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Annuler', style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
        FilledButton(
          onPressed: _submit,
          style: FilledButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
          child: Text('Créer le quiz', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
