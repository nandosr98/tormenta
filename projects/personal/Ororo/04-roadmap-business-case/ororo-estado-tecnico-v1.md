# Ororo — Informe técnico del estado del proyecto (v1)

**Fecha:** 2026-03-09  
**Base de análisis:** estado real de `Ororo-app` (rama `main`) + documentación del repositorio de Ororo  
**Objetivo:** sintetizar situación técnica actual, riesgos, brechas y siguientes pasos accionables del MVP.

## 1) Estado real del código y arquitectura MVP

A nivel técnico, el proyecto **sí está en fase MVP funcional de backend**, con una base Laravel 12 ya aterrizada y módulos implementados por PRs incrementales. El repositorio `Ororo-app` muestra una evolución coherente por módulos (`docs/changes-pr-7` a `docs/changes-pr-12`) y una estructura de dominio bastante limpia para una primera versión. En términos prácticos, no estamos ante un “prototipo vacío”: ya existen modelos, migraciones, comandos de consola, jobs y servicios para operar una cadena mínima de ingestión → normalización → correlación → alerta/síntesis → gobierno.

Componentes implementados y evidenciados en código:
- **Dominio Ororo en Eloquent** (`app/Models/Ororo/*`): `RawEvent`, `NormalizedEvent`, `WorkItem`, `MergeRequest`, `Pipeline`, `Alert`, `PreDailyDigest`, `ModulePolicy`, `ModuleMetric`, `AuditLog`, `ApprovalRequest`, `ModuleKillSwitch`, `AiSummary`, etc.
- **Procesamiento operativo** con comandos y jobs (`app/Console/Commands/Ororo/*`, `NormalizeRawEventJob`).
- **Servicios de negocio desacoplados** (`CanonicalEventNormalizer`, `WorkItemCorrelator`, `TeamsNotificationRouter`, `SafeSummaryBuilder`, `AuditLogger`, `ModuleExecutionGate`, `ModulePolicyResolver`, `ModuleMetricsRecorder`).
- **Capa de configuración** con `config/ororo.php` y políticas observables.
- **Panel mínimo de estado operativo** vía endpoint web `/ororo/status` y controlador dedicado.

Esto confirma que la arquitectura actual del MVP está orientada a ejecución real, no solo a definición documental.

## 2) Evolución reciente y coherencia por PR

La secuencia de PRs incorporada en `main` es consistente con un roadmap técnico incremental:
- PR 7: digest pre-daily.
- PR 8: gobierno básico (auditoría + aprobaciones + kill switch).
- PR 9: políticas configurables + observabilidad mínima.
- PR 10: IA acotada con fallback determinista.
- PR 11: hardening de ingesta/correlación (retry, calidad, ambigüedad).
- PR 12: cierre operativo MVP 1.0 (dashboard, runbook, checklist go-live).

Ese orden tiene sentido técnico: primero se construyó capacidad operacional, luego control y finalmente cierre operativo/documentación. El estado del repo demuestra una disciplina de entrega modular útil para mitigar riesgos de integración tardía.

## 3) Datos, persistencia y trazabilidad

El esquema de migraciones confirma una base de datos alineada con el diseño del MVP:
- tablas núcleo (workspaces/proyectos/sprints/work items/MR/pipelines/alerts/audit);
- eventos raw y normalizados;
- links de correlación;
- notificaciones Teams;
- digest;
- gobierno/políticas/métricas;
- resúmenes IA;
- columnas de hardening en eventos raw.

Desde la perspectiva de ingeniería, esto da tres ventajas claras:
1. **Trazabilidad end-to-end**: se puede reconstruir qué evento entró y qué acción derivó.
2. **Calibración operativa**: políticas y métricas permiten afinar umbrales sin rehacer arquitectura.
3. **Contención de incidentes**: kill switches por módulo reducen radio de impacto.

## 4) Brechas técnicas vigentes

Aunque el MVP está maduro para piloto controlado, persisten brechas importantes:

1. **UI funcional limitada**: actualmente solo existe una vista de estado (`/ororo/status`) y `welcome`. No hay panel administrativo completo para operación de negocio.
2. **Autenticación/autorización web**: en el estado visible de `main` no se observa todavía una capa web de Login/Register operativa conectada al panel de administración ni RBAC detallado en UI.
3. **APIs externas en producción real**: hay base de integración y servicios, pero la robustez final dependerá de validación en entornos con tráfico real, límites de API y variabilidad de datos de Jira/GitLab.
4. **Observabilidad ejecutiva**: existen métricas técnicas base, pero faltan tableros más orientados a decisión de producto/operación (utilidad, ruido, adopción por rol, tiempos de reacción por severidad).
5. **Gestión de configuración por interfaz**: actualmente gran parte del control parece orientado a comandos/configuración técnica; falta capa UX para que perfiles no técnicos operen sin fricción.

## 5) Riesgos técnicos de corto plazo

Riesgos más relevantes para siguientes 2–4 semanas:
- **Riesgo de ruido operativo** si las reglas se activan sin calibración por squad.
- **Riesgo de confianza** si no se vuelve visible la auditoría para usuarios clave (PM/Lead/Operaciones).
- **Riesgo de acoplamiento operativo al equipo técnico** si no se entrega pronto panel admin con permisos granulares.
- **Riesgo de percepción “IA mágica”**: si no se comunica bien que la IA está acotada y con fallback, puede haber expectativas no realistas.

## 6) Recomendaciones técnicas accionables (priorizadas)

**Prioridad alta (inmediata):**
1. Implementar **capa de acceso administrativo** (auth + RBAC + middleware por permisos).
2. Construir **panel de políticas y feature flags** con auditoría de cambios (antes/después, actor, motivo).
3. Integrar en dashboard **métricas de salud + calidad de señal** (latencia, error, útil/ruido, top falsos positivos).

**Prioridad media:**
4. Añadir “centro de incidentes” para replay controlado y gestión de DLQ.
5. Estandarizar contratos de eventos y versionado (event schema registry ligero).
6. Consolidar suite de pruebas E2E para escenarios críticos (pipeline crítica, correlación ambigua, kill switch activo).

**Prioridad de estabilización:**
7. Definir SLO formales del MVP piloto (procesamiento, entrega de digest, tiempo de alerta P0/P1).
8. Activar rollout gradual por módulo/squad para controlar impacto.

## 7) Conclusión técnica

El proyecto Ororo está en un **estado técnicamente sólido para piloto MVP**, con backend modular y controles operativos mejor de lo esperado para esta fase (auditoría, políticas, kill switch, fallback IA). El punto de mayor deuda no es de motor técnico central, sino de **capa de administración y experiencia operativa para el equipo**. Si el siguiente ciclo se enfoca en UI admin, permisos y trazabilidad visible, Ororo puede pasar de MVP técnico funcional a MVP operable por negocio con menor dependencia del equipo de ingeniería.