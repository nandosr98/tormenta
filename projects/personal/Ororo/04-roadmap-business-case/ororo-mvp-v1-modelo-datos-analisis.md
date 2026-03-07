# Ororo — Análisis del Modelo de Datos para MVP v1.0

## Resumen ejecutivo

Este documento define cómo debería ser el modelo de datos del MVP 1.0 de **Ororo**, enfocado en coordinar operación Scrum entre **Jira, GitLab y Microsoft Teams**. El objetivo no es guardar “todo”, sino almacenar lo mínimo necesario para: detectar bloqueos, priorizar alertas, generar resúmenes útiles y mantener trazabilidad con control humano.

La propuesta se basa en cuatro principios:

1. **Normalizar eventos de múltiples fuentes** (Jira/GitLab/Teams) en una estructura común.
2. **Separar hechos de decisiones**: primero guardamos señales objetivas, luego inferencias/acciones.
3. **Auditabilidad por diseño**: todo cambio relevante queda trazado (quién, cuándo, por qué).
4. **Escalabilidad progresiva**: esquema preparado para crecer a más equipos sin rediseño total.

El MVP se centra en casos de uso de alto impacto:
- tickets estancados/bloqueados,
- MRs sin revisión,
- pipelines fallidas con severidad,
- digest pre-daily,
- correlación ticket ↔ MR ↔ pipeline,
- acciones con aprobación (cuando aplique).

---

## 1) Objetivo del modelo de datos

El modelo de datos debe permitir que Ororo:

- Entienda el estado operativo real del sprint.
- Detecte anomalías a tiempo (bloqueos, inactividad, cuellos de botella).
- Genere notificaciones útiles (sin spam).
- Soporte reglas de negocio y decisiones asistidas por IA.
- Mantenga gobierno: permisos, auditoría, calidad de datos y trazabilidad.

**No objetivo del MVP:** construir un data warehouse completo ni sustituir analítica avanzada corporativa.

---

## 2) Enfoque de diseño

### 2.1 Patrón recomendado

Modelo híbrido con tres capas lógicas:

1. **Ingesta (raw/eventos fuente)**
   - Guarda payloads crudos de webhooks/polling para trazabilidad y re-proceso.

2. **Dominio normalizado (core operacional)**
   - Entidades canónicas: work items, merge requests, pipelines, usuarios, equipos.

3. **Acción y gobierno (decisiones/ejecución)**
   - Alertas, recomendaciones, aprobaciones, entregas, auditoría.

### 2.2 Base de datos y componentes

- **DB principal:** PostgreSQL (recomendado) o MySQL 8.
- **Cola:** Redis (Laravel queues + Horizon).
- **Cache efímera:** Redis (de-dup de eventos, rate limits, ventanas de silencio).
- **Storage adjunto (opcional):** S3-compatible para artefactos grandes de reporte.

### 2.3 Convenciones recomendadas

- Todas las tablas con `id` UUID (o bigint si prefieres simplicidad en MVP).
- Campos comunes: `created_at`, `updated_at`, `deleted_at` (soft delete en entidades de negocio).
- Multi-tenant lógico por `workspace_id` (equipo/cliente/área).
- Índices por `workspace_id + estado + updated_at` en entidades operativas.

---

## 3) Entidades núcleo del MVP

## 3.1 `workspaces`

Representa el ámbito organizativo de Ororo (ej. un departamento o producto).

Campos clave:
- `id`
- `name`
- `timezone`
- `status` (active/inactive)
- `settings_json`

Uso:
- Segregar datos y reglas por contexto.

## 3.2 `integrations`

Conexiones configuradas con Jira, GitLab, Teams.

Campos:
- `id`
- `workspace_id`
- `provider` (jira/gitlab/teams)
- `external_base_url`
- `auth_ref` (referencia a secreto, no el secreto en claro)
- `status`
- `last_healthcheck_at`
- `capabilities_json`

Uso:
- Estado de conectividad y capacidades disponibles por proveedor.

## 3.3 `external_identities`

Mapeo de usuarios entre sistemas (Jira/GitLab/Teams).

Campos:
- `id`
- `workspace_id`
- `person_id`
- `provider`
- `external_user_id`
- `external_username`
- `external_email_hash`

Uso:
- Correlación cross-tool (quién hizo qué en cada sistema).

## 3.4 `people`

Entidad canónica de persona (miembro del equipo).

Campos:
- `id`
- `workspace_id`
- `display_name`
- `role` (pm, scrum_master, dev, qa, tech_lead, manager, admin)
- `status`
- `teams_handle` (opcional)

Uso:
- Permisos, ownership, routing de alertas.

## 3.5 `projects`

Proyecto lógico dentro del workspace.

Campos:
- `id`
- `workspace_id`
- `name`
- `jira_project_key`
- `gitlab_project_id`
- `status`

Uso:
- Relacionar tickets/MRs/pipelines por dominio de producto.

## 3.6 `sprints`

Sprints de Scrum.

Campos:
- `id`
- `workspace_id`
- `project_id`
- `name`
- `starts_at`
- `ends_at`
- `goal`
- `status` (planned/active/closed)

Uso:
- KPIs por sprint y digest pre-daily.

## 3.7 `work_items`

Ticket/tarea canónica (Jira issue).

Campos:
- `id`
- `workspace_id`
- `project_id`
- `sprint_id` (nullable)
- `external_issue_id`
- `external_issue_key` (ej. ABC-123)
- `title`
- `type` (story/bug/task/spike)
- `priority`
- `status`
- `assignee_person_id`
- `reporter_person_id`
- `blocked_flag`
- `blocked_reason`
- `last_activity_at`
- `cycle_time_seconds` (derivado)

Uso:
- Detección de estancamiento, bloqueos, seguimiento operativo.

## 3.8 `merge_requests`

MR canónica (GitLab).

Campos:
- `id`
- `workspace_id`
- `project_id`
- `external_mr_id`
- `iid`
- `title`
- `author_person_id`
- `state` (opened/merged/closed)
- `review_status` (pending/in_review/approved/changes_requested)
- `opened_at`
- `merged_at`
- `last_activity_at`

Uso:
- MRs sin revisión, lead time, riesgo de entrega.

## 3.9 `pipelines`

Pipeline canónica (GitLab CI).

Campos:
- `id`
- `workspace_id`
- `project_id`
- `external_pipeline_id`
- `ref`
- `status` (running/success/failed/canceled)
- `severity` (low/medium/high/critical)
- `started_at`
- `finished_at`
- `duration_seconds`
- `failed_stage`

Uso:
- Alertas fallidas, priorización por severidad/impacto.

## 3.10 `work_item_links`

Relación entre ticket y MR/pipeline/commit.

Campos:
- `id`
- `workspace_id`
- `work_item_id`
- `link_type` (mr/pipeline/commit)
- `linked_entity_id`
- `source` (regex en branch, referencia manual, webhook)
- `confidence_score`

Uso:
- Trazabilidad ticket ↔ ejecución técnica.

## 3.11 `events_raw`

Registro crudo de eventos recibidos.

Campos:
- `id`
- `workspace_id`
- `provider`
- `event_type`
- `external_event_id`
- `received_at`
- `payload_json`
- `signature_valid`
- `processed_status` (pending/processed/failed/ignored)
- `error_message`

Uso:
- Reproceso, auditoría, debugging.

## 3.12 `events_normalized`

Evento ya normalizado a modelo interno.

Campos:
- `id`
- `workspace_id`
- `raw_event_id`
- `entity_type` (work_item/mr/pipeline)
- `entity_id`
- `action` (created/updated/status_changed/commented/etc)
- `occurred_at`
- `actor_person_id`
- `diff_json`

Uso:
- Motor de reglas y timeline coherente.

## 3.13 `alerts`

Alertas operativas generadas por reglas/IA.

Campos:
- `id`
- `workspace_id`
- `project_id`
- `alert_type` (stale_ticket, blocked_ticket, failed_pipeline, stale_mr)
- `severity`
- `entity_type`
- `entity_id`
- `title`
- `message`
- `status` (new/acknowledged/resolved/snoozed)
- `created_by` (rule_engine/ai/manual)
- `dedupe_key`
- `resolved_at`

Uso:
- Priorización y seguimiento de incidencias operativas.

## 3.14 `notifications`

Entregas de alertas/resúmenes por canal.

Campos:
- `id`
- `workspace_id`
- `alert_id` (nullable)
- `channel` (teams/email)
- `target`
- `payload_json`
- `delivery_status` (queued/sent/failed)
- `attempts`
- `last_attempt_at`

Uso:
- Evitar duplicados, trazabilidad de entregas.

## 3.15 `digests`

Resúmenes automáticos (daily/weekly/pre-daily).

Campos:
- `id`
- `workspace_id`
- `project_id`
- `digest_type` (pre_daily/daily/weekly)
- `period_start`
- `period_end`
- `summary_markdown`
- `highlights_json`
- `generated_at`

Uso:
- Comunicación resumida, no saturación por alertas sueltas.

## 3.16 `approvals`

Control humano para acciones sensibles.

Campos:
- `id`
- `workspace_id`
- `action_type`
- `action_payload_json`
- `requested_by` (rule_engine/ai/person)
- `approver_person_id`
- `status` (pending/approved/rejected/expired)
- `reason`
- `decided_at`

Uso:
- Gobernanza y seguridad operacional.

## 3.17 `audit_logs`

Bitácora de acciones críticas.

Campos:
- `id`
- `workspace_id`
- `actor_type` (system/person)
- `actor_id`
- `action`
- `entity_type`
- `entity_id`
- `metadata_json`
- `created_at`

Uso:
- Cumplimiento, postmortem, accountability.

## 3.18 `policies`

Reglas configurables de alertado/ruido/riesgo.

Campos:
- `id`
- `workspace_id`
- `name`
- `policy_type` (notification/risk/approval)
- `config_json`
- `enabled`

Uso:
- Ajuste fino sin tocar código.

---

## 4) Relaciones clave (alto nivel)

- `workspace` 1:N `projects`, `people`, `integrations`, `alerts`, `digests`.
- `project` 1:N `sprints`, `work_items`, `merge_requests`, `pipelines`.
- `work_item` N:M `merge_requests` (vía `work_item_links`).
- `events_raw` 1:1..N `events_normalized`.
- `alerts` 1:N `notifications`.
- `alerts` N:1 `work_items`/`merge_requests`/`pipelines` (polimórfico).
- `approvals` referencian acciones propuestas sobre entidades.
- `audit_logs` registra cualquier mutación relevante.

---

## 5) Flujos de datos del MVP

## 5.1 Ingesta de eventos

1. Webhook de Jira/GitLab entra a endpoint Laravel.
2. Verificación de firma.
3. Persistencia en `events_raw`.
4. Job asíncrono normaliza en `events_normalized`.
5. Motor de reglas evalúa condiciones.
6. Si aplica, crea `alerts` + `notifications`.
7. Si requiere control humano, crea `approvals`.

## 5.2 Detección de ticket estancado

- Regla: ticket sin actividad > X horas en estado Y.
- Inputs: `work_items.last_activity_at`, `status`, `priority`.
- Output: alerta con severidad y sugerencia de acción.

## 5.3 Pipeline fallida crítica

- Evento pipeline `failed` + branch/repo crítico.
- Regla calcula severidad.
- Se notifica canal Teams adecuado y owner técnico.

## 5.4 Digest pre-daily

- Scheduler genera snapshot de riesgo del sprint.
- Persiste en `digests`.
- Entrega por `notifications`.

---

## 6) Requisitos funcionales sobre datos

1. Deduplicación de eventos por `external_event_id + provider`.
2. Correlación ticket↔MR por claves de issue en branch/commit/MR title.
3. Cálculo de antigüedad de estado por `events_normalized`.
4. Soporte de reglas por prioridad/tipo/sprint/owner.
5. Registro de estado de entrega de notificaciones.
6. Historial auditable de decisiones y cambios de políticas.

---

## 7) Requisitos no funcionales del modelo

## 7.1 Rendimiento

- Ingesta webhook p95 < 300ms (persistir raw y encolar).
- Procesamiento normalización asíncrono p95 < 5s.
- Consulta dashboard p95 < 1s con índices adecuados.

## 7.2 Seguridad

- Nunca guardar tokens en texto plano en tablas.
- `auth_ref` apunta a vault/secret manager.
- Hash parcial de emails cuando no sean imprescindibles en claro.
- Auditoría inmutable para acciones de gobierno.

## 7.3 Escalabilidad

- Particionar lógicamente por `workspace_id`.
- Tabla `events_raw` con política de retención (ej. 90 días crudo + archivado).
- Índices compuestos por filtros frecuentes.

## 7.4 Usabilidad

- Campos de estado coherentes entre dominios.
- Catálogos controlados (enum/tables lookup) para evitar “texto libre” ambiguo.

---

## 8) Índices recomendados MVP

### `work_items`
- `(workspace_id, status, updated_at)`
- `(workspace_id, assignee_person_id, status)`
- `(workspace_id, last_activity_at)`
- unique `(workspace_id, external_issue_id)`

### `merge_requests`
- `(workspace_id, state, review_status, updated_at)`
- unique `(workspace_id, external_mr_id)`

### `pipelines`
- `(workspace_id, status, severity, created_at)`
- unique `(workspace_id, external_pipeline_id)`

### `alerts`
- `(workspace_id, status, severity, created_at)`
- `(workspace_id, dedupe_key)`

### `events_raw`
- unique `(workspace_id, provider, external_event_id)`
- `(workspace_id, processed_status, received_at)`

---

## 9) Retención y ciclo de vida de datos

- `events_raw`: 90 días online, luego archivado frío.
- `events_normalized`: 180–365 días según necesidad analítica.
- `alerts`/`audit_logs`: retención larga (12–24 meses mínimo).
- `notifications`: 180 días para troubleshooting.
- `digests`: 12 meses para reporting evolutivo.

---

## 10) Estrategia de calidad de datos

1. Validación de esquema por proveedor al ingresar webhooks.
2. Catálogo de errores de normalización (con retries selectivos).
3. Job de reconciliación nocturna para drift de entidades.
4. Métricas de calidad:
   - tasa de eventos inválidos,
   - tasa de correlación ticket↔MR,
   - latencia de sincronización,
   - alertas duplicadas.

---

## 11) Riesgos de modelo y mitigación

1. **Sobre-modelado temprano**
   - Mitigación: mantener MVP con entidades mínimas + extensibilidad por JSON controlado.

2. **Ruido de alertas**
   - Mitigación: `dedupe_key`, políticas de silencio temporal, digests.

3. **Correlación débil ticket↔MR**
   - Mitigación: score de confianza + fallback manual + convención de naming.

4. **Dependencia de payloads externos cambiantes**
   - Mitigación: capa raw + normalizador versionado.

5. **Riesgo de exposición de datos sensibles**
   - Mitigación: minimización de PII, hashing, RBAC estricto, auditoría.

---

## 12) Propuesta de implementación en Laravel (sin código)

## Fase A — Esquema base (Semana 1)
- Migraciones de: workspaces, integrations, people, projects, sprints, work_items, merge_requests, pipelines.
- Seeds mínimos de catálogos/roles.

## Fase B — Ingesta y normalización (Semana 2)
- `events_raw`, `events_normalized`.
- Jobs de normalización por proveedor.

## Fase C — Alertas y notificaciones (Semana 3)
- `alerts`, `notifications`, reglas iniciales.

## Fase D — Gobierno y auditoría (Semana 4)
- `approvals`, `audit_logs`, `policies`.

## Fase E — Digest y refinado operativo (Semana 5)
- `digests`, reportes pre-daily, tuning anti-ruido.

---

## 13) Criterios de aceptación del modelo v1

1. Se pueden ingerir y normalizar eventos Jira/GitLab sin pérdida relevante.
2. Se detectan tickets estancados y pipelines críticas con baja duplicidad.
3. Se genera digest pre-daily coherente con estado real del sprint.
4. Toda acción sensible queda auditable.
5. Los tiempos de respuesta cumplen objetivos no funcionales MVP.

---

## 14) Decisiones recomendadas para cerrar diseño

1. Elegir DB final para MVP (PostgreSQL recomendado).
2. Definir taxonomía final de severidad (P0–P3 o low–critical).
3. Cerrar reglas de correlación ticket↔MR aceptadas por equipo.
4. Acordar retención de `events_raw` con seguridad/compliance.
5. Aprobar catálogo inicial de políticas de notificación y aprobación.

---

## Conclusión

El modelo propuesto ofrece equilibrio entre velocidad de implementación y robustez operativa. Está diseñado para arrancar con valor real en el MVP de Ororo (detección de riesgo, coordinación y trazabilidad) y crecer sin reescritura masiva. Si se implementa por fases en Laravel con disciplina de calidad de datos, Ororo tendrá una base sólida para escalar desde un asistente operativo a una plataforma interna de ejecución inteligente.
