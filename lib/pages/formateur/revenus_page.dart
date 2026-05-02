import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class RevenusFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RevenusFormateurPage({super.key, this.userData});

  @override
  State<RevenusFormateurPage> createState() => _RevenusFormateurPageState();
}

class _RevenusFormateurPageState extends State<RevenusFormateurPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchRevenus();
  }

  Future<void> _fetchRevenus() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/revenus/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _data = json.decode(response.body);
            _isLoading = false;
          });
        }
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tableau de Bord des Revenus', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: NexaColors.darkNavy, borderRadius: BorderRadius.circular(16)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total des Revenus', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 8),
                  Text(_data?['revenus_totaux'] ?? '0 MAD', style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                ],
              ),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.wallet, color: Colors.white, size: 32)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            _buildInfoCard('Ce mois', _data?['mois_en_cours'] ?? '0 MAD', Icons.calendar_month, Colors.blue),
            const SizedBox(width: 16),
            _buildInfoCard('Top Cours', _data?['top_cours'] ?? '-', Icons.star, Colors.amber),
          ],
        )
      ],
    );
  }

  Widget _buildInfoCard(String t, String v, IconData i, Color c) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(i, color: c, size: 20),
            const SizedBox(height: 12),
            Text(t, style: const TextStyle(color: Colors.grey, fontSize: 13)),
            Text(v, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: NexaColors.darkNavy)),
          ],
        ),
      ),
    );
  }
}
