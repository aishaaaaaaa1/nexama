const express = require('express');
const router = express.Router();
const { verifyToken } = require('../utils/authMiddleware');
const BusinessPlanService = require('../services/business-plan.service');
const BpPdfService = require('../services/bp-pdf.service');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Créer un nouveau BP et lancer la génération
router.post('/generate', verifyToken, async (req, res) => {
  const { nom_projet, secteur, reponses_form } = req.body;
  try {
    const plan = await prisma.business_plans.create({
      data: {
        utilisateur_id: req.user.id,
        nom_projet,
        secteur,
        reponses_form,
        statut: 'en_cours'
      }
    });

    // Lancer la génération en arrière-plan ou attendre ?
    // Pour l'instant on attend pour simplifier le flow Flutter
    const version = await BusinessPlanService.generateFullPlan(plan.id);
    
    await prisma.business_plans.update({
      where: { id: plan.id },
      data: { statut: 'genere' }
    });

    res.status(201).json({ plan, version });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Récupérer la liste des BP
router.get('/', verifyToken, async (req, res) => {
  try {
    const plans = await prisma.business_plans.findMany({
      where: { utilisateur_id: req.user.id },
      orderBy: { created_at: 'desc' }
    });
    res.json(plans);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Récupérer un BP spécifique et ses versions
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const plan = await prisma.business_plans.findUnique({
      where: { id: req.params.id },
      include: { versions: { orderBy: { created_at: 'desc' }, take: 1 } }
    });
    res.json(plan);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Exporter en PDF
router.get('/:id/export', verifyToken, async (req, res) => {
  try {
    const plan = await prisma.business_plans.findUnique({
      where: { id: req.params.id },
      include: { versions: { orderBy: { created_at: 'desc' }, take: 1 } }
    });

    if (!plan || !plan.versions.length) {
      return res.status(404).json({ error: 'Plan ou version non trouvé' });
    }

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=BusinessPlan.pdf`);

    await BpPdfService.generatePdf(plan, plan.versions[0], res);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
