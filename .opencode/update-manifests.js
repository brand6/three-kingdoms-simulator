const fs = require('fs');
const path = require('path');
const crypto = require('crypto');

function sha256File(filePath){
  const data = fs.readFileSync(filePath);
  return crypto.createHash('sha256').update(data).digest('hex');
}

function updateManifest(manifestPath){
  const repoRoot = path.resolve(__dirname, '..');
  const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
  const keys = Object.keys(manifest.files || {});
  let changed = 0;
  const prefixes = ['',' .github/',' .opencode/'].map(p=>p.replace(/\s/g,''));
  keys.forEach(k => {
    let found = false;
    for (const pref of prefixes){
      const candidate = path.join(repoRoot, pref, k.replace(/\//g, path.sep));
      if (fs.existsSync(candidate)){
        const h = sha256File(candidate);
        if (manifest.files[k] !== h){
          manifest.files[k] = h;
          changed++;
        }
        found = true;
        break;
      }
    }
    if (!found){
      // try special cases: skills/ -> .github/skills/
      if (k.startsWith('skills/')){
        const alt = path.join(repoRoot, '.github', k.replace(/\//g, path.sep));
        if (fs.existsSync(alt)){
          const h = sha256File(alt);
          if (manifest.files[k] !== h){
            manifest.files[k] = h;
            changed++;
          }
        }
      }
    }
  });
  if (changed > 0){
    fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2)+"\n", 'utf8');
  }
  return changed;
}

const repoRoot = path.resolve(__dirname, '..');
const man1 = path.join(__dirname, 'gsd-file-manifest.json');
const man2 = path.join(repoRoot, '.github', 'gsd-file-manifest.json');
let totalChanged = 0;
if (fs.existsSync(man1)) totalChanged += updateManifest(man1);
if (fs.existsSync(man2)) totalChanged += updateManifest(man2);
console.log('updated entries:', totalChanged);
