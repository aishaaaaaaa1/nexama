const express = require('express');
const router = express.Router();
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const { verifyToken } = require('../utils/authMiddleware');
const FinanceService = require('../services/finance.service');
const InvoicePdfService = require('../services/invoice-pdf.service');
const EmailInvoiceService = require('../services/email-invoice.service');
const ExpenseParserService = require('../services/expense-parser.service');
const ReportService = require('../services/report.service');

// --- DASHBOARD STATS ---
router.get('/stats', verifyToken, async (req, res) => {
  try {
    const stats = await FinanceService.getDashboardStats(req.user.id);
    res.json(stats);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- REPORTS ---
router.get('/reports/excel', verifyToken, async (req, res) => {
  try {
    const stats = await FinanceService.getDashboardStats(req.user.id);
    const invoices = await prisma.factures.findMany({ where: { utilisateur_id: req.user.id } });
    const expenses = await prisma.depenses.findMany({ where: { utilisateur_id: req.user.id } });

    res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    res.setHeader('Content-Disposition', 'attachment; filename=Rapport_Financier.xlsx');

    await ReportService.generateExcelReport({ stats, invoices, expenses }, res);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/reports/pdf', verifyToken, async (req, res) => {
  try {
    const stats = await FinanceService.getDashboardStats(req.user.id);
    const invoices = await prisma.factures.findMany({ where: { utilisateur_id: req.user.id } });
    const expenses = await prisma.depenses.findMany({ where: { utilisateur_id: req.user.id } });

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', 'attachment; filename=Synthese_Financiere.pdf');

    await ReportService.generatePdfSummary({ stats, invoices, expenses }, res);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- FACTURES ---
router.get('/invoices', verifyToken, async (req, res) => {
  try {
    const invoices = await prisma.factures.findMany({
      where: { utilisateur_id: req.user.id },
      include: { items: true },
      orderBy: { date_emission: 'desc' }
    });
    res.json(invoices);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.get('/invoices/:id/download', verifyToken, async (req, res) => {
  try {
    const invoice = await prisma.factures.findUnique({
      where: { id: req.params.id },
      include: { items: true, utilisateur: true }
    });

    if (!invoice || invoice.utilisateur_id !== req.user.id) {
      return res.status(404).json({ error: 'Facture non trouvée' });
    }

    res.setHeader('Content-Type', 'application/pdf');
    res.setHeader('Content-Disposition', `attachment; filename=Facture_${invoice.numero_ref}.pdf`);

    InvoicePdfService.generateInvoicePdf(invoice, res);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/invoices/:id/send-email', verifyToken, async (req, res) => {
  const { email } = req.body;
  try {
    const invoice = await prisma.factures.findUnique({
      where: { id: req.params.id },
      include: { items: true, utilisateur: true }
    });

    if (!invoice || invoice.utilisateur_id !== req.user.id) {
      return res.status(404).json({ error: 'Facture non trouvée' });
    }

    await EmailInvoiceService.sendInvoiceByEmail(invoice, email || 'aichaoutajer2@gmail.com');

    await prisma.factures.update({
      where: { id: invoice.id },
      data: { statut: 'Envoyée' }
    });

    res.json({ message: 'Email envoyé avec succès' });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/invoices', verifyToken, async (req, res) => {
  const { client_nom, client_ice, items, date_echeance } = req.body;
  try {
    let total_ht = 0;
    let total_tva = 0;
    
    const formattedItems = items.map(item => {
      const ht = item.quantite * item.prix_unitaire;
      const tva = ht * (item.tva_taux / 100);
      total_ht += ht;
      total_tva += tva;
      return {
        designation: item.designation,
        quantite: item.quantite,
        prix_unitaire: item.prix_unitaire,
        tva_taux: item.tva_taux,
        total_ht: ht,
        total_ttc: ht + tva
      };
    });

    const invoice = await prisma.factures.create({
      data: {
        utilisateur_id: req.user.id,
        numero_ref: `FAC-${Date.now().toString().slice(-6)}`,
        client_nom,
        client_ice,
        total_ht,
        tva: total_tva,
        total_ttc: total_ht + total_tva,
        date_echeance: new Date(date_echeance),
        statut: 'en_attente',
        items: { create: formattedItems }
      },
      include: { items: true }
    });
    res.status(201).json(invoice);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- DÉPENSES ---
router.get('/expenses', verifyToken, async (req, res) => {
  try {
    const expenses = await prisma.depenses.findMany({
      where: { utilisateur_id: req.user.id },
      orderBy: { date_depense: 'desc' }
    });
    res.json(expenses);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/expenses/parse', verifyToken, async (req, res) => {
  const { image } = req.body;
  try {
    const data = await ExpenseParserService.parseReceipt(image);
    res.json(data);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

router.post('/expenses', verifyToken, async (req, res) => {
  const { titre, categorie, montant, description, date_depense } = req.body;
  try {
    const expense = await prisma.depenses.create({
      data: {
        utilisateur_id: req.user.id,
        titre,
        categorie,
        montant,
        description,
        date_depense: date_depense ? new Date(date_depense) : new Date()
      }
    });
    res.status(201).json(expense);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

// --- FISCALITÉ ---
router.get('/taxes', verifyToken, async (req, res) => {
  try {
    const taxes = await FinanceService.getTaxTimeline(req.user.id);
    res.json(taxes);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

module.exports = router;
