# Resumen ejecutivo — Skynet v1

## Qué es Skynet
Skynet es una iniciativa para implementar un agente de IA interno que actúa como capa de coordinación operativa entre Jira, GitLab y Microsoft Teams en un equipo Scrum de ~20 personas. Su objetivo es reducir trabajo administrativo, anticipar riesgos y mejorar la velocidad de ejecución sin aumentar carga humana.

## Problema que resuelve
Hoy gran parte de la fricción se concentra en tareas repetitivas: seguimiento manual de sprint, tickets estancados, MRs sin revisión, pipelines fallidas sin escalado adecuado y reportes armados manualmente. Skynet transforma esos eventos en acciones priorizadas y trazables.

## Qué automatiza primero (MVP)
1. Digest pre-daily automático con riesgos accionables.
2. Detección de tickets estancados y recordatorios inteligentes.
3. Alertas de pipeline fallida con severidad y escalado por impacto.

Estas tres automatizaciones atacan el mayor costo operativo con complejidad moderada.

## Arquitectura propuesta
- Ingesta por webhooks/polling (Jira/GitLab/Teams).
- Normalización y correlación de eventos en backend.
- Motor híbrido reglas + IA (evita decisiones opacas).
- Ejecución de acciones con trazabilidad y control humano.
- Observabilidad, auditoría y feature flags para despliegue seguro.

## Roadmap recomendado (6 meses)
- Semanas 1–2: baseline, diseño y seguridad.
- Semanas 3–6: MVP operativo con 3 automatizaciones clave.
- Semanas 7–10: acciones con aprobación y mejora de UX en Teams.
- Semanas 11–16: inteligencia de riesgo y reporte ejecutivo.
- Semanas 17–24: escalado multi-equipo y hardening.

## Riesgos críticos y mitigación
- **Ruido de notificaciones:** priorización P0–P3, rate-limits y digest.
- **Errores automáticos:** modo sugerencia inicial + aprobaciones.
- **Seguridad de datos:** RBAC, vault, auditoría y DLP.
- **Baja adopción:** piloto con champions, feedback continuo y quick wins.

## Métricas de éxito
- Reducción del tiempo PM en tareas de seguimiento.
- Menor tiempo en tickets bloqueados/estancados.
- Menor MTTR de pipelines fallidas.
- Mejor ratio compromiso vs cierre de sprint.
- Percepción de utilidad del sistema (>75% objetivo en alertas clave).

## Business case inicial (empresa mediana)
Con supuestos conservadores, Skynet puede recuperar capacidad equivalente a ~1.680 horas/año en coordinación y fricción operativa. Con un coste anual total estimado de 50k–80k EUR (implementación + operación), el ROI puede ser positivo entre mes 9 y 15, dependiendo de adopción y calidad de ejecución.

## Decisión recomendada
Aprobar piloto de 10 semanas con gates de continuidad basados en KPIs. Si se valida reducción de carga operativa, mejora de tiempos de bloqueo y aceptación del equipo, escalar a más squads como capacidad interna estratégica.
