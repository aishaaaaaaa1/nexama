const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();
const nodemailer = require('nodemailer');

class NotificationService {
  constructor() {
    this.transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: process.env.SMTP_PORT,
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
    });
  }

  /**
   * Envoyer une notification (Email + Log BDD pour Push)
   */
  async notify(utilisateurId, titre, message, type = 'info') {
    try {
      const user = await prisma.utilisateurs.findUnique({ where: { id: utilisateurId } });
      if (!user) return;

      // 1. Envoyer Email
      await this.transporter.sendMail({
        from: process.env.SMTP_FROM,
        to: user.email,
        subject: `[NexaMa] ${titre}`,
        text: message,
        html: `<div style="font-family: sans-serif; padding: 20px; border: 1px solid #eee; border-radius: 10px;">
                <h2 style="color: #10B981;">NexaMa Project</h2>
                <p><strong>${titre}</strong></p>
                <p>${message}</p>
                <hr style="border: 0; border-top: 1px solid #eee; margin: 20px 0;">
                <p style="font-size: 12px; color: #666;">Ceci est une notification automatique de votre plateforme NexaMa.</p>
               </div>`
      });

      console.log(`Notification envoyée à ${user.email} : ${titre}`);

      // 2. Simulation Push (Log dans une table dédiée si elle existe)
      // On pourrait ajouter une table 'notifications' au schéma plus tard
    } catch (error) {
      console.error("Notification Error:", error.message);
    }
  }

  /**
   * Alerte de deadline imminente
   */
  async alertDeadline(taskId) {
    const task = await prisma.tasks.findUnique({
      where: { id: taskId },
      include: { assignee: true, project: true }
    });

    if (task && task.assignee) {
      await this.notify(
        task.assignee.id,
        "⚠️ Deadline proche",
        `La tâche "${task.titre}" du projet "${task.project.nom}" arrive à échéance bientôt !`
      );
    }
  }
}

module.exports = new NotificationService();
