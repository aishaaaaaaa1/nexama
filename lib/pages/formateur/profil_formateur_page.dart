import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class ProfilFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ProfilFormateurPage({super.key, this.userData});

  @override
  State<ProfilFormateurPage> createState() => _ProfilFormateurPageState();
}

class _ProfilFormateurPageState extends State<ProfilFormateurPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _profil;

  @override
  void initState() {
    super.initState();
    _fetchProfil();
  }

  Future<void> _fetchProfil() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/profil/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _profil = json.decode(response.body);
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Profil Formateur', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const Text('Gérez votre image de marque et votre biographie publique.', style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
            child: Column(
              children: [
                CircleAvatar(radius: 60, backgroundColor: NexaColors.primaryGreen.withOpacity(0.1), child: const Icon(Icons.person, size: 60, color: NexaColors.primaryGreen)),
                const SizedBox(height: 24),
                Text(_profil?['nom'] ?? 'Formateur Expert', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.star, color: Colors.amber, size: 20), Text(' ${_profil?['rating'] ?? 5.0}', style: const TextStyle(fontWeight: FontWeight.bold))]),
                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 32),
                _buildInfoField('Biographie', _profil?['biographie'] ?? 'Aucune biographie fournie.'),
                const SizedBox(height: 24),
                _buildInfoField('Domaines d\'expertise', (_profil?['expertise'] as List?)?.join(', ') ?? 'N/A'),
                const SizedBox(height: 48),
                SizedBox(
                  width: 200,
                  height: 45,
                  child: ElevatedButton(onPressed: () {}, style: ElevatedButton.styleFrom(backgroundColor: NexaColors.darkNavy, foregroundColor: Colors.white), child: const Text('Modifier le profil')),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, height: 1.5)),
      ],
    );
  }
}
