# Checklist previo: Execution Contract

Usa esta validación rápida antes de empezar.

## Checklist
- [ ] El **objetivo** es específico y verificable.
- [ ] Los **supuestos** están explícitos (sin "asumir en silencio").
- [ ] Los **límites de seguridad** incluyen acciones prohibidas y condiciones de stop.
- [ ] Las **dependencias** están disponibles (acceso, herramientas, rutas, credenciales).
- [ ] El **criterio de éxito** tiene una prueba clara (test, comando, evidencia).
- [ ] La **salida esperada** define formato, nivel de detalle y entregables.

## Señales de riesgo (si aparece alguna, rehacer contrato)
- Objetivo ambiguo ("mejorar", "arreglar" sin definición).
- No se mencionan límites para acciones sensibles (borrado, push, cambios externos).
- No hay forma concreta de validar éxito.

## Ejemplo bueno (resumido)
- **Objetivo:** Agregar hook pre-commit para escaneo de secretos.
- **Supuestos:** Repo git inicializado; bash disponible.
- **Límites de seguridad:** No modificar historial; no enviar secretos a servicios externos.
- **Dependencias:** gitleaks instalado; permisos de escritura en `.git/hooks`.
- **Criterio de éxito:** Commit se bloquea cuando se detecta secreto en staged changes.
- **Salida esperada:** Script instalador + doc + referencia mínima en AGENTS/TOOLS.

## Ejemplo malo
- "Quiero dejarlo más seguro y ya." (sin alcance, sin validación, sin límites)
