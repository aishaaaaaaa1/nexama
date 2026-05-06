const express = require('express');
const router = express.Router();
const { verifyToken } = require('../utils/authMiddleware');
const ForumService = require('../services/forum.service');

// Lister les posts
router.get('/', async (req, res) => {
  try {
    const posts = await ForumService.listPosts(req.query);
    res.json(posts);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Créer un post
router.post('/', verifyToken, async (req, res) => {
  try {
    const post = await ForumService.createPost(req.user.id, req.body);
    res.status(201).json(post);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Détails d'un post
router.get('/:id', async (req, res) => {
  try {
    const post = await ForumService.getPostDetails(req.params.id);
    res.json(post);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Répondre à un post
router.post('/:id/replies', verifyToken, async (req, res) => {
  try {
    const reply = await ForumService.createReply(req.user.id, req.params.id, req.body.contenu);
    res.status(201).json(reply);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
