const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// --- STATISTIQUES GLOBALES (KPIs) ---
router.get('/stats', async (req, res) => {
  try {
    const entrepreneursCount = await prisma.utilisateurs.count({ where: { role: 'entrepreneur' } });
    const investisseursCount = await prisma.utilisateurs.count({ where: { role: 'investisseur' } });
    const projetsCount = await prisma.projets.count();
    
    const usersCount = await prisma.utilisateurs.count();
    
    res.json({
      utilisateurs_totaux: usersCount,
      entrepreneurs: { current: entrepreneursCount, target: 5000 },
      projets: { current: projetsCount, target: 800 },
      investisseurs: { current: investisseursCount, target: 300 },
      levee_fonds: { current: 1250000, target: 5000000 },
      plans_ia: { current: 450, target: 2000 },
      formations: { current: 1200, target: 15000 }
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- GESTION UTILISATEURS ---
router.get('/users', async (req, res) => {
  try {
    const users = await prisma.utilisateurs.findMany({
      orderBy: { created_at: 'desc' },
      take: 50
    });
    // Mapper pour correspondre aux clés attendues par le front
    const mapped = users.map(u => ({
      nom: u.nom_complet || 'Sans nom',
      email: u.email,
      role: u.role,
      statut: u.statut || (u.is_verified ? 'Actif' : 'En attente'),
      date_inscription: u.created_at ? u.created_at.toISOString().split('T')[0] : '2024-05-15'
    }));
    res.json(mapped);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.patch('/users/:id/status', async (req, res) => {
  const { id } = req.params;
  const { statut } = req.body;
  try {
    const user = await prisma.utilisateurs.update({
      where: { id },
      data: { statut }
    });
    res.json(user);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- MONITORING API IA ---
router.get('/ai-monitoring', (req, res) => {
  const stats = global.aiStats || {
    gemini: { nom: 'Google Gemini 2.0 Flash', requetes: 0, latence_totale: 0, erreurs: 0, dernier_statut: 'Initialisation' },
    local: { nom: 'NexaBot Local Engine', requetes: 0, latence_totale: 0, erreurs: 0, dernier_statut: 'Stable' },
    recentQueries: []
  };

  const providers = [stats.gemini, stats.local].map(s => ({
    nom: s.nom,
    statut: s.dernier_statut,
    latence: s.requetes > 0 ? Math.round(s.latence_totale / s.requetes) : 0,
    requetes_24h: s.requetes,
    cout_estime: Math.round((s.requetes * 0.0001) * 100) / 100 // Simulation coût
  }));

  res.json({
    providers,
    recent_queries: stats.recentQueries
  });
});

// --- JOURNAL D'AUDIT ---
router.get('/audit-log', (req, res) => {
  const logs = global.auditLogs || [
    { id: 1, action: 'SYSTÈME_INIT', user: 'system@nexama.ma', detail: 'Initialisation du journal d\'audit', date: new Date(), ip: '127.0.0.1' }
  ];
  res.json(logs);
});

module.exports = router;
