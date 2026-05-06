const nodemailer = require('nodemailer');
const InvoicePdfService = require('./invoice-pdf.service');
const PDFDocument = require('pdfkit');

class EmailInvoiceService {
  static async sendInvoiceByEmail(invoice, recipientEmail) {
    const transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });

    // Générer le PDF dans un buffer
    const pdfBuffer = await new Promise((resolve) => {
      const doc = new PDFDocument({ margin: 50 });
      let chunks = [];
      doc.on('data', (chunk) => chunks.push(chunk));
      doc.on('end', () => resolve(Buffer.concat(chunks)));
      
      // Utiliser la même logique que InvoicePdfService mais sans doc.pipe(res)
      // Note: Pour simplifier, on peut refactoriser InvoicePdfService 
      // pour accepter le "doc" en paramètre.
      this._generateTemplate(doc, invoice);
      doc.end();
    });

    const mailOptions = {
      from: process.env.SMTP_FROM,
      to: recipientEmail,
      subject: `Facture ${invoice.numero_ref} - NexaMa`,
      text: `Bonjour ${invoice.client_nom},\n\nVeuillez trouver ci-joint votre facture ${invoice.numero_ref} pour un montant de ${invoice.total_ttc} MAD.\n\nMerci de votre confiance.\n\nCordialement,\n${invoice.utilisateur.nom_complet}\nNexaMa Platform`,
      attachments: [
        {
          filename: `Facture_${invoice.numero_ref}.pdf`,
          content: pdfBuffer,
        },
      ],
    };

    return transporter.sendMail(mailOptions);
  }

  // Copie de la logique InvoicePdfService (à terme, centraliser)
  static _generateTemplate(doc, invoice) {
    doc.fillColor('#00D084').fontSize(25).text('NexaMa', 50, 50, { bold: true });
    doc.fillColor('#444444').fontSize(10).text('Plateforme de l\'Entrepreneuriat Marocain', 50, 80);
    doc.fontSize(20).text('FACTURE', 400, 50, { align: 'right' });
    doc.fontSize(10).text(`N° : ${invoice.numero_ref}`, 400, 80, { align: 'right' });
    doc.text(`Date : ${new Date(invoice.date_emission).toLocaleDateString('fr-FR')}`, 400, 95, { align: 'right' });
    doc.moveTo(50, 120).lineTo(550, 120).stroke('#EEEEEE');

    doc.fillColor('#000000').fontSize(12).text('ÉMETTEUR', 50, 140, { bold: true });
    doc.fontSize(10).text(invoice.utilisateur.nom_complet, 50, 160);
    doc.text(`Email : ${invoice.utilisateur.email}`, 50, 175);

    doc.fontSize(12).text('DESTINATAIRE', 350, 140, { bold: true });
    doc.fontSize(10).text(invoice.client_nom, 350, 160);
    if (invoice.client_ice) doc.text(`ICE : ${invoice.client_ice}`, 350, 175);

    doc.moveTo(50, 240).lineTo(550, 240).stroke('#EEEEEE');

    let currentY = 285;
    invoice.items.forEach(item => {
      doc.text(item.designation, 50, currentY, { width: 220 });
      doc.text(item.quantite.toString(), 280, currentY);
      doc.text(item.prix_unitaire.toFixed(2), 330, currentY);
      doc.text(item.total_ht.toFixed(2), 480, currentY, { align: 'right' });
      currentY += 25;
    });

    const summaryY = currentY + 30;
    doc.fillColor('#00D084').fontSize(14).text('TOTAL TTC :', 350, summaryY, { bold: true });
    doc.text(`${invoice.total_ttc.toFixed(2)} MAD`, 480, summaryY, { align: 'right', bold: true });

    doc.fillColor('#888888').fontSize(8);
    doc.text('Généré via NexaMa.', 50, 715, { align: 'center' });
  }
}

module.exports = EmailInvoiceService;
