#!/bin/bash
# ============================================================
# upload.sh
# Upload local scripts/ directory and README.md
# to GitHub and Google Drive
# ============================================================

# Exit on error
set -e

# Config
REPO_URL="https://github.com/manciounipd/sheep_geneticdiversity.git"
BRANCH="main"

mkdir -p /home/enrico/upload_tmp

cp -r * /home/enrico/upload_tmp

cd /home/enrico/upload_tmp

# Inizializza repo solo se non esiste già
if [ ! -d ".git" ]; then
  echo ">>> Inizializzo repository locale..."
  git init
  git branch -M "$BRANCH"
  git remote add origin "$REPO_URL"
fi

# Aggiungi solo script/ e README.md
git add .

# Commit con timestamp
git commit -m "Update script folder and README.md on $(date '+%Y-%m-%d %H:%M:%S')" || echo ">>> Nessuna modifica da commitare"

# Push su GitHub
git push -u origin "$BRANCH"


echo ">>> Copio anche su Google Drive..."
#rclone copy script "$GDRIVE_PATH" --progress
#rclone copy README.md "$GDRIVE_PATH" --progress

echo ">>> Upload completato!"
