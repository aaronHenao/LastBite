# Release Candidate — LastBite v1.0.0-rc1

**Fecha:** Mayo 2026
**Versión:** 1.0.0+1
**Build:** APK Debug

---

## ✅ Funcionalidades incluidas

### Autenticación
- Login con email/contraseña via Firebase Auth
- Login con Google
- Registro de usuarios con creación automática de perfil en Firestore
- Cierre de sesión
- Redirección automática según `status` del usuario

### Roles y estados de cuenta
- 3 roles: `admin`, `active`, `viewer`
- 3 estados: `active`, `blocked`, `pendingApproval`
- `BlockedScreen` para usuarios bloqueados
- `PendingScreen` para usuarios pendientes
- `PermissionService` con 8 reglas de negocio separadas de la UI

### Despensa
- Ver lista de productos ordenada por días restantes
- Productos urgentes destacados (≤ 3 días)
- Marcar producto como consumido (suma a "Salvados")
- Eliminar producto
- Agregar manualmente o por código de barras
- Estadísticas: total, urgentes, salvados

### Estados visuales de UI
- Estado vacío: "No tienes productos aún"
- Estado de error con botón reintentar
- Skeleton animado mientras carga
- Banner "Sin conexión" cuando no hay internet
- Badge naranja `pendingSync` en cards
- SnackBar verde de éxito al guardar

### Offline-first
- Guardado local con Drift antes de intentar Firestore
- `syncStatus`: synced / pendingSync / failedSync
- Retry automático al recuperar conexión
- Botón bloqueado después del primer clic para evitar duplicados

### Pruebas automatizadas
- 10 unit tests (reglas de negocio, permisos por rol, alertas)
- 6 widget tests (estados visuales, pantallas de cuenta)

### Entidades
- `AuthUser` — usuario con rol y status
- `Producto` — con syncStatus y estado de negocio
- `Alerta` — notificaciones automáticas por vencimiento
- `Consumo` — historial de productos salvados
- `EstadisticasDespensa` — métricas del usuario

### Alertas y Recetas
- Alertas automáticas por productos próximos a vencer
- Búsqueda de recetas con ingredientes urgentes via Spoonacular

---

## ⚠️ Funcionalidades pendientes

- Pantalla de administración de usuarios (cambiar roles/status desde la app)
- Google Sign-In requiere SHA-1 configurado (ya configurado en Firebase Console)
- Modo oscuro completo

---

## 🔴 Riesgos conocidos

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|------------|
| Fallo de sincronización en dispositivos lentos | Media | Alto | Badge pendingSync + retry automático |
| API Spoonacular tiene límite de 150 requests/día en plan gratuito | Alta | Medio | Cache de recetas en Firestore |
| Usuarios sin documento en Firestore asumen `active` por defecto | Baja | Medio | AuthService crea documento automáticamente |

---

## ✅ Decisión del equipo

**La app está lista para entrega.** Todas las funcionalidades obligatorias están implementadas y probadas. Los riesgos conocidos tienen mitigaciones en el código.
