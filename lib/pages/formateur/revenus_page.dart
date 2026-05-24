import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../widgets/formateur/formateur_ui.dart';

class RevenusFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RevenusFormateurPage({super.key, this.userData});

  @override
  State<RevenusFormateurPage> createState() => _RevenusFormateurPageState();
}

class _RevenusFormateurPageState extends State<RevenusFormateurPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  static const _transactions = [
    {'label': 'Vente — Marketing Digital', 'montant': '+299 MAD', 'date': '16 Mai'},
    {'label': 'Vente — Flutter', 'montant': '+499 MAD', 'date': '14 Mai'},
    {'label': 'Versement mensuel', 'montant': '-12 450 MAD', 'date': '01 Mai'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchRevenus();
  }

  Future<void> _fetchRevenus() async {
    setState(() => _isLoading = true);
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/revenus/$userId'));
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FormateurPageHeader(
            title: 'Revenus',
            subtitle: 'Suivez vos ventes, versements et performance financière.',
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [NexaColors.darkNavy, NexaColors.darkNavy.withValues(alpha: 0.85)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Revenus totaux', style: GoogleFonts.inter(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 8),
                      Text(_data?['revenus_totaux']?.toString() ?? '0 MAD', style: GoogleFonts.inter(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: NexaColors.primaryGreen.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(6)),
                        child: Text('+18 % vs mois dernier', style: GoogleFonts.inter(color: NexaColors.lightGreen, fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 36),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          FormateurStatsRow(
            items: [
              FormateurStatItem(label: 'Ce mois', value: _data?['mois_en_cours']?.toString() ?? '—', icon: Icons.calendar_month, color: Colors.blue),
              FormateurStatItem(label: 'Top cours', value: _data?['top_cours']?.toString() ?? '—', icon: Icons.emoji_events_outlined, color: Colors.amber, hint: 'Meilleure vente'),
              FormateurStatItem(label: 'En attente', value: '12 450 MAD', icon: Icons.hourglass_empty, color: Colors.orange),
            ],
          ),
          const SizedBox(height: 24),
          FormateurSectionCard(
            title: 'Dernières opérations',
            child: Column(
              children: [
                for (var i = 0; i < _transactions.length; i++) ...[
                  if (i > 0) const Divider(height: 28),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (_transactions[i]['montant']!.startsWith('+') ? NexaColors.primaryGreen : Colors.orange).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _transactions[i]['montant']!.startsWith('+') ? Icons.arrow_downward : Icons.arrow_upward,
                          size: 18,
                          color: _transactions[i]['montant']!.startsWith('+') ? NexaColors.primaryGreen : Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text(_transactions[i]['label']!, style: GoogleFonts.inter(fontWeight: FontWeight.w600))),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(_transactions[i]['montant']!, style: GoogleFonts.inter(fontWeight: FontWeight.w800, color: _transactions[i]['montant']!.startsWith('+') ? NexaColors.primaryGreen : NexaColors.darkNavy)),
                          Text(_transactions[i]['date']!, style: GoogleFonts.inter(fontSize: 11, color: FormateurColors.muted)),
                        ],
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
