const { GoogleGenerativeAI } = require("@google/generative-ai");

class ExpenseParserService {
  /**
   * Utiliser Gemini pour extraire les données d'un reçu (image ou texte)
   */
  static async parseReceipt(base64Image) {
    const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
    const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

    const prompt = `Extrais les informations suivantes de ce reçu de dépense au Maroc et retourne-les au format JSON uniquement :
    {
      "titre": "Nom du marchand ou description courte",
      "montant": "Nombre décimal (le montant total en MAD)",
      "date": "Date au format YYYY-MM-DD",
      "categorie": "Une catégorie parmi : Transport, Marketing, Fournitures, Loyer, Logiciels, Alimentation, Autre",
      "description": "Détails supplémentaires si disponibles"
    }
    Si tu ne trouves pas une info, mets null. Ne retourne rien d'autre que le JSON.`;

    const result = await model.generateContent([
      prompt,
      {
        inlineData: {
          data: base64Image,
          mimeType: "image/jpeg"
        }
      }
    ]);

    const response = await result.response;
    const text = response.text();
    
    // Nettoyer le texte pour extraire le JSON
    const jsonMatch = text.match(/\{[\s\S]*\}/);
    if (jsonMatch) {
      return JSON.parse(jsonMatch[0]);
    }
    throw new Error("Impossible de parser le reçu");
  }
}

module.exports = ExpenseParserService;
