import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';

import 'propose_service_page.dart';

class MesServicesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const MesServicesPage({super.key, this.userData});

  @override
  State<MesServicesPage> createState() => _MesServicesPageState();
}

class _MesServicesPageState extends State<MesServicesPage> {
  bool _isLoading = true;
  List<dynamic> _services = [];

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/services/$userId'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _services = json.decode(response.body);
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Mes Services B2B', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProposeServicePage(userData: widget.userData)));
              },
              icon: const Icon(Icons.add),
              label: const Text('Proposer un Service'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 3),
          itemCount: _services.length,
          itemBuilder: (context, index) {
            final s = _services[index];
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Row(
                children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: NexaColors.primaryGreen.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.business_center, color: NexaColors.primaryGreen)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(s['titre'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(s['categorie'], style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                  ),
                  Text('${s['prix_base']} MAD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: NexaColors.primaryGreen)),
                ],
              ),
            );
          },
        )
      ],
    );
  }
}
