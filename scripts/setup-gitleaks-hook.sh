#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [[ -z "${REPO_ROOT}" ]]; then
  echo "Error: ejecuta este script dentro de un repositorio git."
  exit 1
fi

HOOK_PATH="${REPO_ROOT}/.git/hooks/pre-commit"
mkdir -p "$(dirname "${HOOK_PATH}")"

cat > "${HOOK_PATH}" <<'HOOK'
#!/usr/bin/env bash
set -euo pipefail

if ! command -v gitleaks >/dev/null 2>&1; then
  echo "❌ pre-commit bloqueado: gitleaks no está instalado."
  echo "   Instala gitleaks y vuelve a intentar."
  echo "   Bypass excepcional (no recomendado): git commit --no-verify"
  exit 1
fi

TMP_OUT="$(mktemp)"
cleanup() { rm -f "$TMP_OUT"; }
trap cleanup EXIT

run_cmd() {
  set +e
  "$@" >"$TMP_OUT" 2>&1
  local rc=$?
  set -e
  return $rc
}

run_scan() {
  # Preferido: modo git con staged diff (rápido)
  if gitleaks git --help >/dev/null 2>&1; then
    if run_cmd gitleaks git --staged --redact --no-banner; then
      return 0
    fi
    local rc=$?
    if [[ $rc -eq 1 ]]; then
      return 1
    fi
  fi

  # Fallback: protect en staged (versiones antiguas)
  if gitleaks protect --help >/dev/null 2>&1; then
    if run_cmd gitleaks protect --staged --redact --no-banner; then
      return 0
    fi
    local rc=$?
    if [[ $rc -eq 1 ]]; then
      return 1
    fi
  fi

  echo "❌ pre-commit bloqueado: versión de gitleaks no compatible con escaneo staged."
  echo "   Requiere soporte para 'gitleaks git --staged' o 'gitleaks protect --staged'."
  return 2
}

if run_scan; then
  exit 0
fi

rc=$?
if [[ $rc -eq 1 ]]; then
  echo ""
  echo "❌ Posibles secretos detectados en cambios staged. Commit bloqueado."
  echo ""
  cat "$TMP_OUT"
  echo ""
  echo "   Pasos sugeridos:"
  echo "   1) Elimina o reemplaza el secreto por variable de entorno."
  echo "   2) Si fue accidental: git restore --staged <archivo> y corrige."
  echo "   3) Si el secreto ya se filtró, rota credenciales inmediatamente."
  echo "   4) Reintenta el commit después de limpiar."
  echo "   Bypass excepcional: git commit --no-verify (solo con aprobación explícita)."
  exit 1
fi

cat "$TMP_OUT"
exit "$rc"
HOOK

chmod +x "${HOOK_PATH}"

echo "✅ Hook instalado/actualizado en ${HOOK_PATH}"
