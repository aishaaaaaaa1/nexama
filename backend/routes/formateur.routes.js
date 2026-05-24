const express = require('express');
const { PrismaClient } = require('@prisma/client');
const { verifyToken, verifyTokenOptional } = require('../utils/authMiddleware');
const { logAction } = require('../utils/auditLogger');
const UploadService = require('../services/upload.service');
const router = express.Router();
const prisma = new PrismaClient();

// Mock formateur : token optionnel. Premium reste protégé.
router.use(verifyTokenOptional);

// ==========================================
// 1. Mes Cours (store mémoire par formateur)
// ==========================================
const coursStore = new Map();

function seedCours(formateurId) {
  if (coursStore.has(formateurId)) return;
  coursStore.set(formateurId, [
    {
      id: '1',
      titre: 'Marketing Digital pour PME',
      format_media: 'Vidéo',
      duree_minutes: 180,
      prix: 299,
      categorie: 'Marketing',
      statut: 'Publié',
      apprenants: 562,
      taux_completion: 0.72,
      revenus_mad: 8450,
      date_publication: '2024-03-12',
      icone: 'campaign',
    },
    {
      id: '2',
      titre: 'Création de Site Web de A à Z',
      format_media: 'PDF/Vidéo',
      duree_minutes: 240,
      prix: 399,
      categorie: 'IT',
      statut: 'Publié',
      apprenants: 432,
      taux_completion: 0.65,
      revenus_mad: 6780,
      date_publication: '2024-02-20',
      icone: 'web',
    },
    {
      id: '3',
      titre: 'Levée de Fonds & Pitch Deck',
      format_media: 'Vidéo',
      duree_minutes: 120,
      prix: 499,
      categorie: 'Business',
      statut: 'Publié',
      apprenants: 215,
      taux_completion: 0.58,
      revenus_mad: 4320,
      date_publication: '2024-01-15',
      icone: 'business',
    },
    {
      id: '4',
      titre: 'Gestion Financière Simplifiée',
      format_media: 'PDF',
      duree_minutes: 90,
      prix: 199,
      categorie: 'Finance',
      statut: 'Brouillon',
      apprenants: 36,
      taux_completion: 0,
      revenus_mad: 1100,
      date_publication: null,
      icone: 'account_balance',
    },
    {
      id: '5',
      titre: 'Maîtriser Flutter',
      format_media: 'Vidéo',
      duree_minutes: 320,
      prix: 499,
      categorie: 'IT',
      statut: 'Publié',
      apprenants: 156,
      taux_completion: 0.7,
      revenus_mad: 2200,
      date_publication: '2024-04-01',
      icone: 'code',
    },
  ]);
}

function getCoursList(formateurId) {
  seedCours(formateurId);
  return coursStore.get(formateurId);
}

let nextCourseId = 100;

router.get('/cours/:id', async (req, res) => {
  try {
    const list = getCoursList(req.params.id);
    res.json(list);
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.post('/cours/:id', async (req, res) => {
  try {
    const formateurId = req.params.id;
    const list = getCoursList(formateurId);
    const body = req.body || {};
    const prix = Number(body.prix) || 0;
    let imageUrl = body.image_url || null;
    if (body.vignette_data && body.vignette_name) {
      imageUrl = await UploadService.saveFile(body.vignette_data, body.vignette_name);
    }
    const statut = body.statut || 'Brouillon';
    const isPublished = statut === 'Publi\u00e9' || statut === 'Publie';
    const nouveau = {
      id: String(++nextCourseId),
      titre: body.titre || 'Sans titre',
      format_media: body.format_media || 'Vidéo',
      duree_minutes: Number(body.duree_minutes) || 60,
      prix,
      categorie: body.categorie || 'IT',
      statut: isPublished ? 'Publi\u00e9' : statut,
      apprenants: 0,
      taux_completion: 0,
      revenus_mad: 0,
      date_publication: isPublished ? new Date().toISOString().slice(0, 10) : null,
      icone: body.icone || 'school',
      description: body.description || '',
      image_url: imageUrl,
    };
    list.unshift(nouveau);
    res.status(201).json({ message: 'Cours publié avec succès', cours: nouveau });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.put('/cours/:id/:courseId', async (req, res) => {
  try {
    const list = getCoursList(req.params.id);
    const idx = list.findIndex((c) => c.id === req.params.courseId);
    if (idx === -1) {
      return res.status(404).json({ error: 'Cours introuvable' });
    }
    const body = req.body || {};
    const current = list[idx];
    const updated = {
      ...current,
      ...body,
      id: current.id,
    };
    if (body.statut === 'Publié' && !current.date_publication) {
      updated.date_publication = new Date().toISOString().slice(0, 10);
    }
    if (body.statut === 'Brouillon') {
      updated.date_publication = null;
    }
    list[idx] = updated;
    res.json({ message: 'Cours mis à jour', cours: updated });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.delete('/cours/:id/:courseId', async (req, res) => {
  try {
    const list = getCoursList(req.params.id);
    const idx = list.findIndex((c) => c.id === req.params.courseId);
    if (idx === -1) {
      return res.status(404).json({ error: 'Cours introuvable' });
    }
    const [removed] = list.splice(idx, 1);
    res.json({ message: 'Cours supprimé', cours: removed });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==========================================
// 3. Apprenants (store mémoire)
// ==========================================
const apprenantsStore = new Map();

function seedApprenants(formateurId) {
  if (apprenantsStore.has(formateurId)) return;
  apprenantsStore.set(formateurId, [
    {
      id: 'a1',
      conversation_id: 'yassine',
      nom: 'Yassine Mansouri',
      email: 'yassine.m@exemple.ma',
      cours: 'Maîtriser Flutter',
      progression: 0.85,
      statut: 'Actif',
      derniere_activite: 'Il y a 2 heures',
      quiz_moyen: 88,
      temps_etude_h: 24,
      certificat: false,
    },
    {
      id: 'a2',
      conversation_id: 'laila',
      nom: 'Laila Bennani',
      email: 'laila.b@exemple.ma',
      cours: 'Marketing Digital',
      progression: 0.72,
      statut: 'Actif',
      derniere_activite: 'Il y a 5 heures',
      quiz_moyen: 76,
      temps_etude_h: 18,
      certificat: true,
    },
    {
      id: 'a3',
      conversation_id: 'mehdi',
      nom: 'Mehdi O.',
      email: 'mehdi.o@exemple.ma',
      cours: 'Création de Site Web',
      progression: 0.40,
      statut: 'À risque',
      derniere_activite: 'Il y a 1 jour',
      quiz_moyen: 62,
      temps_etude_h: 9,
      certificat: false,
    },
    {
      id: 'a4',
      conversation_id: null,
      nom: 'Imane K.',
      email: 'imane.k@exemple.ma',
      cours: 'Marketing Digital pour PME',
      progression: 0.75,
      statut: 'Actif',
      derniere_activite: 'Il y a 3 heures',
      quiz_moyen: 91,
      temps_etude_h: 31,
      certificat: true,
    },
    {
      id: 'a5',
      conversation_id: null,
      nom: 'Khadija A.',
      email: 'khadija.a@exemple.ma',
      cours: 'Levée de Fonds & Pitch Deck',
      progression: 0.90,
      statut: 'Actif',
      derniere_activite: 'Il y a 6 heures',
      quiz_moyen: 94,
      temps_etude_h: 28,
      certificat: true,
    },
    {
      id: 'a6',
      conversation_id: null,
      nom: 'Salma R.',
      email: 'salma.r@exemple.ma',
      cours: 'Gestion Financière Simplifiée',
      progression: 0.55,
      statut: 'Actif',
      derniere_activite: 'Il y a 1 jour',
      quiz_moyen: 70,
      temps_etude_h: 12,
      certificat: false,
    },
    {
      id: 'a7',
      conversation_id: null,
      nom: 'Amine B.',
      email: 'amine.b@exemple.ma',
      cours: 'Marketing Digital pour PME',
      progression: 0.15,
      statut: 'Inactif',
      derniere_activite: 'Il y a 12 jours',
      quiz_moyen: 45,
      temps_etude_h: 2,
      certificat: false,
    },
  ]);
}

function getApprenants(formateurId) {
  seedApprenants(formateurId);
  return apprenantsStore.get(formateurId);
}

router.get('/apprenants/:id', async (req, res) => {
  try {
    res.json(getApprenants(req.params.id));
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.get('/apprenants/:id/:apprenantId', async (req, res) => {
  try {
    const list = getApprenants(req.params.id);
    const a = list.find((x) => x.id === req.params.apprenantId);
    if (!a) return res.status(404).json({ error: 'Apprenant introuvable' });
    res.json(a);
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.patch('/apprenants/:id/:apprenantId', async (req, res) => {
  try {
    const list = getApprenants(req.params.id);
    const idx = list.findIndex((x) => x.id === req.params.apprenantId);
    if (idx === -1) return res.status(404).json({ error: 'Apprenant introuvable' });
    list[idx] = { ...list[idx], ...req.body, id: list[idx].id };
    res.json({ message: 'Apprenant mis à jour', apprenant: list[idx] });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
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

const quizStore = new Map();
const livesStore = new Map();
const rapportsStore = new Map();
const profilsStore = new Map();
const paiementsStore = new Map();

function todayFr() {
  return new Date().toLocaleDateString('fr-FR', { day: '2-digit', month: 'long', year: 'numeric' });
}

function getQuizList(formateurId) {
  if (!quizStore.has(formateurId)) {
    quizStore.set(formateurId, [
      { id: 'q1', titre: 'Quiz Final Flutter', cours: 'Maîtriser Flutter', questions: 15, participations: 42, moyenne: '85%' },
      { id: 'q2', titre: 'Introduction au Marketing', cours: 'Marketing Digital', questions: 10, participations: 120, moyenne: '78%' },
    ]);
  }
  return quizStore.get(formateurId);
}

function getLivesList(formateurId) {
  if (!livesStore.has(formateurId)) {
    livesStore.set(formateurId, [
      { id: 'l1', titre: 'Session Q&A Live : Backend avec Node.js', date: '20 Mai 2026', heure: '18:00', inscrits: 25 },
      { id: 'l2', titre: 'Webinaire : Stratégies de Vente', date: '25 Mai 2026', heure: '15:00', inscrits: 80 },
    ]);
  }
  return livesStore.get(formateurId);
}

function getRapportsList(formateurId) {
  if (!rapportsStore.has(formateurId)) {
    rapportsStore.set(formateurId, [
      { id: 'r1', nom: 'Rapport_Ventes_Mai_2026.pdf', date: '15 Mai 2026', type: 'VENTES', url: '/uploads/reports/Rapport_Ventes_Mai_2026.pdf' },
      { id: 'r2', nom: 'Analyse_Performance_Cours.pdf', date: '10 Mai 2026', type: 'ACADÉMIQUE', url: '/uploads/reports/Analyse_Performance_Cours.pdf' },
    ]);
  }
  return rapportsStore.get(formateurId);
}

function getProfil(formateurId) {
  if (!profilsStore.has(formateurId)) {
    profilsStore.set(formateurId, {
      nom: 'Karim Alami',
      biographie: "Expert en développement Fullstack et architecture logicielle avec 10 ans d'expérience.",
      expertise: ['Flutter', 'Node.js', 'Cloud Computing'],
      rating: 4.9,
      cours_publies: 5,
      visibilite: 'Activé',
      messages: 'Autorisés',
    });
  }
  return profilsStore.get(formateurId);
}

function getPaiement(formateurId) {
  if (!paiementsStore.has(formateurId)) {
    paiementsStore.set(formateurId, {
      mode: 'Virement Bancaire',
      statut: 'Configuré',
      rib: '4521',
      prochain_versement: '01 Juin 2026',
      montant_attente: '12 450 MAD',
    });
  }
  return paiementsStore.get(formateurId);
}

router.post('/quiz/:id', async (req, res) => {
  const list = getQuizList(req.params.id);
  const body = req.body || {};
  const quiz = {
    id: `q${Date.now()}`,
    titre: body.titre || 'Nouveau quiz',
    cours: body.cours || 'Cours non défini',
    questions: Number(body.questions) || 10,
    participations: 0,
    moyenne: '—',
  };
  list.unshift(quiz);
  res.status(201).json({ message: 'Quiz créé', quiz });
});

router.delete('/quiz/:id/:quizId', async (req, res) => {
  const list = getQuizList(req.params.id);
  const idx = list.findIndex((q) => String(q.id) === String(req.params.quizId));
  if (idx === -1) return res.status(404).json({ error: 'Quiz introuvable' });
  const [quiz] = list.splice(idx, 1);
  res.json({ message: 'Quiz supprimé', quiz });
});

router.post('/lives/:id', async (req, res) => {
  const list = getLivesList(req.params.id);
  const body = req.body || {};
  const live = {
    id: `l${Date.now()}`,
    titre: body.titre || 'Live sans titre',
    date: body.date || todayFr(),
    heure: body.heure || '18:00',
    inscrits: Number(body.inscrits) || 0,
  };
  list.unshift(live);
  res.status(201).json({ message: 'Live programmé', live });
});

router.put('/lives/:id/:liveId', async (req, res) => {
  const list = getLivesList(req.params.id);
  const idx = list.findIndex((l) => String(l.id) === String(req.params.liveId));
  if (idx === -1) return res.status(404).json({ error: 'Live introuvable' });
  list[idx] = { ...list[idx], ...req.body, id: list[idx].id, inscrits: Number(req.body?.inscrits ?? list[idx].inscrits) || 0 };
  res.json({ message: 'Live mis à jour', live: list[idx] });
});

router.delete('/lives/:id/:liveId', async (req, res) => {
  const list = getLivesList(req.params.id);
  const idx = list.findIndex((l) => String(l.id) === String(req.params.liveId));
  if (idx === -1) return res.status(404).json({ error: 'Live introuvable' });
  const [live] = list.splice(idx, 1);
  res.json({ message: 'Live supprimé', live });
});

router.post('/avis/:id/:avisId/reponse', async (req, res) => {
  const reponse = (req.body?.reponse || '').trim();
  if (!reponse) return res.status(400).json({ error: 'Réponse vide' });
  res.json({ message: 'Réponse publiée', avis: { id: req.params.avisId, reponse, reponse_date: todayFr() } });
});

router.post('/rapports/:id', async (req, res) => {
  const list = getRapportsList(req.params.id);
  const type = req.body?.type || 'VENTES';
  const report = {
    id: `r${Date.now()}`,
    nom: `${type === 'VENTES' ? 'Rapport_Ventes' : 'Analyse_Academique'}_${Date.now()}.pdf`,
    date: todayFr(),
    type,
    url: `/uploads/reports/${type}_${Date.now()}.pdf`,
  };
  list.unshift(report);
  res.status(201).json({ message: 'Rapport généré', rapport: report });
});

router.put('/profil/:id', async (req, res) => {
  const current = getProfil(req.params.id);
  const body = req.body || {};
  const updated = {
    ...current,
    ...body,
    expertise: Array.isArray(body.expertise)
      ? body.expertise
      : typeof body.expertise === 'string'
        ? body.expertise.split(',').map((e) => e.trim()).filter(Boolean)
        : current.expertise,
  };
  profilsStore.set(req.params.id, updated);
  res.json({ message: 'Profil mis à jour', profil: updated });
});

router.put('/paiements/:id', async (req, res) => {
  const current = getPaiement(req.params.id);
  const updated = { ...current, ...req.body, statut: 'Configuré' };
  paiementsStore.set(req.params.id, updated);
  res.json({ message: 'Coordonnées bancaires mises à jour', paiement: updated });
});

// ==========================================
// Messages formateur (conversations + fils)
// ==========================================
const conversationsStore = new Map();
const messageThreadsStore = new Map();

function seedMessages(formateurId) {
  if (conversationsStore.has(formateurId)) return;
  const conversations = [
    {
      id: 'yassine',
      expediteur: 'Yassine Mansouri',
      role: 'Apprenant',
      cours: 'Maîtriser Flutter',
      dernier_message: 'Est-ce que le cours Flutter sera mis à jour ?',
      date: '15 Mai 2024',
      heure: '14:32',
      non_lus: 2,
      en_ligne: true,
    },
    {
      id: 'laila',
      expediteur: 'Laila Bennani',
      role: 'Apprenant',
      cours: 'Marketing Digital',
      dernier_message: 'Merci pour la correction du module 3 !',
      date: '14 Mai 2024',
      heure: '09:15',
      non_lus: 0,
      en_ligne: false,
    },
    {
      id: 'admin',
      expediteur: 'Admin NexaMa',
      role: 'Support',
      cours: 'Plateforme',
      dernier_message: 'Votre compte formateur est vérifié. Bonne formation !',
      date: '12 Mai 2024',
      heure: '16:00',
      non_lus: 1,
      en_ligne: true,
    },
    {
      id: 'mehdi',
      expediteur: 'Mehdi O.',
      role: 'Apprenant',
      cours: 'Création de Site Web',
      dernier_message: 'Pouvez-vous ajouter un quiz sur le SEO ?',
      date: '11 Mai 2024',
      heure: '18:45',
      non_lus: 0,
      en_ligne: false,
    },
  ];
  conversationsStore.set(formateurId, conversations);
  messageThreadsStore.set(formateurId, {
    yassine: [
      { id: 'm1', auteur: 'Yassine Mansouri', texte: 'Bonjour, j\'ai une question sur le module 4.', date: '14 Mai', heure: '10:20', expediteur_apprenant: true },
      { id: 'm2', auteur: 'Vous', texte: 'Bonjour Yassine, je vous réponds dans la journée.', date: '14 Mai', heure: '11:05', expediteur_apprenant: false },
      { id: 'm3', auteur: 'Yassine Mansouri', texte: 'Est-ce que le cours Flutter sera mis à jour ?', date: '15 Mai', heure: '14:32', expediteur_apprenant: true },
    ],
    laila: [
      { id: 'm1', auteur: 'Laila Bennani', texte: 'Le quiz du chapitre 2 est très clair.', date: '13 Mai', heure: '16:00', expediteur_apprenant: true },
      { id: 'm2', auteur: 'Vous', texte: 'Ravi que cela vous aide !', date: '14 Mai', heure: '08:30', expediteur_apprenant: false },
      { id: 'm3', auteur: 'Laila Bennani', texte: 'Merci pour la correction du module 3 !', date: '14 Mai', heure: '09:15', expediteur_apprenant: true },
    ],
    admin: [
      { id: 'm1', auteur: 'Admin NexaMa', texte: 'Bienvenue sur NexaMa Formateur.', date: '10 Mai', heure: '09:00', expediteur_apprenant: true },
      { id: 'm2', auteur: 'Admin NexaMa', texte: 'Votre compte formateur est vérifié. Bonne formation !', date: '12 Mai', heure: '16:00', expediteur_apprenant: true },
    ],
    mehdi: [
      { id: 'm1', auteur: 'Mehdi O.', texte: 'Super cours sur le HTML/CSS.', date: '10 Mai', heure: '20:00', expediteur_apprenant: true },
      { id: 'm2', auteur: 'Vous', texte: 'Merci Mehdi, notez le module 5 quand vous pouvez.', date: '11 Mai', heure: '10:00', expediteur_apprenant: false },
      { id: 'm3', auteur: 'Mehdi O.', texte: 'Pouvez-vous ajouter un quiz sur le SEO ?', date: '11 Mai', heure: '18:45', expediteur_apprenant: true },
    ],
  });
}

function getConversations(formateurId) {
  seedMessages(formateurId);
  return conversationsStore.get(formateurId);
}

function getThread(formateurId, convId) {
  seedMessages(formateurId);
  const threads = messageThreadsStore.get(formateurId);
  return threads?.[convId] || [];
}

router.get('/messages/:id', async (req, res) => {
  try {
    res.json(getConversations(req.params.id));
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.get('/messages/:id/:convId', async (req, res) => {
  try {
    res.json({ messages: getThread(req.params.id, req.params.convId) });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.post('/messages/:id/:convId', async (req, res) => {
  try {
    const { id: formateurId, convId } = req.params;
    seedMessages(formateurId);
    const texte = (req.body?.texte || '').trim();
    if (!texte) return res.status(400).json({ error: 'Message vide' });

    const threads = messageThreadsStore.get(formateurId);
    const msg = {
      id: `m${Date.now()}`,
      auteur: 'Vous',
      texte,
      date: 'Aujourd\'hui',
      heure: new Date().toLocaleTimeString('fr-FR', { hour: '2-digit', minute: '2-digit' }),
      expediteur_apprenant: false,
    };
    if (!threads[convId]) threads[convId] = [];
    threads[convId].push(msg);

    const convs = conversationsStore.get(formateurId);
    const conv = convs.find((c) => c.id === convId);
    if (conv) {
      conv.dernier_message = texte;
      conv.date = 'Aujourd\'hui';
      conv.heure = msg.heure;
      conv.non_lus = 0;
    }

    res.status(201).json({ message: 'Message envoyé', msg });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

router.patch('/messages/:id/:convId/read', async (req, res) => {
  try {
    const { id: formateurId, convId } = req.params;
    seedMessages(formateurId);
    const convs = conversationsStore.get(formateurId);
    const conv = convs.find((c) => c.id === convId);
    if (conv) conv.non_lus = 0;
    res.json({ message: 'Conversation marquée comme lue' });
  } catch (error) {
    res.status(500).json({ error: 'Erreur serveur' });
  }
});

// ==========================================
// 6. Premium
// ==========================================
router.post('/premium', verifyToken, async (req, res) => {
  try {
    const { plan } = req.body;
    const user = await prisma.utilisateurs.update({
      where: { id: req.user.id },
      data: { is_verified: true }
    });
    await logAction(req.user.id, 'PREMIUM_UPGRADE', `Passage au plan ${plan} (Formateur)`);
    res.json({ message: `Passage au plan ${plan} réussi !`, user });
  } catch (error) {
    res.status(500).json({ error: "Erreur lors du passage au premium" });
  }
});

module.exports = router;
