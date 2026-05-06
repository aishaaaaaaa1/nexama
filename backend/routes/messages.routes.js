const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const { verifyToken } = require('../utils/authMiddleware');
const prisma = new PrismaClient();

router.use(verifyToken);

// 1. Obtenir la liste des conversations
router.get('/conversations', async (req, res) => {
  try {
    const userId = req.user.id;
    
    // On cherche tous les messages où l'utilisateur est expéditeur ou destinataire
    const messages = await prisma.messages.findMany({
      where: {
        OR: [
          { expediteur_id: userId },
          { destinataire_id: userId }
        ]
      },
      include: {
        expediteur: { select: { id: true, nom_complet: true, role: true } },
        destinataire: { select: { id: true, nom_complet: true, role: true } }
      },
      orderBy: { created_at: 'desc' }
    });

    // Grouper par correspondant
    const conversationsMap = new Map();
    messages.forEach(msg => {
      const otherUser = msg.expediteur_id === userId ? msg.destinataire : msg.expediteur;
      if (!conversationsMap.has(otherUser.id)) {
        conversationsMap.set(otherUser.id, {
          user: otherUser,
          lastMessage: msg.contenu,
          lastDate: msg.created_at,
          unread: !msg.lu && msg.destinataire_id === userId
        });
      }
    });

    res.json(Array.from(conversationsMap.values()));
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 2. Obtenir l'historique avec un utilisateur spécifique
router.get('/:otherUserId', async (req, res) => {
  try {
    const userId = req.user.id;
    const { otherUserId } = req.params;

    const messages = await prisma.messages.findMany({
      where: {
        OR: [
          { expediteur_id: userId, destinataire_id: otherUserId },
          { expediteur_id: otherUserId, destinataire_id: userId }
        ]
      },
      orderBy: { created_at: 'asc' }
    });

    // Marquer comme lu
    await prisma.messages.updateMany({
      where: { expediteur_id: otherUserId, destinataire_id: userId, lu: false },
      data: { lu: true }
    });

    res.json(messages);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// 3. Envoyer un message
router.post('/send', async (req, res) => {
  try {
    const { destinataire_id, contenu } = req.body;
    const expediteur_id = req.user.id;

    if (!destinataire_id || !contenu) {
      return res.status(400).json({ error: "Destinataire et contenu requis" });
    }

    // "Chiffrement" basique (Simulation pour la démo)
    const encodedContent = Buffer.from(contenu).toString('base64');

    const message = await prisma.messages.create({
      data: {
        expediteur_id,
        destinataire_id,
        contenu: encodedContent, // Stocké encodé
        lu: false
      }
    });

    // Pour le front, on décode pour le retour immédiat
    message.contenu = contenu;

    res.status(201).json(message);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
