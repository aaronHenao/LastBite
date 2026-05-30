# Bugs & Backlog — LastBite

## Bugs encontrados y resueltos

| ID | Descripción | Severidad | Estado | Responsable |
|----|-------------|-----------|--------|-------------|
| BUG-001 | `AuthUser` no tenía campo `status` ni `role` | Alta | ✅ Resuelto | Isabella (A) |
| BUG-002 | `_AuthGate` no redirigía según status del usuario | Alta | ✅ Resuelto | Sofía (B) |
| BUG-003 | `AppColors.background` no existía en el tema | Media | ✅ Resuelto | Sofía (B) |
| BUG-004 | `ConnectivityResult` comparación incorrecta | Media | ✅ Resuelto | Isabella (A) |
| BUG-005 | `DespensaRepository` necesitaba parámetro `db` | Alta | ✅ Resuelto | Isabella (A) |
| BUG-006 | Widget tests con tipos de notifier incorrectos | Media | ✅ Resuelto | Sofía (B) |
| BUG-007 | Botón guardar permitía doble clic y duplicaba productos | Alta | ✅ Resuelto | Sofía (B) |
| BUG-008 | Google Sign-In fallaba por falta de SHA-1 | Alta | ✅ Resuelto | Sofía (B) |
| BUG-009 | Firestore del proyecto original no tenía campo `status` | Alta | ✅ Resuelto | Ambas — nuevo proyecto Firebase |
| BUG-010 | `flutter analyze` tenía 5 errores críticos | Alta | ✅ Resuelto | Ambas |
| BUG-011 | Flutter SDK desactualizado (3.41.4 → 3.44.0) | Media | ✅ Resuelto | Sofía (B) |

## Bugs pendientes

| ID | Descripción | Severidad | Estado | Notas |
|----|-------------|-----------|--------|-------|
| BUG-012 | Pantalla de administración de usuarios no implementada | Media | ⚠️ Pendiente | Cambiar roles/status desde la app requiere más tiempo |
| BUG-013 | `failedSync` no tiene UI de reintento manual | Baja | ⚠️ Pendiente | El retry es automático pero no hay botón manual |
| BUG-014 | API Spoonacular tiene límite de 150 requests/día | Media | ⚠️ Conocido | Cache en Firestore mitiga el problema |

## Backlog de mejoras futuras

| ID | Descripción | Prioridad |
|----|-------------|-----------|
| BACK-001 | Pantalla de admin para cambiar status y role de usuarios | Alta |
| BACK-002 | Notificaciones push cuando un producto está próximo a vencer | Alta |
| BACK-003 | Modo oscuro completo | Baja |
| BACK-004 | Tests de integración end-to-end | Media |
| BACK-005 | Crashlytics para monitoreo de errores en producción | Media |
| BACK-006 | Exportar lista de despensa a PDF | Baja |

## Leyenda

- ✅ **Resuelto** — corregido en este RC
- ⚠️ **Pendiente** — conocido, sin resolver
- 🔄 **En progreso** — alguien trabajando en ello
