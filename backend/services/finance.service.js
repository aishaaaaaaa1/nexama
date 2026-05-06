const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class FinanceService {
  /**
   * Calculer les statistiques financières pour un utilisateur
   */
  static async getDashboardStats(userId) {
    const now = new Date();
    const currentMonth = now.getMonth();
    const currentYear = now.getFullYear();

    // 1. Chiffre d'Affaires (CA) - Total factures payées
    const invoices = await prisma.factures.findMany({
      where: { utilisateur_id: userId, statut: 'payee' }
    });
    const totalCA = invoices.reduce((sum, inv) => sum + inv.total_ht, 0);

    // 2. Dépenses totales
    const expenses = await prisma.depenses.findMany({
      where: { utilisateur_id: userId }
    });
    const totalExpenses = expenses.reduce((sum, exp) => sum + exp.montant, 0);

    // 3. Factures en attente (Recouvrement)
    const pendingInvoices = await prisma.factures.findMany({
      where: { utilisateur_id: userId, statut: 'en_attente' }
    });
    const totalPending = pendingInvoices.reduce((sum, inv) => sum + inv.total_ttc, 0);

    // 4. Taux de recouvrement
    const totalInvoiced = await prisma.factures.count({ where: { utilisateur_id: userId } });
    const paidCount = await prisma.factures.count({ where: { utilisateur_id: userId, statut: 'payee' } });
    const recoveryRate = totalInvoiced > 0 ? (paidCount / totalInvoiced) * 100 : 0;

    // 5. Cashflow prévisionnel (Projets simplifiés)
    const cashflow = totalCA - totalExpenses + totalPending;

    return {
      total_ca: totalCA,
      total_expenses: totalExpenses,
      net_profit: totalCA - totalExpenses,
      pending_payments: totalPending,
      recovery_rate: recoveryRate.toFixed(1),
      cashflow_forecast: cashflow
    };
  }

  /**
   * Obtenir la timeline fiscale
   */
  static async getTaxTimeline(userId) {
    return await prisma.rappels_fiscaux.findMany({
      where: { utilisateur_id: userId },
      orderBy: { date_limite: 'asc' }
    });
  }

  /**
   * Calculer la TVA (Simplifié pour Auto-Entrepreneur)
   * Note: Au Maroc, les AE sont souvent exonérés jusqu'à un certain seuil,
   * mais le dashboard doit supporter la configuration.
   */
  static calculateTVA(ht, taux) {
    const tva = ht * (taux / 100);
    return {
      tva: tva,
      ttc: ht + tva
    };
  }
}

module.exports = FinanceService;
