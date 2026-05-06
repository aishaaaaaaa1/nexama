const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class TrainerService {
  /**
   * Statistiques globales pour un formateur
   */
  static async getDashboardStats(trainerId) {
    const courses = await prisma.cours.findMany({
      where: { formateur_id: trainerId },
      include: {
        _count: { select: { inscriptions: true } }
      }
    });

    const totalStudents = courses.reduce((sum, c) => sum + c._count.inscriptions, 0);
    const totalEarnings = courses.reduce((sum, c) => sum + (c._count.inscriptions * c.prix), 0);

    // Calculer le taux de complétion moyen
    const inscriptions = await prisma.inscriptions_cours.findMany({
      where: { cours: { formateur_id: trainerId } }
    });
    const finishedCount = inscriptions.filter(i => i.termine).length;
    const avgCompletion = inscriptions.length > 0 ? (finishedCount / inscriptions.length) * 100 : 0;

    return {
      totalCourses: courses.length,
      totalStudents,
      totalEarnings,
      avgCompletion: Math.round(avgCompletion),
      courses: courses.map(c => ({
        id: c.id,
        titre: c.titre,
        prix: c.prix,
        students: c._count.inscriptions,
        revenue: c._count.inscriptions * c.prix
      }))
    };
  }

  /**
   * Liste détaillée des étudiants inscrits aux cours du formateur
   */
  static async getStudentsList(trainerId) {
    return prisma.inscriptions_cours.findMany({
      where: { cours: { formateur_id: trainerId } },
      include: {
        utilisateur: { select: { nom_complet: true, email: true, avatar_url: true } },
        cours: { select: { titre: true } }
      }
    });
  }
}

module.exports = TrainerService;
