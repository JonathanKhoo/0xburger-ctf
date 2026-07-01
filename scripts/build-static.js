const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const dist = path.join(root, 'dist');

fs.rmSync(dist, { recursive: true, force: true });
fs.mkdirSync(path.join(dist, 'assets'), { recursive: true });

for (const file of ['index.html', 'ctftime.json', '_headers']) {
  fs.copyFileSync(path.join(root, file), path.join(dist, file));
}

for (const file of ['app.js', 'styles.css']) {
  fs.copyFileSync(path.join(root, 'assets', file), path.join(dist, 'assets', file));
}

console.log(`Built static site in ${dist}`);
