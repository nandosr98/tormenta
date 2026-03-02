# Informe de mejoras para Tormenta (2026-03-02)

## Resumen ejecutivo

Tormenta ya opera como un asistente de alta utilidad para trabajo diario, automatización y coordinación en canales de mensajería. Sin embargo, para pasar del nivel “asistente competente” al nivel “sistema personal operativo de confianza”, hay que reforzar siete pilares: **capacidades**, **integraciones**, **fiabilidad**, **seguridad**, **productividad**, **observabilidad** y **UX de comandos**. Este informe propone mejoras concretas, priorizadas y accionables, con un roadmap por fases para desplegarlas sin romper la experiencia actual.

La idea central es simple: Tormenta debe ser cada vez más autónoma en lo interno (diagnóstico, preparación, ejecución, verificación y documentación), pero seguir siendo extremadamente prudente en acciones externas o irreversibles. Esta combinación permite velocidad sin perder control humano. El foco no es añadir “más features” por añadir, sino construir una plataforma que:

1. reduzca fricción diaria,
2. minimice errores repetidos,
3. detecte problemas antes de que escalen,
4. ofrezca trazabilidad real,
5. mantenga costos bajo control,
6. y preserve la privacidad de Nando y su entorno.

Para lograrlo, se recomiendan cuatro líneas de evolución:

- **Sistema operativo de tareas**: convertir pedidos ambiguos en planes ejecutables con validaciones pre y post.
- **Memoria de alta calidad**: menos ruido, más decisiones útiles, con revisión periódica asistida.
- **Arquitectura de ejecución dual robusta**: chat principal siempre libre + subagentes especializados con SLAs internos.
- **Gobernanza técnica ligera**: estándares mínimos de seguridad, logs, testing y release para cambios del asistente.

Si se implementa el roadmap propuesto (0-3 meses para bases, 3-6 meses para robustez y 6-12 meses para escalamiento), Tormenta puede aumentar de forma tangible su valor: menos idas y vueltas, respuestas más consistentes, menos interrupciones, y mejor soporte a decisiones técnicas y operativas.

---

## 1) Nuevas capacidades recomendadas

### 1.1 Planificador inteligente con “contrato de ejecución”

Hoy muchas tareas llegan en lenguaje natural con niveles variables de precisión. Propuesta: incorporar un paso interno estandarizado que construya un **contrato de ejecución** antes de actuar, con:

- objetivo,
- supuestos detectados,
- límites de seguridad,
- dependencias,
- criterio de éxito,
- salida esperada.

**Valor:** menos malentendidos, menos retrabajo, más resultados verificables.

**Acción concreta:** plantilla interna de 6 campos y validación automática previa a tareas de >3 pasos.

### 1.2 Modo “preflight” para tareas técnicas

Antes de tocar sistemas/proyectos, ejecutar chequeos rápidos:

- estado de git (branch, cambios sin commit),
- disponibilidad de herramientas (gh, docker, node, php, etc.),
- permisos/rutas,
- conectividad mínima.

**Valor:** evita fallos evitables en mitad de una operación.

**Acción concreta:** script preflight reutilizable + respuesta resumida con semáforo (verde/amarillo/rojo).

### 1.3 Biblioteca de playbooks reutilizables

Definir playbooks para patrones frecuentes:

- investigar bug,
- preparar release,
- revisar CI roto,
- hardening básico,
- migración de versión de runtime,
- actualización de dependencias con rollback plan.

**Valor:** consistencia operacional y menor variabilidad entre sesiones.

**Acción concreta:** carpeta `playbooks/` con markdowns ejecutables + checklists.

### 1.4 Motor de “auto-verificación” posterior

Tras cada tarea relevante, Tormenta debería verificar:

- que el archivo existe donde prometió,
- que pruebas/comandos clave pasan,
- que los cambios están versionados,
- que el resultado comunicado coincide con estado real.

**Valor:** confianza. Menos “se supone que quedó hecho”.

**Acción concreta:** checklist post-run automática con salida corta al usuario.

### 1.5 Asistente de decisiones por impacto/coste

Agregar modo análisis de opciones con matriz simple:

- impacto,
- esfuerzo,
- riesgo,
- costo operativo/token,
- reversibilidad.

**Valor:** ayuda a priorizar sin discusiones largas.

**Acción concreta:** comando de decisión rápida que devuelva top 3 opciones.

---

## 2) Integraciones recomendadas

### 2.1 Integración profunda con GitHub (beyond CRUD)

No solo listar issues/PRs: sumar “flujo de mantenimiento”:

- detección de PRs estancados,
- resumen diario de estado de CI,
- identificación de reviewers bloqueantes,
- alertas de dependabot con severidad priorizada,
- etiquetado sugerido por contenido.

**Acción:** job recurrente con reporte compacto y enlaces.

### 2.2 Integración de observabilidad técnica (Grafana/Loki/Prometheus)

Permitir que Tormenta consulte paneles y logs para responder:

- “¿Qué se rompió en la última hora?”
- “¿Fue deploy o tráfico?”
- “¿Qué endpoint degradó?”

**Acción:** conectores de lectura con scopes de solo lectura + queries predefinidas.

### 2.3 Integración de calendario/tareas con bidireccionalidad

Ya hay reglas de Evento/Recordatorio. Escalar con:

- reconciliación (evitar duplicados),
- reprogramación inteligente,
- resumen matinal y bloque de foco,
- detección de conflictos entre calendarios.

**Acción:** capa de normalización de eventos + IDs persistentes de referencia.

### 2.4 Integración con gestión de secretos

Mover tokens/credenciales a un backend de secretos (1Password CLI, Vault o similar) en vez de variables sueltas.

**Acción:** wrapper interno para recuperar secretos por alias y rotación trimestral.

### 2.5 Integración de conocimiento local (RAG privado liviano)

Indexar documentación local y notas del workspace con actualización incremental.

**Valor:** respuestas más precisas sobre contexto real de Nando.

**Acción:** índice local con metadatos (fecha, proyecto, confiabilidad).

---

## 3) Mejoras de fiabilidad

### 3.1 Política de reintentos por tipo de error

No todos los errores deben reintentarse igual. Definir estrategias:

- red/transitorio: retry exponencial,
- permisos: no retry, escalar con mensaje claro,
- validación: pedir dato faltante,
- conflicto de estado: refrescar y reintentar una vez.

**Acción:** tabla de errores canónica y manejador común.

### 3.2 Idempotencia en tareas automatizadas

Toda tarea programada (cron/heartbeat) debe ser idempotente:

- usar lockfiles temporales,
- registrar última ejecución efectiva,
- detectar output ya generado.

**Acción:** mini framework de jobs con control de duplicados.

### 3.3 “Definition of done” por tipo de tarea

Cada categoría (reporte, fix, deploy note, resumen) debe tener criterios mínimos.

**Acción:** archivo `standards/dod.md` con chequeo automático.

### 3.4 Gestión de timeouts y degradación elegante

Cuando una herramienta tarda, Tormenta debe:

1) seguir en background,
2) informar estado,
3) entregar parcial útil,
4) no bloquear el chat.

**Acción:** plantilla de mensajes de progreso y fallback por timeout.

### 3.5 Pruebas de regresión para habilidades críticas

Crear tests semiautomáticos para skills clave (github, weather, healthcheck, etc.).

**Acción:** suite de smoke tests semanal + alerta en fallo.

---

## 4) Seguridad y privacidad

### 4.1 Clasificación de datos por sensibilidad

Definir niveles: público, interno, sensible, crítico; con reglas de uso y salida por canal.

**Acción:** política simple en `SECURITY.md` + validación previa a mensajes externos.

### 4.2 Principio de mínimo privilegio en integraciones

Cada token/integración con scopes estrictamente necesarios.

**Acción:** auditoría mensual de permisos + reporte de reducción de superficie.

### 4.3 Registro de acciones sensibles

Operaciones como push, borrado, cambios de configuración o envíos externos deben quedar trazadas.

**Acción:** log estructurado local (fecha, acción, repositorio, resultado, hash/ID).

### 4.4 Escaneo de secretos en commits

Antes de commit/push, ejecutar detector de secretos para evitar filtraciones.

**Acción:** hook pre-commit con gitleaks/trufflehog en modo rápido.

### 4.5 Política de aprobación contextual

Mantener autonomía en interno seguro, pero requerir confirmación para:

- acciones irreversibles,
- difusión pública,
- acceso ampliado,
- cambio de políticas base.

**Acción:** matriz de autorización por categoría de riesgo.

---

## 5) Productividad y flujo de trabajo

### 5.1 Orquestación inteligente de subagentes

Formalizar cuándo delegar al worker:

- tareas >10 min estimados,
- múltiples repos/herramientas,
- análisis extenso,
- generación de artefactos largos.

**Acción:** gatillos automáticos + formato de handoff estándar.

### 5.2 Plantillas de entregables

Para evitar variación de calidad, usar plantillas para:

- informes técnicos,
- planes de migración,
- postmortems,
- propuestas de roadmap,
- checklist de release.

**Acción:** repositorio de plantillas versionadas.

### 5.3 Cache de contexto por proyecto

Guardar contexto operativo por repo/proyecto:

- comandos útiles,
- convenciones,
- versiones,
- rutas clave,
- historial de fallos frecuentes.

**Acción:** `context/<proyecto>.md` autogenerado y mantenido.

### 5.4 Gestión de costo/token por objetivo

No solo medir tokens: relacionar consumo con valor entregado.

**Acción:** reporte semanal “token por tipo de tarea” + optimizaciones.

### 5.5 Ciclo de mejora continua

Cada error relevante debería producir una mejora concreta (regla, checklist o script).

**Acción:** “error → aprendizaje → cambio” documentado en 24h.

---

## 6) Observabilidad y métricas

### 6.1 Dashboard operativo de Tormenta

Métricas mínimas:

- tareas completadas / fallidas,
- tiempo medio de resolución,
- retrabajo (reaperturas),
- uso de subagentes,
- consumo de tokens por categoría,
- porcentaje de tareas con verificación post-run.

**Acción:** tablero semanal con tendencia.

### 6.2 Trazas por ejecución

Cada ejecución debería tener un ID y etapas:

- input,
- plan,
- acciones,
- validaciones,
- salida final.

**Acción:** logging estructurado JSON para análisis y debugging.

### 6.3 Alertas de degradación

Alertar cuando:

- sube ratio de fallos,
- aumenta latencia media,
- crece tiempo bloqueado,
- cae tasa de éxito en tareas críticas.

**Acción:** umbrales con notificaciones discretas.

### 6.4 Métrica de satisfacción operativa

No solo “funcionó/no funcionó”: medir “¿evitó trabajo real?”

**Acción:** etiqueta rápida en cierres (útil, parcial, poco útil) para aprendizaje.

### 6.5 Auditoría mensual de calidad

Revisión de una muestra de tareas con rubric:

- precisión,
- seguridad,
- claridad,
- eficiencia,
- trazabilidad.

**Acción:** informe mensual con 3 mejoras priorizadas.

---

## 7) UX de comandos y experiencia de uso

### 7.1 Comandos naturales con aliases cortos

Mantener comandos técnicos pero permitir lenguaje humano consistente.

Ejemplos:

- “revísame este PR y dime blockers”
- “prepara informe ejecutivo de X en 1 página”
- “lanza worker para investigar bug Y y vuelve con plan”

**Acción:** catálogo de aliases + parser semántico básico.

### 7.2 Confirmaciones inteligentes (no spam)

Evitar confirmaciones innecesarias en tareas internas seguras; pedirlas solo cuando aumenta el riesgo.

**Acción:** política de confirmación por riesgo y canal.

### 7.3 Respuestas de estado uniformes

Formato breve estándar para progreso:

- qué está haciendo,
- cuánto falta,
- próximo hito,
- si requiere intervención.

**Acción:** plantillas de estado y finalización.

### 7.4 Modo “resumen ejecutivo” y “modo técnico”

Permitir alternar nivel de detalle por defecto de forma explícita.

**Acción:** preferencia persistente por contexto/canal.

### 7.5 Sistema de comandos descubrible

Documentar capacidades con ejemplos cortos y reales.

**Acción:** `HELP.md` con recetas por objetivo (no por herramienta).

---

## 8) Arquitectura y gobernanza técnica recomendada

### 8.1 Capas separadas

- **Interacción** (mensajes/comandos)
- **Orquestación** (planes/decisiones)
- **Ejecución** (tools/subagentes)
- **Memoria** (corto/largo plazo)
- **Observabilidad** (logs/métricas)

**Valor:** reduce acoplamiento y facilita evolución.

### 8.2 Versionado de comportamientos

Cambios en reglas importantes deberían tener versión y changelog.

**Acción:** `CHANGELOG-TORMENTA.md` con impacto y rollback.

### 8.3 Entorno de staging para skills

Probar nuevas skills antes de producción.

**Acción:** rama + suite de smoke tests + checklist de release.

### 8.4 Gestión de deuda técnica del asistente

Registrar debt items y priorizarlos como cualquier producto.

**Acción:** backlog trimestral con puntaje impacto/riesgo.

### 8.5 Política de rollback

Si una mejora rompe flujo, poder revertir rápido.

**Acción:** rollback playbook en menos de 10 minutos.

---

## 9) Roadmap por fases

## Fase 1 (0-30 días): Fundaciones operativas

**Objetivo:** reducir errores evitables y ganar trazabilidad.

Entregables:

1. Preflight estándar para tareas técnicas.
2. Checklist post-run obligatorio en tareas críticas.
3. Logging básico de acciones sensibles.
4. Plantillas de estado y cierre.
5. Hook de escaneo de secretos pre-commit.

KPIs esperados:

- -30% fallos por contexto incompleto.
- +40% tareas con verificación explícita.
- 0 incidentes de secretos en commits.

## Fase 2 (30-90 días): Robustez y productividad

**Objetivo:** escalar throughput sin degradar calidad.

Entregables:

1. Orquestación formal de subagentes con handoff estándar.
2. Biblioteca de playbooks reutilizables.
3. Dashboard operativo inicial.
4. DoD por tipo de tarea.
5. Gestión de reintentos por clase de error.

KPIs esperados:

- +25% velocidad en tareas complejas.
- -20% retrabajo.
- +30% resolución en primer intento.

## Fase 3 (90-180 días): Integración inteligente

**Objetivo:** conectar señales externas para decidir mejor.

Entregables:

1. Integración de observabilidad (logs/métricas).
2. Flujos avanzados GitHub (PRs estancados, CI, riesgos).
3. Reconciliación calendario-recordatorios.
4. Índice de conocimiento local incremental.

KPIs esperados:

- -35% tiempo de diagnóstico de incidentes.
- +20% visibilidad de bloqueos antes de escalar.
- +15% decisiones asistidas con contexto útil.

## Fase 4 (180-365 días): Madurez y autonomía supervisada

**Objetivo:** convertir Tormenta en plataforma confiable de operación personal.

Entregables:

1. Gobierno de cambios versionado + rollback maduro.
2. Auditorías mensuales automáticas de calidad.
3. Matriz de permisos dinámica por sensibilidad.
4. Métricas de valor (impacto real sobre tiempo ahorrado).

KPIs esperados:

- +50% tareas automatizadas con mínima intervención.
- -40% incidencias operativas repetidas.
- Alta satisfacción sostenida en utilidad y claridad.

---

## 10) Priorización sugerida (impacto vs esfuerzo)

### Alta prioridad / bajo esfuerzo

- preflight,
- checklist post-run,
- plantillas de salida,
- escaneo de secretos,
- definición de DoD.

### Alta prioridad / esfuerzo medio

- orquestación de subagentes,
- dashboard de métricas,
- logging estructurado,
- playbooks críticos.

### Alta prioridad / esfuerzo alto

- integración observabilidad completa,
- RAG privado incremental,
- política de permisos contextual automatizada.

### Baja prioridad por ahora

- refinamientos cosméticos de UX sin impacto operativo,
- automatizaciones no recurrentes o demasiado específicas.

---

## 11) Riesgos y mitigaciones

1. **Sobreautomatización sin control**
   - Mitigación: matriz de aprobación por riesgo.

2. **Aumento de complejidad operativa**
   - Mitigación: arquitectura por capas + documentación mínima obligatoria.

3. **Ruido en memoria/contexto**
   - Mitigación: higiene semanal de memoria y curación de largo plazo.

4. **Dependencia de integraciones frágiles**
   - Mitigación: fallbacks y degradación elegante.

5. **Coste de tokens creciente**
   - Mitigación: métricas por valor + modo breve por defecto.

---

## 12) Conclusión

Mejorar Tormenta no es solo añadir funciones: es construir un sistema personal que combine velocidad, criterio y confiabilidad. El mayor retorno está en estandarizar ejecución (preflight + post-verificación), fortalecer gobernanza (seguridad, trazabilidad, rollback), y profesionalizar la operación (métricas, playbooks, subagentes con contrato claro).

Con este plan, Tormenta puede evolucionar de “asistente que responde bien” a “infraestructura personal de ejecución confiable”, capaz de sostener trabajo intenso sin perder claridad ni seguridad. La prioridad debe ser pragmática: primero reducir errores y aumentar previsibilidad; luego escalar integración e inteligencia; finalmente consolidar autonomía supervisada con métricas de impacto real.

Si el foco se mantiene en propuestas accionables y medición continua, en menos de un año Tormenta puede convertirse en una ventaja competitiva diaria para Nando: menos fricción, más foco, mejores decisiones y más tiempo para trabajo de alto valor.
