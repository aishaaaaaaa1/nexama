import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';
import 'dart:convert';

class LivesWebinairesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const LivesWebinairesPage({super.key, this.userData});

  @override
  State<LivesWebinairesPage> createState() => _LivesWebinairesPageState();
}

class _LivesWebinairesPageState extends State<LivesWebinairesPage> {
  bool _isLoading = true;
  List<dynamic> _lives = [];

  @override
  void initState() {
    super.initState();
    _fetchLives();
  }

  Future<void> _fetchLives() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/formateur/lives/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          _lives = json.decode(response.body);
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lives & Webinaires', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
                const Text('Interagissez en direct avec vos apprenants.', style: TextStyle(color: Colors.grey)),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Programmer un Live'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 32),
        Expanded(
          child: ListView.separated(
            itemCount: _lives.length,
            separatorBuilder: (c, i) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final live = _lives[index];
              return Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                      child: const Icon(Icons.live_tv, color: Colors.red),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(live['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text('${live['date']} à ${live['heure']} • ${live['inscrits']} inscrits', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                    ElevatedButton(onPressed: () {}, child: const Text('Gérer'))
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
