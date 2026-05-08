# Runbook — Resolver `plugin id mismatch` en OpenClaw

## Objetivo
Eliminar warnings tipo:
- `plugin id mismatch (manifest uses "...", entry hints "...")`

y dejar el arranque del gateway limpio de avisos de mapeo de plugins.

---

## Qué significa este warning
OpenClaw compara:
1. **ID declarado en el manifest del plugin** (canónico)
2. **ID/nombre sugerido en la entrada configurada** (`plugins.entries.*`)

Si no coinciden exactamente, lanza warning.

---

## Causa más común
Entradas históricas con sufijos tipo:
- `-provider`
- `-plugin`
- `-speech`

cuando el manifest actual usa ID limpio (ej. `openai`, `xai`, `deepgram`, etc.).

---

## Procedimiento recomendado (seguro)

### 1) Backup de config
Archivo típico:
- `/home/tormenta/.openclaw/openclaw.json`

```bash
cp /home/tormenta/.openclaw/openclaw.json /home/tormenta/.openclaw/openclaw.json.bak.$(date +%F-%H%M)
```

### 2) Identificar pares en conflicto
Desde el log de arranque/update, tomar líneas:
- `manifest uses "X", entry hints "Y"`

Regla:
- **usar siempre `X` (manifest)** como id final.

### 3) Normalizar `plugins.entries`
En `openclaw.json`, para cada entrada conflictiva:
- sustituir el id/hint legado por el id canónico del manifest.

Ejemplos típicos:
- `openai-provider` → `openai`
- `xai-plugin` → `xai`
- `deepgram-provider` → `deepgram`
- `elevenlabs-speech` → `elevenlabs`

### 4) Validar config
```bash
openclaw status --deep
```
Comprobar que desaparecen warnings de `plugin id mismatch`.

### 5) Reiniciar gateway (si aplica)
```bash
openclaw gateway restart
```
Si el host no soporta `systemctl --user`, usar el método operativo del entorno para reiniciar el proceso gateway.

---

## Estrategia incremental (recomendada)
- Corregir primero plugins realmente usados (OpenAI/Telegram/Whisper/Deepgram/etc.).
- Verificar.
- Luego limpiar el resto en lote.

Esto reduce riesgo de romper proveedores no críticos.

---

## Checklist de cierre
- [ ] Backup de `openclaw.json` hecho
- [ ] Entradas conflictivas normalizadas a IDs de manifest
- [ ] `openclaw status --deep` sin warnings de `plugin id mismatch`
- [ ] Gateway reiniciado y operativo
- [ ] Healthcheck posterior OK

---

## Nota operativa para este entorno
Ya se observó que el restart automático puede fallar con:
- `systemctl --user unavailable: Failed to connect to bus`

En ese caso, aplicar el reinicio por mecanismo alternativo del host o mantener cambio hasta ventana con reinicio controlado.
