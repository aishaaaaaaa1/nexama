const fs = require('fs');
const path = require('path');

class UploadService {
  constructor() {
    this.uploadDir = path.join(__dirname, '../uploads');
    if (!fs.existsSync(this.uploadDir)) {
      fs.mkdirSync(this.uploadDir, { recursive: true });
    }
  }

  /**
   * Sauvegarder un fichier Base64 (Simulation sans dépendance)
   */
  async saveFile(base64Data, originalName) {
    const extension = path.extname(originalName);
    const uniqueId = Date.now() + '-' + Math.round(Math.random() * 1E9);
    const fileName = `${uniqueId}${extension}`;
    const filePath = path.join(this.uploadDir, fileName);

    // Supprimer le header base64 si présent
    const data = base64Data.replace(/^data:.*;base64,/, "");
    
    fs.writeFileSync(filePath, data, 'base64');

    return `/uploads/${fileName}`;
  }
}

module.exports = new UploadService();
