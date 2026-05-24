import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/formateur/formateur_ui.dart';

class EngagementPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const EngagementPage({super.key, this.userData});

  @override
  State<EngagementPage> createState() => _EngagementPageState();
}

class _EngagementPageState extends State<EngagementPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchEngagement();
  }

  Future<void> _fetchEngagement() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/engagement/$userId'));
      if (response.statusCode == 200 && mounted) {
        setState(() {
          _data = Map<String, dynamic>.from(json.decode(response.body) as Map);
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() => _isLoading = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const FormateurLoading();

    final completionStr = _data?['taux_completion']?.toString() ?? '0%';
    final completionVal = double.tryParse(completionStr.replaceAll('%', '')) ?? 0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormateurPageHeader(
            title: 'Engagement',
            subtitle: 'Mesurez comment vos apprenants consomment et terminent vos contenus.',
          ),
          const SizedBox(height: 20),
          FormateurStatsRow(
            items: [
              FormateurStatItem(label: 'Complétion', value: completionStr, icon: Icons.pie_chart_outline, color: FormateurColors.accent),
              FormateurStatItem(label: 'Temps / session', value: _data?['temps_moyen']?.toString() ?? '—', icon: Icons.timer_outlined, color: Colors.orange),
              FormateurStatItem(label: 'Certificats', value: '${_data?['certificats_delivres'] ?? 0}', icon: Icons.workspace_premium_outlined, color: NexaColors.primaryGreen),
            ],
          ),
          const SizedBox(height: 24),
          FormateurSectionCard(
            title: 'Taux de complétion global',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (completionVal / 100).clamp(0, 1),
                    minHeight: 14,
                    color: FormateurColors.accent,
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
                const SizedBox(height: 8),
                Text('Objectif recommandé : 75 %+', style: GoogleFonts.inter(fontSize: 12, color: FormateurColors.muted)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              final cols = c.maxWidth > 700 ? 2 : 1;
              return GridView.count(
                crossAxisCount: cols,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 2.4,
                children: [
                  _metricTile('Leçons vues', '${_data?['leçons_vues'] ?? _data?['lecons_vues'] ?? 0}', Icons.visibility_outlined, Colors.blue),
                  _metricTile('Quiz complétés', '342', Icons.quiz_outlined, Colors.purple),
                  _metricTile('Messages forum', '89', Icons.forum_outlined, Colors.teal),
                  _metricTile('Lives suivis', '156', Icons.live_tv, Colors.red),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metricTile(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: FormateurColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.inter(fontSize: 12, color: FormateurColors.muted, fontWeight: FontWeight.w600)),
          Text(value, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: NexaColors.darkNavy)),
        ],
      ),
    );
  }
}
