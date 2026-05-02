import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class DisponibilitesPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const DisponibilitesPage({super.key, this.userData});

  @override
  State<DisponibilitesPage> createState() => _DisponibilitesPageState();
}

class _DisponibilitesPageState extends State<DisponibilitesPage> {
  bool _isAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gérer mes disponibilités', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const Text('Définissez vos horaires de travail et votre statut actuel.', style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 32),
        Container(
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
                      Text(_isAvailable ? 'Vous apparaissez comme disponible pour de nouveaux clients' : 'Vous êtes actuellement hors ligne', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                  Switch(
                    value: _isAvailable,
                    onChanged: (v) => setState(() => _isAvailable = v),
                    activeColor: NexaColors.primaryGreen,
                  )
                ],
              ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 32),
              const Row(
                children: [
                  Icon(Icons.calendar_month, color: NexaColors.primaryGreen),
                  SizedBox(width: 12),
                  Text('Horaires hebdomadaires', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 24),
              _buildDayRow('Lundi', '09:00 - 18:00', true),
              _buildDayRow('Mardi', '09:00 - 18:00', true),
              _buildDayRow('Mercredi', '09:00 - 18:00', true),
              _buildDayRow('Jeudi', '09:00 - 18:00', true),
              _buildDayRow('Vendredi', '09:00 - 16:00', true),
              _buildDayRow('Samedi', 'Fermé', false),
              _buildDayRow('Dimanche', 'Fermé', false),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildDayRow(String day, String hours, bool isOpen) {
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
              IconButton(
                onPressed: () {
                  _showTimeEditDialog(context, day, hours);
                },
                icon: const Icon(Icons.edit_outlined, size: 16, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTimeEditDialog(BuildContext context, String day, String currentHours) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Modifier les horaires : $day', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Row(
              children: [
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Début', hintText: '09:00'))),
                SizedBox(width: 16),
                Expanded(child: TextField(decoration: InputDecoration(labelText: 'Fin', hintText: '18:00'))),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Statut :'),
            Row(
              children: [
                Radio(value: true, groupValue: true, onChanged: (_) {}),
                const Text('Ouvert'),
                Radio(value: false, groupValue: true, onChanged: (_) {}),
                const Text('Fermé'),
              ],
            )
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Horaires mis à jour !'), backgroundColor: Colors.green));
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white),
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }
}
