const ExcelJS = require('exceljs');
const PDFDocument = require('pdfkit');

class ReportService {
  /**
   * Générer un rapport Excel complet
   */
  static async generateExcelReport(data, res) {
    const workbook = new ExcelJS.Workbook();
    
    // --- FEUILLE RÉSUMÉ ---
    const summarySheet = workbook.addWorksheet('Résumé Financier');
    summarySheet.columns = [
      { header: 'Indicateur', key: 'label', width: 25 },
      { header: 'Valeur (MAD)', key: 'value', width: 20 }
    ];
    summarySheet.addRows([
      { label: 'Chiffre d\'Affaires Total', value: data.stats.total_ca },
      { label: 'Dépenses Totales', value: data.stats.total_expenses },
      { label: 'Bénéfice Net', value: data.stats.net_profit },
      { label: 'TVA à Déclarer (Est.)', value: data.stats.total_ca * 0.2 }
    ]);

    // --- FEUILLE FACTURES ---
    const invoiceSheet = workbook.addWorksheet('Factures');
    invoiceSheet.columns = [
      { header: 'Référence', key: 'numero_ref', width: 15 },
      { header: 'Client', key: 'client_nom', width: 25 },
      { header: 'Total HT', key: 'total_ht', width: 15 },
      { header: 'Total TTC', key: 'total_ttc', width: 15 },
      { header: 'Statut', key: 'statut', width: 12 },
      { header: 'Date', key: 'date_emission', width: 15 }
    ];
    invoiceSheet.addRows(data.invoices);

    // --- FEUILLE DÉPENSES ---
    const expenseSheet = workbook.addWorksheet('Dépenses');
    expenseSheet.columns = [
      { header: 'Titre', key: 'titre', width: 25 },
      { header: 'Catégorie', key: 'categorie', width: 15 },
      { header: 'Montant', key: 'montant', width: 15 },
      { header: 'Description', key: 'description', width: 30 },
      { header: 'Date', key: 'date_depense', width: 15 }
    ];
    expenseSheet.addRows(data.expenses);

    // Styling
    workbook.eachSheet((sheet) => {
      sheet.getRow(1).font = { bold: true };
      sheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF00D084' } };
    });

    await workbook.xlsx.write(res);
  }

  /**
   * Générer un rapport PDF de synthèse
   */
  static async generatePdfSummary(data, res) {
    const doc = new PDFDocument({ margin: 50 });
    doc.pipe(res);

    doc.fillColor('#00D084').fontSize(25).text('NexaMa - Rapport Financier', 50, 50, { bold: true });
    doc.fillColor('#444444').fontSize(10).text(`Période : Janvier 2024 - Décembre 2024`, 50, 80);
    
    doc.moveTo(50, 110).lineTo(550, 110).stroke('#EEEEEE');

    // Stats Section
    doc.fillColor('#000000').fontSize(16).text('Résumé de l\'Activité', 50, 130, { bold: true });
    doc.fontSize(12).text(`Chiffre d'Affaires : ${data.stats.total_ca.toFixed(2)} MAD`, 50, 160);
    doc.text(`Dépenses Totales : ${data.stats.total_expenses.toFixed(2)} MAD`, 50, 180);
    doc.fillColor('#00D084').text(`Bénéfice Net : ${data.stats.net_profit.toFixed(2)} MAD`, 50, 200, { bold: true });

    doc.moveTo(50, 230).lineTo(550, 230).stroke('#EEEEEE');

    // Category Breakdown
    doc.fillColor('#000000').fontSize(16).text('Répartition des Dépenses', 50, 250, { bold: true });
    let y = 280;
    const categories = [...new Set(data.expenses.map(e => e.categorie))];
    categories.forEach(cat => {
      const total = data.expenses.filter(e => e.categorie === cat).reduce((sum, e) => sum + e.montant, 0);
      doc.fontSize(10).text(`${cat} : ${total.toFixed(2)} MAD`, 50, y);
      y += 20;
    });

    doc.fillColor('#888888').fontSize(8).text('Rapport généré automatiquement par NexaMa.', 50, 700, { align: 'center' });

    doc.end();
  }
}

module.exports = ReportService;
