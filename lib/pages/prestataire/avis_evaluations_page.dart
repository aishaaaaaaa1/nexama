import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class AvisEvaluationsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const AvisEvaluationsPage({super.key, this.userData});

  @override
  State<AvisEvaluationsPage> createState() => _AvisEvaluationsPageState();
}

class _AvisEvaluationsPageState extends State<AvisEvaluationsPage> {
  bool _isLoading = true;
  List<dynamic> _evaluations = [];

  @override
  void initState() {
    super.initState();
    _fetchEvaluations();
  }

  Future<void> _fetchEvaluations() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/evaluations/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _evaluations = json.decode(response.body);
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

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Avis & Évaluations', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            const Text('Retours de vos clients sur vos prestations.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _evaluations.length,
              separatorBuilder: (c, i) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final e = _evaluations[index];
                return Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(e['client'] ?? 'Client Anonyme', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Row(
                            children: List.generate(5, (i) => Icon(Icons.star, color: i < (e['note'] ?? 0) ? Colors.amber : Colors.grey[300], size: 16)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(e['date'] ?? 'Date inconnue', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 16),
                      Text(e['commentaire'] ?? 'Aucun commentaire laissé.', style: const TextStyle(fontSize: 14, height: 1.5)),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
