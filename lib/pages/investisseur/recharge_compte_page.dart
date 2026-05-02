import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../services/api_service.dart';
import '../../config/api_config.dart';

class RechargeComptePage extends StatefulWidget {
  final Map<String, dynamic>? userData;
  const RechargeComptePage({super.key, this.userData});

  @override
  State<RechargeComptePage> createState() => _RechargeComptePageState();
}

class _RechargeComptePageState extends State<RechargeComptePage> {
  final _montantController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _recharge() async {
    if (_montantController.text.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      final userId = widget.userData?['id'] ?? 'user_123';
      final response = await ApiService.post(
        ApiConfig.uri('/api/invest/recharge/$userId'),
        body: {'montant': _montantController.text},
      );

      if (mounted) {
        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Succès : Compte rechargé de ${_montantController.text} MAD.')));
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur lors du rechargement.')));
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Une erreur est survenue.')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recharger mon compte'), backgroundColor: Colors.white, foregroundColor: NexaColors.darkNavy, elevation: 0),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.account_balance_wallet_outlined, size: 80, color: NexaColors.primaryGreen),
              const SizedBox(height: 32),
              Text('Montant à recharger', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Choisissez le montant que vous souhaitez ajouter à votre portefeuille d\'investissement.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              TextField(
                controller: _montantController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  hintText: '0.00',
                  suffixText: 'MAD',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 32),
              Wrap(
                spacing: 12,
                children: ['1000', '5000', '10000', '50000'].map((m) => ChoiceChip(
                  label: Text('$m MAD'),
                  selected: _montantController.text == m,
                  onSelected: (s) => setState(() => _montantController.text = m),
                )).toList(),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _recharge,
                  style: ElevatedButton.styleFrom(backgroundColor: NexaColors.primaryGreen, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  child: _isSubmitting ? const CircularProgressIndicator(color: Colors.white) : const Text('Confirmer le rechargement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
