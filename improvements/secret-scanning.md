# Secret scanning (pre-commit con gitleaks)

## Objetivo
Bloquear commits que incluyan posibles secretos en cambios staged.

## Instalación
1. Instala gitleaks en tu sistema.
2. Desde la raíz del repo, ejecuta:

```bash
bash scripts/setup-gitleaks-hook.sh
```

3. Verifica que exista `.git/hooks/pre-commit` y sea ejecutable.

## Comportamiento del hook
- Intenta primero: `gitleaks git --staged` (rápido).
- Si no está disponible, usa fallback: `gitleaks protect --staged`.
- Si detecta secretos potenciales, **falla el commit** con mensaje accionable.

## Política de bypass
- Permitido solo de forma **excepcional** y con aprobación explícita:

```bash
git commit --no-verify
```

- Todo bypass debe justificarse y corregirse luego.

## Remediación cuando falla
1. Identifica el archivo/línea reportado.
2. Elimina secreto del código/historial staged.
3. Mueve secretos a variables de entorno o secret manager.
4. Si el secreto pudo exponerse, **rota credenciales**.
5. Reintenta commit.
