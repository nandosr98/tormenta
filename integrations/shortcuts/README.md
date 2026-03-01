# iOS Atajos (Shortcuts) bridge for Tormenta

Objetivo: crear recordatorios en la app **Recordatorios** de forma nativa y fiable.

## Shortcut recomendado: `Tormenta - Crear Recordatorio`

### Entrada esperada
Texto (desde Share Sheet o pegado manualmente) en formato:

`titulo|fecha_hora_iso|lista`

Ejemplo:
`Prueba hecha por tormenta|2026-02-27T12:45:00+01:00|Recordatorios`

### Pasos del Atajo
1. **Recibir entrada** (Texto)
2. **Dividir texto** por `|`
3. Variables:
   - `titulo` = item 1
   - `fecha` = item 2
   - `lista` = item 3 (si vacío, usar `Recordatorios`)
4. Acción **Añadir nuevo recordatorio**:
   - Título = `titulo`
   - Lista = `lista`
   - Fecha/hora = `fecha`
   - Nota = `Creado por Tormenta`
5. (Opcional) Mostrar notificación: `Recordatorio creado`.

## Uso rápido
- Desde iPhone: ejecutar el atajo y pegar payload.
- Desde Tormenta: generar payload y enviártelo listo para copiar.

## Nota
Este puente evita inconsistencias de CalDAV con VTODO en Apple Reminders.
