const express = require('express');
const https = require('https');
const router = express.Router();

// ==========================================
// Base de connaissances NexaBot intégrée
// ==========================================
const knowledgeBase = [
  // Salutations
  { keywords: ['bonjour', 'salut', 'hello', 'bonsoir', 'hey', 'salam', 'coucou'],
    reply: "Bonjour ! 👋 Je suis **NexaBot**, votre assistant NexaMa. Comment puis-je vous aider aujourd'hui ?\n\nVoici ce que je peux faire :\n- 📊 Vous guider sur la plateforme\n- 💰 Répondre à vos questions fiscales\n- 📝 Conseils business\n- 🤝 Aide au matching investisseurs" },

  // Merci
  { keywords: ['merci', 'thanks', 'thank'],
    reply: "Avec plaisir ! 😊 N'hésitez pas si vous avez d'autres questions." },

  // TVA
  { keywords: ['tva'],
    reply: "## TVA au Maroc 🇲🇦\n\n**Taux standard** : 20%\n\n**Autres taux :**\n- **14%** : Transport, énergie, travaux immobiliers\n- **10%** : Hôtellerie, restauration, huiles alimentaires\n- **7%** : Eau, produits pharmaceutiques\n- **0%** : Exportations, produits de première nécessité\n\n**Seuil d'assujettissement** : CA > 500 000 MAD/an\n\n**Déclaration** :\n- Mensuelle si CA > 1M MAD\n- Trimestrielle sinon\n\n💡 Utilisez le module **Dashboard Gestion** de NexaMa pour suivre automatiquement vos obligations TVA !" },

  // IR / Impôt sur le revenu
  { keywords: ['impot', 'impôt', 'ir ', 'revenu'],
    reply: "## Impôt sur le Revenu (IR) au Maroc 🇲🇦\n\n**Barème progressif 2024 :**\n\n| Tranche | Taux |\n|---|---|\n| 0 - 30 000 MAD | 0% |\n| 30 001 - 50 000 MAD | 10% |\n| 50 001 - 60 000 MAD | 20% |\n| 60 001 - 80 000 MAD | 30% |\n| 80 001 - 180 000 MAD | 34% |\n| > 180 000 MAD | 38% |\n\n**Auto-entrepreneurs** : Taux simplifié de **1% à 2%** selon l'activité.\n\n💡 NexaMa calcule automatiquement vos estimations d'IR dans le module **Finances** !" },

  // Auto-entrepreneur
  { keywords: ['auto-entrepreneur', 'autoentrepreneur', 'auto entrepreneur', 'statut ae'],
    reply: "## Statut Auto-Entrepreneur au Maroc 🇲🇦\n\n**Conditions :**\n- CA < 500 000 MAD/an (services)\n- CA < 2 000 000 MAD/an (commerce)\n- Inscription gratuite en ligne sur ae.gov.ma\n\n**Avantages :**\n- ✅ Pas de comptabilité complexe\n- ✅ IR simplifié (1% commerce, 2% services)\n- ✅ Pas de TVA obligatoire\n- ✅ Couverture CNSS (AMO)\n\n**Obligations :**\n- Déclaration trimestrielle du CA\n- Paiement IR + CNSS\n- Facturation conforme\n\n💡 NexaMa vous aide à gérer tout ça automatiquement !" },

  // CNSS
  { keywords: ['cnss', 'sécurité sociale', 'securite sociale', 'cotisation'],
    reply: "## CNSS pour Auto-Entrepreneurs 🇲🇦\n\n**Cotisations mensuelles** :\n- Taux : entre **50 et 300 MAD/mois** selon le CA\n- Couvre l'AMO (Assurance Maladie Obligatoire)\n\n**Droits :**\n- Remboursement des soins médicaux\n- Indemnités journalières de maladie\n- Pension de retraite (après 3 240 jours de cotisation)\n\n💡 NexaMa envoie des **rappels automatiques** pour ne jamais oublier vos échéances CNSS !" },

  // Patente
  { keywords: ['patente', 'taxe professionnelle'],
    reply: "## Taxe Professionnelle (Patente) 🇲🇦\n\n- **Exonération** les 5 premières années pour les nouvelles entreprises\n- Calculée sur la valeur locative des locaux professionnels\n- Taux : **10% à 30%** selon la classe d'activité\n\n⚠️ Les auto-entrepreneurs sont **exonérés** de la patente." },

  // Facture
  { keywords: ['facture', 'facturation', 'devis'],
    reply: "## Créer une Facture Conforme 🇲🇦\n\n**Mentions obligatoires (DGI) :**\n1. Identité du vendeur (nom, ICE, IF, RC)\n2. Date et numéro de facture (séquentiel)\n3. Désignation des biens/services\n4. Prix unitaire HT\n5. Taux et montant de TVA\n6. Total TTC\n7. Conditions de paiement\n\n💡 Le module **Facturation** de NexaMa génère automatiquement des factures conformes aux normes DGI !" },

  // Business plan
  { keywords: ['business plan', 'plan d\'affaire', 'business model'],
    reply: "## Business Plan avec NexaMa 📝\n\nNotre **Générateur IA** crée votre business plan en 10 étapes guidées.\n\n👉 Allez dans **Générateur IA** dans le menu pour commencer !" },

  // NexaMa / Plateforme
  { keywords: ['nexama', 'plateforme', 'fonctionnalités', 'comment ça marche'],
    reply: "## NexaMa — Votre Écosystème Digital 🚀\n\n**10 modules intégrés :**\n\n1. 🤝 **Matching Investisseurs**\n2. 📊 **Dashboard Gestion**\n3. 🛒 **Marketplace B2B**\n4. 📋 **CRM**\n5. 🎓 **Micro-Learning**\n6. 🤖 **Assistant IA**\n7. 👥 **Gestion RH**\n8. 💰 **Simulateur Financement**\n9. 💬 **Forum**\n10. 📜 **Base Documentaire**" },
];

function findBestResponse(message) {
  const lowerMsg = message.toLowerCase().normalize("NFD").replace(/[\u0300-\u036f]/g, "");
  let bestMatch = null;
  let bestScore = 0;

  for (const entry of knowledgeBase) {
    let score = 0;
    for (const keyword of entry.keywords) {
      const normalizedKeyword = keyword.normalize("NFD").replace(/[\u0300-\u036f]/g, "");
      if (lowerMsg.includes(normalizedKeyword)) {
        score += keyword.length;
      }
    }
    if (score > bestScore) {
      bestScore = score;
      bestMatch = entry;
    }
  }
  return bestMatch ? bestMatch.reply : null;
}

// ==========================================
// POST /api/chatbot
// ==========================================
router.post('/', async (req, res) => {
  try {
    const { message, history } = req.body;
    if (!message) return res.status(400).json({ error: 'Message requis' });

    const GEMINI_API_KEY = process.env.GEMINI_API_KEY;

    if (GEMINI_API_KEY) {
      try {
        const systemContext = `Tu es NexaBot, un assistant IA polyvalent intégré à NexaMa. Réponds à TOUTES les questions. Réponds en français, sois concis, formate en markdown.`;
        const contents = [];
        if (history && Array.isArray(history) && history.length > 0) {
          for (const msg of history) {
            contents.push({ role: msg.role === 'user' ? 'user' : 'model', parts: [{ text: msg.text }] });
          }
          contents.push({ role: 'user', parts: [{ text: message }] });
        } else {
          contents.push({ role: 'user', parts: [{ text: systemContext + '\n\n' + message }] });
        }

        const payload = JSON.stringify({ contents });
        const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_API_KEY}`;

        const apiResponse = await new Promise((resolve, reject) => {
          const urlObj = new URL(url);
          const options = {
            hostname: urlObj.hostname,
            path: urlObj.pathname + urlObj.search,
            method: 'POST',
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
          const reply = data.candidates?.[0]?.content?.parts?.[0]?.text;
          if (reply) return res.json({ reply });
        }
      } catch (err) {
        console.error('Gemini error:', err.message);
      }
    }

    const localReply = findBestResponse(message);
    if (localReply) return res.json({ reply: localReply });

    res.json({ reply: "Je suis NexaBot ! Posez-moi une question sur la fiscalité, la création d'entreprise ou l'utilisation de NexaMa." });
  } catch (error) {
    console.error('Chatbot error:', error.message);
    res.json({ reply: "Une erreur est survenue." });
  }
});

module.exports = router;
