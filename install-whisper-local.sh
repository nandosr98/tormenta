#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Actualizando repositorios..."
sudo apt update

echo "[2/5] Instalando dependencias del sistema..."
sudo apt install -y ffmpeg pipx

echo "[3/5] Asegurando PATH de pipx..."
pipx ensurepath

# Cargar PATH para la sesión actual (sin reiniciar terminal)
export PATH="$HOME/.local/bin:$PATH"

echo "[4/5] Instalando Whisper CLI con pipx..."
pipx install --force openai-whisper

echo "[5/5] Verificando instalación..."
whisper --help | head -n 5

echo "Instalación completada. Eliminando este script del workspace..."
rm -f -- "$0"
