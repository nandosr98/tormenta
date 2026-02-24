#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Actualizando repositorios..."
sudo apt update

echo "[2/5] Instalando dependencias del sistema..."
sudo apt install -y python3-pip python3-venv ffmpeg

echo "[3/5] Instalando Whisper CLI en usuario local..."
python3 -m pip install --user -U openai-whisper

echo "[4/5] Asegurando PATH en ~/.bashrc..."
if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.bashrc"; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

export PATH="$HOME/.local/bin:$PATH"

echo "[5/5] Verificando instalación..."
whisper --help | head -n 5

echo "Instalación completada. Eliminando este script del workspace..."
rm -f -- "$0"
