const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class CourseService {
  /**
   * Lister les cours avec filtres
   */
  static async listCourses(filters = {}) {
    const { categorie, niveau, search } = filters;
    return prisma.cours.findMany({
      where: {
        categorie: categorie || undefined,
        niveau: niveau || undefined,
        titre: search ? { contains: search, mode: 'insensitive' } : undefined,
      },
      include: {
        formateur: { select: { nom_complet: true, avatar_url: true } },
        _count: { select: { chapitres: true } }
      }
    });
  }

  /**
   * Récupérer les détails d'un cours (avec chapitres et leçons)
   */
  static async getCourseDetails(courseId, userId) {
    const course = await prisma.cours.findUnique({
      where: { id: courseId },
      include: {
        formateur: true,
        chapitres: {
          orderBy: { ordre: 'asc' },
          include: {
            lecons: {
              orderBy: { ordre: 'asc' },
              include: {
                progressions: { where: { utilisateur_id: userId } }
              }
            }
          }
        }
      }
    });

    return course;
  }

  /**
   * Inscription à un cours
   */
  static async enroll(courseId, userId) {
    return prisma.inscriptions_cours.upsert({
      where: { cours_id_utilisateur_id: { cours_id: courseId, utilisateur_id: userId } },
      update: {},
      create: { cours_id: courseId, utilisateur_id: userId }
    });
  }

  /**
   * Marquer une leçon comme terminée
   */
  static async completeLesson(userId, lessonId) {
    return prisma.progression_lecons.upsert({
      where: { utilisateur_id_lecon_id: { utilisateur_id: userId, lecon_id: lessonId } },
      update: { complete: true },
      create: { utilisateur_id: userId, lecon_id: lessonId, complete: true }
    });
  }

  /**
   * Calculer la progression globale d'un utilisateur sur un cours
   */
  static async getCourseProgress(courseId, userId) {
    const lessons = await prisma.lecons.findMany({
      where: { chapitre: { cours_id: courseId } }
    });
    const totalLessons = lessons.length;
    
    const completedLessons = await prisma.progression_lecons.count({
      where: {
        utilisateur_id: userId,
        complete: true,
        lecon: { chapitre: { cours_id: courseId } }
      }
    });

    const percent = totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;
    
    return {
      percent: Math.round(percent),
      completedLessons,
      totalLessons,
      isFinished: completedLessons === totalLessons && totalLessons > 0
    };
  }
}

module.exports = CourseService;
