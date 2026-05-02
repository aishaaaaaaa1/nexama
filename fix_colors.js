const fs = require('fs');
const path = require('path');

function walk(dir, done) {
    let results = [];
    fs.readdir(dir, (err, list) => {
        if (err) return done(err);
        let i = 0;
        (function next() {
            let file = list[i++];
            if (!file) return done(null, results);
            file = path.resolve(dir, file);
            fs.stat(file, (err, stat) => {
                if (stat && stat.isDirectory()) {
                    walk(file, (err, res) => {
                        results = results.concat(res);
                        next();
                    });
                } else {
                    results.push(file);
                    next();
                }
            });
        })();
    });
}

walk('lib/pages', (err, files) => {
    if (err) throw err;
    files.forEach(file => {
        if (file.endsWith('.dart')) {
            let content = fs.readFileSync(file, 'utf8');
            if (content.includes('withValues')) {
                console.log('Fixing ' + file);
                const newContent = content.replace(/\.withValues\(alpha: ([\d\.]+)\)/g, '.withOpacity($1)');
                fs.writeFileSync(file, newContent, 'utf8');
            }
        }
    });
});
