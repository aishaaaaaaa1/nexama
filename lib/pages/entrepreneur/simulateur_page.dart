import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import '../../theme/app_theme.dart';

class SimulateurPage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const SimulateurPage({super.key, this.userData});

  @override
  State<SimulateurPage> createState() => _SimulateurPageState();
}

class _SimulateurPageState extends State<SimulateurPage> {
  final TextEditingController _montantController = TextEditingController(text: '100000');
  double _taux = 4.5; // Taux INTELAKA ou autre
  double _dureeAnnees = 5;
  
  double _mensualite = 0;
  double _coutTotal = 0;

  @override
  void initState() {
    super.initState();
    _calculer();
  }

  void _calculer() {
    double P = double.tryParse(_montantController.text) ?? 0;
    double r = (_taux / 100) / 12; // Taux mensuel
    double n = _dureeAnnees * 12; // Nombre de mois

    if (P > 0 && r > 0 && n > 0) {
      double m = (P * r * pow(1 + r, n)) / (pow(1 + r, n) - 1);
      setState(() {
        _mensualite = m;
        _coutTotal = (m * n) - P;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Simulateur de Financement', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold, color: NexaColors.darkNavy)),
        const Text('Estimez vos mensualités pour le programme INTILAKA ou autre crédit bancaire.', style: TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 32),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Montant du prêt (MAD)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _montantController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        prefixIcon: const Icon(Icons.money),
                      ),
                      onChanged: (v) => _calculer(),
                    ),
                    const SizedBox(height: 24),
                    Text('Taux d\'intérêt annuel : ${_taux.toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _taux,
                      min: 1.0, max: 15.0, divisions: 140,
                      activeColor: NexaColors.primaryGreen,
                      onChanged: (v) { setState(() => _taux = v); _calculer(); },
                    ),
                    const SizedBox(height: 24),
                    Text('Durée du remboursement : ${_dureeAnnees.toInt()} ans', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Slider(
                      value: _dureeAnnees,
                      min: 1, max: 15, divisions: 14,
                      activeColor: NexaColors.primaryGreen,
                      onChanged: (v) { setState(() => _dureeAnnees = v); _calculer(); },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [NexaColors.darkNavy, Color(0xFF1E293B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(16)
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance, color: Colors.white, size: 48),
                    const SizedBox(height: 16),
                    const Text('Votre Mensualité Estimée', style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 8),
                    Text('${_mensualite.toStringAsFixed(2)} MAD', style: GoogleFonts.inter(color: NexaColors.primaryGreen, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 32),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Capital Emprunté', style: TextStyle(color: Colors.white70)),
                        Text('${_montantController.text} MAD', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Coût Total du Crédit', style: TextStyle(color: Colors.white70)),
                        Text('${_coutTotal.toStringAsFixed(2)} MAD', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
                        onPressed: () {},
                        child: const Text('Générer un dossier de demande', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}
