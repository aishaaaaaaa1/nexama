const { GoogleGenerativeAI } = require("@google/generative-ai");
// Utilisation de fetch natif (Node 18+)

class AIService {
  constructor() {
    this.gemini = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);
  }

  /**
   * Générer du texte avec fallback automatique
   * 1. Gemini 1.5 Flash
   * 2. Groq (Llama 3) - Si clé présente
   */
  async generateText(prompt, systemPrompt = "") {
    const fullPrompt = systemPrompt ? `${systemPrompt}\n\n${prompt}` : prompt;

    // --- FALLBACK 1: GEMINI ---
    try {
      const model = this.gemini.getGenerativeModel({ model: "gemini-1.5-flash" });
      const result = await model.generateContent(fullPrompt);
      const response = await result.response;
      return response.text();
    } catch (error) {
      console.error("Gemini Error:", error.message);
      
      // --- FALLBACK 2: GROQ (Si configurer) ---
      if (process.env.GROQ_API_KEY) {
        try {
          const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
            method: 'POST',
            headers: { 
              'Authorization': `Bearer ${process.env.GROQ_API_KEY}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              model: "llama3-70b-8192",
              messages: [
                { role: "system", content: systemPrompt },
                { role: "user", content: prompt }
              ]
            })
          });
          const data = await response.json();
          return data.choices[0].message.content;
        } catch (groqError) {
          console.error("Groq Error:", groqError.message);
        }
      }

      throw new Error("Toutes les APIs IA ont échoué. Veuillez réessayer plus tard.");
    }
  }
}

module.exports = new AIService();
