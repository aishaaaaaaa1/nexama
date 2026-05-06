const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { verifyToken } = require('../utils/authMiddleware');
const { logAction } = require('../utils/auditLogger');
const router = express.Router();
const prisma = new PrismaClient();

router.use(verifyToken);

// ==========================================
// 1. Obtenir les projets à découvrir (Mock / DB)
// ==========================================
router.get('/projets', async (req, res) => {
  try {
    const { secteur, region, stade, budget_min, budget_max } = req.query;
    let projets = [
      { id: "1", nom: "GreenTech Solutions Agri", description: "Solution SaaS pour l'irrigation intelligente au Maroc.", secteur: "Agritech", ville: "Agadir", budget_recherche: 500000, stade_evolution: "Amorçage", trust_score: 8.5, statut_matching: "nouveau", pitch: "Notre technologie permet d'économiser 40% d'eau.", created_at: new Date() },
      { id: "2", nom: "EduConnect Platform", description: "Plateforme cloud de gestion pour écoles privées.", secteur: "Edtech", ville: "Casablanca", budget_recherche: 1200000, stade_evolution: "Croissance", trust_score: 9.1, statut_matching: "interesse", pitch: "EduConnect digitalise l'intégralité du parcours scolaire.", created_at: new Date() },
      { id: "3", nom: "PayMa Fintech", description: "Solution de paiement mobile pour les commerçants.", secteur: "Fintech", ville: "Rabat", budget_recherche: 800000, stade_evolution: "Amorçage", trust_score: 7.8, statut_matching: "en_discussion", pitch: "PayMa simplifie le paiement pour 2M de commerçants.", created_at: new Date() },
      { id: "4", nom: "MedConnect Santé", description: "Télémédecine pour zones rurales du Maroc.", secteur: "HealthTech", ville: "Marrakech", budget_recherche: 2000000, stade_evolution: "Expansion", trust_score: 9.4, statut_matching: "nouveau", pitch: "Connecter les patients ruraux aux médecins spécialistes.", created_at: new Date() },
      { id: "5", nom: "LogiTrack Transport", description: "Optimisation logistique par IA pour le transport.", secteur: "Logistique", ville: "Tanger", budget_recherche: 350000, stade_evolution: "Amorçage", trust_score: 7.2, statut_matching: "vu", pitch: "Réduire les coûts de transport de 30% grâce à l'IA.", created_at: new Date() },
      { id: "6", nom: "SolarFarm Morocco", description: "Énergie solaire pour exploitations agricoles.", secteur: "Energie", ville: "Ouarzazate", budget_recherche: 5000000, stade_evolution: "Croissance", trust_score: 9.5, statut_matching: "nouveau", pitch: "Fournir de l'énergie verte aux fermes du sud.", created_at: new Date() },
    ];

    // Filtering algorithm
    if (secteur) projets = projets.filter(p => p.secteur.toLowerCase() === secteur.toLowerCase());
    if (region) projets = projets.filter(p => p.ville.toLowerCase() === region.toLowerCase());
    if (stade) projets = projets.filter(p => p.stade_evolution.toLowerCase() === stade.toLowerCase());
    if (budget_min) projets = projets.filter(p => p.budget_recherche >= parseInt(budget_min));
    if (budget_max) projets = projets.filter(p => p.budget_recherche <= parseInt(budget_max));

    res.json(projets);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// Matching algorithm endpoint
router.get('/matching/:investisseur_id', async (req, res) => {
  try {
    const { secteurs, regions, stade, budget_min, budget_max } = req.query;
    const allProjets = [
      { id: "1", nom: "GreenTech Solutions Agri", secteur: "Agritech", ville: "Agadir", budget_recherche: 500000, stade_evolution: "Amorçage", trust_score: 8.5, description: "Irrigation intelligente" },
      { id: "2", nom: "EduConnect Platform", secteur: "Edtech", ville: "Casablanca", budget_recherche: 1200000, stade_evolution: "Croissance", trust_score: 9.1, description: "Gestion scolaire cloud" },
      { id: "3", nom: "PayMa Fintech", secteur: "Fintech", ville: "Rabat", budget_recherche: 800000, stade_evolution: "Amorçage", trust_score: 7.8, description: "Paiement mobile" },
      { id: "4", nom: "MedConnect Santé", secteur: "HealthTech", ville: "Marrakech", budget_recherche: 2000000, stade_evolution: "Expansion", trust_score: 9.4, description: "Télémédecine rurale" },
      { id: "5", nom: "LogiTrack Transport", secteur: "Logistique", ville: "Tanger", budget_recherche: 350000, stade_evolution: "Amorçage", trust_score: 7.2, description: "Optimisation logistique IA" },
      { id: "6", nom: "SolarFarm Morocco", secteur: "Energie", ville: "Ouarzazate", budget_recherche: 5000000, stade_evolution: "Croissance", trust_score: 9.5, description: "Énergie solaire agricole" },
    ];

    // Scoring algorithm: secteur(40%) + region(25%) + stade(20%) + trust(15%)
    const prefSecteurs = secteurs ? secteurs.split(',') : [];
    const prefRegions = regions ? regions.split(',') : [];

    const scored = allProjets.map(p => {
      let score = 0;
      if (prefSecteurs.length === 0 || prefSecteurs.some(s => p.secteur.toLowerCase().includes(s.toLowerCase()))) score += 40;
      if (prefRegions.length === 0 || prefRegions.some(r => p.ville.toLowerCase().includes(r.toLowerCase()))) score += 25;
      if (!stade || p.stade_evolution.toLowerCase() === stade.toLowerCase()) score += 20;
      score += (p.trust_score / 10) * 15;
      return { ...p, matching_score: Math.min(Math.round(score), 99) };
    });

    scored.sort((a, b) => b.matching_score - a.matching_score);
    res.json(scored);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur matching" });
  }
});

// Track interest status
router.post('/projets/:projet_id/interet', async (req, res) => {
  try {
    const { investisseur_id, statut } = req.body; // vu, interesse, en_discussion, cloture
    res.json({ message: `Statut mis à jour: ${statut}`, projet_id: req.params.projet_id });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 2. Recharge Compte & Premium
// ==========================================
router.post('/recharge/:id', async (req, res) => {
  try {
    const { montant } = req.body;
    res.json({ message: `Compte rechargé de ${montant} MAD`, nouveau_solde: "550 000 MAD" });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/premium', async (req, res) => {
  try {
    const { plan } = req.body;
    const user = await prisma.utilisateurs.update({
      where: { id: req.user.id },
      data: { is_verified: true }
    });
    await logAction(req.user.id, 'PREMIUM_UPGRADE', `Passage au plan ${plan} (Investisseur)`);
    res.json({ message: "Passage au premium réussi !", plan, user });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 3. Obtenir les investissements (Portfolio)
// ==========================================
router.get('/mes-investissements/:investisseur_id', async (req, res) => {
  try {
    const investissementsMock = [
      {
        id: "inv1",
        projet_nom: "Fintech CashFlow",
        montant: 250000,
        date_invest: new Date("2024-01-15"),
        statut: "actif",
        rendement: "+12%"
      }
    ];
    res.json(investissementsMock);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 4. Documents & Favoris & Messages
// ==========================================
router.get('/documents/:id', async (req, res) => {
  res.json([
    { id: 1, nom: "Accord_Confidentialité_GreenTech.pdf", date: "10 Mai 2024", taille: "850 KB", type: "PDF" },
    { id: 2, nom: "Pacte_Actionnaires_v1.pdf", date: "05 Mai 2024", taille: "2.1 MB", type: "PDF" },
  ]);
});

router.get('/favoris/:id', async (req, res) => {
  res.json([
    { id: "fav1", nom: "SolarFarm Morocco", secteur: "Energie", budget_recherche: 5000000, trust_score: 9.5 },
    { id: "fav2", nom: "BioGrow Tech", secteur: "AgriTech", budget_recherche: 800000, trust_score: 8.8 },
  ]);
});

router.get('/messages/:id', async (req, res) => {
  res.json([
    { id: 1, expediteur: "Admin NexaMa", role: "admin", texte: "Votre compte premium est activé.", date: "12 Mai 2024", lu: true },
    { id: 2, expediteur: "GreenTech Solutions", role: "entrepreneur", texte: "Merci pour votre intérêt pour notre projet. Quand seriez-vous disponible pour un appel ?", date: "14 Mai 2024", lu: false },
    { id: 3, expediteur: "Karim Alami", role: "investisseur", texte: "Bonjour, je serais intéressé par un co-investissement sur le projet EduConnect.", date: "15 Mai 2024", lu: false },
    { id: 4, expediteur: "Sara Bennis", role: "investisseur", texte: "Avez-vous pu consulter le pacte d'actionnaires ?", date: "10 Mai 2024", lu: true },
  ]);
});

module.exports = router;
