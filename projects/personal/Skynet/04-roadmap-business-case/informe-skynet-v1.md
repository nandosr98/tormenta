# Informe estratégico y técnico — Proyecto Skynet v1

**Fecha:** 2026-03-05  
**Ámbito:** Diseño e implementación de un agente de IA interno para un equipo Scrum (~20 personas) usando Jira, GitLab y Microsoft Teams.  
**Audiencia:** Dirección, PM/Scrum Master, Engineering Manager, Tech Leads, DevOps, QA y equipo de implementación.

---

## 0) Resumen de propósito

Skynet es una iniciativa para convertir la operación diaria de un equipo de desarrollo en un sistema más predecible, menos dependiente de tareas manuales y más orientado a flujo de valor. El foco no es “meter IA por moda”, sino construir un **sistema operativo de coordinación** apoyado en IA que quite fricción en cuatro puntos críticos: seguimiento de sprint, coordinación entre personas, visibilidad ejecutiva y reacción temprana ante riesgos.

La hipótesis de negocio es clara: en un equipo de ~20 personas, una parte relevante del tiempo operativo se consume en tareas de bajo valor directo (recordatorios, reportes, perseguir bloqueos, alinear estados Jira/GitLab, recopilar contexto para dailies/reviews). Al automatizar ese trabajo con reglas + eventos + IA contextual, la empresa puede liberar capacidad, reducir errores de coordinación y mejorar la velocidad de entrega sin forzar jornadas ni contratar inmediatamente más estructura.

Skynet se plantea como una plataforma modular. No sustituye al PM, Scrum Master o Tech Lead; **amplifica** su capacidad operativa. El sistema toma señales de Jira, GitLab y Teams, detecta patrones (bloqueos, inactividad, MRs atascadas, pipelines fallidos, desalineaciones), propone o ejecuta acciones, y distribuye información útil en el canal correcto y en el momento correcto.

Este informe define una propuesta aplicable, con arquitectura técnica viable, automatizaciones priorizadas, gobierno operativo, roadmap realista por fases y business case inicial para empresa mediana.

---

## 1) Visión general del sistema

### 1.1 Problema que resuelve

En equipos Scrum medianos, la eficiencia no suele caer por falta de capacidad técnica, sino por **pérdidas de coordinación**:

- Tickets con estado obsoleto respecto a actividad real.
- Bloqueos detectados tarde.
- PM/Scrum Master dedicando horas a consolidar estado manualmente.
- MRs pendientes sin visibilidad de prioridad.
- Pipelines rotas que impactan sprint y no escalan a tiempo.
- Exceso de mensajes no accionables en Teams.

Skynet se diseña para reducir esta entropía operativa.

### 1.2 Rol del agente dentro de la empresa

El agente IA actúa como una **capa de orquestación operacional**:

1. **Observa** eventos de Jira/GitLab/Teams.
2. **Normaliza** y correlaciona información por ticket, MR, responsable, sprint y objetivo.
3. **Interpreta** con reglas deterministas + IA (resúmenes, clasificación, priorización).
4. **Actúa**: notifica, propone, actualiza o abre tareas automáticas.
5. **Aprende** de feedback humano para ajustar ruido/valor.

No es un chatbot generalista. Es un sistema orientado a operaciones de delivery.

### 1.3 Principios de diseño

- **Accionable > informativo:** cada notificación debe sugerir próximo paso.
- **Menos ruido, más precisión:** control estricto de frecuencia, prioridad y destinatarios.
- **Humano en el loop** para acciones sensibles.
- **Trazabilidad total:** toda acción automática debe ser auditable.
- **Arquitectura incremental:** empezar por casos de alto ROI, escalar por evidencia.

### 1.4 Impacto esperado en productividad

Impactos típicos esperados en 3–6 meses:

- 25–40% menos tiempo de PM en seguimiento manual.
- 15–25% menos tiempo de ciclo en tickets con dependencia alta.
- 20–35% menos tiempo de resolución de incidentes de pipeline por detección temprana.
- Mejora de previsibilidad del sprint (desviación menor entre compromiso y cierre).

### 1.5 Qué debe seguir siendo humano

- Priorización estratégica de backlog.
- Decisiones de alcance/compromiso de sprint.
- Evaluación de trade-offs técnicos críticos.
- Gestión interpersonal y coaching del equipo.
- Aprobación final de cambios en políticas operativas.

La IA no reemplaza liderazgo. Lo hace más efectivo.

---

## 2) Contexto operativo del equipo objetivo

### 2.1 Perfil de empresa mediana

Se asume una empresa de producto o servicios tecnológicos con:

- 2–4 squads o un squad ampliado de ~20 personas.
- Sprint de 2 semanas.
- PM/Scrum Master con carga de coordinación alta.
- GitLab como plataforma principal de repositorio + CI/CD.
- Jira como fuente de verdad de trabajo planificado.
- Teams como canal transversal de comunicación.

### 2.2 Dolor operacional actual (baseline)

Se observan síntomas frecuentes:

- Daily con 35–45% del tiempo en reconstruir estado.
- Tickets “In Progress” sin actividad real por >3 días.
- MRs listas sin revisión por falta de visibilidad cruzada.
- Dependencias entre equipos no explicitadas.
- Reportes de sprint elaborados manualmente en hojas/documentos.

### 2.3 Objetivo de transformación

Pasar de gestión reactiva basada en perseguir personas a una gestión proactiva basada en señales automáticas y decisiones rápidas.

---

## 3) Casos de uso concretos (aplicables, no genéricos)

### 3.1 Detección de tickets bloqueados o estancados

**Señales consideradas:**
- Estado Jira = “Blocked” o etiqueta equivalente.
- Comentarios con palabras clave (“dependencia”, “esperando”, “bloqueado”).
- Sin cambios de estado ni commits asociados en N días.
- MR asociada sin actividad de revisión.

**Comportamiento Skynet:**
- Clasifica bloqueo: técnico, funcional, dependencia externa, QA, infraestructura.
- Notifica en canal Teams del squad con plantilla accionable:
  - Ticket
  - Tipo de bloqueo
  - Días bloqueado
  - Responsable propuesto para destrabe
  - Próximo punto de control
- Si supera umbral (ej. 48h), escala a PM + Tech Lead.

**Valor real:** evita que bloqueos “silenciosos” consuman capacidad del sprint.

### 3.2 Brief automático pre-daily (07:45)

Antes de daily, Skynet publica resumen con:

- Top 5 riesgos del sprint.
- Tickets que cambiaron de estado en últimas 24h.
- Tickets sin movimiento >48h.
- MRs críticas pendientes de revisión.
- Pipelines fallidas activas.

Formato corto (3–5 minutos de lectura), con enlaces directos.

**Resultado esperado:** daily centrada en decisiones, no en recopilación manual.

### 3.3 Resumen inteligente de Merge Requests

Cuando se abre MR, el agente genera:

- Resumen funcional (qué cambia para el usuario/negocio).
- Resumen técnico (módulos impactados, riesgo, migraciones).
- Checklist sugerido de revisión.
- Relación con ticket Jira.

Cuando MR supera cierto tamaño o riesgo, recomienda reviewers por historial de ownership.

### 3.4 Recordatorios de hygiene de Jira sin fricción

En lugar de “spam masivo”, el agente manda mensajes personalizados:

- “Tu ticket SKY-231 lleva 4 días en In Progress sin comentario. ¿Sigue activo o lo marcamos bloqueado?”
- Botones rápidos en Teams: **Actualizar estado**, **Marcar bloqueado**, **Postergar 24h**.

### 3.5 Alerta de pipeline fallida con impacto de sprint

No toda falla amerita el mismo ruido.

Skynet cruza:
- Rama afectada
- Ticket/sprint asociado
- Entorno impactado
- Criticidad del componente

Luego decide ruta:
- Canal técnico si impacto bajo.
- Canal squad + mención PM/Lead si afecta entregable comprometido.
- Escalado si >X minutos sin recuperación.

### 3.6 Reporte automático de mitad de sprint

El día hábil central del sprint, genera:

- Burn-up/burn-down sintético.
- Riesgo de no cumplir compromiso.
- Historias con probabilidad baja de cierre.
- Recomendaciones: dividir alcance, reforzar revisión, renegociar dependencia.

### 3.7 Detección de saturación de revisores

Analiza cola de MRs y carga por reviewer:

- Revisor con >N MRs pendientes y SLA alto.
- Redistribución sugerida por experiencia en módulo.
- Alertas suaves para evitar cuello de botella humano.

### 3.8 Gestión de handoff QA-Dev

Cuando ticket pasa a “Ready for QA”, Skynet valida:

- Enlace a MR merged.
- Evidencia de pruebas mínimas.
- Entorno de despliegue correcto.

Si falta algo, devuelve automáticamente con checklist faltante.

### 3.9 Reporte ejecutivo semanal (dirección)

En lenguaje no técnico:

- Progreso por iniciativa.
- Riesgos abiertos relevantes.
- Tendencia de throughput.
- Bloqueos inter-área.
- Decisiones requeridas a nivel gerencial.

### 3.10 Postmortem asistido de incidentes de delivery

Tras falla relevante, Skynet prepara borrador:

- Línea temporal de eventos (pipeline, commits, despliegue, rollback).
- Hipótesis de causa raíz.
- Acciones correctivas y preventivas sugeridas.

---

## 4) Arquitectura técnica objetivo

### 4.1 Arquitectura de alto nivel

Componentes propuestos:

1. **Ingestion Layer**
   - Webhooks Jira/GitLab/Teams.
   - Polling programado para eventos no cubiertos por webhook.

2. **Event Bus / Queue**
   - Kafka/RabbitMQ/SQS (según stack).
   - Desacople entre recepción y procesamiento.

3. **Orchestrator Service (Skynet Core)**
   - Normalización de eventos.
   - Correlación por entidades (ticket, MR, sprint, usuario).
   - Enrutamiento a reglas y motor IA.

4. **Rules Engine**
   - Reglas deterministas (SLA, umbrales, deduplicación, escalado).
   - Priorización de alertas.

5. **AI Decision Layer**
   - LLM para resumen, clasificación semántica, recomendación de acción.
   - Guardrails y validadores.

6. **Action Executors**
   - Actualizaciones Jira.
   - Comentarios/etiquetas GitLab.
   - Mensajes/cards Teams.
   - Creación de tareas de seguimiento.

7. **Data Store**
   - PostgreSQL para estado operacional y auditoría.
   - Redis para caché de contexto y rate-limit.

8. **Observability & Admin**
   - Logs estructurados.
   - Métricas (Prometheus/Grafana).
   - Consola de gobierno (feature flags, umbrales, silenciado).

### 4.2 Integración con Jira API

Funciones críticas:

- Lectura de issues, estados, transiciones, comentarios, campos custom.
- Escritura de comentarios automáticos con trazabilidad.
- Transición de estados (cuando política lo permita).
- JQL para consultas de sprint y estancamiento.

**Buenas prácticas técnicas:**
- Usar cuenta de servicio dedicada.
- Permisos mínimos por proyecto.
- Respetar rate limits y paginación.
- Idempotencia en actualizaciones (evitar doble transición).

### 4.3 Integración con GitLab API y webhooks

Eventos clave:
- merge_request events
- pipeline events
- push events
- note events

Acciones típicas:
- Anotar MR con resumen generado.
- Etiquetar MRs de alto riesgo.
- Detectar pipeline failed y correlacionar ticket.
- Calcular lead time de cambio por rama/entorno.

### 4.4 Integración con Microsoft Teams

Canales de interacción:
- Mensajes en canales por squad.
- Mensajes directos (recordatorios personalizados).
- Adaptive Cards con acciones rápidas.
- Teams Workflows para flujos sin código/complementarios.

Principio: Teams como “front-end conversacional” del sistema.

### 4.5 Modelo de eventos y correlación

Entidad canónica propuesta:

- `work_item` (jira_issue_key, summary, status, assignee, sprint, priority)
- `code_change` (mr_id, repo, branch, reviewers, pipeline_status)
- `coord_signal` (blocked_score, stale_score, risk_score)
- `action_log` (trigger, action_type, target, result, actor=bot/human)

Correlación por reglas:
- Convención de clave Jira en commits/MR title.
- Mapeo repo ↔ proyecto Jira.
- Tabla de ownership por módulo.

### 4.6 Jobs automatizados

Tipos de jobs:

- **Near real-time** (webhook-driven): pipeline fail, MR open/update.
- **Batch horario**: pre-daily, mid-sprint report, weekly executive summary.
- **Batch nocturno**: limpieza, recomputación de métricas, entrenamiento de umbrales.

Scheduler recomendado: Temporal, Quartz, BullMQ o equivalente según stack.

### 4.7 Flujos de evento ejemplo

#### Flujo A: Pipeline fallida
1. GitLab webhook emite `pipeline_failed`.
2. Ingestion valida firma y serializa evento.
3. Core correlaciona con MR/ticket/sprint.
4. Rules Engine calcula severidad.
5. AI layer redacta mensaje accionable (si aplica).
6. Executor publica en Teams + comenta ticket Jira.
7. Audit log registra acción y latencia.

#### Flujo B: Ticket estancado
1. Job horario ejecuta JQL de inactividad.
2. Core cruza con commits/MR recientes.
3. Si estancado real, genera recordatorio personalizado.
4. Si reincidente, escala a PM en resumen de riesgo.

### 4.8 Seguridad y cumplimiento técnico

- OAuth/App tokens en vault (HashiCorp Vault, AWS Secrets Manager o similar).
- Cifrado en tránsito (TLS) y en reposo.
- Rotación de secretos automatizada.
- Auditoría de acceso a datos sensibles.
- Segmentación por proyecto y principio de mínimo privilegio.

### 4.9 Despliegue y operación

Entornos:
- Dev (sandbox APIs)
- Staging (datos anonimizados/parciales)
- Prod (controlado por feature flags)

Estrategia de despliegue:
- Canary por squad.
- Rollback automático ante tasa alta de errores o spam.
- Versionado de prompts/reglas como código.

---

## 5) Diseño del agente de IA

### 5.1 Capacidades necesarias

1. **Comprensión contextual** de tickets, MRs, pipelines y estado sprint.
2. **Resumen multi-fuente** con enfoque accionable.
3. **Clasificación de riesgo** (bloqueo, atraso, dependencia, calidad).
4. **Recomendación de siguiente acción** según rol (dev, PM, lead).
5. **Comunicación adaptativa** por canal y urgencia.

### 5.2 Patrón recomendado: IA asistida por reglas

Arquitectura de decisión híbrida:

- Reglas deterministas para triggers, umbrales, rate-limits, escalado.
- LLM para redacción, síntesis, etiquetado semántico y propuestas.

Nunca delegar al LLM decisiones de seguridad o cambios críticos sin validación.

### 5.3 Diseño de prompts (orientación operativa)

Estructura sugerida de prompt de producción:

- **Rol**: “Eres un asistente operativo de delivery para equipo Scrum.”
- **Contexto estructurado**: ticket, MR, pipeline, SLA, sprint day.
- **Objetivo**: “Genera mensaje corto con riesgo + acción concreta.”
- **Restricciones**: longitud máxima, no inventar datos, tono neutral.
- **Formato de salida**: JSON validable (`risk_level`, `summary`, `actions[]`).

### 5.4 Tooling del agente

Herramientas internas expuestas al agente:

- `get_issue(issue_key)`
- `get_mr(mr_id)`
- `search_stale_tickets(sprint_id)`
- `post_teams_message(channel, payload)`
- `comment_jira(issue_key, text)`
- `update_issue_status(issue_key, transition)` [con aprobaciones]

### 5.5 Guardrails y control de calidad

- Validación de esquema JSON antes de ejecutar acción.
- Filtros de lenguaje para evitar conclusiones categóricas sin evidencia.
- Deduplicación temporal (no repetir alerta igual en ventana corta).
- Límite de notificaciones por persona/día.
- “Confidence threshold”: si baja confianza, pedir confirmación humana.

### 5.6 Prevención de alucinaciones

- RAG sobre datos internos en tiempo real (no memoria libre del modelo).
- Prohibir invención de IDs/estados.
- Respuestas citando entidades concretas (ticket, MR, pipeline ID).
- Fallback a respuesta determinista cuando falte contexto.

### 5.7 Política anti-spam

Modelo de prioridad:

- **P0**: bloqueo crítico de entrega / producción.
- **P1**: riesgo alto de sprint.
- **P2**: higiene operativa importante.
- **P3**: recomendaciones informativas.

Solo P0/P1 interrumpen. P2/P3 se agrupan en resúmenes.

### 5.8 Feedback loop

Cada notificación en Teams incorpora reacción rápida:

- ✅ útil
- 🔕 demasiado ruido
- ❌ incorrecto

Se usan para recalibrar reglas y prompts semanalmente.

---

## 6) Automatizaciones recomendadas (priorizadas por impacto)

### 6.1 Criterio de priorización

Se prioriza por matriz:

- Impacto operacional
- Facilidad de implementación
- Riesgo de error
- Dependencia de cambio cultural

### 6.2 Top 12 automatizaciones

#### A1. Resumen pre-daily automático (alto impacto, baja complejidad)
- Fuente: Jira + GitLab.
- Salida: Teams canal squad.
- Beneficio: reduce tiempo de sincronización y foco difuso.

#### A2. Detección de tickets estancados con recordatorio contextual
- Fuente: Jira + actividad GitLab.
- Salida: DM Teams + consolidado PM.
- Beneficio: evita acumulación silenciosa de deuda de proceso.

#### A3. Alerta inteligente de pipeline fallida
- Fuente: GitLab webhook.
- Salida: canal técnico / squad según severidad.
- Beneficio: menor MTTR de problemas de entrega.

#### A4. Resumen de MR para acelerar code review
- Fuente: GitLab MR diff + metadata.
- Salida: comentario en MR + Teams.
- Beneficio: reduce tiempo para entender cambios grandes.

#### A5. Sincronización Jira ↔ GitLab en eventos clave
- Ejemplo: MR merged → transición Jira a “Ready for QA”.
- Beneficio: consistencia de estado sin trabajo manual.

#### A6. Reporte de mitad de sprint con predicción de riesgo
- Fuente: Jira velocity + throughput actual.
- Beneficio: correcciones tempranas, menos sorpresas al cierre.

#### A7. Cola de revisiones y rebalanceo de reviewers
- Fuente: MRs abiertas + SLA de revisión.
- Beneficio: evita cuellos de botella personales.

#### A8. Alertas de dependencia inter-equipo
- Fuente: vínculos Jira y etiquetas dependencia.
- Beneficio: escalado anticipado de bloqueos externos.

#### A9. Weekly executive digest para dirección
- Fuente: KPIs agregados + riesgos.
- Beneficio: visibilidad sin microgestión.

#### A10. Checklist automático QA readiness
- Fuente: Jira + MR + pipeline.
- Beneficio: menor retrabajo entre Dev y QA.

#### A11. Seguimiento de SLA de respuesta en tickets críticos
- Beneficio: disciplina operacional y foco en prioridades reales.

#### A12. Detección de riesgo de scope creep en sprint
- Fuente: entradas tardías + cambios de estimación.
- Beneficio: protege predictibilidad.

### 6.3 Automatizaciones por herramienta

#### Jira
- Señales de estancamiento.
- Propuestas de transición de estado.
- Comentarios automáticos de contexto.
- Score de salud por ticket.

#### GitLab
- Etiquetado de MRs por riesgo/tamaño.
- Notificación por pipeline y cobertura.
- Recordatorios de revisión por SLA.

#### Teams
- Adaptive cards para acciones rápidas.
- Digest diarios/semanales por audiencia.
- Escalado por menciones inteligentes.

#### Cruzadas
- Correlación ticket-MR-pipeline.
- Actualización de estado automática con validación.
- Alertas de dependencia y bloqueo compartidas.

---

## 7) Uso de Microsoft Teams Workflows

### 7.1 Dónde encaja Teams Workflows

Teams Workflows (Power Automate) permite cubrir rápido automatizaciones ligeras sin desarrollo profundo, ideal para:

- Notificaciones simples.
- Formularios de confirmación.
- Puentes entre eventos y acciones estándar.

Skynet debe usar Workflows como capa complementaria, no sustituto del core.

### 7.2 Patrones recomendados

1. **Webhook → Workflow → Canal Teams** para eventos informativos.
2. **Adaptive Card con botones** que llama endpoint Skynet.
3. **Workflow de aprobación** para acciones sensibles (ej. transición masiva).

### 7.3 Casos concretos con Workflows

- Pipeline fallida crítica crea tarjeta con botones:
  - “Asignar owner”
  - “Abrir incidente”
  - “Silenciar 30 min”

- Ticket bloqueado >48h dispara workflow de escalado:
  - Notifica a PM + Lead
  - Solicita causa raíz y ETA.

- Resumen semanal de squad publicado automáticamente los viernes 16:00.

### 7.4 Gobernanza de Workflows

- Catálogo central de flujos activos.
- Owner por flujo y caducidad/revisión trimestral.
- Nombres estandarizados (`SKY_[SQUAD]_[OBJETIVO]_[VERSION]`).
- Logs de ejecución y tasa de error.

---

## 8) Roadmap de implementación realista

### 8.1 Estrategia por fases (6 meses)

#### Fase 0 (Semana 1–2): Descubrimiento y baseline

Objetivos:
- Mapear proceso actual y dolores cuantificados.
- Definir KPIs base (tiempos, bloqueos, ruido).
- Alinear políticas de seguridad y gobierno.

Entregables:
- Documento de arquitectura inicial.
- Matriz de automatizaciones priorizadas.
- Plan de acceso API y permisos.

#### Fase 1 (Semana 3–6): MVP operativo

Alcance MVP:
- Ingesta de eventos GitLab (MR + pipeline).
- Lectura Jira para correlación básica.
- Publicación en Teams de 3 automatizaciones:
  1) Pre-daily digest
  2) Pipeline fail alert
  3) Ticket estancado alert

Criterio de éxito:
- >85% de eventos procesados correctamente.
- Feedback útil >70% en notificaciones.

#### Fase 2 (Semana 7–10): Sincronización y acciones

- Comentarios automáticos en Jira/MR.
- Reglas de escalado por SLA.
- Adaptive cards con acción rápida.
- Consola mínima de configuración de umbrales.

#### Fase 3 (Semana 11–16): Inteligencia de riesgo y negocio

- Predicción de riesgo de sprint.
- Digest ejecutivo semanal.
- Métricas por squad y comparativas.
- Ajuste fino de ruido/señal.

#### Fase 4 (Semana 17–24): Escalado y estandarización

- Extensión a otros equipos/proyectos.
- Hardening seguridad/compliance.
- Playbook operativo y handover.
- Modelo de mejora continua mensual.

### 8.2 Recursos sugeridos

Equipo núcleo (mínimo):
- 1 Product Owner interno (50%).
- 1 Tech Lead backend/integraciones.
- 1 Engineer full-stack/platform.
- 1 DevOps parcial.
- 1 representante PM/Scrum.

### 8.3 Riesgos de implementación del roadmap

- Intentar automatizar demasiado pronto.
- Falta de ownership por squad.
- Desalineación entre proceso real y reglas automatizadas.
- Ausencia de mecanismo formal de feedback.

---

## 9) Riesgos y buenas prácticas

### 9.1 Riesgos principales

1. **Sobrenotificación** que genere fatiga.
2. **Acciones incorrectas automáticas** por datos ambiguos.
3. **Dependencia excesiva del bot** en vez de disciplina de equipo.
4. **Exposición de datos sensibles** en canales abiertos.
5. **Deriva de reglas/prompts** sin control de cambios.

### 9.2 Buenas prácticas operativas

- Lanzar con “modo sugerencia” antes de “modo acción”.
- Medir precisión de cada automatización por separado.
- Revisar semanalmente falsas alertas.
- Definir “horarios de silencio” para alertas no críticas.
- Mantener catálogo vivo de reglas y owners.

### 9.3 Seguridad y gobierno

- RBAC por rol y equipo.
- Registro de auditoría inmutable de acciones del bot.
- Revisión de permisos trimestral.
- DLP para evitar publicación de secretos en mensajes.
- Comité ligero de gobierno (PM + Lead + Security + Platform).

### 9.4 Gestión de errores

- Retries exponenciales para APIs externas.
- Dead-letter queue para eventos fallidos.
- Alertas operativas cuando backlog de cola crece.
- Fallback manual documentado por tipo de fallo.

### 9.5 Ética y transparencia

- Marcar siempre cuándo una recomendación fue generada por IA.
- Permitir opt-out temporal por usuario/canal.
- Explicabilidad mínima de decisiones (“se detectó por X e Y”).

---

## 10) Métricas de éxito (KPI / OKR operativos)

### 10.1 KPIs de eficiencia operativa

- Horas semanales de PM dedicadas a seguimiento manual.
- Tiempo de preparación de daily/reporte.
- % tickets con estado actualizado correctamente.

### 10.2 KPIs de flujo de delivery

- Lead time de ticket (In Progress → Done).
- Tiempo medio en estado bloqueado.
- Throughput por sprint.
- Ratio compromiso vs completado.

### 10.3 KPIs de calidad de coordinación

- Tiempo de primera revisión de MR.
- MRs pendientes >48h.
- MTTR de pipelines fallidas.
- % handoff QA rechazados por falta de checklist.

### 10.4 KPIs de adopción y percepción

- Tasa de interacción con mensajes del bot.
- Feedback útil/no útil por automatización.
- Tasa de silenciamiento o queja por ruido.

### 10.5 Objetivos iniciales (primer trimestre)

- Reducir 30% tiempo administrativo de PM.
- Reducir 20% tickets estancados >72h.
- Reducir 25% tiempo de respuesta a pipeline fallida.
- Lograr >75% valoración útil de notificaciones P1/P2.

---

## 11) Propuesta de negocio y business case inicial (empresa mediana)

### 11.1 Hipótesis financiera de referencia

Supuestos conservadores para equipo de 20 personas:

- 2 PM/Scrum roles con coste empresa medio anual 65k–80k EUR.
- 14–16 perfiles técnicos con coste medio anual 55k–75k EUR.
- Tiempo operativo no productivo por coordinación: 8–15%.

Si Skynet reduce solo 4–6 puntos de esa fricción, el ahorro/capacidad recuperada es relevante.

### 11.2 Modelo de valor

**Valor directo:**
- Menos horas administrativas repetitivas.
- Menor retrabajo por desalineaciones.
- Menor tiempo de espera por bloqueos/revisiones.

**Valor indirecto:**
- Mejor previsibilidad ante negocio.
- Menor desgaste del equipo.
- Mejor capacidad de escalar sin añadir coordinación proporcional.

### 11.3 Estimación simple de ROI (12 meses)

Ejemplo conservador:

- Capacidad recuperada PM: 10 h/semana total x 48 sem = 480 h.
- Capacidad recuperada dev por fricción menor: 25 h/semana total x 48 = 1200 h.
- Total: 1680 h/año.

Con coste medio blended 45 EUR/h:
- Valor recuperado ≈ 75,600 EUR/año.

Coste estimado proyecto año 1:
- Implementación (personas + setup): 35,000–55,000 EUR.
- Operación/mantenimiento: 15,000–25,000 EUR.
- Total año 1: 50,000–80,000 EUR.

Resultado:
- ROI probable positivo en 9–15 meses según adopción y alcance.

### 11.4 Escenarios de negocio

- **Escenario prudente:** adopción parcial, ROI cercano al break-even en 12 meses.
- **Escenario objetivo:** automatizaciones clave adoptadas, ROI 20–40% en año 1.
- **Escenario alto impacto:** expansión multi-squad, ROI >50% en año 2.

### 11.5 Costes no financieros

- Cambio cultural de trabajo con señales automáticas.
- Necesidad de disciplina en nomenclatura Jira/GitLab.
- Curva de ajuste de ruido en primeras 6–8 semanas.

### 11.6 Recomendación ejecutiva

Aprobar Skynet con enfoque por fases, gate de valor al final de cada fase y criterio estricto de “automatización solo si demuestra impacto”.

---

## 12) Diseño detallado de datos, reglas y decisiones

### 12.1 Diccionario mínimo de datos

Para que Skynet no sea genérico, se recomienda configurar explícitamente:

- Estados Jira válidos por flujo real de la empresa.
- Definición de “estancado” por tipo de ticket.
- Umbrales SLA por prioridad.
- Repositorios críticos vs no críticos.
- Canales Teams por squad y por severidad.

### 12.2 Reglas ejemplo (pseudo)

```text
RULE_STALE_TICKET:
IF jira.status IN ["In Progress", "In Review"]
AND jira.last_transition_at > 72h
AND gitlab.commits_last_72h = 0
THEN signal.stale_score = HIGH
ACTION: dm_assignee + include in pre_daily_digest
```

```text
RULE_PIPELINE_CRITICAL:
IF pipeline.status = FAILED
AND pipeline.branch = "main"
AND issue.priority IN ["High", "Critical"]
THEN severity = P0
ACTION: teams_alert(channel_incidents) + mention(oncall_lead)
```

### 12.3 Matriz de decisión de notificación

- Notificar a **individuo** cuando la acción es personal y concreta.
- Notificar a **canal** cuando la acción requiere coordinación colectiva.
- Escalar a **PM/Lead** cuando hay riesgo de sprint/cliente.

### 12.4 Política de frecuencia

- Máximo 3 notificaciones P2 por usuario/día.
- P3 solo en digest.
- Ventana de supresión para eventos repetidos (ej. 30 min).

### 12.5 Modelo de puntaje de riesgo

`risk_score = (blocked_weight * blocked_days) + (sla_weight * overdue) + (dependency_weight * external_dependency) + (quality_weight * failed_pipeline)`

Se calibran pesos por histórico del equipo.

---

## 13) Operación diaria sugerida (runbook)

### 13.1 Cadencia diaria

- 07:45 — Digest pre-daily por squad.
- 09:30–18:00 — Alertas en tiempo real (P0/P1).
- 13:00 — Mini-check de tickets estancados.
- 17:30 — Resumen de cierres y riesgos para mañana.

### 13.2 Cadencia semanal

- Miércoles: informe de mitad de sprint.
- Viernes: digest ejecutivo.
- Retro: revisión de precisión de automatizaciones.

### 13.3 Roles operativos

- **Owner de Skynet (Product/Platform):** prioriza backlog de automatizaciones.
- **Tech Owner:** mantiene reglas/integraciones.
- **Scrum/PM:** valida utilidad real y ajustes de señal.

---

## 14) Plan de adopción cultural

### 14.1 Principio

Sin adopción, no hay valor. El rollout debe gestionar comportamiento, no solo tecnología.

### 14.2 Estrategia de adopción

1. Piloto con 1 squad y champions internos.
2. Capacitación breve por rol (dev, PM, lead).
3. Manual de “qué esperar del bot” y “cómo dar feedback”.
4. Revisión quincenal de ruido/valor.

### 14.3 Señales de buena adopción

- El equipo usa acciones rápidas en Teams.
- Se reducen pings manuales del PM.
- Se corrigen estados Jira proactivamente.

---

## 15) Gobierno de producto Skynet

### 15.1 Backlog del propio Skynet

Gestionar Skynet como producto interno:

- Features por impacto medible.
- Bugs de calidad de señal.
- Deuda técnica de integraciones.
- Mejora de prompts/reglas.

### 15.2 Comité mensual de evolución

Participantes: Engineering Manager, PM principal, Security, Platform, representante de devs.

Revisa:
- KPIs vs baseline.
- Nuevas automatizaciones candidatas.
- Incidentes y lecciones.
- Decisiones de escalado.

### 15.3 Política de cambios

- Reglas/prompts versionados en Git.
- Pull request obligatoria con test de regresión.
- Feature flags para activar por squad.

---

## 16) Arquitectura de pruebas y calidad

### 16.1 Tipos de pruebas

- Unit tests para reglas deterministas.
- Contract tests contra APIs Jira/GitLab/Teams.
- Integration tests de flujo end-to-end.
- Prompt regression tests con casos dorados.

### 16.2 Dataset de validación

- Casos reales anonimizados de sprints anteriores.
- Etiquetas humanas sobre “alerta útil/no útil”.
- Escenarios extremos: avalancha de pipelines fallidas, tickets huérfanos.

### 16.3 SLOs operativos del sistema

- Disponibilidad de procesamiento de eventos: 99.5%.
- Latencia p95 de alerta crítica: <90 segundos.
- Error rate de acciones automáticas: <1%.

---

## 17) Integración técnica detallada por API

### 17.1 Jira

Endpoints de referencia (conceptual):
- búsqueda issues (JQL)
- transiciones
- comentarios
- sprints/boards

Patrones:
- cache de metadatos (estados/transiciones)
- reintentos con backoff
- reconciliación nocturna para detectar desvíos

### 17.2 GitLab

Entradas:
- webhooks de MR, pipelines, notes
- consultas puntuales para enrich de contexto

Salida:
- comentarios en MR
- etiquetas automáticas
- lectura de cobertura / estado jobs

### 17.3 Teams

- Bot app para mensajes y tarjetas.
- Workflows para aprobación/acciones ligeras.
- Webhooks entrantes para digest.

---

## 18) Recomendación de stack tecnológico

Stack sugerido (ejemplo pragmático):

- Backend: Node.js (NestJS) o Python (FastAPI).
- Cola: RabbitMQ o SQS.
- DB: PostgreSQL + Redis.
- Scheduler: Temporal/BullMQ.
- Observabilidad: OpenTelemetry + Grafana/Loki.
- Infra: Kubernetes o servicios gestionados según madurez.

Criterio de elección: habilidades internas y coste de operación.

---

## 19) Matriz de riesgos con mitigación

| Riesgo | Probabilidad | Impacto | Mitigación |
|---|---:|---:|---|
| Ruido excesivo en Teams | Media | Alta | rate-limit + digest + feedback loop |
| Acción automática incorrecta | Baja/Media | Alta | modo sugerencia + approvals |
| Fallo de API externa | Media | Media | retries + DLQ + fallback manual |
| Baja adopción del equipo | Media | Alta | champions + quick wins + formación |
| Exposición de datos sensibles | Baja | Muy alta | RBAC + DLP + revisión seguridad |

---

## 20) Plan de inversión inicial y operación

### 20.1 Inversión inicial (aproximada)

- Diseño + implementación MVP: 6–10 semanas.
- Costo estimado: 35k–55k EUR según recursos internos/externos.

### 20.2 Operación continua

- 0.5–1 FTE para mantenimiento y evolución.
- Costo anual 15k–25k EUR (sin contar infra compleja).

### 20.3 Decisión recomendada

Avanzar con un piloto controlado de 10 semanas con gate de continuidad basado en KPIs:

1. reducción de carga PM,
2. mejora en tiempos de bloqueo,
3. satisfacción del equipo respecto a utilidad de alertas.

---

## 21) Blueprint de implementación (primeros 90 días)

### Días 1–15
- Levantar baseline métrico.
- Configurar accesos API y secretos.
- Definir diccionario de estados/umbrales.

### Días 16–45
- Construir ingestion + core correlación.
- Activar 3 automatizaciones MVP.
- Instrumentar observabilidad y auditoría.

### Días 46–75
- Incorporar Adaptive cards y acciones rápidas.
- Ajustar prioridades de alerta por feedback.
- Publicar informe de mitad de sprint automático.

### Días 76–90
- Ejecutar evaluación de ROI preliminar.
- Decidir expansión a más squads.
- Formalizar governance y backlog v2.

---

## 22) Ejemplos de mensajes operativos (plantillas)

### 22.1 Pipeline fallida crítica

> 🔴 **Pipeline fallida en `main`** (Repo: payments-api)  
> Ticket asociado: SKY-482 (Prioridad Alta)  
> Impacto: Bloquea entrega del Sprint 14  
> Siguiente acción sugerida: @oncall-backend revisar job `integration-tests` (error en migración).  
> ETA de actualización: 30 min.

### 22.2 Ticket estancado

> 🟠 **Ticket estancado SKY-451**  
> Estado: In Progress (sin movimiento 76h)  
> Dependencia detectada: respuesta de equipo Data  
> Acción sugerida: marcar bloqueo formal + escalar dependencia en canal #squad-payments.

### 22.3 Digest pre-daily

> **Resumen pre-daily — Squad Payments**  
> - 2 bloqueos activos (>48h)  
> - 3 MRs listas sin reviewer asignado  
> - 1 pipeline crítica fallando en `main`  
> - Riesgo sprint: Medio-Alto (probabilidad de no completar SKY-482)  
> Recomendación: reasignar revisión de MR !219 y acordar plan de contingencia para SKY-482.

---

## 23) Qué NO automatizar al inicio

- Cambios de prioridad Jira sin aprobación.
- Cierre automático de tickets por inferencia.
- Asignación de responsables en incidentes críticos sin validación.
- Mensajes fuera de horario para eventos no críticos.

Empezar simple evita pérdida de confianza.

---

## 24) Conclusiones ejecutivas

Skynet tiene potencial de convertirse en una capacidad estratégica interna: no solo un bot de alertas, sino una plataforma de coordinación inteligente que reduce fricción y mejora entrega. El éxito dependerá menos del modelo de IA y más de tres factores: diseño de proceso, calidad de integración y disciplina de gobierno.

Para una empresa mediana, la recomendación es implementar por fases con foco en quick wins medibles. Las primeras automatizaciones deben apuntar a donde hoy se pierde más tiempo: preparación de estado, seguimiento de bloqueos y reacción ante fallas de pipeline. Si en 10 semanas se demuestra mejora tangible en estos frentes, escalar Skynet será una decisión de negocio sólida.

En resumen, Skynet es viable técnica y económicamente si se ejecuta como producto interno con métricas, ownership claro y control de ruido. La IA aporta valor real cuando opera sobre datos vivos del flujo de trabajo y cuando cada intervención llega en el contexto correcto con una acción concreta.

---

## 25) Anexo A — Backlog inicial de épicas y features

### Épica E1: Event Ingestion
- F1. Webhook receptor GitLab
- F2. Polling Jira incremental
- F3. Normalización canónica de eventos

### Épica E2: Alertas MVP
- F4. Pre-daily digest
- F5. Pipeline fail alerts
- F6. Ticket staleness reminders

### Épica E3: Action Layer
- F7. Comentario automático Jira/MR
- F8. Adaptive cards Teams
- F9. Aprobaciones para acciones sensibles

### Épica E4: Intelligence Layer
- F10. Resumen MR con IA
- F11. Clasificación de bloqueos
- F12. Predicción riesgo sprint

### Épica E5: Governance & Analytics
- F13. Panel de métricas
- F14. Auditoría y trazabilidad
- F15. Gestión de umbrales y feature flags

---

## 26) Anexo B — KPI baseline template

Antes de arrancar, capturar 4 semanas históricas:

- Horas PM en seguimiento manual por semana.
- Nº tickets estancados >72h por sprint.
- Tiempo medio de revisión de MR.
- MTTR de pipelines fallidas.
- Ratio compromiso/completado sprint.
- Percepción del equipo (encuesta rápida 1–5).

Con baseline, el impacto deja de ser subjetivo.

---

## 27) Anexo C — Plan de comunicación interna del proyecto

### Audiencias
- Dirección
- PM/Scrum
- Desarrollo/QA
- Seguridad/IT

### Mensajes clave
- Skynet no vigila personas; mejora flujo.
- Se mide valor real, no actividad del bot.
- Habrá fase piloto con ajustes por feedback.

### Hitos de comunicación
- Kickoff
- Demo MVP semana 6
- Informe de valor semana 10
- Decisión de escalado semana 12

---

## 28) Anexo D — Checklist de readiness para pasar a producción

- [ ] Secretos en vault y rotación activa
- [ ] Logs y métricas operativas visibles
- [ ] Feature flags por automatización
- [ ] Runbook de incidentes documentado
- [ ] Aprobación Security y Data Owner
- [ ] Entrenamiento básico de usuarios completado
- [ ] Plan de rollback validado

---

## 29) Profundización técnica: arquitectura lógica por dominios

Para garantizar que Skynet sea mantenible a medio plazo, conviene separar claramente los dominios funcionales y técnicos. Esta separación evita un “monolito de automatizaciones” difícil de evolucionar y permite que nuevos casos de uso se incorporen sin romper los existentes.

### 29.1 Dominio de identidad y permisos

Este dominio gestiona:
- Cuentas de servicio para Jira, GitLab y Teams.
- Mapeo de identidades entre sistemas (ej. correo corporativo ↔ usuario Jira ↔ usuario GitLab ↔ usuario Teams).
- Matrices de permisos por tipo de acción.

Problema real a resolver: muchos equipos fallan en automatización porque no tienen una identidad unificada. Cuando el agente detecta que un ticket pertenece a “Juan Pérez” en Jira pero en GitLab figura como `jperez-dev`, la correlación se rompe. Para Skynet, la calidad de esta capa define la calidad de todas las recomendaciones.

Implementación sugerida:
- Tabla `identity_map` con claves externas y nivel de confianza de mapeo.
- Proceso de reconciliación semanal con reporte de conflictos.
- Aprobación manual para emparejamientos ambiguos.

### 29.2 Dominio de ingestión y validación de eventos

No todos los eventos entrantes deben pasar al núcleo. Es clave filtrar, validar firma, deduplicar y normalizar temprano.

Puntos críticos:
- Validar firmas HMAC de webhooks para evitar inyección.
- Detectar reenvíos duplicados por reintentos del proveedor.
- Mantener orden lógico de eventos cuando sea necesario (por ejemplo, pipeline update antes de pipeline finalization).

Buenas prácticas:
- `event_id` global + `source_event_id` por proveedor.
- Ventana de deduplicación configurable (ej. 10 minutos para pipelines).
- Versionado de esquema de evento (`event_schema_version`).

### 29.3 Dominio de contexto operativo

Este dominio crea el “estado vivo” del trabajo:
- Sprint actual por equipo.
- Tickets activos por status y prioridad.
- MRs abiertas, reviewers, edad y pipeline.
- Bloqueos y dependencias vigentes.

Sin este dominio, la IA solo ve fragmentos. Con él, puede priorizar correctamente.

Patrón útil: mantener una vista materializada por squad que se refresque por eventos. Esto permite responder rápido para digest y alertas sin consultas costosas en vivo.

### 29.4 Dominio de decisión y política

El motor de decisión no debe estar “hardcodeado” en múltiples servicios. Debe existir un dominio central de políticas:
- Umbrales de estancamiento por tipo de ticket.
- Políticas de escalado por severidad.
- Horarios de silencio.
- Restricciones por rol.

Sugerencia: modelar políticas como configuración versionada en Git y cargada dinámicamente con validación. Así, cambiar una regla no implica despliegue completo.

### 29.5 Dominio de comunicación y experiencia

La calidad percibida de Skynet depende en gran medida de cómo comunica:
- Mensajes con contexto mínimo suficiente.
- Enlaces directos a acción.
- Lenguaje no ambiguo.
- Prioridad visible.

Diseño recomendado de mensaje:
1. Qué pasó.
2. Por qué importa.
3. Qué hacer ahora.
4. En cuánto tiempo.

### 29.6 Dominio analítico y mejora continua

Este dominio consolida métricas de desempeño del propio Skynet:
- precisión de alertas,
- latencias,
- acciones aceptadas/rechazadas,
- feedback de utilidad,
- ratio de falsas alarmas.

Sin medición de calidad, el sistema se degrada lentamente y el equipo pierde confianza.

---

## 30) Modelo operativo por rol (RACI práctico)

Un error común en iniciativas de automatización es no definir responsabilidades. A continuación, un RACI operativo recomendado para Skynet.

### 30.1 Dirección / Sponsor

**Responsable de:**
- Asegurar presupuesto y prioridad transversal.
- Definir objetivos de negocio medibles.
- Resolver bloqueos inter-área.

**No debe hacer:**
- Microgestionar configuración técnica.

### 30.2 Product Owner de Skynet

**Responsable de:**
- Priorizar backlog de automatizaciones.
- Traducir dolor operativo a features concretas.
- Definir criterios de aceptación y métricas.

**Aporta valor cuando:**
- evita automatizar cosas “bonitas” sin ROI.

### 30.3 Tech Lead de Plataforma

**Responsable de:**
- Arquitectura técnica y decisiones de stack.
- Calidad de integraciones y resiliencia.
- Seguridad, observabilidad y mantenibilidad.

### 30.4 PM / Scrum Master del equipo piloto

**Responsable de:**
- Validar utilidad real de notificaciones.
- Ajustar cadencias y formatos.
- Incorporar Skynet al ritual Scrum sin fricción.

### 30.5 Developers / QA

**Responsable de:**
- Usar acciones rápidas y feedback de calidad.
- Mantener convenciones mínimas (clave Jira en MR/commit).
- Reportar falsas alertas y gaps de contexto.

### 30.6 Security / IT

**Responsable de:**
- Revisar permisos y exposición de datos.
- Aprobar controles de cumplimiento.
- Auditar accesos y retención de logs.

---

## 31) Casuística avanzada de uso en entorno Scrum de 20 personas

### 31.1 Escenario realista: sprint con dependencia externa

Contexto:
- Squad A (8 personas) depende de un endpoint del equipo Data (Squad B).
- Ticket SKY-611 no puede cerrarse hasta recibir contrato final.
- El sprint tiene objetivo comprometido al negocio.

Comportamiento esperado de Skynet:
1. Detecta comentarios de dependencia y ausencia de progreso técnico.
2. Clasifica bloqueo como “externo inter-equipo”.
3. Notifica al canal de Squad A con recomendación de escalado formal.
4. Crea automáticamente una tarea de seguimiento para PM.
5. Si pasan 24h sin respuesta de Squad B, eleva a Engineering Manager.

Resultado:
- Se reduce el tiempo muerto por espera no visible.
- La conversación pasa de informal a trazable.

### 31.2 Escenario: sobrecarga de code review

Contexto:
- Semana final de sprint.
- 9 MRs abiertas, 4 con más de 2 días sin revisión.
- Reviewer principal saturado.

Skynet:
- Detecta cuello de botella de reviewer.
- Sugiere redistribución basada en ownership histórico.
- Genera mensaje de coordinación con prioridad y SLA.
- Marca riesgo de cierre del sprint en digest.

Resultado:
- Se evita que revisión sea el cuello final de entrega.

### 31.3 Escenario: “todo está en progreso”

Contexto clásico en Jira:
- Muchos tickets en In Progress.
- Pocos en Done.
- Work in progress descontrolado.

Skynet:
- Calcula WIP por persona y por squad.
- Detecta umbral excedido.
- Recomienda política de foco (cerrar antes de abrir nuevos).
- Informa al PM sobre riesgo de multitarea improductiva.

### 31.4 Escenario: pipeline inestable recurrente

Contexto:
- El mismo job falla intermitente 5 veces en una semana.

Skynet:
- Agrupa incidentes similares.
- Evita 5 alertas separadas y genera un solo caso de “inestabilidad sistémica”.
- Sugiere acción estructural (hardening de tests o infraestructura).

Resultado:
- Se ataca causa raíz y no solo síntomas.

---

## 32) Diseño de datos extensivo para trazabilidad y analítica

### 32.1 Esquema base recomendado (conceptual)

Tablas principales:
- `events_raw`
- `events_normalized`
- `entities_issue`
- `entities_mr`
- `entities_pipeline`
- `risk_signals`
- `notifications`
- `notification_feedback`
- `automation_runs`
- `policy_versions`

### 32.2 Campos críticos por tabla

`events_raw`:
- id, source, received_at, signature_valid, payload_hash, payload_json

`events_normalized`:
- id, source_event_id, event_type, happened_at, entity_refs, normalized_json

`risk_signals`:
- signal_id, issue_key, mr_id, signal_type, score, confidence, generated_at

`notifications`:
- notification_id, channel_type, channel_target, priority, dedupe_key, status, sent_at

`notification_feedback`:
- notification_id, user_id, feedback_type (useful/noisy/wrong), created_at, notes

### 32.3 Métrica de “calidad de señal”

Definición sugerida:

`signal_quality = (useful_feedback / total_feedback) - (wrong_feedback / total_feedback)`

Interpretación:
- >0.5: señal fuerte
- 0.2–0.5: aceptable
- <0.2: revisar reglas/prompt

### 32.4 Retención de datos

Política recomendada:
- `events_raw`: 90 días (o menos si compliance exige).
- `events_normalized`: 180 días.
- `metrics_aggregated`: 24 meses.

Racional: preservar analítica útil sin acumular datos sensibles innecesariamente.

---

## 33) Diseño de prompts y evaluación del agente IA en producción

### 33.1 Biblioteca de prompts por tarea

Separar prompts por intención:
- `prompt_mr_summary_vX`
- `prompt_blocker_classifier_vX`
- `prompt_daily_digest_vX`
- `prompt_exec_summary_vX`

Cada prompt debe tener:
- owner,
- versión,
- changelog,
- fecha de activación,
- métricas antes/después.

### 33.2 Evaluación continua

No basta “funciona en demo”. En producción se requiere:
- benchmark semanal con casos etiquetados.
- tasa de exactitud por tipo de salida.
- análisis de errores frecuentes.

### 33.3 Pruebas de regresión de prompts

Antes de desplegar una versión nueva:
- correr set de 100 casos históricos.
- validar que no empeora precisión en escenarios críticos.
- activar inicialmente en modo sombra para 10% de eventos.

### 33.4 Estrategia de fallback

Cuando el LLM falla, timeout o baja confianza:
- usar plantillas deterministas básicas.
- priorizar continuidad del proceso sobre sofisticación.

Ejemplo:
- si no hay resumen inteligente de MR, publicar resumen estructurado mínimo: ficheros tocados, tamaño diff, estado pipeline, reviewers pendientes.

---

## 34) Diseño de automatizaciones cruzadas Jira-GitLab-Teams en detalle

### 34.1 Automatización cruzada C1: apertura de MR sin ticket vinculado

Regla:
- Si MR no incluye clave Jira válida, comentar automáticamente con instrucción y bloquear merge opcionalmente según política.

Valor:
- mejora trazabilidad end-to-end.

### 34.2 Automatización cruzada C2: ticket en “In Review” sin MR activa

Regla:
- Si ticket está en revisión pero no existe MR abierta/actualizada en ventana reciente, alertar inconsistencia.

Valor:
- reduce estados engañosos en Jira.

### 34.3 Automatización cruzada C3: MR merged sin transición Jira

Regla:
- Tras merge, si ticket sigue en In Progress, proponer transición automática a Ready for QA.

Control:
- ejecución automática sólo si check de QA readiness pasa.

### 34.4 Automatización cruzada C4: pipeline rota y ticket crítico cercano a deadline

Regla:
- correlación de pipeline fail + due date ticket + prioridad alta.

Acción:
- alerta P0 con mención a on-call + PM + lead.
- card de decisión con opciones: rollback, hotfix, replan.

### 34.5 Automatización cruzada C5: cierre de sprint asistido

En último día de sprint:
- generar lista de tickets con probabilidad de no cierre.
- sugerir traspaso o división.
- preparar borrador de resumen de sprint para retro.

---

## 35) Equipamiento de observabilidad y soporte operativo

### 35.1 Dashboards imprescindibles

1. **Salud de integración**
   - eventos/min,
   - errores por API,
   - latencias por proveedor.

2. **Eficacia de automatizaciones**
   - alertas enviadas,
   - útiles vs ruido,
   - acciones completadas.

3. **Impacto de negocio**
   - horas PM ahorradas,
   - tickets estancados,
   - MTTR pipelines.

### 35.2 Alertas internas del sistema

Skynet debe monitorearse a sí mismo:
- cola acumulada > umbral,
- error rate webhook > 2%,
- latencia p95 > 120s,
- caída de feedback útil por debajo de 60%.

### 35.3 Runbook de incidentes de Skynet

Para cada incidente técnico:
- identificar tipo (ingestión, decisión, acción, comunicación).
- aplicar mitigación temporal.
- registrar postmortem.
- actualizar regla para prevenir recurrencia.

---

## 36) Seguridad, privacidad y cumplimiento: guía práctica

### 36.1 Clasificación de datos

Datos manejados por Skynet pueden incluir:
- identificadores de personas,
- contenido de comentarios internos,
- metadata de repositorios,
- potencialmente referencias a incidentes sensibles.

Clasificar datos en:
- público interno,
- sensible interno,
- restringido.

### 36.2 Controles mínimos

- secretos fuera de código,
- tokens con expiración corta,
- scopes mínimos por integración,
- cifrado en reposo y tránsito,
- registro de acceso administrativo.

### 36.3 Cumplimiento y auditoría

- conservar trazabilidad de decisiones automáticas,
- habilitar export de auditoría ante revisión,
- establecer política de retención y borrado.

### 36.4 Riesgo de fuga por mensajes

Mitigación:
- redacción segura (evitar volcar logs sensibles en Teams),
- detección de patrones secretos (tokens, passwords),
- revisión de canales destino (privado vs general).

---

## 37) Marco de buenas prácticas para evitar sobreautomatización

### 37.1 Síntomas de sobreautomatización

- El equipo ignora al bot por exceso de mensajes.
- Las personas dejan de pensar críticamente y siguen sugerencias sin criterio.
- Se automatizan excepciones raras en vez de problemas frecuentes.

### 37.2 Regla de oro

Automatizar sólo cuando se cumplen tres condiciones:
1. tarea repetitiva,
2. decisión de bajo/medio riesgo,
3. beneficio medible.

### 37.3 Ciclo de vida de una automatización

1. Propuesta (hipótesis + KPI).
2. Piloto en modo recomendación.
3. Medición de precisión y valor.
4. Activación parcial.
5. Revisión periódica o retiro.

### 37.4 “Kill switch” organizacional

Toda automatización debe poder desactivarse en segundos sin despliegue. Esto preserva la operación en caso de ruido o fallo.

---

## 38) Métricas avanzadas y cuadro de mando ejecutivo

### 38.1 Métricas de flujo profundo

- Aging WIP por percentiles (p50/p85/p95).
- Variabilidad de cycle time.
- Ratio de retrabajo (tickets reabiertos).
- Tiempo de espera entre “ready” y “started”.

### 38.2 Métricas de colaboración

- Tiempo de respuesta entre menciones críticas.
- Distribución de carga de revisión.
- Dependencias abiertas/cerradas por sprint.

### 38.3 Métricas de salud del sistema de IA

- Confidence promedio por tipo de recomendación.
- Tasa de fallback determinista.
- Drift de prompts (cambio de performance por versión).

### 38.4 Panel ejecutivo mensual

Debe responder 5 preguntas:
1. ¿Entregamos más valor con igual capacidad?
2. ¿Dónde perdemos tiempo hoy?
3. ¿Qué automatizaciones sí funcionan?
4. ¿Qué riesgos operativos crecen?
5. ¿Dónde invertir el próximo mes?

---

## 39) Plan de escalado multi-equipo

### 39.1 Estrategia de expansión

Después del piloto exitoso:
- Expandir a un segundo squad con perfil diferente.
- Mantener núcleo común + políticas específicas por equipo.
- Evitar copiar configuraciones sin adaptación.

### 39.2 Modelo federado

Core central + “perfiles de squad”:
- umbrales,
- canales,
- ownership,
- horarios,
- reglas opcionales.

### 39.3 Riesgos de escala

- inconsistencia entre equipos,
- sobrecarga de mantenimiento,
- pérdida de foco en valor.

Mitigación:
- catálogo estándar + excepciones justificadas.

---

## 40) Business case ampliado con sensibilidad

### 40.1 Variables de sensibilidad

El ROI depende de:
- nivel de adopción (bajo/medio/alto),
- calidad de datos fuente,
- disciplina operativa del equipo,
- alcance del despliegue.

### 40.2 Escenario bajo

- adopción 40%,
- ahorro anual 45k EUR,
- coste anual total 60k EUR,
- ROI negativo en año 1, positivo en año 2 si se corrigen problemas.

### 40.3 Escenario medio (recomendado)

- adopción 65%,
- ahorro anual 85k EUR,
- coste anual 65k EUR,
- ROI positivo desde mes 10–12.

### 40.4 Escenario alto

- adopción 80%+,
- ahorro anual 120k–150k EUR,
- coste 75k EUR,
- ROI robusto en año 1 y alto en año 2.

### 40.5 Indicador financiero clave para dirección

`Coste de coordinación evitado / coste de operación de Skynet`

Meta inicial razonable: >1.2 al cierre de 12 meses.

---

## 41) Plan de ejecución técnica detallado (sprints de implementación)

### Sprint técnico 1

- Infra base (repositorio, CI, entorno dev).
- Servicio receptor de webhooks.
- Persistencia de eventos raw.
- Observabilidad básica.

### Sprint técnico 2

- Normalización de eventos GitLab.
- Conector Jira lectura.
- Correlación ticket-MR inicial.
- Primer dashboard operativo.

### Sprint técnico 3

- Automatización A1, A2, A3 en modo recomendación.
- Integración Teams bot + cards simples.
- Métrica de feedback y deduplicación.

### Sprint técnico 4

- Acciones semi-automáticas con aprobación.
- Reglas de escalado.
- Reporte semanal ejecutivo.
- Hardening de seguridad.

### Sprint técnico 5

- Ajustes por feedback real.
- Pruebas de carga.
- Plan de expansión a segundo squad.

---

## 42) Catálogo de decisiones arquitectónicas (ADR sugeridas)

1. **ADR-001**: elección de cola de eventos.
2. **ADR-002**: modelo híbrido reglas + LLM.
3. **ADR-003**: formato canónico de eventos.
4. **ADR-004**: estrategia de deduplicación.
5. **ADR-005**: política de notificación por severidad.
6. **ADR-006**: retención de datos y cumplimiento.
7. **ADR-007**: enfoque de despliegue por feature flags.

Cada ADR debe incluir contexto, decisión, alternativas descartadas y consecuencias.

---

## 43) Guía de implementación de Teams Workflows paso a paso

### 43.1 Workflow tipo: alerta de bloqueo

1. Trigger HTTP desde Skynet.
2. Parse JSON del evento.
3. Condición: severidad >= P1.
4. Publicar Adaptive Card en canal de squad.
5. Capturar acción de usuario (confirmar, escalar, posponer).
6. Enviar callback a API Skynet para registrar decisión.

### 43.2 Workflow tipo: aprobación de acción automática

1. Skynet propone transición Jira sensible.
2. Workflow envía solicitud al PM.
3. PM aprueba/rechaza desde Teams.
4. Resultado ejecuta acción y queda auditado.

### 43.3 Recomendaciones de diseño

- Mensajes cortos y decisiones binarias.
- Evitar formularios largos.
- Mantener experiencia móvil usable.

---

## 44) Riesgos de adopción humana y mitigaciones de cambio

### 44.1 Objeción: “el bot me controla”

Respuesta de gestión:
- explicar que no mide productividad individual como fin,
- mostrar foco en flujo del equipo,
- compartir métricas agregadas, no ranking punitivo.

### 44.2 Objeción: “otro canal más”

Mitigación:
- consolidar en Teams, no abrir nuevas plataformas,
- desactivar notificaciones redundantes.

### 44.3 Objeción: “prefiero hacerlo manual”

Mitigación:
- demostrar ahorro real de tiempo,
- mantener opción humana en acciones sensibles,
- recoger y actuar sobre feedback rápido.

---

## 45) Buenas prácticas de ingeniería para longevidad del sistema

- Infra como código.
- Pruebas automáticas antes de producción.
- Contratos API versionados.
- Dependencias actualizadas y escaneo de seguridad.
- Documentación operativa viva.
- On-call claro para plataforma Skynet.

---

## 46) Checklist de decisiones para comité ejecutivo

Antes de aprobar fase de escalado:
- ¿Se cumplieron KPIs mínimos de piloto?
- ¿La percepción del equipo es positiva (>70%)?
- ¿El costo de mantenimiento está bajo control?
- ¿La gobernanza de datos pasó validación de seguridad?
- ¿Existe owner claro para evolución continua?

Si dos o más respuestas son “no”, mantener en fase de ajuste.

---

## 47) Cierre final

La oportunidad de Skynet no está en “hacer más notificaciones”, sino en convertir datos dispersos de Jira, GitLab y Teams en decisiones operativas rápidas, confiables y trazables. Implementado con foco y gobernanza, puede recortar fricción estructural, mejorar predictibilidad de entrega y liberar talento para trabajo de mayor valor.

Para una empresa mediana, el enfoque recomendado es incremental, medible y orientado a resultados de negocio desde el primer trimestre. El criterio clave es simple: cada automatización debe demostrar que ahorra tiempo, reduce riesgo o mejora la coordinación de forma verificable. Cuando eso se cumple de manera sostenida, Skynet deja de ser un experimento y se convierte en una capacidad competitiva interna.

Con arquitectura modular, gobierno de producto y métricas de valor, Skynet puede escalar desde un piloto operativo a una plataforma transversal de excelencia de delivery. En ese trayecto, la IA debe mantenerse al servicio del proceso y de las personas: ayudando a decidir mejor, antes y con menos fricción.

---

## 48) Apéndice técnico: ejemplos de contratos de evento (JSON de referencia)

> Nota: los siguientes contratos son de referencia conceptual para estandarizar comunicación entre servicios internos de Skynet.

### 48.1 Evento normalizado: `issue.stale.detected`

```json
{
  "event_id": "evt_01JXYZ...",
  "event_type": "issue.stale.detected",
  "source": "skynet.rules",
  "occurred_at": "2026-03-05T07:30:00Z",
  "schema_version": "1.0.0",
  "data": {
    "issue_key": "SKY-451",
    "project": "SKY",
    "status": "In Progress",
    "assignee": "juan.perez",
    "stale_hours": 76,
    "last_activity_at": "2026-03-02T03:10:00Z",
    "sprint": "Sprint 14",
    "signals": {
      "no_commits": true,
      "no_comments": true,
      "dependency_detected": true
    },
    "risk_score": 0.81,
    "confidence": 0.88
  },
  "trace": {
    "correlation_id": "corr_8f9...",
    "causation_id": "job_stale_scan_2026-03-05T07"
  }
}
```

### 48.2 Evento normalizado: `pipeline.failed.critical`

```json
{
  "event_id": "evt_01JXYZ...",
  "event_type": "pipeline.failed.critical",
  "source": "gitlab.webhook",
  "occurred_at": "2026-03-05T08:12:19Z",
  "schema_version": "1.0.0",
  "data": {
    "pipeline_id": 112345,
    "project": "payments-api",
    "branch": "main",
    "status": "failed",
    "failed_job": "integration-tests",
    "mr_id": 219,
    "issue_key": "SKY-482",
    "sprint": "Sprint 14",
    "priority": "High",
    "severity": "P0",
    "impact": "blocks sprint commitment"
  }
}
```

### 48.3 Evento de acción: `notification.sent`

```json
{
  "event_id": "evt_01JXYZ...",
  "event_type": "notification.sent",
  "source": "skynet.action",
  "occurred_at": "2026-03-05T08:12:25Z",
  "data": {
    "notification_id": "ntf_7781",
    "channel": "teams",
    "target": "#squad-payments",
    "priority": "P0",
    "template": "pipeline_critical_v2",
    "dedupe_key": "pipeline_112345_main_failed",
    "status": "delivered"
  }
}
```

Estos contratos son esenciales para que los servicios se desacoplen sin perder trazabilidad.

---

## 49) Apéndice de implementación organizacional: plan de entrenamiento por rol

### 49.1 Objetivo del entrenamiento

No se trata de enseñar “cómo funciona un LLM”, sino de asegurar que cada rol sabe:
- qué esperar de Skynet,
- cómo interactuar,
- cuándo confiar,
- cuándo escalar o corregir.

### 49.2 Módulos por rol

#### Módulo PM/Scrum (90 min)

Contenidos:
- Lectura de digest y score de riesgo.
- Gestión de bloqueos con tarjetas Teams.
- Ajuste de umbrales de ruido.
- Buenas prácticas de priorización apoyada por señales.

Objetivo concreto:
- reducir tiempo de seguimiento manual sin perder control.

#### Módulo Desarrollo (60 min)

Contenidos:
- Convenciones de trazabilidad Jira-GitLab.
- Uso de recordatorios y acciones rápidas.
- Interpretación de alertas de pipeline/MR.
- Proceso para reportar falsa alerta.

Objetivo concreto:
- integrar Skynet en flujo diario sin fricción.

#### Módulo Leads (75 min)

Contenidos:
- Lectura de métricas de cuello de botella.
- Escalado inteligente de riesgos.
- Priorización de mejoras del sistema.

Objetivo concreto:
- convertir señales operativas en decisiones de capacidad.

#### Módulo Seguridad/IT (60 min)

Contenidos:
- Permisos mínimos y rotación de secretos.
- Auditoría y retención de datos.
- Revisión de flujos sensibles.

Objetivo concreto:
- garantizar despliegue seguro y sostenible.

### 49.3 Formato y cadencia

- Semana de lanzamiento: sesiones en vivo + guía rápida.
- Semana 2 y 4: office hours de dudas.
- Mes 2: refresco focalizado según errores recurrentes.

---

## 50) Escenarios de contingencia y continuidad de negocio

### 50.1 Caída temporal de Jira API

Impacto:
- menor precisión de correlación y estatus.

Respuesta:
1. Entrar en modo degradado.
2. Continuar alertas GitLab/Teams críticas.
3. Reconciliar datos cuando Jira vuelva.
4. Marcar mensajes generados en modo parcial.

### 50.2 Caída temporal de GitLab webhooks

Impacto:
- pérdida de eventos near real-time.

Respuesta:
1. Activar polling de recuperación con ventana temporal.
2. Reconstituir eventos faltantes por API.
3. Evitar alertas duplicadas con dedupe hash.

### 50.3 Indisponibilidad de Teams

Impacto:
- no hay canal de notificación principal.

Respuesta:
1. Encolar notificaciones prioritarias.
2. Habilitar canal alterno (email interno o dashboard alert).
3. Reintentar publicación con política escalonada.

### 50.4 Error lógico en regla crítica

Impacto:
- spam o acciones incorrectas.

Respuesta:
1. Activar kill switch inmediato.
2. Revertir a versión previa de política.
3. Ejecutar análisis post-incidente.
4. Añadir test de regresión específico.

### 50.5 Recomendación de continuidad

Definir RTO/RPO internos para Skynet:
- RTO objetivo: <2 horas.
- RPO operativo: <15 minutos para eventos críticos.

Aunque Skynet no sea sistema transaccional principal, su disponibilidad impacta coordinación y tiempo de respuesta del equipo.

---

## 51) Guía de adopción por madurez organizacional

### 51.1 Empresa en madurez baja de proceso

Características:
- Jira desactualizado con frecuencia.
- Convenciones inconsistentes en GitLab.
- Daily más descriptiva que decisoria.

Recomendación:
- empezar con automatizaciones de higiene y trazabilidad.
- reforzar convenciones antes de modelos avanzados.
- no desplegar predicciones complejas todavía.

### 51.2 Empresa en madurez media

Características:
- proceso Scrum estable pero con cuellos de coordinación.
- métricas básicas disponibles.

Recomendación:
- implementar núcleo completo MVP.
- activar riesgo de sprint y rebalanceo de revisión.
- establecer governance mensual.

### 51.3 Empresa en madurez alta

Características:
- datos consistentes,
- prácticas DevOps maduras,
- cultura de mejora continua.

Recomendación:
- extender Skynet a planeación de capacidad,
- incorporar aprendizaje adaptativo de umbrales,
- explorar integración con catálogo de servicios y observabilidad productiva.

---

## 52) Recomendación final de decisión ejecutiva

### 52.1 Decisión propuesta

Aprobar implementación de Skynet con enfoque por fases, empezando por un piloto de 10 semanas en un squad representativo, condicionado a tres metas:

1. Reducción comprobable de carga administrativa de PM/Scrum.
2. Mejora en tiempo de resolución de bloqueos y fallas de pipeline.
3. Percepción positiva del equipo respecto a utilidad y ruido.

### 52.2 Condiciones de éxito

- Sponsor activo con capacidad de desbloqueo.
- Owner de producto interno dedicado.
- Disciplina técnica en trazabilidad Jira-GitLab.
- Gobierno de seguridad desde día uno.

### 52.3 Señales para escalar

Escalar a más equipos cuando:
- KPI de utilidad >75% en notificaciones relevantes,
- reducción >20% de tickets estancados,
- operación estable (SLOs cumplidos por 6 semanas continuas).

### 52.4 Señales para pausar y recalibrar

Pausar expansión si:
- el ruido supera valor percibido,
- la tasa de error de acción automática sube,
- no hay owner operativo claro.

### 52.5 Cierre estratégico

Skynet no debe evaluarse por “cantidad de IA”, sino por su capacidad de reducir coordinación improductiva y elevar la calidad de ejecución del equipo. Si se mantiene ese criterio, el proyecto puede transformarse en una ventaja operativa tangible para una empresa mediana: más foco técnico, mejor previsibilidad y decisiones más rápidas con menos desgaste organizacional.

---

## 53) Apéndice práctico: backlog de los primeros 30 tickets de implementación

Para facilitar ejecución inmediata, se propone un backlog inicial orientado a entrega incremental. Cada ticket puede transformarse en issue de Jira con estimación y criterios de aceptación.

### 53.1 Infraestructura y seguridad (tickets 1–8)

1. Crear repositorio `skynet-core` con estructura base y pipelines de CI.
2. Configurar gestor de secretos (vault) y variables por entorno.
3. Definir cuentas de servicio para Jira, GitLab y Teams con scopes mínimos.
4. Implementar rotación de tokens y alerta de expiración.
5. Configurar base de datos PostgreSQL y esquema inicial.
6. Configurar Redis para caché y deduplicación.
7. Crear stack de observabilidad (logs estructurados + métricas).
8. Definir política de retención de datos y borrado automático.

### 53.2 Ingestión y normalización (tickets 9–15)

9. Implementar endpoint seguro para webhook GitLab con validación de firma.
10. Implementar polling incremental Jira para cambios de issues.
11. Definir modelo canónico de eventos (`events_normalized`).
12. Implementar deduplicación por `source_event_id` + hash payload.
13. Registrar traza `correlation_id` para flujo end-to-end.
14. Construir worker de persistencia asíncrona en cola.
15. Crear pruebas de contrato para webhooks y normalización.

### 53.3 Correlación y reglas MVP (tickets 16–22)

16. Implementar mapeo issue Jira ↔ MR GitLab por clave.
17. Regla `stale_ticket_detected` con umbral configurable.
18. Regla `pipeline_failed_critical` para rama main.
19. Regla `mr_pending_review_sla` con dedupe temporal.
20. Motor de priorización P0/P1/P2/P3.
21. Política de horarios de silencio para alertas no críticas.
22. Panel simple para activar/desactivar reglas por squad.

### 53.4 Comunicación Teams y UX (tickets 23–27)

23. Integrar bot Teams para canal de squad.
24. Diseñar plantilla de digest pre-daily.
25. Diseñar plantilla de alerta crítica de pipeline.
26. Implementar Adaptive Cards con botones de acción rápida.
27. Capturar feedback útil/ruido/incorrecto desde Teams.

### 53.5 Analítica y gobierno (tickets 28–30)

28. Dashboard KPI de operación (latencia, errores, volumen).
29. Dashboard KPI de impacto (tickets estancados, MTTR pipeline, carga PM).
30. Reporte semanal automático para comité de seguimiento.

### 53.6 Criterios de aceptación globales del backlog inicial

- Trazabilidad completa desde evento origen hasta notificación final.
- Latencia p95 <120 segundos para alertas P0/P1.
- Cero secretos en repositorio.
- Cobertura de pruebas mínima del 70% en módulos críticos.
- Mecanismo de rollback de reglas documentado y probado.

### 53.7 Dependencias técnicas a resolver desde el día 1

- Convención estable de claves Jira en ramas/MRs.
- Definición única de estados de Jira por tipo de trabajo.
- Catálogo de canales Teams por squad y severidad.
- Lista de owners por componente/repositorio.

### 53.8 Definición de “listo para piloto”

Se considera que Skynet está listo para piloto cuando:

- procesa eventos GitLab en tiempo real con estabilidad,
- genera digest diario útil y consistente,
- detecta tickets estancados con precisión aceptable,
- notifica pipelines críticas con contexto accionable,
- registra feedback para mejora continua.

### 53.9 Entregables visibles al final de las primeras 6 semanas

- 3 automatizaciones MVP activas.
- 2 dashboards funcionales.
- guía operativa para PM y devs.
- informe de resultados preliminares con baseline comparativo.

### 53.10 Conclusión operativa del apéndice

Este backlog reduce ambigüedad de arranque y permite que el proyecto comience con foco en resultados concretos, no en discusiones abstractas. Si la organización ejecuta estos 30 tickets con disciplina y revisión quincenal de impacto, Skynet pasará rápidamente de concepto a capacidad operacional real.

---

## 54) Nota final de implementación para comité de lanzamiento

Para iniciar de forma segura, se recomienda una reunión de lanzamiento de 60 minutos con cuatro acuerdos explícitos: alcance exacto del piloto, métricas de éxito obligatorias, responsables por cada integración y protocolo de escalado ante incidentes de automatización. Esta reunión evita expectativas ambiguas y acorta tiempo de decisión durante las primeras semanas. Además, conviene fijar una revisión ejecutiva en la semana 6 para decidir continuidad, ajustes o pausa con base en datos observables y no en percepciones aisladas, con acta formal firmada.
