import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class PipelineConfig {
  final List<String> colonnes;
  final Map<String, String> titresColonnes;
  final Map<String, Color> couleursColonnes;

  const PipelineConfig({
    required this.colonnes,
    required this.titresColonnes,
    required this.couleursColonnes,
  });

  static const prestataire = PipelineConfig(
    colonnes: ['prospects', 'qualifies', 'devis', 'nego', 'gagne'],
    titresColonnes: {
      'prospects': 'PROSPECTS',
      'qualifies': 'QUALIFIÉS',
      'devis': 'DEVIS ENVOYÉ',
      'nego': 'NÉGOCIATION',
      'gagne': 'GAGNÉ',
    },
    couleursColonnes: {
      'prospects': Color(0xFF94A3B8),
      'qualifies': Color(0xFF3B82F6),
      'devis': Colors.orange,
      'nego': Colors.purple,
      'gagne': NexaColors.primaryGreen,
    },
  );

  static const entrepreneur = PipelineConfig(
    colonnes: ['prospects', 'devis', 'commande', 'facture', 'encaissement'],
    titresColonnes: {
      'prospects': 'PROSPECTS',
      'devis': 'DEVIS',
      'commande': 'COMMANDE',
      'facture': 'FACTURE',
      'encaissement': 'ENCAISSEMENT',
    },
    couleursColonnes: {
      'prospects': Color(0xFF94A3B8),
      'devis': Colors.orange,
      'commande': Colors.purple,
      'facture': Colors.redAccent,
      'encaissement': NexaColors.primaryGreen,
    },
  );
}

String dealCompanyName(Map<String, dynamic> deal) =>
    (deal['nom_entreprise'] ?? deal['client_nom'] ?? 'Client').toString();

String dealContactName(Map<String, dynamic> deal) =>
    (deal['contact_nom'] ?? '').toString();

String dealLastInteractionLabel(Map<String, dynamic> deal) {
  final raw = deal['derniere_interaction'] ?? deal['updated_at'] ?? deal['date_creation'];
  if (raw == null) return '—';
  final s = raw.toString();
  return s.length >= 10 ? s.substring(0, 10) : s;
}

double dealAmount(Map<String, dynamic> deal) {
  final v = deal['montant_estime'];
  if (v is num) return v.toDouble();
  return double.tryParse(v?.toString() ?? '') ?? 0.0;
}

Map<String, dynamic> normalizeDeal(Map<String, dynamic> d) {
  final copy = Map<String, dynamic>.from(d);
  copy['nom_entreprise'] = dealCompanyName(copy);
  copy['montant_estime'] = dealAmount(copy);
  copy['historique'] ??= ['Créé — ${dealLastInteractionLabel(copy)}'];
  copy['documents'] ??= <dynamic>[];
  if (copy['statut'] == 'prospect') copy['statut'] = 'prospects';
  return copy;
}
