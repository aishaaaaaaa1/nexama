const express = require('express');
const router = express.Router();
const { verifyToken } = require('../utils/authMiddleware');
const ProjectExecutionService = require('../services/project-execution.service');
const UploadService = require('../services/upload.service');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Lister les projets où l'utilisateur est membre
router.get('/', verifyToken, async (req, res) => {
  try {
    const projects = await prisma.projects_execution.findMany({
      where: {
        members: { some: { utilisateur_id: req.user.id } }
      },
      include: {
        members: { include: { utilisateur: true } },
        _count: { select: { tasks: true } }
      }
    });
    res.json(projects);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Créer un projet
router.post('/', verifyToken, async (req, res) => {
  try {
    const project = await ProjectExecutionService.createProject(req.user.id, req.body);
    res.status(201).json(project);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Récupérer les tâches d'un projet (Kanban)
router.get('/:id/tasks', verifyToken, async (req, res) => {
  try {
    const tasks = await prisma.tasks.findMany({
      where: { project_id: req.params.id },
      include: { assignee: true, _count: { select: { comments: true } } },
      orderBy: { updated_at: 'desc' }
    });
    res.json(tasks);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Mettre à jour une tâche (Drag & Drop)
router.put('/tasks/:taskId', verifyToken, async (req, res) => {
  try {
    const task = await ProjectExecutionService.updateTaskStatus(req.params.taskId, req.body.statut);
    res.json(task);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Stats & KPIs
router.get('/:id/stats', verifyToken, async (req, res) => {
  try {
    const stats = await ProjectExecutionService.getProjectStats(req.params.id);
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- MESSAGERIE DE GROUPE ---

// Récupérer les messages du projet
router.get('/:id/messages', verifyToken, async (req, res) => {
  try {
    const messages = await prisma.project_messages.findMany({
      where: { project_id: req.params.id },
      include: { expediteur: true },
      orderBy: { created_at: 'asc' }
    });
    res.json(messages);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Envoyer un message au groupe
router.post('/:id/messages', verifyToken, async (req, res) => {
  try {
    const message = await prisma.project_messages.create({
      data: {
        project_id: req.params.id,
        expediteur_id: req.user.id,
        contenu: req.body.contenu
      },
      include: { expediteur: true }
    });
    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Ajouter une pièce jointe à une tâche
router.post('/tasks/:taskId/attachments', verifyToken, async (req, res) => {
  const { fileData, fileName, mimeType } = req.body;
  try {
    const url = await UploadService.saveFile(fileData, fileName);
    
    const attachment = await prisma.task_attachments.create({
      data: {
        task_id: req.params.taskId,
        nom_fichier: fileName,
        url: url,
        type_mime: mimeType
      }
    });

    res.status(201).json(attachment);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
