const express = require('express');
const router = express.Router();
const { verifyToken } = require('../utils/authMiddleware');
const TrainerService = require('../services/trainer.service');

// Middleware pour vérifier que l'utilisateur est un formateur
const checkTrainerRole = (req, res, next) => {
  if (req.user.role !== 'formateur') {
    return res.status(403).json({ error: "Accès réservé aux formateurs" });
  }
  next();
};

// Stats du dashboard formateur
router.get('/stats', verifyToken, checkTrainerRole, async (req, res) => {
  try {
    const stats = await TrainerService.getDashboardStats(req.user.id);
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Liste des étudiants
router.get('/students', verifyToken, checkTrainerRole, async (req, res) => {
  try {
    const students = await TrainerService.getStudentsList(req.user.id);
    res.json(students);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
