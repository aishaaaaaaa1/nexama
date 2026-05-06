const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class MarketplaceService {
  /**
   * Lister les services avec filtres
   */
  static async getServices(filters = {}) {
    const { categorie, ville, prixMin, prixMax, search } = filters;
    
    return prisma.services_b2b.findMany({
      where: {
        actif: true,
        categorie: categorie || undefined,
        prix_basique: {
          gte: prixMin ? parseFloat(prixMin) : undefined,
          lte: prixMax ? parseFloat(prixMax) : undefined,
        },
        OR: search ? [
          { titre: { contains: search, mode: 'insensitive' } },
          { description: { contains: search, mode: 'insensitive' } },
          { tags: { has: search } }
        ] : undefined,
        prestataire: ville ? {
          ville: { contains: ville, mode: 'insensitive' }
        } : undefined
      },
      include: {
        prestataire: {
          select: {
            id: true,
            nom_complet: true,
            avatar_url: true,
            ville: true,
            prestataire_profile: true
          }
        }
      }
    });
  }

  /**
   * Créer une commande avec mise sous séquestre
   */
  static async createOrder(clientId, serviceId, data) {
    const { tier, brief, fichiers } = data;
    
    const service = await prisma.services_b2b.findUnique({
      where: { id: serviceId }
    });

    if (!service) throw new Error("Service non trouvé");

    let montant = service.prix_basique;
    if (tier === 'standard') montant = service.prix_standard || montant;
    if (tier === 'premium') montant = service.prix_premium || montant;

    return prisma.$transaction(async (tx) => {
      // 1. Créer la commande
      const order = await tx.commandes_b2b.create({
        data: {
          client_id: clientId,
          prestataire_id: service.prestataire_id,
          service_id: serviceId,
          montant_total: montant,
          brief,
          fichiers_joints: fichiers || [],
          statut: 'EN_ATTENTE',
          date_livraison_est: new Date(Date.now() + service.delai_livraison * 24 * 60 * 60 * 1000)
        }
      });

      // 2. Initialiser la transaction Escrow (BLOQUÉ par défaut après simulation paiement)
      await tx.escrow_transactions.create({
        data: {
          commande_id: order.id,
          montant: montant,
          statut_escrow: 'BLOQUE',
          reference_paiement: `PAY-${Date.now()}`
        }
      });

      return order;
    });
  }

  /**
   * Libérer les fonds (Validation client)
   */
  static async validateAndReleaseFunds(orderId, clientId) {
    const order = await prisma.commandes_b2b.findUnique({
      where: { id: orderId },
      include: { escrow: true }
    });

    if (!order || order.client_id !== clientId) throw new Error("Commande non autorisée");
    if (order.statut !== 'LIVREE') throw new Error("La commande n'a pas encore été livrée");

    return prisma.$transaction(async (tx) => {
      // 1. Update Commande
      await tx.commandes_b2b.update({
        where: { id: orderId },
        data: { statut: 'VALIDEE' }
      });

      // 2. Libérer Escrow
      await tx.escrow_transactions.update({
        where: { commande_id: orderId },
        data: {
          statut_escrow: 'LIBERE',
          date_liberation: new Date()
        }
      });

      // 3. Update réputation prestataire (simplifié)
      await tx.prestataire_profiles.update({
        where: { utilisateur_id: order.prestataire_id },
        data: { score_reputation: { increment: 0.1 } }
      });

      return { message: "Fonds libérés avec succès" };
    });
  }
}

module.exports = MarketplaceService;
