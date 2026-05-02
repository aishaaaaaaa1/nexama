import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class PaiementFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const PaiementFormateurPage({super.key, this.userData});

  @override
  State<PaiementFormateurPage> createState() => _PaiementFormateurPageState();
}

class _PaiementFormateurPageState extends State<PaiementFormateurPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    _fetchPaiementInfo();
  }

  Future<void> _fetchPaiementInfo() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/paiements/$userId'));
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
        Text('Paramètres de Paiement', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const Text('Gérez vos modes de versement et consultez vos fonds en attente.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
          child: Column(
            children: [
              _buildInfoRow('Mode de versement', _data?['mode'] ?? 'Non configuré', Icons.account_balance),
              const Divider(height: 48),
              _buildInfoRow('Statut du compte', _data?['statut'] ?? 'Inactif', Icons.verified_user),
              const Divider(height: 48),
              _buildInfoRow('Prochain versement', _data?['prochain_versement'] ?? 'N/A', Icons.calendar_today),
              const Divider(height: 48),
              _buildInfoRow('Montant en attente', _data?['montant_attente'] ?? '0 MAD', Icons.payments, isValueBold: true),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white), child: const Text('Modifier les coordonnées bancaires')),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, {bool isValueBold = false}) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 16),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 15)),
        const Spacer(),
        Text(value, style: TextStyle(fontWeight: isValueBold ? FontWeight.bold : FontWeight.w600, fontSize: 16, color: isValueBold ? NexaColors.primaryGreen : NexaColors.darkNavy)),
      ],
    );
  }
}
