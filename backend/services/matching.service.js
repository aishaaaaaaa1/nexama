const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

/**
 * Service de matching intelligent NexaMa
 */
class MatchingService {
  /**
   * Calcule le score de matching entre un projet et un investisseur
   * @param {Object} projet 
   * @param {Object} profileInvestisseur 
   * @returns {Number} score (0-100)
   */
  static async calculateScore(projet, profileInvestisseur) {
    let score = 0;
    console.log(`Matching project ${projet.nom} (${projet.secteur}) for investor ${profileInvestisseur.id}`);

    // 1. Matching Secteur (40%) - Bloquant
    const secteursInt = profileInvestisseur.secteurs_interet || [];
    if (!secteursInt.includes(projet.secteur)) {
      console.log(`- Sector mismatch: ${projet.secteur} not in ${secteursInt}`);
      return 0;
    }
    score += 40;
    console.log(`- Sector match! Score: ${score}`);

    // 2. Localisation (20%)
    const regionsPref = profileInvestisseur.regions_pref || [];
    if (regionsPref.length === 0 || regionsPref.includes(projet.region)) {
      score += 20;
    } else if (regionsPref.includes(projet.ville)) {
      score += 15; // Ville incluse mais pas région principale
    }

    // 3. Budget (25%)
    // On vérifie si le budget recherché est dans la fourchette de l'investisseur
    if (projet.budget_recherche >= profileInvestisseur.ticket_min && 
        projet.budget_recherche <= profileInvestisseur.ticket_max) {
      score += 25;
    } else {
      // Proximité du budget
      const distanceMin = Math.abs(projet.budget_recherche - profileInvestisseur.ticket_min);
      const distanceMax = Math.abs(projet.budget_recherche - profileInvestisseur.ticket_max);
      const closer = Math.min(distanceMin, distanceMax);
      if (closer < projet.budget_recherche * 0.2) {
        score += 10; // Proche à 20%
      }
    }

    // 4. Stade d'évolution (15%)
    // Note: Pour simplifier, on assume que investisseur_profiles aura un champ stades_pref plus tard
    // Pour l'instant, on donne un score de base
    score += 10; 

    // Bonus Trust Score (Entrepreneur)
    const bonusTrust = (projet.trust_score / 100) * 10;
    score += bonusTrust;

    return Math.min(Math.round(score), 100);
  }

  /**
   * Calcule le Trust Score d'un entrepreneur (0-100)
   */
  static async updateTrustScore(userId) {
    const user = await prisma.utilisateurs.findUnique({
      where: { id: userId },
      include: { projets: true }
    });

    if (!user) return 0;

    let score = 0;

    // 1. Profil complété (40%)
    if (user.nom_complet) score += 10;
    if (user.email && user.is_verified) score += 10;
    if (user.telephone) score += 10;
    if (user.ville) score += 10;

    // 2. Activité Projets (30%)
    if (user.projets.length > 0) score += 15;
    const hasDetailedProjects = user.projets.some(p => p.description_detaillee && p.pdf_url);
    if (hasDetailedProjects) score += 15;

    // 3. Validation Admin (30%)
    if (user.statut === 'actif') score += 30;

    // Mise à jour en base
    await prisma.utilisateurs.update({
      where: { id: userId },
      data: { trust_score: score }
    });

    return score;
  }

  /**
   * Obtenir les meilleures recommandations pour un investisseur
   */
  static async getRecommendationsForInvestor(investisseurId) {
    console.log(`Getting recommendations for investor ID: ${investisseurId}`);
    const profile = await prisma.investisseur_profiles.findUnique({
      where: { utilisateur_id: investisseurId }
    });

    if (!profile) {
      console.log(`- Profile NOT FOUND for investor ${investisseurId}`);
      return [];
    }
    console.log(`- Profile found: ${JSON.stringify(profile)}`);

    const allProjets = await prisma.projets.findMany({
      include: { entrepreneur: true }
    });
    console.log(`- Found ${allProjets.length} total projects in DB`);

    const scoredProjets = await Promise.all(allProjets.map(async (p) => {
      const score = await this.calculateScore(p, profile);
      return { ...p, matching_score: score };
    }));

    console.log(`- Scored ${scoredProjets.length} projects`);

    return scoredProjets
      // .filter(p => p.matching_score > 0) // Désactivé pour débugger
      .sort((a, b) => b.matching_score - a.matching_score);
  }
}

module.exports = MatchingService;
