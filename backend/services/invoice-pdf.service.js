const PDFDocument = require('pdfkit');

class InvoicePdfService {
  /**
   * Générer un PDF de facture professionnel
   */
  static generateInvoicePdf(invoice, res) {
    const doc = new PDFDocument({ margin: 50 });

    // Stream le PDF directement vers la réponse Express
    doc.pipe(res);

    // --- HEADER ---
    doc.fillColor('#00D084').fontSize(25).text('NexaMa', 50, 50, { bold: true });
    doc.fillColor('#444444').fontSize(10).text('Plateforme de l\'Entrepreneuriat Marocain', 50, 80);
    
    doc.fontSize(20).text('FACTURE', 400, 50, { align: 'right' });
    doc.fontSize(10).text(`N° : ${invoice.numero_ref}`, 400, 80, { align: 'right' });
    doc.text(`Date : ${new Date(invoice.date_emission).toLocaleDateString('fr-FR')}`, 400, 95, { align: 'right' });

    doc.moveTo(50, 120).lineTo(550, 120).stroke('#EEEEEE');

    // --- INFOS PARTIES ---
    doc.fillColor('#000000').fontSize(12).text('ÉMETTEUR (Prestataire)', 50, 140, { bold: true });
    doc.fontSize(10).text(invoice.utilisateur.nom_complet, 50, 160);
    doc.text(`Email : ${invoice.utilisateur.email}`, 50, 175);
    doc.text('Statut : Auto-Entrepreneur', 50, 190);

    doc.fontSize(12).text('DESTINATAIRE (Client)', 350, 140, { bold: true });
    doc.fontSize(10).text(invoice.client_nom, 350, 160);
    if (invoice.client_ice) doc.text(`ICE : ${invoice.client_ice}`, 350, 175);
    if (invoice.client_adresse) doc.text(invoice.client_adresse, 350, 190, { width: 200 });

    doc.moveTo(50, 240).lineTo(550, 240).stroke('#EEEEEE');

    // --- TABLEAU DES ARTICLES ---
    const tableTop = 260;
    doc.fillColor('#666666').fontSize(10);
    doc.text('Désignation', 50, tableTop, { bold: true });
    doc.text('Qté', 280, tableTop, { bold: true });
    doc.text('P.U (MAD)', 330, tableTop, { bold: true });
    doc.text('TVA', 410, tableTop, { bold: true });
    doc.text('Total HT', 480, tableTop, { align: 'right', bold: true });

    let currentY = tableTop + 25;
    invoice.items.forEach(item => {
      doc.fillColor('#000000').fontSize(10);
      doc.text(item.designation, 50, currentY, { width: 220 });
      doc.text(item.quantite.toString(), 280, currentY);
      doc.text(item.prix_unitaire.toFixed(2), 330, currentY);
      doc.text(`${item.tva_taux}%`, 410, currentY);
      doc.text(item.total_ht.toFixed(2), 480, currentY, { align: 'right' });
      currentY += 25;
    });

    doc.moveTo(50, currentY).lineTo(550, currentY).stroke('#EEEEEE');

    // --- RÉCAPITULATIF FINANCIER ---
    const summaryY = currentY + 30;
    doc.fontSize(10).text('Total HT :', 350, summaryY);
    doc.text(`${invoice.total_ht.toFixed(2)} MAD`, 480, summaryY, { align: 'right', bold: true });

    doc.text('TVA (20%) :', 350, summaryY + 20);
    doc.text(`${invoice.tva.toFixed(2)} MAD`, 480, summaryY + 20, { align: 'right', bold: true });

    doc.fillColor('#00D084').fontSize(14).text('TOTAL TTC :', 350, summaryY + 45, { bold: true });
    doc.text(`${invoice.total_ttc.toFixed(2)} MAD`, 480, summaryY + 45, { align: 'right', bold: true });

    // --- BAS DE PAGE ---
    doc.fillColor('#888888').fontSize(8);
    doc.text('Mention Légale : Auto-entrepreneur exonéré de TVA selon l\'article 91 du CGI (ou soumis selon régime).', 50, 700, { align: 'center' });
    doc.text('Généré via NexaMa - La plateforme des entrepreneurs marocains.', 50, 715, { align: 'center' });

    doc.end();
  }
}

module.exports = InvoicePdfService;
