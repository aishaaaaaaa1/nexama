const PDFDocument = require('pdfkit');

class BpPdfService {
  /**
   * Générer un PDF professionnel pour le Business Plan
   */
  static async generatePdf(plan, version, res) {
    const doc = new PDFDocument({
      margin: 50,
      size: 'A4',
      bufferPages: true
    });

    // --- COUVERTURE ---
    doc.rect(0, 0, doc.page.width, 150).fill('#0F172A');
    doc.fillColor('#FFFFFF')
       .fontSize(32)
       .font('Helvetica-Bold')
       .text('BUSINESS PLAN', 50, 60);
    
    doc.fillColor('#0F172A')
       .fontSize(24)
       .text(plan.nom_projet.toUpperCase(), 50, 180);
    
    doc.fontSize(14)
       .font('Helvetica')
       .text(`Secteur : ${plan.secteur}`, 50, 220);
    
    doc.moveDown(10);
    doc.fontSize(12)
       .text(`Généré par NexaMa AI le ${new Date().toLocaleDateString('fr-FR')}`, 50, doc.page.height - 100);

    // --- SECTIONS ---
    const sections = version.contenu_json;
    const sectionNames = {
      resume: 'Résumé Exécutif',
      marche: 'Étude de Marché',
      swot: 'Analyse SWOT',
      modele: 'Modèle Économique',
      marketing: 'Stratégie Marketing',
      financier: 'Prévisions Financières'
    };

    for (const [key, content] of Object.entries(sections)) {
      doc.addPage();
      
      // Header Section
      doc.fillColor('#10B981').fontSize(18).font('Helvetica-Bold').text(sectionNames[key] || key.toUpperCase());
      doc.moveDown(0.5);
      doc.rect(50, doc.y, 50, 3).fill('#10B981');
      doc.moveDown(2);

      // Content
      doc.fillColor('#334155').fontSize(12).font('Helvetica').text(content, {
        align: 'justify',
        lineGap: 4
      });
    }

    // --- FOOTER & NUMÉROTATION ---
    const range = doc.bufferedPageRange();
    for (let i = range.start; i < range.start + range.count; i++) {
      doc.switchToPage(i);
      doc.fontSize(10).fillColor('#94A3B8').text(
        `NexaMa - Page ${i + 1}`,
        50,
        doc.page.height - 50,
        { align: 'center' }
      );
    }

    doc.pipe(res);
    doc.end();
  }
}

module.exports = BpPdfService;
