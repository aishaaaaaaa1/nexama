import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

class MesCoursPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MesCoursPage({super.key, this.userData});

  @override
  State<MesCoursPage> createState() => _MesCoursPageState();
}

class _MesCoursPageState extends State<MesCoursPage> {
  bool _isLoading = true;
  List<dynamic> _cours = [];

  @override
  void initState() {
    super.initState();
    _fetchCours();
  }

  Future<void> _fetchCours() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/cours/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _cours = json.decode(response.body);
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mes Cours & Formations', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Publier un Cours'),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF8B5CF6), foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 24),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _cours.length,
          separatorBuilder: (c, i) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final c = _cours[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: const Color(0xFFF5F3FF), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.videocam, color: Color(0xFF8B5CF6))),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(c['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: NexaColors.darkNavy)),
                        const SizedBox(height: 4),
                        Text('${c['format_media']} • ${c['duree_minutes']} minutes', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('${c['prix']} MAD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: NexaColors.primaryGreen)),
                      const SizedBox(height: 4),
                      const Text('Prix public', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
