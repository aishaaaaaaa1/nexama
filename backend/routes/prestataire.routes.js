const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { verifyToken } = require('../utils/authMiddleware');
const { logAction } = require('../utils/auditLogger');
const router = express.Router();
const prisma = new PrismaClient();

router.use(verifyToken);

// ==========================================
// 1. Mes Services
// ==========================================
router.get('/services/:id', async (req, res) => {
  try {
    const services = [
      { id: "1", titre: "Design Logo", categorie: "Design", prix_base: 800 },
      { id: "2", titre: "Développement Web", categorie: "IT", prix_base: 5000 }
    ];
    res.json(services);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 2. Commandes Reçues
// ==========================================
router.get('/commandes/:id', async (req, res) => {
  try {
    const commandes = [
      { id: "CMD-1025", client: "GreenTech Solutions", service: "Développement site web", montant: "3 500 MAD", statut: "En cours", echeance: "20 Mai 2024" },
      { id: "CMD-1024", client: "StartUp Maroc", service: "Design application mobile", montant: "4 200 MAD", statut: "En cours", echeance: "18 Mai 2024" },
      { id: "CMD-1023", client: "BuildMorocco", service: "Rédaction contenu SEO", montant: "1 200 MAD", statut: "Terminé", echeance: "17 Mai 2024" }
    ];
    res.json(commandes);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 3. Proposer un Service
// ==========================================
router.post('/services/:id', async (req, res) => {
  try {
    // En temps normal, on enregistre en base ici.
    res.status(201).json({ message: "Service créé avec succès", service: req.body });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 4. Revenus
// ==========================================
router.get('/revenus/:id', async (req, res) => {
  try {
    res.json({
      total_revenus: "45 800 MAD",
      en_attente: "12 400 MAD",
      historique: [5000, 8000, 12000, 10000, 15000, 18000]
    });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 5. Placeholders pour autres pages
// ==========================================
router.get('/disponibilites/:id', async (req, res) => { res.json({ statut: "Disponible", prochain_creneau: "Aujourd'hui, 14:00" }); });
router.get('/messages/:id', async (req, res) => {
  res.json([
    { id: 1, expediteur: "Admin NexaMa", texte: "Bienvenue sur votre espace prestataire !", date: "15 Mai 2024", lu: true },
    { id: 2, expediteur: "Ali M.", texte: "Bonjour, seriez-vous disponible pour un nouveau projet ?", date: "16 Mai 2024", lu: false },
  ]);
});
router.get('/abonnements/:id', async (req, res) => { res.json({ plan: "Gratuit", expiration: "Illimité" }); });

// ==========================================
// 6. CRM Pipeline
// ==========================================
router.get('/crm/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const deals = await prisma.crm_deals.findMany({
      where: { utilisateur_id: id },
      orderBy: { created_at: 'desc' }
    });
    res.json(deals);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/crm/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { client_nom, montant_estime, statut } = req.body;
    const newDeal = await prisma.crm_deals.create({
      data: {
        utilisateur_id: id,
        client_nom: client_nom || 'Nouveau Prospect',
        montant_estime: montant_estime || 0.0,
        statut: statut || 'prospect'
      }
    });
    res.status(201).json(newDeal);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.put('/crm/deal/:dealId', async (req, res) => {
  try {
    const { dealId } = req.params;
    const { statut } = req.body;
    const updatedDeal = await prisma.crm_deals.update({
      where: { id: dealId },
      data: { statut }
    });
    res.json(updatedDeal);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 4. Évaluations & Avis
// ==========================================
router.get('/evaluations/:id', async (req, res) => {
  res.json([
    { id: 1, client: "Hassan B.", note: 5, commentaire: "Excellent travail sur mon logo !", date: "12 Mai 2024" },
    { id: 2, client: "Sara M.", note: 4, commentaire: "Très pro, un peu de retard sur le délai.", date: "10 Mai 2024" },
    { id: 3, client: "Karim T.", note: 5, commentaire: "Je recommande vivement.", date: "05 Mai 2024" },
  ]);
});

// ==========================================
// 5. Transactions & Paiements
// ==========================================
router.get('/transactions/:id', async (req, res) => {
  res.json([
    { id: "TX-1001", date: "15 Mai 2024", montant: "3 500 MAD", statut: "Terminé", description: "Développement Site Vitrine" },
    { id: "TX-1002", date: "12 Mai 2024", montant: "1 200 MAD", statut: "En attente", description: "Maintenance Mensuelle" },
    { id: "TX-1003", date: "08 Mai 2024", montant: "5 000 MAD", statut: "Terminé", description: "Design App Mobile" },
  ]);
});

// ==========================================
// 7. Quiz & Évaluations (Formations)
// ==========================================
router.get('/quiz/:id', async (req, res) => {
  res.json([
    { id: 1, titre: "Quiz : Bases du Design", apprenants: 45, moyenne: "16/20", statut: "Actif" },
    { id: 2, titre: "Évaluation : Développement Web", apprenants: 32, moyenne: "14/20", statut: "Terminé" },
  ]);
});

// ==========================================
// 8. Sessions Live & Webinaires
// ==========================================
router.get('/lives/:id', async (req, res) => {
  res.json([
    { id: 1, titre: "Atelier : Pitcher son projet", date: "20 Mai 2024", heure: "18:00", inscrits: 12 },
    { id: 2, titre: "Q&A : Statut Auto-Entrepreneur", date: "25 Mai 2024", heure: "14:30", inscrits: 25 },
  ]);
});

// ==========================================
// 9. Premium
// ==========================================
router.post('/premium', async (req, res) => {
  try {
    const { plan } = req.body;
    const user = await prisma.utilisateurs.update({
      where: { id: req.user.id },
      data: { is_verified: true }
    });
    await logAction(req.user.id, 'PREMIUM_UPGRADE', `Passage au plan ${plan} (Prestataire)`);
    res.json({ message: `Passage au plan ${plan} réussi !`, user });
  } catch (error) {
    res.status(500).json({ error: "Erreur lors du passage au premium" });
  }
});

module.exports = router;
