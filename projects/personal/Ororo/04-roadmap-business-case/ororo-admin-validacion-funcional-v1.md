# Ororo Admin Panel — Validación funcional v1

Fecha: 2026-03-17  
Branch evaluada: `main`  
Repo: `/home/tormenta/.openclaw/workspace/projects/personal/Ororo-app`

## 1) Preparación de entorno (migraciones/seeders)

### Resultado
- **Estado:** OK (con observación de infraestructura local)

### Evidencia
- Comando ejecutado (contenedor PHP 8.4):
  - `docker exec -w /var/www/html ororo-app php artisan migrate:fresh --seed`
- Resultado:
  - migraciones completadas
  - seeders ejecutados: `OroroCatalogSeeder`, `OroroBootstrapSeeder`, `OroroRbacSeeder`, `OroroUserTypesSeeder`

### Observación infra (no bloqueante para admin)
- Al intentar levantar stack nuevo con `docker compose up -d` falló por conflicto de puerto `3307` (ya ocupado por `ororo-mysql`).
- Se validó usando stack ya operativo (`ororo-app` + `ororo-mysql` + `ororo-nginx`).

---

## 2) Batería funcional del módulo admin (auth/authorization + flujos)

### Suite enfocada en admin/governance
Comando:
- `docker exec -w /var/www/html ororo-app php artisan test --testsuite=Feature --filter='Ororo(Admin|Policies|Governance|Audit|Health|Rbac|Panel|Dashboard)'`

Resultado:
- **16 tests PASS / 0 FAIL**

Cobertura funcional validada por tests:
- acceso a dashboard con/sin permiso (`admin.panel.view`)
- RBAC dinámico (role + permission assignment)
- CRUD de policies (`admin.policies.manage`) + validación de unicidad
- acciones de alertas (`ack`)
- kill switch con razón obligatoria
- audit timeline visible para rol autorizado
- health dashboard visible para rol autorizado
- baseline governance (aprobaciones + bloqueo por kill switch)

### Verificación de regresión amplia (contexto)
Comando:
- `docker exec -w /var/www/html ororo-app php artisan test --testsuite=Feature`

Resultado:
- **53 PASS / 3 FAIL** (fallos fuera del foco directo del panel admin)
- Fallos detectados:
  1. `OroroEventNormalizationTest` (2 fallos): firma de `NormalizeRawEventJob::handle()` requiere 2 dependencias y el test invoca con 1.
  2. `OroroTeamsNotificationsTest` (1 fallo): violación de unique constraint en `ororo_module_metrics` bajo sqlite in-memory.

Impacto para panel admin:
- **No bloquea** el funcionamiento E2E del panel admin validado en la suite específica.

---

## 3) Smoke test manual por rutas clave

> Nota: el control browser OpenClaw no estuvo disponible en esta sesión host, por lo que el smoke manual se hizo por HTTP + validación de rutas y pruebas funcionales de autorización.

### 3.1 Rutas admin registradas
Comando:
- `php artisan route:list --path=admin`

Rutas clave detectadas (13):
- `/admin` (dashboard)
- `/admin/policies` (index/create/store/edit/update/destroy)
- `/admin/alerts` + acción
- `/admin/kill-switch` + toggle
- `/admin/audit`
- `/admin/health`

### 3.2 Control de acceso no autenticado
Comprobación HTTP sobre `http://localhost:8080`:
- `/admin` -> `302 /login`
- `/admin/policies` -> `302 /login`
- `/admin/alerts` -> `302 /login`
- `/admin/kill-switch` -> `302 /login`
- `/admin/audit` -> `302 /login`
- `/admin/health` -> `302 /login`

Interpretación:
- el perímetro de autenticación de rutas admin responde correctamente.

### 3.3 Smoke funcional autenticado/autorizado
Evidencia indirecta fuerte por tests de feature admin:
- permisos denegados (403) cuando faltan capabilities
- acceso OK para usuarios con permisos explícitos por módulo
- transiciones de estado (alerta ack, policy CRUD, kill switch toggle con reason) operativas

---

## 4) Estado por módulo (OK/KO)

| Módulo | Estado | Evidencia principal |
|---|---|---|
| Auth gate admin (login + middleware) | **OK** | Redirección 302 a `/login` en rutas admin sin sesión |
| Dashboard admin | **OK** | `OroroAdminPanelFoundationTest`, `OroroAdminDashboardRedesignTest` |
| RBAC dinámico (roles/permisos) | **OK** | `OroroAdminRbacTest` |
| Policies CRUD | **OK** | `OroroPoliciesCrudTest` |
| Alert actions | **OK** | `OroroAdminGovernanceActionsTest::test_can_acknowledge_alert` |
| Kill switch | **OK** | `OroroAdminGovernanceActionsTest::test_requires_reason_for_kill_switch_toggle` + governance basic |
| Auditoría | **OK** | `OroroAdminAuditHealthTest::test_audit_timeline_is_visible_for_authorized_user` |
| Health dashboard | **OK** | `OroroAdminAuditHealthTest::test_health_dashboard_renders_widgets_for_authorized_user` |

---

## 5) Bugs encontrados (con severidad)

### Bug A — Suite no-admin rota por firma de job
- **Severidad:** Media (calidad/CI)
- **Área:** Normalización de eventos (no admin UI)
- **Detalle:** tests llaman `NormalizeRawEventJob::handle()` con argumentos insuficientes tras cambio de firma (ahora requiere `CanonicalEventNormalizer` + `EventQualityScorer`).
- **Riesgo:** CI inestable, posible deuda técnica en cobertura de ingest/normalization.

### Bug B — Duplicidad métrica en sqlite in-memory
- **Severidad:** Media (calidad/CI)
- **Área:** Teams notifications metrics (no admin UI)
- **Detalle:** inserción duplicada en `ororo_module_metrics` rompe unique constraint en test de dedupe window.
- **Riesgo:** ruido en pipelines de test y falsa percepción de regresión.

### Bug C — Conflicto local de puerto Docker (3307)
- **Severidad:** Baja (entorno local)
- **Área:** levantado de stack paralelo
- **Detalle:** `docker compose up -d` falla si existe otro `mysql` ocupando `3307`.
- **Riesgo:** fricción operativa para validaciones rápidas.

---

## 6) Fixes rápidos recomendados

1. **Normalización tests (Bug A)**
   - actualizar tests para resolver dependencias del contenedor al invocar `handle()` (o despachar job vía bus para resolución automática).
2. **Métricas dedupe (Bug B)**
   - usar `updateOrCreate`/`upsert` en recorder o aislar mejor estado por test (fecha/clave) para evitar colisión.
3. **Docker local (Bug C)**
   - parametrizar puerto DB en `.env.local`/compose o documentar comando alterno (`--remove-orphans` + puerto libre).

---

## 7) Definición de “panel admin listo para piloto”

Se considera **listo para piloto** cuando se cumplen simultáneamente:

1. **Seguridad y acceso:**
   - todas las rutas admin protegidas por autenticación y gates por permiso.
2. **Operación funcional mínima:**
   - dashboard carga métricas base,
   - policies CRUD funcional,
   - alert actions operativas,
   - kill switch con trazabilidad y reason obligatoria,
   - vistas de audit y health accesibles por permisos dedicados.
3. **Evidencia automatizada estable:**
   - suite específica de admin en verde (actualmente cumplido).
4. **No defectos críticos/altos en admin:**
   - en esta validación: **no se detectaron KO en admin**.

### Veredicto actual
- **Panel admin: LISTO PARA PILOTO (condicionado)**
- Condición: cerrar los 2 fallos de suite no-admin para tener baseline de CI totalmente verde.

---

## 8) PRs de fixes rápidos

- No se crearon PRs en esta ejecución, porque no se detectaron bugs menores directamente en el módulo admin que bloquearan su operación funcional.
- Recomendación: abrir PRs separados para Bug A y Bug B (calidad de test suite global).
