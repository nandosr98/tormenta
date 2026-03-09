# Ororo — Estrategia técnica de UI/Panel Admin para dirigir y modificar el comportamiento del sistema (v1)

**Fecha:** 2026-03-09  
**Objetivo:** definir, con enfoque implementable, cómo habilitar un panel de administración para que el equipo pueda gobernar Ororo sin depender del desarrollo para cambios operativos frecuentes.

## 1) Principio rector del panel

El panel admin de Ororo debe ser un **centro de control operativo**, no solo un dashboard bonito. Su función principal es permitir que perfiles de operación (PM, Tech Lead, Operaciones, Owner de Ororo) puedan:
1. ajustar reglas y políticas;
2. activar/desactivar módulos con seguridad;
3. monitorear salud y calidad de señal;
4. auditar decisiones y acciones;
5. intervenir rápidamente ante incidentes.

Si el panel no permite esas cinco capacidades con baja fricción, Ororo seguirá siendo técnicamente potente pero operativamente dependiente de ingeniería.

## 2) Arquitectura propuesta del panel

### 2.1 Capa de frontend
- UI web interna en Laravel (Blade + componentes UI consistentes, o Livewire para interacción server-driven).
- Navegación por áreas operativas (no por estructura técnica interna).
- Diseño orientado a “operador bajo presión”: prioridad a claridad, estado, acciones y confirmaciones.

### 2.2 Capa backend del panel
- Controladores/acciones administrativas separadas del flujo de ingestión productivo.
- Endpoints con autorización estricta por permiso granular.
- Validaciones de rango y coherencia para cambios de política (evitar configuraciones peligrosas).

### 2.3 Capa de configuración y estado
- Repositorio de políticas en DB (`module_policies`, `policy_versions`) con versionado.
- Flags por módulo/squad (`module_kill_switches`).
- Modelo de snapshot operacional para el home del panel (latencia, colas, errores, alertas activas, calidad de señal).

### 2.4 Capa de auditoría
- Registro obligatorio de toda mutación administrativa:
  - actor,
  - acción,
  - valor previo,
  - valor nuevo,
  - motivo,
  - timestamp,
  - correlation_id.
- Trazabilidad navegable desde UI (no solo tablas técnicas).

## 3) Módulos de administración (mapa funcional)

## Módulo A — Centro de estado (Home Operativo)
Debe responder en 30 segundos: “¿Ororo está sano y útil hoy?”.

Widgets recomendados:
- salud de ingestión (ok/degradado/caído),
- cola de procesamiento y backlog,
- latencia p95 por flujo crítico,
- alertas emitidas por severidad,
- ratio útil/ruido/incorrecto (últimas 24h/7d),
- top causas de fallo.

## Módulo B — Políticas y reglas
Pantalla para editar umbrales sin despliegue:
- estancamiento por horas,
- ventanas de dedupe,
- frecuencia máxima de alertas,
- criterios de severidad,
- horarios de silencio.

Requisitos UX:
- mostrar impacto esperado antes de guardar;
- validación semántica (ejemplo: no permitir frecuencia imposible);
- “guardar como borrador” y “aplicar” separados.

## Módulo C — Feature flags y kill switch
- Activar/desactivar por módulo y por squad.
- Modo “read-only/sombra” para probar sin impacto.
- Botón de kill switch rápido con confirmación reforzada y expiración opcional.

## Módulo D — Gestión de rutas/canales
- Configurar destinos Teams por severidad y tipo de alerta.
- Probar envío de mensaje de verificación.
- Detectar rutas huérfanas (canales inválidos o sin permisos).

## Módulo E — Aprobaciones
- Bandeja de acciones sensibles pendientes (ej.: cambios de automatización con riesgo).
- Flujo aprobar/rechazar con justificación obligatoria.
- SLA de aprobación y escalado automático.

## Módulo F — Auditoría y trazabilidad
- Buscador por correlation_id, módulo, actor, rango de tiempo, tipo de evento.
- Línea de tiempo completa evento→regla→notificación→acción humana.
- Exportación para revisión interna/compliance.

## Módulo G — Calidad de señal
- Ranking de alertas más útiles y más ruidosas.
- Evolución por squad y por tipo de notificación.
- Recomendaciones automáticas de tuning de políticas.

## Módulo H — Incidentes operativos
- Vista de errores recurrentes, DLQ/reintentos, eventos ambiguos.
- Playbooks rápidos: reintentar, pausar módulo, abrir incidente.

## 4) Permisos y roles (RBAC)

Roles propuestos:
- **Super Admin Plataforma:** control total + seguridad.
- **Ororo Product Owner:** políticas funcionales, no secretos críticos.
- **Operaciones/PM:** ajustes de frecuencia/umbrales acotados y seguimiento.
- **Tech Lead:** tuning técnico-operativo y aprobaciones de riesgo medio.
- **Auditor/Compliance:** solo lectura de trazas y reportes.

Permisos deben ser atómicos (ejemplos):
- `policy.read`, `policy.update`, `policy.publish`,
- `kill_switch.toggle`,
- `routing.update`,
- `approval.resolve`,
- `audit.export`,
- `incident.replay`.

Reglas clave:
1. principio de mínimo privilegio,
2. separación de funciones (quien propone no siempre publica),
3. permisos por ámbito (global vs squad).

## 5) UX operativa: cómo debe sentirse el panel

La UX no debe parecer una consola de desarrollador. Debe optimizar decisiones rápidas:
- etiquetas claras de estado (Sano / Degradado / Crítico);
- semáforos de riesgo;
- lenguaje de acción (“Reducir ruido”, “Contener módulo”, “Revisar correlaciones ambiguas”);
- confirmaciones con contexto (“Este cambio puede aumentar alertas +35% en squad A”);
- modo oscuro/alto contraste opcional para uso intensivo.

Flujos críticos de UX:
1. **Incidente de ruido masivo:** abrir home → ver módulo causante → activar kill switch → registrar motivo → monitorear normalización.
2. **Ajuste semanal:** revisar calidad de señal → editar umbral → aplicar en modo limitado → observar impacto 48h.
3. **Auditoría puntual:** buscar correlation_id de alerta discutida → reconstruir cadena completa → exportar evidencia.

## 6) Seguridad del panel

Controles mínimos exigibles:
- autenticación fuerte (sesión segura + opción MFA para roles críticos),
- CSRF, rate limit y protección anti brute-force,
- validación estricta server-side de todos los inputs,
- protección de secretos fuera de UI en texto plano,
- logs de acceso administrativo,
- expiración de sesión y reautenticación para acciones de alto impacto,
- hardening de headers y aislamiento de rutas admin.

Adicionalmente, para acciones críticas (kill switch global, cambio de enrutamiento P0) se recomienda **doble confirmación** o aprobación dual en producción.

## 7) Trazabilidad y auditoría operable

La auditoría debe dejar de ser un tema “de cumplimiento” y pasar a ser una herramienta diaria. Por eso el panel debe exponer:
- comparación visual antes/después de políticas,
- quién cambió qué y por qué,
- relación entre cambios de política y variaciones de ruido/utilidad,
- feed cronológico de eventos importantes.

Esto acelera aprendizaje operativo y evita discusiones basadas en percepciones.

## 8) Feature flags como estrategia de despliegue

No usar feature flags solo como interruptor técnico. Usarlas como estrategia de negocio:
- `shadow_mode`: evalúa señal sin publicar,
- `pilot_enabled`: activa en squad controlado,
- `auto_action_enabled`: separa sugerencia de ejecución,
- `ai_summary_enabled`: permite apagar IA sin romper flujo base.

Cada flag debe tener owner, fecha de revisión y criterio de salida (cuándo se consolida o se retira).

## 9) Métricas del panel (mínimo viable)

Métricas técnicas:
- latencia p95 por flujo,
- error rate por integración,
- backlog de cola,
- ratio de fallback IA.

Métricas operativas:
- alertas por severidad,
- tiempo hasta primera acción,
- ratio útil/ruido/incorrecto,
- top reglas con mayor falso positivo,
- módulos más intervenidos por kill switch.

Métricas de gobernanza:
- cambios de políticas por semana,
- aprobaciones pendientes fuera de SLA,
- incidentes cerrados con trazabilidad completa.

## 10) Roadmap UI por fases

### Fase 1 (2 semanas) — Núcleo admin mínimo
- Login de admin + RBAC base.
- Home operativo con estado global.
- Visualización de políticas (solo lectura) + auditoría básica.

### Fase 2 (2–3 semanas) — Operación configurable
- Edición de políticas con validaciones.
- Feature flags y kill switch por módulo/squad.
- Gestión de rutas de notificación.

### Fase 3 (2 semanas) — Gobierno fuerte
- Bandeja de aprobaciones.
- Auditoría avanzada con filtros/exportación.
- Comparativas antes/después por cambio.

### Fase 4 (2 semanas) — Optimización UX y métricas
- Panel de calidad de señal.
- Recomendaciones de tuning.
- Flujos guiados para incidentes y playbooks.

## 11) Cierre

El siguiente salto de Ororo no depende de más automatizaciones complejas, sino de convertir su potencia técnica actual en **operación gobernable por el equipo**. Un panel admin bien diseñado debe permitir dirigir el comportamiento del sistema con seguridad, trazabilidad y velocidad de reacción. Si se ejecuta este plan por fases, Ororo puede pasar de MVP técnico a plataforma operativa madura, con menor dependencia de ingeniería y mayor control de negocio sobre el comportamiento diario del producto.