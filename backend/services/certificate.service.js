const PDFDocument = require('pdfkit');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class CertificateService {
  /**
   * Générer un certificat de réussite
   */
  static async generate(userId, courseId) {
    const user = await prisma.utilisateurs.findUnique({ where: { id: userId } });
    const course = await prisma.cours.findUnique({ where: { id: courseId } });
    
    if (!user || !course) throw new Error("Données introuvables");

    const uniqueId = Date.now().toString(36).toUpperCase();
    const codeVerif = `CERT-${uniqueId}`;

    // Enregistrer en BDD
    await prisma.certificats.create({
      data: {
        utilisateur_id: userId,
        cours_id: courseId,
        code_verif: codeVerif
      }
    });

    const doc = new PDFDocument({ layout: 'landscape', size: 'A4' });

    // Design du certificat
    doc.rect(0, 0, doc.page.width, doc.page.height).fill('#F8FAFC');
    doc.rect(40, 40, doc.page.width - 80, doc.page.height - 80).lineWidth(2).stroke('#10B981');

    doc.fontSize(40).fillColor('#0F172A').text('CERTIFICAT DE RÉUSSITE', 0, 150, { align: 'center' });
    doc.fontSize(18).fillColor('#64748B').text('Ce document atteste que', 0, 220, { align: 'center' });
    
    doc.fontSize(32).fillColor('#10B981').text(user.nom_complet, 0, 260, { align: 'center' });
    
    doc.fontSize(18).fillColor('#64748B').text('a complété avec succès la formation', 0, 320, { align: 'center' });
    doc.fontSize(24).fillColor('#0F172A').text(course.titre, 0, 360, { align: 'center' });

    doc.fontSize(12).fillColor('#94A3B8').text(`Délivré le : ${new Date().toLocaleDateString('fr-FR')}`, 0, 450, { align: 'center' });
    doc.fontSize(12).fillColor('#94A3B8').text(`Code de vérification : ${codeVerif}`, 0, 470, { align: 'center' });

    doc.end();
    return doc;
  }
}

module.exports = CertificateService;
