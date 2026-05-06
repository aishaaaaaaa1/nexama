const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Log une action dans le système d'audit.
 * Note: Actuellement simulé ou enregistré dans une table d'audit si elle existe.
 */
const logAction = async (userId, action, detail, ip = '127.0.0.1') => {
  try {
    const user = await prisma.utilisateurs.findUnique({ where: { id: userId } });
    const logEntry = {
      id: Date.now(),
      action,
      user: user ? user.email : 'Utilisateur inconnu',
      detail,
      date: new Date(),
      ip
    };

    // Pour l'instant on garde en mémoire globale pour la session (simulation)
    if (!global.auditLogs) global.auditLogs = [];
    global.auditLogs.unshift(logEntry);
    
    // Garder seulement les 100 derniers
    if (global.auditLogs.length > 100) global.auditLogs.pop();

    console.log(`[AUDIT] ${action} par ${logEntry.user}: ${detail}`);
  } catch (error) {
    console.error("Erreur lors du logging d'audit:", error);
  }
};

module.exports = { logAction };
