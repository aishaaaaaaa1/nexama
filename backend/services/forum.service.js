const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class ForumService {
  /**
   * Lister les discussions du forum
   */
  static async listPosts(filters = {}) {
    const { categorie, search } = filters;
    return prisma.forum_posts.findMany({
      where: {
        categorie: categorie || undefined,
        OR: search ? [
          { titre: { contains: search, mode: 'insensitive' } },
          { contenu: { contains: search, mode: 'insensitive' } }
        ] : undefined
      },
      include: {
        utilisateur: { select: { nom_complet: true, avatar_url: true } },
        _count: { select: { replies: true } }
      },
      orderBy: { created_at: 'desc' }
    });
  }

  /**
   * Créer une nouvelle discussion
   */
  static async createPost(userId, data) {
    return prisma.forum_posts.create({
      data: {
        utilisateur_id: userId,
        titre: data.titre,
        contenu: data.contenu,
        categorie: data.categorie
      },
      include: { utilisateur: true }
    });
  }

  /**
   * Récupérer une discussion et ses réponses
   */
  static async getPostDetails(postId) {
    return prisma.forum_posts.findUnique({
      where: { id: postId },
      include: {
        utilisateur: { select: { nom_complet: true, avatar_url: true } },
        replies: {
          include: { utilisateur: { select: { nom_complet: true, avatar_url: true } } },
          orderBy: { created_at: 'asc' }
        }
      }
    });
  }

  /**
   * Répondre à une discussion
   */
  static async createReply(userId, postId, contenu) {
    return prisma.forum_replies.create({
      data: {
        post_id: postId,
        utilisateur_id: userId,
        contenu: contenu
      },
      include: { utilisateur: true }
    });
  }
}

module.exports = ForumService;
