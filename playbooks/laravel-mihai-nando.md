# Laravel style guide (Mihai + Nando)

## Stack base detectado
- Laravel 11/12, PHP 8.2
- Breeze + Livewire + Mary UI + Tailwind + Vite + Alpine
- Cashier (Stripe), Horizon, Google Ads SDK, SEO package, cookie consent
- Proyectos tipo servicio (flujo request -> pago -> seguimiento -> admin)

## Estructura que se repite
- `app/Http/Controllers` con lógica de flujo de negocio (no ultraligera)
- `app/Livewire` para panel/admin y vistas dinámicas
- `app/Jobs/StripeWebhooks/*` para eventos de Stripe
- `app/Helpers/*` para integración externa (Stripe/GoogleAds)
- `app/Rules/*` para validaciones de dominio (NoHtml, DNI, Recaptcha)
- `app/Enums/*Status.php` para estados de negocio
- `app/Mail/*` para notificaciones de cada evento

## Convenciones observadas
- Nombres explícitos en castellano/inglés mezclados por contexto de negocio.
- IDs de tracking con `str_pad(mt_rand(...),8,'0',STR_PAD_LEFT)`.
- Mucho uso de `Log::info/warning/error` en pasos clave.
- Validación inline en controller con reglas + mensajes personalizados.
- Sesión para recuperar flujos interrumpidos (login/recover/payment).
- Redirects por `route()` y vistas blade por feature.

## Filosofía de implementación
1. Sacar flujo completo primero (happy path end-to-end).
2. Meter observabilidad pronto (logs y estados trazables).
3. Integraciones externas encapsuladas en helper/job.
4. Soportar recuperación de sesión y reintentos (flujo real de usuario).
5. Mantener velocidad y pragmatismo antes que sobre-arquitectura.

## Reglas para código nuevo (para Storm)
- Mantener la estructura de carpetas ya usada en cada repo.
- No introducir patrones nuevos (DDD/CQRS/etc.) salvo pedido explícito.
- Si hay feature nueva con pago/webhook:
  - `Enum` de estados
  - `Model` + migración
  - `Job` por webhook relevante
  - `Mail` para evento de negocio
  - logs de trazabilidad
- Usar `FormRequest` cuando la validación crezca; inline si es simple.
- Priorizar naming y estilo ya presente en ese repo sobre estilo “ideal”.
- Usar Docker siguiendo la estructura existente de `docker-compose.yml` y las carpetas/archivos que ese compose referencia.
- Al crear proyectos nuevos, mantener nombre de contenedor = nombre del proyecto (evita conflictos entre stacks).

## Checklist rápido al arrancar tarea
- [ ] Identificar módulo más parecido y replicar patrón.
- [ ] Revisar rutas existentes y naming de vistas.
- [ ] Confirmar estado de negocio y enum asociado.
- [ ] Añadir logs en entradas/salidas críticas.
- [ ] Cubrir flujo principal + caso de recuperación/error.
- [ ] No romper panel admin/livewire existente.
