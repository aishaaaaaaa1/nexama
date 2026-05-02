const fs = require('fs');
const path = require('path');

const libPagesDir = path.join(__dirname, 'lib', 'pages');

function replaceInFile(filePath) {
  let content = fs.readFileSync(filePath, 'utf8');
  let changed = false;

  if (content.includes('http.get')) {
    content = content.replace(/http\.get/g, 'ApiService.get');
    changed = true;
  }
  if (content.includes('http.post')) {
    content = content.replace(/http\.post/g, 'ApiService.post');
    changed = true;
  }
  if (content.includes('http.put')) {
    content = content.replace(/http\.put/g, 'ApiService.put');
    changed = true;
  }
  if (content.includes('http.delete')) {
    content = content.replace(/http\.delete/g, 'ApiService.delete');
    changed = true;
  }

  if (changed) {
    // Add import if not present
    if (!content.includes('api_service.dart')) {
      const match = content.match(/^import .*;/gm);
      if (match) {
        const lastImportIndex = content.lastIndexOf(match[match.length - 1]);
        const insertPosition = lastImportIndex + match[match.length - 1].length;
        
        // determine the correct relative path
        const depth = filePath.replace(libPagesDir, '').split(path.sep).length - 1;
        let relativePath = '../services/api_service.dart';
        if (depth > 1) {
          relativePath = '../../services/api_service.dart';
        }
        
        content = content.slice(0, insertPosition) + `\nimport '${relativePath}';` + content.slice(insertPosition);
      }
    }
    fs.writeFileSync(filePath, content, 'utf8');
    console.log('Fixed', filePath);
  }
}

function traverseDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      traverseDir(fullPath);
    } else if (fullPath.endsWith('.dart') && !fullPath.includes('login_page.dart') && !fullPath.includes('signup_page.dart') && !fullPath.includes('api_service.dart')) {
      replaceInFile(fullPath);
    }
  }
}

traverseDir(libPagesDir);
console.log('Done!');
