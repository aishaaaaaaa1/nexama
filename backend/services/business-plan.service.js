const AIService = require('./ai.service');
const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class BusinessPlanService {
  /**
   * Générer un BP complet par sections
   */
  static async generateFullPlan(planId) {
    const plan = await prisma.business_plans.findUnique({ where: { id: planId } });
    if (!plan) throw new Error("Plan non trouvé");

    const context = JSON.stringify(plan.reponses_form);
    const sections = [
      { id: 'resume', title: 'Résumé Exécutif', prompt: "Rédige un résumé exécutif percutant pour ce projet au Maroc. Sois concis et convaincant." },
      { id: 'marche', title: 'Étude de Marché', prompt: "Analyse le marché cible au Maroc pour ce projet. Inclus les tendances et opportunités." },
      { id: 'swot', title: 'Analyse SWOT', prompt: "Génère une analyse SWOT structurée (Forces, Faiblesses, Opportunités, Menaces) pour ce projet." },
      { id: 'modele', title: 'Modèle Économique', prompt: "Explique en détail comment ce projet va générer des revenus (business model)." },
      { id: 'marketing', title: 'Stratégie Marketing', prompt: "Définis une stratégie de lancement et de croissance adaptée au marché marocain." },
      { id: 'financier', title: 'Prévisions Financières', prompt: "Génère des prévisions financières sur 3 ans (CA, Coûts, Bénéfices) sous forme de tableau texte." },
    ];

    const generatedContent = {};
    const systemPrompt = `Tu es un expert en business plan pour le marché marocain. Projet: ${plan.nom_projet}. Secteur: ${plan.secteur}. Contexte utilisateur: ${context}`;

    // Génération parallèle pour la vitesse (ou séquentielle pour éviter les limites de taux)
    for (const section of sections) {
      try {
        generatedContent[section.id] = await AIService.generateText(section.prompt, systemPrompt);
      } catch (error) {
        generatedContent[section.id] = "Erreur lors de la génération de cette section.";
      }
    }

    // Sauvegarder la version
    return prisma.business_plan_versions.create({
      data: {
        plan_id: planId,
        contenu_json: generatedContent
      }
    });
  }
}

module.exports = BusinessPlanService;
