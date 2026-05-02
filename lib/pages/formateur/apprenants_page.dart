import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class ApprenantsFormateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const ApprenantsFormateurPage({super.key, this.userData});

  @override
  State<ApprenantsFormateurPage> createState() => _ApprenantsFormateurPageState();
}

class _ApprenantsFormateurPageState extends State<ApprenantsFormateurPage> {
  bool _isLoading = true;
  List<dynamic> _apprenants = [];

  @override
  void initState() {
    super.initState();
    _fetchApprenants();
  }

  Future<void> _fetchApprenants() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/apprenants/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _apprenants = json.decode(response.body);
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

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Suivi des Apprenants', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.5),
            itemCount: _apprenants.length,
            itemBuilder: (context, index) {
              final a = _apprenants[index];
              return Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(backgroundColor: NexaColors.primaryGreen.withOpacity(0.1), child: Text(a['nom'][0], style: const TextStyle(color: NexaColors.primaryGreen))),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(a['nom'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Cours: ${a['cours']}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(child: LinearProgressIndicator(value: a['progression'], color: NexaColors.primaryGreen, backgroundColor: const Color(0xFFF1F5F9))),
                        const SizedBox(width: 12),
                        Text('${(a['progression'] * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
