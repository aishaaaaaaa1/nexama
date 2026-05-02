const https = require('https');
const fs = require('fs');
const path = require('path');

const baseUrl = 'https://www.gstatic.com/flutter-canvaskit/59aa584fdf100e6c78c785d8a5b565d1de4b48ab/chromium/';
const files = ['canvaskit.js', 'canvaskit.wasm'];
const targetDir = path.join(__dirname, '../web/canvaskit');

if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

files.forEach(file => {
  const targetPath = path.join(targetDir, file);
  const fileStream = fs.createWriteStream(targetPath);
  
  https.get(baseUrl + file, (response) => {
    response.pipe(fileStream);
    fileStream.on('finish', () => {
      fileStream.close();
      console.log(`✅ Téléchargé : ${file}`);
    });
  }).on('error', (err) => {
    fs.unlinkSync(targetPath);
    console.error(`❌ Erreur pour ${file} :`, err.message);
  });
});
