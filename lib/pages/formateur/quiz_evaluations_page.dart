import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/formateur/formateur_ui.dart';

class _QuizItem {
  const _QuizItem({
    required this.id,
    required this.titre,
    required this.cours,
    required this.questions,
    required this.participations,
    required this.moyenne,
  });

  final String id;
  final String titre;
  final String cours;
  final int questions;
  final int participations;
  final String moyenne;
}

class QuizEvaluationsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const QuizEvaluationsPage({super.key, this.userData});

  @override
  State<QuizEvaluationsPage> createState() => _QuizEvaluationsPageState();
}

class _QuizEvaluationsPageState extends State<QuizEvaluationsPage> {
  final List<_QuizItem> _quizzes = [];
  bool _isLoading = true;

  String get _formateurId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchQuizzes();
  }

  _QuizItem _quizFromJson(dynamic raw, int index) {
    final m = raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
    return _QuizItem(
      id: m['id']?.toString() ?? 'quiz-$index',
      titre: m['titre']?.toString() ?? 'Quiz sans titre',
      cours: m['cours']?.toString() ?? 'Cours non defini',
      questions: (m['questions'] as num?)?.toInt() ?? int.tryParse('${m['questions']}') ?? 0,
      participations: (m['participations'] as num?)?.toInt() ?? int.tryParse('${m['participations']}') ?? 0,
      moyenne: m['moyenne']?.toString() ?? '—',
    );
  }

  Future<void> _fetchQuizzes() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/quiz/$_formateurId'));
      if (response.statusCode == 200 && mounted) {
        final decoded = json.decode(response.body);
        setState(() {
          _quizzes
            ..clear()
            ..addAll(decoded is List ? List.generate(decoded.length, (i) => _quizFromJson(decoded[i], i)) : const []);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) setState(() => _isLoading = false);
  }

  void _showSnack(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(fontWeight: FontWeight.w500)),
        backgroundColor: error ? const Color(0xFFB91C1C) : NexaColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _openNouveauQuiz() async {
    final draft = await _CreerQuizAlertDialog.show(context);
    if (!mounted || draft == null) return;

    var created = draft;
    try {
      final response = await ApiService.post(
        ApiConfig.uri('/api/formateur/quiz/$_formateurId'),
        body: {'titre': draft.titre, 'cours': draft.cours, 'questions': draft.questions},
      );
      if (response.statusCode == 201) {
        final decoded = json.decode(response.body);
        if (decoded is Map && decoded['quiz'] != null) {
          created = _quizFromJson(decoded['quiz'], 0);
        }
      } else {
        _showSnack('Le quiz a ete ajoute localement, mais pas sauvegarde.', error: true);
      }
    } catch (_) {
      _showSnack("API indisponible : le quiz reste ajoute localement.", error: true);
    }

    setState(() => _quizzes.insert(0, created));
    _showSnack('Quiz "${created.titre}" ajoute.');
  }

  Future<void> _confirmDeleteQuiz(_QuizItem q) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Supprimer le quiz ?', style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        content: Text('"${q.titre}" sera retire de la liste.', style: GoogleFonts.inter(fontSize: 14, height: 1.4)),
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

    try {
      await ApiService.delete(ApiConfig.uri('/api/formateur/quiz/$_formateurId/${q.id}'));
    } catch (_) {}

    setState(() => _quizzes.removeWhere((e) => e.id == q.id));
    _showSnack('Quiz supprime.');
  }

  int get _totalParticipations => _quizzes.fold<int>(0, (s, q) => s + q.participations);

  String get _moyenneGlobale {
    final values = _quizzes.map((q) => double.tryParse(q.moyenne.replaceAll('%', '').trim())).whereType<double>().toList();
    if (values.isEmpty) return '—';
    return '${(values.reduce((a, b) => a + b) / values.length).round()} %';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const FormateurLoading();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormateurPageHeader(
          title: 'Quiz & evaluations',
          subtitle: 'Tests de connaissances, scores et participation par cours.',
          trailing: ElevatedButton.icon(
            onPressed: _openNouveauQuiz,
            icon: const Icon(Icons.add),
            label: const Text('Nouveau quiz'),
            style: formateurPrimaryStyle(),
          ),
        ),
        const SizedBox(height: 20),
        FormateurStatsRow(
          items: [
            FormateurStatItem(label: 'Quiz actifs', value: '${_quizzes.length}', icon: Icons.quiz_outlined, color: FormateurColors.accent),
            FormateurStatItem(label: 'Participations', value: '$_totalParticipations', icon: Icons.people_outline, color: Colors.blue),
            FormateurStatItem(label: 'Moyenne globale', value: _moyenneGlobale, icon: Icons.trending_up, color: NexaColors.primaryGreen),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _quizzes.isEmpty
              ? FormateurEmptyState(icon: Icons.quiz_outlined, title: 'Aucun quiz', message: 'Creez un quiz pour evaluer vos apprenants.', actionLabel: 'Nouveau quiz', onAction: _openNouveauQuiz)
              : ListView.separated(
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
                Text('Cours : ${q.cours}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    _buildTag(Icons.help_outline, '${q.questions} questions'),
                    _buildTag(Icons.people_outline, '${q.participations} participations'),
                    _buildTag(Icons.trending_up, '${q.moyenne} moyenne'),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Supprimer',
            icon: const Icon(Icons.delete_outline_rounded, size: 22, color: Color(0xFF94A3B8)),
            style: IconButton.styleFrom(hoverColor: const Color(0xFFFEE2E2), highlightColor: const Color(0xFFFEE2E2)),
            onPressed: () => _confirmDeleteQuiz(q),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

class _CreerQuizAlertDialog extends StatefulWidget {
  static Future<_QuizItem?> show(BuildContext context) {
    return showDialog<_QuizItem>(context: context, builder: (_) => _CreerQuizAlertDialog());
  }

  @override
  State<_CreerQuizAlertDialog> createState() => _CreerQuizAlertDialogState();
}

class _CreerQuizAlertDialogState extends State<_CreerQuizAlertDialog> {
  final _titre = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _cours = 'Marketing Digital';
  int _nbQuestions = 10;

  static const _coursOptions = ['Marketing Digital', 'SEO Avance', 'Entrepreneuriat', 'Finance pour createurs'];

  @override
  void dispose() {
    _titre.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    Navigator.of(context).pop(
      _QuizItem(
        id: 'local-${DateTime.now().millisecondsSinceEpoch}',
        titre: _titre.text.trim(),
        cours: _cours,
        questions: _nbQuestions,
        participations: 0,
        moyenne: '—',
      ),
    );
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
                  decoration: InputDecoration(labelText: 'Titre du quiz', hintText: 'Ex. Quiz final - module 3', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Indiquez un titre' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  key: ValueKey('cours_$_cours'),
                  initialValue: _cours,
                  decoration: InputDecoration(labelText: 'Cours associe', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
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
          child: Text('Creer le quiz', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
