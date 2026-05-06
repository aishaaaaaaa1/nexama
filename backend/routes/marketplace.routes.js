const express = require('express');
const router = express.Router();
const { verifyToken } = require('../utils/authMiddleware');
const MarketplaceService = require('../services/marketplace.service');

// --- SERVICES ---

// Lister les services
router.get('/services', async (req, res) => {
  try {
    const services = await MarketplaceService.getServices(req.query);
    res.json(services);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- COMMANDES ---

// Créer une commande
router.post('/orders', verifyToken, async (req, res) => {
  try {
    const order = await MarketplaceService.createOrder(req.user.id, req.body.serviceId, req.body);
    res.status(201).json(order);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// Valider une commande (Libération des fonds)
router.post('/orders/:id/validate', verifyToken, async (req, res) => {
  try {
    const result = await MarketplaceService.validateAndReleaseFunds(req.params.id, req.user.id);
    res.json(result);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
