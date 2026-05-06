const express = require('express');
const router = express.Router();
const MatchingService = require('../services/matching.service');
const { verifyToken } = require('../utils/authMiddleware');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

router.use(verifyToken);

// 1. Obtenir les recommandations pour l'investisseur connecté
router.get('/investisseur/recommandations', async (req, res) => {
  try {
    if (req.user.role !== 'investisseur') {
      return res.status(403).json({ error: "Accès réservé aux investisseurs" });
    }
    const recommandations = await MatchingService.getRecommendationsForInvestor(req.user.id);
    res.json(recommandations);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 2. Mettre à jour le profil investisseur
router.post('/investisseur/profile', async (req, res) => {
  try {
    const { secteurs_interet, ticket_min, ticket_max, regions_pref, type_invest } = req.body;
    const profile = await prisma.investisseur_profiles.upsert({
      where: { utilisateur_id: req.user.id },
      update: { secteurs_interet, ticket_min, ticket_max, regions_pref, type_invest },
      create: {
        utilisateur_id: req.user.id,
        secteurs_interet,
        ticket_min,
        ticket_max,
        regions_pref,
        type_invest
      }
    });
    res.json(profile);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 3. Pipeline : Marquer un intérêt pour un projet
router.post('/projets/:projetId/interet', async (req, res) => {
  try {
    const { projetId } = req.params;
    const { statut } = req.body; // VU, INTERESSE, DISCUSSION, etc.
    
    const investissement = await prisma.investissements.upsert({
      where: {
        // Note: Prisma multi-field unique constraint needed here if we want to avoid duplicates
        // For now, we simulate with a findFirst
        id: (await prisma.investissements.findFirst({
          where: { projet_id: projetId, investisseur_id: req.user.id }
        }))?.id || '00000000-0000-0000-0000-000000000000'
      },
      update: { statut },
      create: {
        projet_id: projetId,
        investisseur_id: req.user.id,
        montant: 0,
        statut: statut || 'INTERESSE'
      }
    });
    
    res.json(investissement);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 3. Pipeline de l'investisseur (Matchs)
router.get('/investisseur/pipeline', verifyToken, async (req, res) => {
  try {
    const pipeline = await prisma.pipeline_matching.findMany({
      where: { 
        investisseur_id: req.user.id,
        statut: { in: ['INTÉRESSÉ', 'EN_DISCUSSION'] }
      },
      include: { 
        projet: { 
          include: { 
            entrepreneur: {
              select: { id: true, nom_complet: true, email: true, role: true }
            } 
          } 
        } 
      },
      orderBy: { updated_at: 'desc' }
    });
    res.json(pipeline);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
