import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

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
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/engagement/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _data = json.decode(response.body);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Engagement & Statistiques', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const Text('Analysez comment vos apprenants interagissent avec votre contenu.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          childAspectRatio: 2,
          children: [
            _buildMetricCard('Taux de Complétion', _data?['taux_completion'] ?? '0%', Icons.pie_chart, Colors.purple),
            _buildMetricCard('Temps Moyen / Session', _data?['temps_moyen'] ?? '0 min', Icons.timer, Colors.orange),
            _buildMetricCard('Leçons Vues', '${_data?['leçons_vues'] ?? 0}', Icons.remove_red_eye, Colors.blue),
            _buildMetricCard('Certificats Délivrés', '${_data?['certificats_delivres'] ?? 0}', Icons.card_membership, Colors.green),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        ],
      ),
    );
  }
}
