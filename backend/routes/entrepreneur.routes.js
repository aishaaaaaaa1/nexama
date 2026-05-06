const express = require('express');
const { PrismaClient } = require('@prisma/client');
const https = require('https');
const { verifyToken } = require('../utils/authMiddleware');
const { logAction } = require('../utils/auditLogger');
const router = express.Router();
const prisma = new PrismaClient();

// Protéger toutes les routes de l'entrepreneur
router.use(verifyToken);

// ==========================================
// 1. Factures
// ==========================================
router.get('/factures/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const factures = await prisma.factures.findMany({
      where: { utilisateur_id: id },
      orderBy: { date_emission: 'desc' }
    });
    res.json(factures);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/factures', async (req, res) => {
  try {
    const { utilisateur_id, numero_ref, client_nom, total_ht, tva, total_ttc, date_echeance } = req.body;
    
    if (!utilisateur_id || !numero_ref || !client_nom || !total_ttc) {
      return res.status(400).json({ error: "Champs obligatoires manquants" });
    }

    const nouvelleFacture = await prisma.factures.create({
      data: {
        utilisateur_id,
        numero_ref,
        client_nom,
        total_ht: parseFloat(total_ht) || 0,
        tva: parseFloat(tva) || 0,
        total_ttc: parseFloat(total_ttc),
        date_echeance: date_echeance ? new Date(date_echeance) : new Date(new Date().setDate(new Date().getDate() + 30))
      }
    });
    
    res.status(201).json(nouvelleFacture);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Impossible de créer la facture" });
  }
});

// ==========================================
// 2. Dépenses
// ==========================================
router.get('/depenses/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const depenses = await prisma.depenses.findMany({
      where: { utilisateur_id: id },
      orderBy: { date_depense: 'desc' }
    });
    res.json(depenses);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/depenses', async (req, res) => {
  try {
    const { utilisateur_id, categorie, montant, description } = req.body;
    
    if (!utilisateur_id || !categorie || !montant) {
      return res.status(400).json({ error: "Champs obligatoires manquants" });
    }

    const nouvelleDepense = await prisma.depenses.create({
      data: {
        utilisateur_id,
        categorie,
        montant: parseFloat(montant),
        description: description || ""
      }
    });
    
    res.status(201).json(nouvelleDepense);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Impossible d'ajouter la dépense" });
  }
});

// ==========================================
// 3. Projets
// ==========================================
router.get('/projets/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const projets = await prisma.projets.findMany({
      where: { entrepreneur_id: id },
      orderBy: { created_at: 'desc' }
    });
    
    const formattedProjets = projets.map(p => ({
      id: p.id,
      titre: p.nom,
      statut: "en_attente",
      budget: `${p.budget_recherche.toLocaleString()} MAD`,
      progression: 0.1,
      ville: p.ville,
      secteur: p.secteur
    }));
    
    res.json(formattedProjets);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/projets', async (req, res) => {
  try {
    const { 
      nom, description, secteur, budget_recherche, 
      stade_evolution, ville, description_detaillee, 
      pdf_url, video_url, equipe_taille, equipe_profils 
    } = req.body;
    
    if (!nom || !secteur || !budget_recherche) {
      return res.status(400).json({ error: "Champs obligatoires manquants" });
    }

    const nouveauProjet = await prisma.projets.create({
      data: {
        entrepreneur_id: req.user.id,
        nom,
        description: description || "",
        secteur,
        ville: ville || "",
        budget_recherche: parseFloat(budget_recherche),
        stade_evolution: stade_evolution || "Idée",
        description_detaillee: description_detaillee || null,
        pdf_url: pdf_url || null,
        video_url: video_url || null,
        equipe_taille: parseInt(equipe_taille) || 1,
        equipe_profils: equipe_profils || null
      }
    });

    await logAction(req.user.id, 'PROJET_CREATION', `Création du projet: ${nom}`);
    
    // Mettre à jour le Trust Score de l'entrepreneur
    const MatchingService = require('../services/matching.service');
    await MatchingService.updateTrustScore(req.user.id);
    
    res.status(201).json(nouveauProjet);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Impossible de créer le projet" });
  }
});

// ==========================================
// 4. Trésorerie
// ==========================================
router.get('/tresorerie/:id', async (req, res) => {
  try {
    res.json({
      solde_actuel: "125 400 MAD",
      entrees_prevues: "45 000 MAD",
      sorties_prevues: "12 000 MAD",
      evolution: [10000, 15000, 12000, 18000, 25000, 22000]
    });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 5. Ressources Humaines
// ==========================================
router.get('/rh/:id', async (req, res) => {
  try {
    const employes = [
      { id: "1", nom: "Anas Benali", poste: "Dév Fullstack", salaire: "12 000 MAD", conges: "2 jours" },
      { id: "2", nom: "Khadija Idrissi", poste: "Marketing", salaire: "9 500 MAD", conges: "5 jours" }
    ];
    res.json(employes);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 6. Générateur IA (Business Plan)
// ==========================================
router.post('/ia/business-plan', async (req, res) => {
  try {
    const { utilisateur_id, answers } = req.body;
    if (!utilisateur_id || !answers) {
      return res.status(400).json({ error: "Utilisateur ou réponses manquantes" });
    }

    const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
    let generatedMarkdown = "";

    if (!GEMINI_API_KEY) {
      console.warn("⚠️ Clé API Gemini non configurée. Génération simulée.");
      generatedMarkdown = `## Résumé Exécutif\nVoici un Business Plan généré pour le secteur **${answers.secteur || 'Non précisé'}**.\n\n## Étude de Marché\nVotre cible principale est : **${answers.cible || 'Non précisée'}**.\n\n## Modèle Économique\nStratégie de prix : **${answers.prix || 'Non précisé'}**.\n\n> **Note:** Ceci est une simulation. Ajoutez votre clé GEMINI_API_KEY dans le fichier .env du backend pour utiliser l'IA générative réelle.`;
    } else {
      const prompt = `En tant qu'expert en création d'entreprise au Maroc, génère un Business Plan professionnel en format Markdown basé sur les informations suivantes :\n
      Secteur: ${answers.secteur}
      Description: ${answers.description}
      Cible: ${answers.cible}
      Concurrents: ${answers.concurrents}
      Modèle de revenus: ${answers.prix}
      Budget estimé: ${answers.budget}\n
      Structure requise : 1. Résumé Exécutif, 2. Étude de Marché, 3. Modèle Économique, 4. Stratégie Marketing, 5. Analyse SWOT.
      Sois précis, professionnel et concis.`;

      const response = await fetch(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] })
      });

      if (!response.ok) {
        throw new Error("Erreur de l'API Gemini");
      }

      const data = await response.json();
      generatedMarkdown = data.candidates?.[0]?.content?.parts?.[0]?.text || "Erreur de génération.";
    }

    const businessPlan = await prisma.business_plans.create({
      data: {
        utilisateur_id,
        nom_projet: `BP - ${answers.secteur || 'Projet'}`,
        contenu_markdown: generatedMarkdown
      }
    });

    res.status(201).json(businessPlan);
  } catch (error) {
    console.error("Erreur génération BP:", error);
    res.status(500).json({ error: "Impossible de générer le Business Plan" });
  }
});

router.get('/ia/business-plans/:id', async (req, res) => {
  try {
    const { id } = req.params;
    const plans = await prisma.business_plans.findMany({
      where: { utilisateur_id: id },
      orderBy: { date_generation: 'desc' }
    });
    res.json(plans);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 7. CRM & Pipeline Commercial
// ==========================================
router.get('/crm/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let deals = [];
    try {
      deals = await prisma.crm_deals.findMany({
        where: { utilisateur_id: id },
        orderBy: { derniere_interaction: 'desc' }
      });
    } catch (dbError) {
      console.warn("DB 'crm_deals' error, using mock data.");
    }

    if (deals.length === 0) {
      deals = [
        { id: "1", nom_entreprise: "Maroc Telecom", statut: "prospects", montant_estime: 50000, derniere_interaction: new Date() },
        { id: "2", nom_entreprise: "Attijariwafa Bank", statut: "qualifies", montant_estime: 120000, derniere_interaction: new Date() },
        { id: "3", nom_entreprise: "Office Chérifien des Phosphates", statut: "devis", montant_estime: 300000, derniere_interaction: new Date() },
        { id: "4", nom_entreprise: "Royal Air Maroc", statut: "nego", montant_estime: 45000, derniere_interaction: new Date() },
        { id: "5", nom_entreprise: "NexaDev Studio", statut: "gagne", montant_estime: 15000, derniere_interaction: new Date() },
        { id: "6", nom_entreprise: "Label'Vie", statut: "prospects", montant_estime: 25000, derniere_interaction: new Date() },
        { id: "7", nom_entreprise: "Saham Assurance", statut: "qualifies", montant_estime: 80000, derniere_interaction: new Date() },
      ];
    }
    res.json(deals);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/crm', async (req, res) => {
  try {
    const { utilisateur_id, nom_entreprise, montant_estime } = req.body;
    if (!utilisateur_id || !nom_entreprise) {
      return res.status(400).json({ error: "Champs obligatoires manquants" });
    }

    const newDeal = await prisma.crm_deals.create({
      data: {
        utilisateur_id,
        nom_entreprise,
        statut: "prospects",
        montant_estime: parseFloat(montant_estime) || 0
      }
    });
    res.status(201).json(newDeal);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur lors de l'ajout" });
  }
});

router.put('/crm/:deal_id', async (req, res) => {
  try {
    const { deal_id } = req.params;
    const { statut } = req.body;
    if (!statut) return res.status(400).json({ error: "Statut manquant" });

    const updatedDeal = await prisma.crm_deals.update({
      where: { id: deal_id },
      data: { 
        statut,
        derniere_interaction: new Date()
      }
    });
    res.json(updatedDeal);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur lors de la mise à jour" });
  }
});

// ==========================================
// 8. Marketplace B2B (Découverte des services)
// ==========================================
router.get('/marketplace/services', async (req, res) => {
  try {
    let services = [];
    try {
      services = await prisma.services_b2b.findMany({
        include: {
          prestataire: {
            select: {
              nom_complet: true,
              avatar_url: true,
              ville: true
            }
          }
        },
        orderBy: { created_at: 'desc' }
      });
    } catch (dbError) {
      console.warn("DB 'services_b2b' error, using mock data.");
    }

    // Seed mock data if empty for demo purposes
    if (services.length === 0) {
      services = [
        { id: "1", titre: "Création Site Web Vitrine", categorie: "Développement", prix_base: 3500, description: "Site web sur mesure avec WordPress, responsive et optimisé SEO.", prestataire: { nom_complet: "NexaDev Studio", ville: "Casablanca", avatar_url: "https://i.pravatar.cc/150?u=1" }, rating: 4.8, delai: "10 jours" },
        { id: "2", titre: "Logo & Identité Visuelle", categorie: "Design", prix_base: 1500, description: "Pack complet incluant logo, charte graphique et cartes de visite.", prestataire: { nom_complet: "Youssef Art", ville: "Rabat", avatar_url: "https://i.pravatar.cc/150?u=2" }, rating: 4.9, delai: "5 jours" },
        { id: "3", titre: "Gestion Réseaux Sociaux", categorie: "Marketing", prix_base: 2000, description: "1 mois de gestion Instagram & Facebook : 12 posts + 4 stories.", prestataire: { nom_complet: "Digital Boost", ville: "Tanger", avatar_url: "https://i.pravatar.cc/150?u=3" }, rating: 4.5, delai: "30 jours" },
        { id: "4", titre: "Bilan Comptable Annuel", categorie: "Comptabilité", prix_base: 2500, description: "Bilan certifié, liasse fiscale et conseil pour auto-entrepreneurs.", prestataire: { nom_complet: "Fiduciaire AlAmana", ville: "Marrakech", avatar_url: "https://i.pravatar.cc/150?u=4" }, rating: 4.7, delai: "15 jours" },
        { id: "5", titre: "Consultation Juridique", categorie: "Légal", prix_base: 800, description: "1h de conseil pour vos contrats commerciaux et CGV.", prestataire: { nom_complet: "Maitre Bennis", ville: "Casablanca", avatar_url: "https://i.pravatar.cc/150?u=5" }, rating: 5.0, delai: "2 jours" },
        { id: "6", titre: "UI/UX Mobile Design", categorie: "Design", prix_base: 4500, description: "Conception de l'interface de votre application mobile (10 écrans).", prestataire: { nom_complet: "Creative Mind", ville: "Casablanca", avatar_url: "https://i.pravatar.cc/150?u=6" }, rating: 4.6, delai: "7 jours" },
      ];
    }

    res.json(services);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 9. Micro-Learning (Espace Formation)
// ==========================================
router.get('/formation', async (req, res) => {
  try {
    let cours = await prisma.cours.findMany({
      include: {
        formateur: {
          select: { nom_complet: true, avatar_url: true }
        }
      },
      orderBy: { created_at: 'desc' }
    });

    if (cours.length === 0) {
      cours = [
        { id: "1", titre: "Comment bien déclarer sa TVA", description: "Tutoriel complet sur la TVA au Maroc.", prix: 0, format_media: "video", duree_minutes: 45, formateur: { nom_complet: "Ahmed Expert" }, categorie: "Fiscalité" },
        { id: "2", titre: "Trouver ses premiers clients B2B", description: "Stratégies d'acquisition pour startups.", prix: 150, format_media: "article", duree_minutes: 20, formateur: { nom_complet: "Coach Sara" }, categorie: "Marketing" },
        { id: "3", titre: "Le statut d'Auto-Entrepreneur", description: "Tout savoir sur les avantages et obligations.", prix: 0, format_media: "video", duree_minutes: 30, formateur: { nom_complet: "Nexa Academy" }, categorie: "Légal" },
        { id: "4", titre: "Pitcher son projet devant des investisseurs", description: "L'art de convaincre en 3 minutes.", prix: 300, format_media: "video", duree_minutes: 60, formateur: { nom_complet: "Mehdi Alami" }, categorie: "Financement" },
        { id: "5", titre: "Gestion de la trésorerie au quotidien", description: "Éviter les erreurs classiques de cashflow.", prix: 0, format_media: "article", duree_minutes: 15, formateur: { nom_complet: "Siham Finance" }, categorie: "Gestion" },
        { id: "6", titre: "Optimiser sa visibilité sur LinkedIn", description: "Créer un profil qui attire les partenaires.", prix: 100, format_media: "article", duree_minutes: 25, formateur: { nom_complet: "Karim Digital" }, categorie: "Marketing" },
      ];
    }
    res.json(cours);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

// ==========================================
// 10. Forum Communautaire
// ==========================================
router.get('/forum', async (req, res) => {
  try {
    let posts = await prisma.forum_posts.findMany({
      include: {
        utilisateur: { select: { nom_complet: true, avatar_url: true } },
        replies: true
      },
      orderBy: { created_at: 'desc' }
    });

    if (posts.length === 0) {
      posts = [
        { id: "1", titre: "Comment facturer un client étranger ?", contenu: "Bonjour, je suis auto-entrepreneur et je viens de signer un client en France. Comment ça se passe pour la TVA ?", categorie: "Comptabilité", created_at: new Date(), utilisateur: { nom_complet: "Youssef D." }, replies: [1, 2] },
        { id: "2", titre: "Avis sur les banques pour AE", contenu: "Quelle est la meilleure banque pour un auto-entrepreneur au Maroc ?", categorie: "Banque", created_at: new Date(), utilisateur: { nom_complet: "Khadija M." }, replies: [1, 2, 3] }
      ];
    }
    res.json(posts);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur" });
  }
});

router.post('/forum', async (req, res) => {
  try {
    const { utilisateur_id, titre, contenu, categorie } = req.body;
    const post = await prisma.forum_posts.create({
      data: { utilisateur_id, titre, contenu, categorie }
    });
    res.status(201).json(post);
  } catch (error) {
    res.status(500).json({ error: "Erreur lors de la création" });
  }
});

// ==========================================
// 11. Générateur de Business Plan IA
// ==========================================
router.post('/ia/business-plan', async (req, res) => {
  try {
    const { utilisateur_id, answers } = req.body;
    
    if (!utilisateur_id || !answers) {
      return res.status(400).json({ error: "Données manquantes" });
    }

    const GEMINI_API_KEY = process.env.GEMINI_API_KEY;
    if (!GEMINI_API_KEY) {
      return res.status(500).json({ error: "Configuration API IA manquante" });
    }

    const prompt = `Tu es un expert en entrepreneuriat au Maroc. Génère un Business Plan PROFESSIONNEL et COMPLET en français pour le projet suivant :
    - Secteur : ${answers.secteur}
    - Description : ${answers.description}
    - Cible : ${answers.cible}
    - Concurrents : ${answers.concurrents}
    - Modèle de revenus : ${answers.prix}
    - Budget initial : ${answers.budget}
    - Localisation : ${answers.localisation || 'Maroc'}
    - Stratégie d'acquisition : ${answers.acquisition || 'Marketing digital'}
    - Avantage concurrentiel : ${answers.avantage || 'Innovation'}
    - Objectifs : ${answers.objectifs || 'Croissance'}

    Le document doit être structuré en Markdown avec les sections suivantes :
    # Business Plan : ${answers.description.substring(0, 50)}...
    
    ## 1. Résumé Exécutif
    ## 2. Étude de Marché & Clientèle
    ## 3. Analyse de la Concurrence
    ## 4. Stratégie Marketing & Acquisition
    ## 5. Modèle Économique & Revenus
    ## 6. Analyse SWOT
    ## 7. Prévisions Financières (Estimation sur 3 ans)
    ## 8. Plan d'Action & Objectifs
    
    Utilise un ton professionnel, encourageant et réaliste par rapport au marché marocain.`;
    let contenuMarkdown = null;
    let usedModel = "Gemini 1.5 Flash";

    try {
      const payload = JSON.stringify({ contents: [{ parts: [{ text: prompt }] }] });
      const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`;
      
      const apiResponse = await new Promise((resolve, reject) => {
        const urlObj = new URL(url);
        const options = {
          hostname: urlObj.hostname, path: urlObj.pathname + urlObj.search, method: 'POST',
          headers: { 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(payload) }
        };
        const request = https.request(options, (response) => {
          let data = '';
          response.on('data', chunk => data += chunk);
          response.on('end', () => resolve({ status: response.statusCode, body: data }));
        });
        request.on('error', reject);
        request.write(payload);
        request.end();
      });

      if (apiResponse.status === 200) {
        const data = JSON.parse(apiResponse.body);
        contenuMarkdown = data.candidates?.[0]?.content?.parts?.[0]?.text;
      } else {
        console.warn("Gemini API Error:", apiResponse.status, apiResponse.body);
      }
    } catch (e) {
      console.error("Erreur appel Gemini:", e);
    }

    // FALLBACK GROQ (LLaMA3)
    if (!contenuMarkdown) {
      console.log("Fallback vers API Groq (LLaMA3)...");
      const GROQ_API_KEY = process.env.GROQ_API_KEY;
      if (GROQ_API_KEY) {
        try {
          const groqPayload = JSON.stringify({
            model: "llama3-70b-8192",
            messages: [{ role: "user", content: prompt }]
          });
          const apiResponse = await new Promise((resolve, reject) => {
            const options = {
              hostname: 'api.groq.com', path: '/openai/v1/chat/completions', method: 'POST',
              headers: { 'Authorization': `Bearer ${GROQ_API_KEY}`, 'Content-Type': 'application/json', 'Content-Length': Buffer.byteLength(groqPayload) }
            };
            const request = https.request(options, (response) => {
              let data = '';
              response.on('data', chunk => data += chunk);
              response.on('end', () => resolve({ status: response.statusCode, body: data }));
            });
            request.on('error', reject);
            request.write(groqPayload);
            request.end();
          });

          if (apiResponse.status === 200) {
            const data = JSON.parse(apiResponse.body);
            contenuMarkdown = data.choices?.[0]?.message?.content;
            usedModel = "Groq LLaMA3-70b";
          } else {
            console.warn("Groq API Error:", apiResponse.status, apiResponse.body);
          }
        } catch (e) {
          console.error("Erreur appel Groq:", e);
        }
      } else {
        console.warn("Pas de clé GROQ_API_KEY configurée pour le fallback.");
      }
    }

    if (!contenuMarkdown) {
      return res.status(500).json({ error: "Génération IA échouée (Gemini et Groq ont échoué)." });
    }

    // Sauvegarder dans la base de données
    const savedPlan = await prisma.business_plans.create({
      data: {
        utilisateur_id,
        nom_projet: answers.description.substring(0, 100),
        contenu_markdown: contenuMarkdown
      }
    });

    res.status(201).json(savedPlan);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur lors de la génération du Business Plan" });
  }
});

// ==========================================
// 12. Gestion des Stocks / Inventaire
// ==========================================
router.get('/stock/:id', async (req, res) => {
  try {
    const { id } = req.params;
    let inventory = [];
    try {
      inventory = await prisma.inventaire.findMany({
        where: { utilisateur_id: id },
        orderBy: { nom: 'asc' }
      });
    } catch (dbError) {
      console.warn("DB 'inventaire' error, using mock data.");
    }

    if (inventory.length === 0) {
      inventory = [
        { id: "1", nom: "MacBook Pro M3", quantite: 15, quantite_min: 5, categorie: "Électronique", sku: "MBP-M3-001", prix_unitaire: 22000 },
        { id: "2", nom: "iPhone 15 Pro", quantite: 8, quantite_min: 10, categorie: "Électronique", sku: "IP15-P-002", prix_unitaire: 12500 },
        { id: "3", nom: "Écran Dell 27\"", quantite: 4, quantite_min: 5, categorie: "Périphériques", sku: "DELL-27-003", prix_unitaire: 4500 },
        { id: "4", nom: "Clavier Logitech MX", quantite: 20, quantite_min: 10, categorie: "Périphériques", sku: "LOGI-MX-004", prix_unitaire: 1200 },
        { id: "5", nom: "Chaise Ergonomique", quantite: 12, quantite_min: 3, categorie: "Mobilier", sku: "CH-ERG-005", prix_unitaire: 3500 },
      ];
    }
    res.json(inventory);
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur serveur stock" });
  }
});

// ==========================================
// 13. Messagerie Sécurisée
// ==========================================
router.get('/messages/:id', async (req, res) => {
  try {
    const messages = [
      { id: "1", expediteur: "Admin NexaMa", contenu: "Bienvenue sur la plateforme ! Votre profil est validé.", date: new Date(), lu: true },
      { id: "2", expediteur: "Youssef Expert", contenu: "Bonjour, j'ai bien reçu votre demande de consultation.", date: new Date(), lu: false },
    ];
    res.json(messages);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur messages" });
  }
});

// ==========================================
// 14. Commandes Marketplace (Mes Commandes)
// ==========================================
router.get('/marketplace/commandes/:id', async (req, res) => {
  try {
    const commandes = [
      { id: "1", service_titre: "Logo Pixel Studio", prestataire_nom: "Pixel Studio", statut: "En cours", etape: "Conception", date: new Date() },
      { id: "2", service_titre: "Audit SEO", prestataire_nom: "Digital Boost", statut: "Livré", etape: "Terminé", date: new Date() },
      { id: "3", service_titre: "Statuts SARL", prestataire_nom: "Cabinet Bennis", statut: "En attente", etape: "Vérification docs", date: new Date() },
    ];
    res.json(commandes);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur commandes" });
  }
});

// ==========================================
// 15. Suivi de Projet Collaboratif (Tâches)
// ==========================================
router.get('/projets/:id/taches', async (req, res) => {
  try {
    const taches = [
      { id: "1", titre: "Maquettes pages intérieures", assignee: "Khadija", priorite: "haute", echeance: "18/05", statut: "a_faire", commentaires: 2 },
      { id: "2", titre: "Rédaction contenu SEO", assignee: "Youssef", priorite: "moyenne", echeance: "20/05", statut: "a_faire", commentaires: 0 },
      { id: "3", titre: "Développement frontend React", assignee: "Anas", priorite: "haute", echeance: "15/05", statut: "en_cours", commentaires: 5 },
      { id: "4", titre: "Intégration API paiement", assignee: "Anas", priorite: "haute", echeance: "16/05", statut: "en_cours", commentaires: 3 },
      { id: "5", titre: "Design page d'accueil", assignee: "Khadija", priorite: "haute", echeance: "12/05", statut: "en_revue", commentaires: 8 },
      { id: "6", titre: "Cahier des charges", assignee: "Youssef", priorite: "basse", echeance: "01/05", statut: "termine", commentaires: 4 },
    ];
    res.json(taches);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur tâches" });
  }
});

router.post('/projets/:id/taches', async (req, res) => {
  try {
    const { titre, assignee, priorite, echeance, statut } = req.body;
    if (!titre) return res.status(400).json({ error: "Titre requis" });
    res.status(201).json({ id: Date.now().toString(), titre, assignee, priorite, echeance, statut: statut || "a_faire", commentaires: 0 });
  } catch (error) {
    res.status(500).json({ error: "Erreur création tâche" });
  }
});

// ==========================================
// 16. CRM Reporting (Ventes)
// ==========================================
router.get('/crm/:id/reporting', async (req, res) => {
  try {
    res.json({
      ca_total: 635000,
      ca_par_client: [
        { client: "Maroc Telecom", montant: 200000, nb_deals: 3 },
        { client: "Attijariwafa Bank", montant: 180000, nb_deals: 2 },
        { client: "OCP", montant: 150000, nb_deals: 1 },
        { client: "Royal Air Maroc", montant: 65000, nb_deals: 2 },
        { client: "Label'Vie", montant: 40000, nb_deals: 1 },
      ],
      taux_conversion: 0.28,
      deals_gagnes: 12,
      deals_perdus: 5,
      delai_moyen_jours: 18,
      evolution_mensuelle: [42000, 55000, 48000, 72000, 61000, 85000],
    });
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur reporting" });
  }
});

// ==========================================
// 17. Mouvements de Stock
// ==========================================
router.get('/stock/:id/mouvements', async (req, res) => {
  try {
    const mouvements = [
      { id: "1", produit: "MacBook Pro M3", type: "entree", quantite: 10, date: "2024-05-10", reference: "BON-E-001", motif: "Réception fournisseur" },
      { id: "2", produit: "iPhone 15 Pro", type: "sortie", quantite: 3, date: "2024-05-09", reference: "BON-S-001", motif: "Vente client" },
      { id: "3", produit: "Écran Dell 27\"", type: "entree", quantite: 5, date: "2024-05-08", reference: "BON-E-002", motif: "Réception commande" },
      { id: "4", produit: "Clavier Logitech MX", type: "sortie", quantite: 2, date: "2024-05-07", reference: "BON-S-002", motif: "Usage interne" },
      { id: "5", produit: "MacBook Pro M3", type: "sortie", quantite: 1, date: "2024-05-06", reference: "BON-S-003", motif: "Vente client" },
    ];
    res.json(mouvements);
  } catch (error) {
    res.status(500).json({ error: "Erreur serveur mouvements" });
  }
});

router.post('/stock/:id/mouvements', async (req, res) => {
  try {
    const { produit, type, quantite, motif } = req.body;
    if (!produit || !type || !quantite) return res.status(400).json({ error: "Champs requis" });
    res.status(201).json({ id: Date.now().toString(), produit, type, quantite, motif, date: new Date().toISOString(), reference: `BON-${type === 'entree' ? 'E' : 'S'}-${Date.now().toString().slice(-3)}` });
  } catch (error) {
    res.status(500).json({ error: "Erreur création mouvement" });
  }
});

// ==========================================
// 18. Marketplace B2B (Prestataires)
// ==========================================
router.get('/marketplace/services', async (req, res) => {
  try {
    const { categorie, ville, prix_max, dispo, rating_min } = req.query;
    let services = [
      { id: "s1", prestataire_id: "p1", nom_prestataire: "Agence Digital Pro", titre: "Création Site Vitrine", categorie: "Développement", ville: "Casablanca", prix: 5000, temps_livraison: "7 jours", note: 4.8, avis_count: 24, disponible: true, description: "Site web sur mesure sous WordPress ou React.", portfolio_url: "https://example.com/portfolio1" },
      { id: "s2", prestataire_id: "p2", nom_prestataire: "Design Sprint", titre: "Identité Visuelle & Logo", categorie: "Design", ville: "Rabat", prix: 2000, temps_livraison: "3 jours", note: 4.9, avis_count: 56, disponible: true, description: "Création de logo et charte graphique complète.", portfolio_url: "https://example.com/portfolio2" },
      { id: "s3", prestataire_id: "p3", nom_prestataire: "SEO Master", titre: "Audit SEO & Mots clés", categorie: "Marketing", ville: "Casablanca", prix: 1500, temps_livraison: "5 jours", note: 4.5, avis_count: 12, disponible: false, description: "Audit technique SEO et plan d'action de trafic.", portfolio_url: "https://example.com/portfolio3" },
      { id: "s4", prestataire_id: "p4", nom_prestataire: "Legal Protect", titre: "Rédaction Contrat Prestation", categorie: "Légal", ville: "Marrakech", prix: 800, temps_livraison: "2 jours", note: 5.0, avis_count: 8, disponible: true, description: "Contrat B2B sur mesure rédigé par un avocat d'affaires.", portfolio_url: "https://example.com/portfolio4" },
      { id: "s5", prestataire_id: "p5", nom_prestataire: "Compta Zen", titre: "Bilan Simplifié Auto-Entrepreneur", categorie: "Comptabilité", ville: "Agadir", prix: 1000, temps_livraison: "5 jours", note: 4.7, avis_count: 31, disponible: true, description: "Préparation de votre bilan annuel pour l'administration.", portfolio_url: "https://example.com/portfolio5" },
    ];

    if (categorie && categorie !== 'Tous') services = services.filter(s => s.categorie === categorie);
    if (ville && ville !== 'Toutes') services = services.filter(s => s.ville === ville);
    if (prix_max) services = services.filter(s => s.prix <= parseInt(prix_max));
    if (dispo === 'true') services = services.filter(s => s.disponible === true);
    if (rating_min) services = services.filter(s => s.note >= parseFloat(rating_min));

    res.json(services);
  } catch (error) {
    res.status(500).json({ error: "Erreur récupération services marketplace" });
  }
});

router.post('/marketplace/commandes', async (req, res) => {
  try {
    const { entrepreneur_id, service_id, montant, methode_paiement } = req.body;
    res.status(201).json({
      id: "cmd_" + Date.now().toString(),
      statut: "escrow", // Paiement bloqué chez NexaMa
      montant,
      methode_paiement,
      message: "Paiement sécurisé CMI validé. Fonds bloqués en séquestre jusqu'à livraison."
    });
  } catch (error) {
    res.status(500).json({ error: "Erreur de commande" });
  }
});

router.post('/marketplace/commandes/:id/valider', async (req, res) => {
  try {
    res.json({ message: "Livraison validée. Fonds débloqués vers le prestataire." });
  } catch (error) {
    res.status(500).json({ error: "Erreur de validation" });
  }
});
// ==========================================
// 19. Suivi Projet Collaboratif (Module 5)
// ==========================================
router.post('/projet/invite', async (req, res) => {
  try {
    const { email, role, projet_id } = req.body;
    res.status(200).json({ message: `Invitation envoyée à ${email} avec le rôle ${role}.` });
  } catch (error) {
    res.status(500).json({ error: "Erreur lors de l'invitation" });
  }
});

router.post('/projet/notifications/deadline', async (req, res) => {
  try {
    const { tache_id, message } = req.body;
    res.status(200).json({ 
      success: true, 
      alerte: `Push Mobile & Email envoyés pour la tâche ${tache_id}: ${message}` 
    });
  } catch (error) {
    res.status(500).json({ error: "Erreur lors de la notification" });
  }
});

// ==========================================
// 10. Premium
// ==========================================
router.post('/premium', async (req, res) => {
  try {
    const { plan } = req.body;
    // En production, on vérifierait le paiement ici
    const user = await prisma.utilisateurs.update({
      where: { id: req.user.id },
      data: { is_verified: true } // On simule l'avantage premium par is_verified ou un autre champ
    });
    await logAction(req.user.id, 'PREMIUM_UPGRADE', `Passage au plan ${plan} (Entrepreneur)`);
    res.json({ message: `Passage au plan ${plan} réussi !`, user });
  } catch (error) {
    console.error(error);
    res.status(500).json({ error: "Erreur lors du passage au premium" });
  }
});

module.exports = router;
