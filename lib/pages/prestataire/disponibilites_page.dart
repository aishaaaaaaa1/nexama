import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../config/api_config.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class DisponibilitesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const DisponibilitesPage({super.key, this.userData});

  @override
  State<DisponibilitesPage> createState() => _DisponibilitesPageState();
}

class _DisponibilitesPageState extends State<DisponibilitesPage> {
  bool _isLoading = true;
  bool _isAvailable = true;
  Map<String, Map<String, dynamic>> _horaires = {};

  String get _userId => widget.userData?['id']?.toString() ?? 'user_123';

  @override
  void initState() {
    super.initState();
    _fetchDisponibilites();
  }

  Future<void> _fetchDisponibilites() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.get(ApiConfig.uri('/api/prestataire/disponibilites/$_userId'));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map;
        final raw = decoded['horaires'] as Map? ?? {};
        setState(() {
          _isAvailable = decoded['statut']?.toString() != 'Indisponible';
          _horaires = raw.map((key, value) => MapEntry(key.toString(), Map<String, dynamic>.from(value as Map)));
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}
    if (mounted) {
      setState(() {
        _horaires = {
          'Lundi': {'ouvert': true, 'debut': '09:00', 'fin': '18:00'},
          'Mardi': {'ouvert': true, 'debut': '09:00', 'fin': '18:00'},
          'Mercredi': {'ouvert': true, 'debut': '09:00', 'fin': '18:00'},
          'Jeudi': {'ouvert': true, 'debut': '09:00', 'fin': '18:00'},
          'Vendredi': {'ouvert': true, 'debut': '09:00', 'fin': '16:00'},
          'Samedi': {'ouvert': false, 'debut': '', 'fin': ''},
          'Dimanche': {'ouvert': false, 'debut': '', 'fin': ''},
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _saveDisponibilites() async {
    try {
      await ApiService.put(
        ApiConfig.uri('/api/prestataire/disponibilites/$_userId'),
        body: {'statut': _isAvailable ? 'Disponible' : 'Indisponible', 'horaires': _horaires},
      );
    } catch (_) {}
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Disponibilités mises à jour.'), backgroundColor: NexaColors.primaryGreen, behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Gérer mes disponibilités', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy))),
            ElevatedButton.icon(onPressed: _saveDisponibilites, icon: const Icon(Icons.save_outlined), label: const Text('Enregistrer'), style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white)),
          ],
        ),
        const Text('Définissez vos horaires de travail et votre statut actuel.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Expanded(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Statut de disponibilité', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(_isAvailable ? 'Disponible pour de nouveaux clients' : 'Actuellement indisponible', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                      Switch(value: _isAvailable, onChanged: (v) => setState(() => _isAvailable = v), activeThumbColor: NexaColors.primaryGreen),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 24),
                  for (final day in _horaires.keys) _buildDayRow(day, _horaires[day]!),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayRow(String day, Map<String, dynamic> value) {
    final isOpen = value['ouvert'] == true;
    final hours = isOpen ? '${value['debut']} - ${value['fin']}' : 'Fermé';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(day, style: const TextStyle(fontWeight: FontWeight.w500)),
          Row(
            children: [
              Text(hours, style: TextStyle(color: isOpen ? NexaColors.darkNavy : Colors.red, fontWeight: isOpen ? FontWeight.bold : FontWeight.normal)),
              const SizedBox(width: 8),
              IconButton(onPressed: () => _showTimeEditDialog(day, value), icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _showTimeEditDialog(String day, Map<String, dynamic> current) async {
    final start = TextEditingController(text: current['debut']?.toString() ?? '09:00');
    final end = TextEditingController(text: current['fin']?.toString() ?? '18:00');
    var open = current['ouvert'] == true;
    final updated = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setLocal) => AlertDialog(
          title: Text('Modifier les horaires : $day', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(children: [
                Expanded(child: TextField(controller: start, decoration: const InputDecoration(labelText: 'Début', hintText: '09:00'))),
                const SizedBox(width: 16),
                Expanded(child: TextField(controller: end, decoration: const InputDecoration(labelText: 'Fin', hintText: '18:00'))),
              ]),
              const SizedBox(height: 16),
              SwitchListTile(value: open, onChanged: (v) => setLocal(() => open = v), title: const Text('Ouvert')),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, {'ouvert': open, 'debut': start.text.trim(), 'fin': end.text.trim()}),
              style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
    start.dispose();
    end.dispose();
    if (updated == null) return;
    setState(() => _horaires[day] = updated);
    _saveDisponibilites();
  }
}
