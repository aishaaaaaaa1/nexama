const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { verifyToken, verifyTokenOptional } = require('../utils/authMiddleware');
const { logAction } = require('../utils/auditLogger');
const router = express.Router();
const prisma = new PrismaClient();

router.use(verifyTokenOptional);

/** JWT / URL peuvent différer par type (ex. rare) — normaliser en string. */
function ownerMismatch(urlUserId, req) {
  return String(urlUserId || '') !== String(req.user?.id || '');
}

const commandesStore = new Map();
const servicesStore = new Map();
const disponibilitesStore = new Map();
const documentsStore = new Map();
const opportunitiesStore = new Map();
const portfolioStore = new Map();
const profilsStore = new Map();

function getCommandes(prestataireId) {
  if (!commandesStore.has(prestataireId)) {
    commandesStore.set(prestataireId, [
      { id: 'CMD-1025', client: 'GreenTech Solutions', service: 'Développement site web', montant: '3 500 MAD', statut: 'escrow', echeance: '20 Mai 2026', livrable_url: null },
      { id: 'CMD-1024', client: 'StartUp Maroc', service: 'Design application mobile', montant: '4 200 MAD', statut: 'escrow', echeance: '18 Mai 2026', livrable_url: null },
      { id: 'CMD-1023', client: 'BuildMorocco', service: 'Rédaction contenu SEO', montant: '1 200 MAD', statut: 'terminee', echeance: '17 Mai 2026', livrable_url: '/uploads/livrables/cmd-1023.zip' },
    ]);
  }
  return commandesStore.get(prestataireId);
}

function getServices(prestataireId) {
  if (!servicesStore.has(prestataireId)) {
    servicesStore.set(prestataireId, [
      { id: 'svc1', titre: 'Création site web vitrine', categorie: 'IT & Développement', prix_base: 2500 },
      { id: 'svc2', titre: 'Design logo & identité visuelle', categorie: 'Design', prix_base: 800 },
      { id: 'svc3', titre: 'Rédaction contenu SEO', categorie: 'Rédaction', prix_base: 300 },
    ]);
  }
  return servicesStore.get(prestataireId);
}

function getDisponibilites(prestataireId) {
  if (!disponibilitesStore.has(prestataireId)) {
    disponibilitesStore.set(prestataireId, {
      statut: 'Disponible',
      prochain_creneau: "Aujourd'hui, 14:00",
      horaires: {
        Lundi: { ouvert: true, debut: '09:00', fin: '18:00' },
        Mardi: { ouvert: true, debut: '09:00', fin: '18:00' },
        Mercredi: { ouvert: true, debut: '09:00', fin: '18:00' },
        Jeudi: { ouvert: true, debut: '09:00', fin: '18:00' },
        Vendredi: { ouvert: true, debut: '09:00', fin: '16:00' },
        Samedi: { ouvert: false, debut: '', fin: '' },
        Dimanche: { ouvert: false, debut: '', fin: '' },
      },
    });
  }
  return disponibilitesStore.get(prestataireId);
}

function getDocuments(prestataireId) {
  if (!documentsStore.has(prestataireId)) {
    documentsStore.set(prestataireId, [
      { id: 'doc1', nom: 'Contrat_CMD-1025.pdf', type: 'PDF', date: '15 Mai 2026', taille: '240 Ko', url: '/uploads/docs/Contrat_CMD-1025.pdf' },
      { id: 'doc2', nom: 'Facture_Mai_2026.pdf', type: 'PDF', date: '20 Mai 2026', taille: '180 Ko', url: '/uploads/docs/Facture_Mai_2026.pdf' },
      { id: 'doc3', nom: 'Attestation_fiscale.png', type: 'IMAGE', date: '10 Mai 2026', taille: '1.1 Mo', url: '/uploads/docs/Attestation_fiscale.png' },
    ]);
  }
  return documentsStore.get(prestataireId);
}

function getOpportunities(prestataireId) {
  if (!opportunitiesStore.has(prestataireId)) {
    opportunitiesStore.set(prestataireId, [
      { id: 'opp1', titre: 'Développement Application Mobile E-commerce', client: 'Sanae Boutique', budget: '15 000 - 25 000 MAD', delai: '2 mois', tags: ['Flutter', 'Firebase'], description: 'Application mobile pour boutique en ligne.', statut: 'ouverte' },
      { id: 'opp2', titre: 'Refonte Identité Visuelle', client: 'Atlas Tech', budget: '5 000 MAD', delai: '2 semaines', tags: ['Design', 'Logo'], description: 'Logo et charte graphique moderne.', statut: 'ouverte' },
      { id: 'opp3', titre: 'Campagne Marketing Digital SEO/Ads', client: 'Hotel Riad Marrakesh', budget: '3 000 MAD / mois', delai: 'Long terme', tags: ['SEO', 'Google Ads'], description: 'Amélioration de la visibilité Google.', statut: 'ouverte' },
    ]);
  }
  return opportunitiesStore.get(prestataireId);
}

function getPortfolio(prestataireId) {
  if (!portfolioStore.has(prestataireId)) {
    portfolioStore.set(prestataireId, [
      { id: 'pf1', titre: 'Site vitrine cabinet conseil', categorie: 'Développement Web' },
      { id: 'pf2', titre: 'Identité visuelle restaurant', categorie: 'Design UI/UX' },
      { id: 'pf3', titre: 'Campagne SEO locale', categorie: 'Marketing Digital' },
    ]);
  }
  return portfolioStore.get(prestataireId);
}

function getProfil(prestataireId) {
  if (!profilsStore.has(prestataireId)) {
    profilsStore.set(prestataireId, {
      biographie: 'Prestataire expérimenté en solutions digitales pour entreprises marocaines.',
      specialites: 'Développement Web, Design UI/UX, Marketing Digital',
      ville: 'Casablanca',
      tarif_horaire: '500',
      competences: ['Flutter', 'React', 'Node.js', 'Figma', 'SEO', 'Branding'],
    });
  }
  return profilsStore.get(prestataireId);
}

// ==========================================
// 1. Mes Services
// ==========================================
router.get('/services/:id', async (req, res) => {
  try {
    if (ownerMismatch(req.params.id, req)) {
      return res.status(403).json({ error: 'Accès refusé' });
    }
    const rows = await prisma.services_b2b.findMany({
      where: { prestataire_id: req.user.id, actif: true },
      orderBy: { created_at: 'desc' },
      select: {
        id: true,
        titre: true,
        categorie: true,
        prix_basique: true,
      },
    });
    const services = rows.map((r) => ({
      id: r.id,
      titre: r.titre,
      categorie: r.categorie,
      prix_base: r.prix_basique,
    }));
    res.json(services);
  } catch (error) {
    console.error(error);
    res.json(getServices(req.params.id));
  }
});

/** Désactive le service (soft delete) — reste cohérent avec les commandes liées. */
router.delete('/services/:id/:serviceId', async (req, res) => {
  try {
    if (ownerMismatch(req.params.id, req)) {
      return res.status(403).json({ error: 'Accès refusé' });
    }
    const { serviceId } = req.params;
    const result = await prisma.services_b2b.updateMany({
      where: {
        id: serviceId,
        prestataire_id: req.user.id,
      },
      data: { actif: false },
    });
    if (result.count === 0) {
      return res.status(404).json({ error: 'Service introuvable' });
    }
    res.json({ message: 'Service supprimé' });
  } catch (error) {
    console.error(error);
    const list = getServices(req.params.id);
    const idx = list.findIndex((s) => s.id === req.params.serviceId);
    if (idx === -1) return res.status(404).json({ error: 'Service introuvable' });
    list.splice(idx, 1);
    res.json({ message: 'Service supprimé' });
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
    res.json(getCommandes(req.params.id));
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.put('/commandes/:id/:commandeId/livrer', async (req, res) => {
  try {
    const list = getCommandes(req.params.id);
    const commande = list.find((c) => c.id === req.params.commandeId);
    if (!commande) return res.status(404).json({ error: 'Commande introuvable' });
    commande.statut = 'livree';
    commande.livrable_url = req.body?.livrable_url || req.body?.livrableUrl || null;
    commande.date_livraison = new Date().toISOString();
    res.json({ message: 'Livraison envoyée', commande });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==========================================
// 3. Proposer un Service
// ==========================================
router.post('/services/:id', async (req, res) => {
  try {
    if (ownerMismatch(req.params.id, req)) {
      return res.status(403).json({ error: 'Accès refusé' });
    }
    const { titre, description, categorie, prix_base } = req.body;
    if (!titre || !categorie || description === undefined || description === null) {
      return res.status(400).json({ error: 'Champs requis manquants' });
    }
    const prix = Number(prix_base);
    if (Number.isNaN(prix) || prix < 0) {
      return res.status(400).json({ error: 'Prix invalide' });
    }
    const created = await prisma.services_b2b.create({
      data: {
        prestataire_id: req.user.id,
        titre: String(titre).slice(0, 255),
        description: String(description),
        categorie: String(categorie).slice(0, 100),
        prix_basique: prix,
        tags: [],
      },
    });
    res.status(201).json({
      message: 'Service créé avec succès',
      service: {
        id: created.id,
        titre: created.titre,
        categorie: created.categorie,
        prix_base: created.prix_basique,
      },
    });
  } catch (error) {
    console.error(error);
    const list = getServices(req.params.id);
    const created = {
      id: `svc${Date.now()}`,
      titre: String(req.body?.titre || 'Nouveau service').slice(0, 255),
      categorie: String(req.body?.categorie || 'Service').slice(0, 100),
      prix_base: Number(req.body?.prix_base) || 0,
    };
    list.unshift(created);
    res.status(201).json({ message: 'Service créé avec succès', service: created });
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
router.get('/disponibilites/:id', async (req, res) => { res.json(getDisponibilites(req.params.id)); });
router.put('/disponibilites/:id', async (req, res) => {
  const current = getDisponibilites(req.params.id);
  const updated = { ...current, ...req.body, horaires: { ...current.horaires, ...(req.body?.horaires || {}) } };
  disponibilitesStore.set(req.params.id, updated);
  res.json({ message: 'Disponibilités mises à jour', disponibilites: updated });
});
router.get('/documents/:id', async (req, res) => { res.json(getDocuments(req.params.id)); });
router.get('/opportunites/:id', async (req, res) => { res.json(getOpportunities(req.params.id)); });
router.post('/opportunites/:id/:opportunityId/postuler', async (req, res) => {
  const list = getOpportunities(req.params.id);
  const opportunity = list.find((o) => o.id === req.params.opportunityId);
  if (!opportunity) return res.status(404).json({ error: 'Opportunité introuvable' });
  opportunity.statut = 'postulé';
  opportunity.date_candidature = new Date().toISOString();
  res.json({ message: 'Candidature envoyée', opportunity });
});
router.get('/portfolio/:id', async (req, res) => { res.json(getPortfolio(req.params.id)); });
router.post('/portfolio/:id', async (req, res) => {
  const list = getPortfolio(req.params.id);
  const project = { id: `pf${Date.now()}`, titre: req.body?.titre || 'Nouveau projet', categorie: req.body?.categorie || 'Portfolio' };
  list.unshift(project);
  res.status(201).json({ message: 'Projet ajouté', project });
});
router.get('/profil-public/:id', async (req, res) => { res.json(getProfil(req.params.id)); });
router.put('/profil-public/:id', async (req, res) => {
  const current = getProfil(req.params.id);
  const updated = {
    ...current,
    ...req.body,
    competences: Array.isArray(req.body?.competences)
      ? req.body.competences
      : typeof req.body?.competences === 'string'
        ? req.body.competences.split(',').map((c) => c.trim()).filter(Boolean)
        : current.competences,
  };
  profilsStore.set(req.params.id, updated);
  res.json({ message: 'Profil public mis à jour', profil: updated });
});
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
const CRM_MOCK_DEALS = [
  { id: "1", nom_entreprise: "Maroc Telecom", statut: "prospects", montant_estime: 50000, derniere_interaction: new Date() },
  { id: "2", nom_entreprise: "Attijariwafa Bank", statut: "qualifies", montant_estime: 120000, derniere_interaction: new Date() },
  { id: "3", nom_entreprise: "Office Chérifien des Phosphates", statut: "devis", montant_estime: 300000, derniere_interaction: new Date() },
  { id: "4", nom_entreprise: "Royal Air Maroc", statut: "nego", montant_estime: 45000, derniere_interaction: new Date() },
  { id: "5", nom_entreprise: "NexaDev Studio", statut: "gagne", montant_estime: 15000, derniere_interaction: new Date() },
  { id: "6", nom_entreprise: "Label'Vie", statut: "prospects", montant_estime: 25000, derniere_interaction: new Date() },
  { id: "7", nom_entreprise: "Saham Assurance", statut: "qualifies", montant_estime: 80000, derniere_interaction: new Date() },
];

router.get('/crm/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let deals = [];
    try {
      deals = await prisma.crm_deals.findMany({
        where: { utilisateur_id: id },
        orderBy: { derniere_interaction: 'desc' }
      });
    } catch (dbError) {
      console.warn("DB 'crm_deals' error, using mock data.");
    }

    if (deals.length === 0) {
      deals = CRM_MOCK_DEALS;
    }
    res.json(deals);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/crm/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const { client_nom, nom_entreprise, contact_nom, montant_estime, statut } = req.body;
    const entreprise = nom_entreprise || client_nom || 'Nouveau Prospect';
    const newDeal = await prisma.crm_deals.create({
      data: {
        utilisateur_id: id,
        nom_entreprise: entreprise,
        montant_estime: parseFloat(montant_estime) || 0.0,
        statut: statut || 'prospects',
        derniere_interaction: new Date()
      }
    });
    const payload = { ...newDeal, contact_nom: contact_nom || null };
    res.status(201).json(payload);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur lors de l'ajout" });
  }
});

router.put('/crm/deal/:dealId', async (req, res) => {
  try {
    const { dealId } = req.params;
    const { statut } = req.body;
    if (!statut) return res.status(400).json({ error: "Statut manquant" });

    const updatedDeal = await prisma.crm_deals.update({
      where: { id: dealId },
      data: {
        statut,
        derniere_interaction: new Date()
      }
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
