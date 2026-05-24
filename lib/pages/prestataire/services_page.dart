import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../theme/app_theme.dart';
import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';

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

  Future<String?> _resolveUserId() async {
    final stored = await AuthService.getUserData();
    return stored?['id']?.toString() ?? widget.userData?['id']?.toString();
  }

  Future<void> _fetchServices() async {
    try {
      final userId = await _resolveUserId();
      if (userId == null || userId.isEmpty) {
        if (mounted) {
          setState(() {
            _services = [];
            _isLoading = false;
          });
        }
        return;
      }
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

  Future<void> _confirmAndDeleteService(BuildContext context, dynamic s) async {
    final serviceId = s['id']?.toString();
    if (serviceId == null || serviceId.isEmpty) return;

    final titre = '${s['titre'] ?? 'ce service'}';
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Supprimer le service ?'),
        content: Text('« $titre » sera retiré de votre liste Mes Services B2B.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final userId = await _resolveUserId();
    if (userId == null || userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Session introuvable.')));
      }
      return;
    }
    try {
      final response = await ApiService.delete(ApiConfig.uri('/api/prestataire/services/$userId/$serviceId'));
      if (!mounted) return;
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Service supprimé.')));
        await _fetchServices();
      } else if (response.statusCode == 404) {
        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Service introuvable.')));
        await _fetchServices();
      } else {
        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Impossible de supprimer le service.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('Erreur réseau.')));
      }
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProposeServicePage(userData: widget.userData)),
                ).then((_) => _fetchServices());
              },
              icon: const Icon(Icons.add),
              label: const Text('Proposer un Service'),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            )
          ],
        ),
        const SizedBox(height: 24),
        if (_services.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Aucun service pour le moment. Cliquez sur « Proposer un Service » pour en ajouter.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
              ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 2.65),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final s = _services[index];
              final prix = s['prix_base'];
              final prixStr = prix is num ? (prix == prix.roundToDouble() ? prix.round().toString() : prix.toStringAsFixed(2)) : '$prix';
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
                          Text('${s['titre']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${s['categorie']}', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        ],
                      ),
                    ),
                    Text('$prixStr MAD', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: NexaColors.primaryGreen)),
                    const SizedBox(width: 4),
                    Tooltip(
                      message: 'Supprimer',
                      child: IconButton(
                        icon: Icon(Icons.delete_outline, size: 22, color: Colors.grey.shade600),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => _confirmAndDeleteService(context, s),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}
