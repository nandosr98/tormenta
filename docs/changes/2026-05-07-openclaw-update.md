# OpenClaw update — 2026-05-07

## Cambio aplicado
- Ejecutado `openclaw update`.
- Versión anterior: `2026.3.2`
- Versión nueva: `2026.5.6`

## Resultado
- Update global completado correctamente.
- Plugins: sin actualizaciones requeridas.

## Hallazgos post-update
- Warning operativo: `gateway.trustedProxies` vacío (solo relevante si se expone UI tras reverse proxy).
- Reinicio del servicio no automático en este host por entorno sin bus de `systemctl --user`.

## Acción recomendada
- Si el Control UI se expone tras proxy, configurar `gateway.trustedProxies` con IPs del proxy.
- Reiniciar gateway manualmente con método compatible del entorno actual cuando aplique.
