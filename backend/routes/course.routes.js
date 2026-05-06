const express = require('express');
const router = express.Router();
const { verifyToken } = require('../utils/authMiddleware');
const CourseService = require('../services/course.service');
const CertificateService = require('../services/certificate.service');

// Lister les cours
router.get('/', async (req, res) => {
  try {
    const courses = await CourseService.listCourses(req.query);
    res.json(courses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Détails d'un cours (authentifié pour voir la progression)
router.get('/:id', verifyToken, async (req, res) => {
  try {
    const course = await CourseService.getCourseDetails(req.params.id, req.user.id);
    res.json(course);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Inscription
router.post('/:id/enroll', verifyToken, async (req, res) => {
  try {
    const enrollment = await CourseService.enroll(req.params.id, req.user.id);
    res.status(201).json(enrollment);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Marquer progression
router.post('/lessons/:lessonId/complete', verifyToken, async (req, res) => {
  try {
    const progress = await CourseService.completeLesson(req.user.id, req.params.lessonId);
    res.json(progress);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Stats de progression cours
router.get('/:id/progress', verifyToken, async (req, res) => {
  try {
    const stats = await CourseService.getCourseProgress(req.params.id, req.user.id);
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Télécharger certificat
router.get('/:id/certificate', verifyToken, async (req, res) => {
  try {
    const doc = await CertificateService.generate(req.user.id, req.params.id);
    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=certificat-${req.params.id}.pdf`);
    doc.pipe(res);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
