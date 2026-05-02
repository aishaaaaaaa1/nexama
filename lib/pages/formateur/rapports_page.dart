import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class RapportsPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RapportsPage({super.key, this.userData});

  @override
  State<RapportsPage> createState() => _RapportsPageState();
}

class _RapportsPageState extends State<RapportsPage> {
  bool _isLoading = true;
  List<dynamic> _rapports = [];

  @override
  void initState() {
    super.initState();
    _fetchRapports();
  }

  Future<void> _fetchRapports() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/rapports/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _rapports = json.decode(response.body);
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
        Text('Rapports Académiques & Ventes', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const Text('Téléchargez vos bilans mensuels et analyses de performance.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: _rapports.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final r = _rapports[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    const Icon(Icons.description, color: NexaColors.primaryGreen, size: 32),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r['nom'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('Généré le ${r['date']} • Type: ${r['type']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.download_outlined, color: NexaColors.darkNavy))
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
