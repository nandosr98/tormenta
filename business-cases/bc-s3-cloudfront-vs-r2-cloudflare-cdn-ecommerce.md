# Business Case FinOps — Migración de imágenes de Amazon S3 + CloudFront a Cloudflare R2 + Cloudflare CDN

## Resumen ejecutivo (orientado a dirección)

La plataforma de e-commerce presenta un patrón de coste típico en cargas de media global: **el egress domina el coste total**. En el estado actual (S3 + CloudFront), el almacenamiento es relativamente bajo frente a la salida mensual de datos (50–200 TB/mes). La propuesta de mover serving público a **Cloudflare R2 + Cloudflare CDN** apunta a capturar ahorro por dos vías:

1. **R2 no cobra egress hacia Internet** para objetos servidos desde R2.  
2. Costes de operación por request y almacenamiento en R2 competitivos frente a S3 para este perfil de uso.

### Conclusión ejecutiva

- **Sí hay caso económico sólido** para migración parcial o total del serving público de imágenes a R2+Cloudflare CDN, especialmente a partir de >50 TB/mes de salida.
- En escenarios de 50–200 TB/mes, el ahorro estimado es significativo y recurrente. Con supuestos conservadores, el ahorro total anual puede situarse en un rango aproximado de **35% a 70%** según patrón real de caché, mix de requests y discounts actuales en AWS.
- **Recomendación principal:** enfoque **híbrido progresivo** en 2 fases:
  - Fase 1: mantener S3 para procesos internos y source-of-truth; servir público prioritario desde R2+Cloudflare CDN.
  - Fase 2: evaluar migración completa de bucket público según KPI de rendimiento, errores y coste real post-piloto.

Este enfoque reduce riesgo operacional, mantiene rollback simple y permite capturar ahorro pronto.

---

## 1) Contexto y alcance

### Contexto
- Plataforma e-commerce global con alto tráfico y gran volumen de imágenes (ficha de producto, miniaturas, banners, assets de campaña).
- Arquitectura actual:
  - **Storage:** Amazon S3
  - **Delivery:** Amazon CloudFront
- Dolor principal: coste de salida de datos (egress) elevado.

### Alcance del business case
- Evaluación técnico-económica para serving de imágenes públicas.
- Escenarios de volumen:
  - Storage: **1, 3 y 5 TB**
  - Egress: **50, 100, 150 y 200 TB/mes**
- Incluye arquitectura, rendimiento, operación, riesgos, seguridad, migración y recomendación final.

---

## 2) Supuestos de modelado de costes (transparencia FinOps)

> Nota: precios exactos pueden variar por región, contrato enterprise, compromisos de volumen y descuentos privados. Este modelo usa valores de mercado razonables para comparar órdenes de magnitud.

### Supuestos AWS (aprox.)
- S3 Standard storage: **$0.023/GB-mes**
- CloudFront data transfer out (promedio efectivo): **$0.04–$0.08/GB** (se usa baseline **$0.06/GB** para tabla central)
- Requests y operaciones: se tratan como componente menor respecto al egress para este patrón.

### Supuestos Cloudflare
- R2 storage: **$0.015/GB-mes**
- R2 egress to Internet: **$0/GB**
- Operaciones R2 (Class A/B) y requests CDN: coste bajo relativo para media-heavy (incluido de forma conservadora en un bloque fijo/variable pequeño).
- CDN Cloudflare: se asume coste medio efectivo menor al stack CloudFront+S3 en este caso (especialmente por egress evitado en origen).

### Supuestos de tráfico de imagen
- Cache-hit ratio esperado en edge: 85%–97% según catálogo y TTL.
- Transformaciones on-the-fly: volumen moderado (thumbnails/responsive).

---

## 3) Análisis de costes (CRÍTICO)

## 3.1 Fórmulas simplificadas

### Arquitectura actual (S3 + CloudFront)
- Coste storage mensual ≈ `GB_storage * 0.023`
- Coste egress mensual (baseline) ≈ `GB_egress * 0.06`
- Coste total ≈ storage + egress + requests/ops (menor)

### Arquitectura propuesta (R2 + Cloudflare CDN)
- Coste storage mensual ≈ `GB_storage * 0.015`
- Egress desde R2 a Internet ≈ **0**
- Coste total ≈ storage + requests/ops + CDN/transformaciones (si aplica)

---

## 3.2 Tabla de costes mensuales (baseline)

Supuesto baseline para comparar: egress AWS a **$0.06/GB**.  
Se añade componente operativo conservador en R2/CDN (requests/ops/transform): **$150/mes** fijo en escenarios de 50–100TB y **$300/mes** en 150–200TB.

| Storage | Egress/mes | AWS S3+CF (USD/mes) | R2+CF CDN (USD/mes) | Ahorro USD/mes | Ahorro % |
|---|---:|---:|---:|---:|---:|
| 1 TB | 50 TB | ~3,095 | ~165 | ~2,930 | ~94.7% |
| 1 TB | 100 TB | ~6,167 | ~165 | ~6,002 | ~97.3% |
| 1 TB | 150 TB | ~9,239 | ~315 | ~8,924 | ~96.6% |
| 1 TB | 200 TB | ~12,311 | ~315 | ~11,996 | ~97.4% |
| 3 TB | 50 TB | ~3,142 | ~196 | ~2,946 | ~93.7% |
| 3 TB | 100 TB | ~6,214 | ~196 | ~6,018 | ~96.8% |
| 3 TB | 150 TB | ~9,286 | ~346 | ~8,940 | ~96.3% |
| 3 TB | 200 TB | ~12,358 | ~346 | ~12,012 | ~97.2% |
| 5 TB | 50 TB | ~3,189 | ~227 | ~2,962 | ~92.9% |
| 5 TB | 100 TB | ~6,261 | ~227 | ~6,034 | ~96.4% |
| 5 TB | 150 TB | ~9,333 | ~377 | ~8,956 | ~96.0% |
| 5 TB | 200 TB | ~12,405 | ~377 | ~12,028 | ~97.0% |

> Observación: estas cifras muestran el efecto del egress. En la práctica, contratos enterprise de AWS pueden reducir el diferencial; por eso el análisis de sensibilidad es clave.

---

## 3.3 Coste por GB servido (indicador FinOps clave)

### AWS (baseline)
- Coste unitario dominado por egress: **~$0.06/GB** (+ overhead pequeño de storage/ops).

### R2 + Cloudflare CDN
- Egress origen: **$0/GB**
- Coste unitario efectivo depende de requests, transformaciones y plan CDN, típicamente mucho menor para media delivery masiva.

---

## 3.4 Análisis de sensibilidad

Para evitar sesgo por un único precio de egress AWS:

- Si AWS efectivo fuera **$0.04/GB**: ahorro sigue fuerte (rango aproximado 70–90%).
- Si AWS efectivo fuera **$0.08/GB**: ahorro se amplifica (rango >90% en escenarios altos).
- Si hay descuento enterprise muy agresivo en CloudFront + ahorro por cache muy alto: el ahorro podría bajar a banda **35–60%**, pero sigue material en 100–200 TB/mes.

### Sensibilidad por crecimiento
- Cada +10TB/mes en AWS (a $0.06/GB) añade ~**$614/mes** de coste variable.
- En R2 ese componente de egress no crece igual, por lo que la brecha se ensancha con el volumen.

---

## 4) Comparativa de arquitectura

## 4.1 Arquitectura actual (S3 + CloudFront)

Flujo:
1. App sube assets a S3.
2. CloudFront distribuye globalmente.
3. Usuarios consumen imágenes vía edge.

Fortalezas:
- Integración nativa con AWS.
- Observabilidad y gobernanza dentro de un mismo cloud.

Debilidades:
- Egress costoso a gran escala.
- Coste variable sensible a crecimiento de tráfico.

## 4.2 Arquitectura propuesta (R2 + Cloudflare CDN)

Flujo:
1. App sube assets a R2 (S3-compatible API).
2. Cloudflare CDN sirve desde edge global.
3. Egress de R2 no se cobra como en S3.

Fortalezas:
- Gran palanca de ahorro por egress.
- Excelente capa edge y herramientas de performance.

Debilidades:
- Cambios operativos en pipelines y observabilidad.
- Menor “natividad” con servicios AWS adyacentes.

## 4.3 Opción híbrida recomendada

- S3 como repositorio interno/source-of-truth (backoffice, procesamiento, histórico).
- R2 como storage de serving público para assets de frontend.
- Sincronización bidireccional o unidireccional según gobernanza.

Ventaja: captura ahorro sin ruptura inmediata del ecosistema AWS.

---

## 5) Rendimiento

### Latencia y edge
- CloudFront y Cloudflare tienen redes globales maduras.
- Rendimiento final dependerá de:
  - hit ratio real,
  - cercanía del edge,
  - estrategia de cache keys,
  - TTL y purge patterns.

### Eficiencia de caché
- Si el catálogo tiene alta reutilización (best sellers, thumbnails, banners), ambos rinden bien.
- Cloudflare suele destacar en facilidad de reglas edge, cache policies y optimizaciones en borde.

### Impacto usuario global
- Debe medirse con RUM/A-B por región (EU/US/LATAM/APAC).
- KPI objetivo: p95 TTFB y p95 LCP en páginas con imágenes pesadas.

---

## 6) Impacto operativo

### Cambios en flujos de despliegue
- Ajuste de endpoints storage (S3 endpoint -> R2 endpoint).
- Gestión de credenciales y buckets nuevos.
- Adaptación de jobs de invalidación/purge.

### CI/CD
- Actualizar scripts de upload/sync.
- Añadir pruebas de consistencia (checksum, MIME, ACL/public access).
- Automatizar fallback/rollback de rutas de delivery.

### Subida de imágenes
- Mantener API de aplicación estable y desacoplar proveedor vía adapter.
- Recomendado: capa interna `MediaStorageProvider` con drivers S3/R2.

---

## 7) Comparativa de funcionalidades

## Transformación de imágenes
- AWS: opciones con Lambda@Edge / CloudFront Functions / soluciones de terceros.
- Cloudflare: stack edge amigable para resize/format conversion (WebP/AVIF) y reglas por dispositivo.

## Integraciones y eventos
- AWS ecosistema más amplio y nativo con servicios internos.
- Cloudflare cubre caso web performance + edge muy bien, pero integraciones internas pueden requerir adaptación.

## Madurez ecosistema
- AWS: mayor madurez enterprise end-to-end.
- Cloudflare: muy fuerte en red/edge y costos de delivery.

---

## 8) Riesgos y trade-offs

1. **Vendor strategy dual**
   - Pro: evita lock-in completo.
   - Con: añade complejidad operativa.

2. **Pérdida de integración nativa AWS**
   - Riesgo en pipelines actuales si dependen de eventos AWS específicos.

3. **Curva de aprendizaje**
   - Equipo debe dominar políticas y tooling Cloudflare.

4. **Observabilidad distribuida**
   - Métricas en dos plataformas; requiere panel unificado.

5. **Riesgo de migración de metadata**
   - ACLs, headers cache-control, invalidaciones masivas.

---

## 9) Seguridad y cumplimiento

### IAM vs controles Cloudflare
- AWS IAM extremadamente granular y conocido por equipos cloud.
- En Cloudflare, control equivalente existe, pero con modelo distinto y governance a definir.

### Gobierno del dato
- Definir clasificación de assets (público vs interno) para evitar mover datos no aptos a ruta pública.
- Aplicar cifrado at-rest/in-transit, rotación de keys y least-privilege en ambos lados.

### Enterprise readiness
- Revisar requisitos de auditoría, retención de logs y compliance por región.
- Definir RTO/RPO y pruebas de recuperación para el canal de media.

---

## 10) Estrategia de migración (por fases)

## Fase 0 — Diseño y baseline (1–2 semanas)
- Captura de baseline real: coste, hit ratio, latencia, errores.
- Definir KPIs y umbrales de éxito.

## Fase 1 — Piloto controlado (2–4 semanas)
- Migrar subset de imágenes (p.ej. banners y thumbnails de 10% tráfico).
- Activar dual-write opcional (S3 + R2) para seguridad operativa.
- Medir impacto y ajustar cache policies.

## Fase 2 — Migración progresiva de tráfico (4–8 semanas)
- Escalar por categorías/regiones.
- Mantener rollback rápido por DNS/routing.

## Fase 3 — Optimización y consolidación
- Evaluar mantener híbrido o completar migración de serving público.
- Refinar costos y observabilidad FinOps mensual.

### Rollback plan
- Mantener origin S3 activo durante transición.
- Feature flag para volver a CloudFront path en minutos.
- Sincronización continua para evitar drift de objetos.

---

## 11) Recomendación final

## Opción recomendada: **Híbrida con intención de consolidar**

### Por qué
- Maximiza ahorro temprano con riesgo acotado.
- Evita big-bang.
- Conserva integraciones AWS internas mientras se externaliza delivery público.

### Decisión propuesta a comité
1. Aprobar piloto R2+Cloudflare CDN para serving público de imágenes.  
2. Mantener S3 para procesos internos y fallback durante 1–2 ciclos de release.  
3. Evaluar go/no-go a migración completa tras 8–12 semanas con KPIs:
   - ahorro neto mensual real,
   - p95 latencia global,
   - error rate,
   - overhead operativo.

---

## 12) Checklist ejecutable (próximo paso)

1. Recolectar 30 días de datos reales (coste/volumen/latencia/hit ratio).  
2. Montar PoC con 1 bucket R2 + zona CDN + reglas de cache.  
3. Implementar adapter de storage (S3/R2) en app.  
4. Habilitar tráfico piloto 10% con observabilidad comparativa.  
5. Entregar informe post-piloto con recomendación final cuantificada.

---

## Anexo A — Plantilla de datos a completar por Finanzas/Plataforma

- Coste mensual actual total (S3 + CloudFront): _____
- Egress mensual real (GB/TB): _____
- Requests mensuales (CloudFront): _____
- Storage medio (GB/TB): _____
- Hit ratio cache actual: _____
- p95 TTFB por región: _____
- Incidentes de media últimos 90 días: _____
- Objetivo de ahorro anual: _____

Con esta tabla cerrada, se puede pasar de business case estimado a business case financiero con precisión de decisión.
