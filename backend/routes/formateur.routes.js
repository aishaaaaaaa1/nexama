const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { verifyToken } = require('../utils/authMiddleware');
const router = express.Router();
const prisma = new PrismaClient();

router.use(verifyToken);

// ==========================================
// 1. Mes Cours
// ==========================================
router.get('/cours/:id', async (req, res) => {
  try {
    const cours = [
      { id: "1", titre: "Maîtriser Flutter", format_media: "Vidéo", duree_minutes: 120, prix: 499 },
      { id: "2", titre: "Marketing Digital", format_media: "PDF/Vidéo", duree_minutes: 90, prix: 299 }
    ];
    res.json(cours);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 2. Publier un Cours
// ==========================================
router.post('/cours/:id', async (req, res) => {
  try {
    res.status(201).json({ message: "Cours publié avec succès", cours: req.body });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 3. Apprenants
// ==========================================
router.get('/apprenants/:id', async (req, res) => {
  try {
    const apprenants = [
      { id: "1", nom: "Yassine Mansouri", cours: "Flutter Avancé", progression: 0.85 },
      { id: "2", nom: "Laila Bennani", cours: "Marketing Digital", progression: 0.40 }
    ];
    res.json(apprenants);
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
      revenus_totaux: "82 500 MAD",
      mois_en_cours: "15 200 MAD",
      top_cours: "Développement Web"
    });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 5. Placeholders pour autres pages
// ==========================================
router.get('/quiz/:id', async (req, res) => { 
  res.json([
    { id: 1, titre: "Quiz Final Flutter", questions: 15, participations: 42, moyenne: "85%" },
    { id: 2, titre: "Introduction au Marketing", questions: 10, participations: 120, moyenne: "78%" },
  ]); 
});
router.get('/lives/:id', async (req, res) => { 
  res.json([
    { id: 1, titre: "Session Q&A Live : Backend avec Node.js", date: "20 Mai 2024", heure: "18:00", inscrits: 25 },
    { id: 2, titre: "Webinaire : Stratégies de Vente", date: "25 Mai 2024", heure: "15:00", inscrits: 80 },
  ]); 
});
router.get('/avis/:id', async (req, res) => { 
  res.json([
    { id: 1, eleve: "Mehdi O.", note: 5, texte: "Génial ! Le formateur est très pédagogue.", date: "12 Mai 2024" },
    { id: 2, eleve: "Imane K.", note: 4, texte: "Très bon contenu, j'aurais aimé plus d'exercices.", date: "10 Mai 2024" },
  ]); 
});
router.get('/engagement/:id', async (req, res) => { 
  res.json({ 
    taux_completion: "72%", 
    temps_moyen: "45 min", 
    lecons_vues: 1250,
    certificats_delivres: 85
  }); 
});
router.get('/rapports/:id', async (req, res) => { 
  res.json([
    { id: 1, nom: "Rapport_Ventes_Mai_2024.pdf", date: "15 Mai 2024", type: "VENTES" },
    { id: 2, nom: "Analyse_Performance_Cours.pdf", date: "10 Mai 2024", type: "ACADÉMIQUE" },
  ]); 
});
router.get('/profil/:id', async (req, res) => { 
  res.json({ 
    nom: "Karim Alami", 
    biographie: "Expert en développement Fullstack et architecture logicielle avec 10 ans d'expérience.",
    expertise: ["Flutter", "Node.js", "Cloud Computing"],
    rating: 4.9
  }); 
});
router.get('/parametres/:id', async (req, res) => { 
  res.json({ notifications: true, visibilite: "public", mode_paiement: "Virement" }); 
});
router.get('/paiements/:id', async (req, res) => { 
  res.json({ 
    mode: "Virement Bancaire", 
    statut: "Configuré",
    prochain_versement: "01 Juin 2024",
    montant_attente: "12 450 MAD"
  }); 
});

router.get('/messages/:id', async (req, res) => {
  res.json([
    { id: 1, expediteur: "Admin NexaMa", texte: "Nouveau message de support.", date: "10 Mai 2024", lu: true },
    { id: 2, expediteur: "Yassine M.", texte: "Est-ce que le cours Flutter sera mis à jour ?", date: "15 Mai 2024", lu: false },
  ]);
});

module.exports = router;
