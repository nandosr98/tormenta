# Guía operativa: cuándo y cómo usar Execution Contract

## Cuándo es obligatorio
Requiere Execution Contract si se cumple al menos una:
1. Tarea de **más de 3 pasos**.
2. Tarea **de alto riesgo** (cambios destructivos, producción, seguridad, pushes masivos, acceso externo).

## Flujo corto
1. Completar `execution-contract-template.md`.
2. Validar con `execution-contract-checklist.md`.
3. Ejecutar solo cuando el checklist esté OK.

## Formato de salida (conciso)
Usa este bloque al iniciar la ejecución:

```md
Execution Contract
- Objetivo: ...
- Supuestos: ...
- Límites de seguridad: ...
- Dependencias: ...
- Criterio de éxito: ...
- Salida esperada: ...
```
