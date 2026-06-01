# LastBite 🌿

Aplicación móvil desarrollada en Flutter que ayuda a los usuarios a gestionar los productos de su despensa, reduciendo el desperdicio de alimentos mediante alertas de vencimiento, persistencia local y sincronización con Firebase.

---

## Integrantes del equipo

| Nombre |
|---|
| Isabella |
| Sofía |
| Aaron |

---

## Descripción del problema

El desperdicio de alimentos en el hogar ocurre principalmente porque las personas no llevan un registro de lo que tienen en su despensa ni de las fechas de vencimiento. LastBite permite registrar productos, recibir alertas antes de que venzan y marcarlos como consumidos, incentivando el aprovechamiento de los alimentos.

---

## Roles implementados

| Rol | Descripción |
|---|---|
| `admin` | Puede ver todos los productos de la despensa |
| `active` | Puede agregar, ver y consumir sus propios productos |
| `viewer` | Solo puede ver productos, sin agregar ni eliminar |

---

## Usuarios de prueba

| Correo | Contraseña | Rol | Estado | Qué permite validar |
|---|---|---|---|---|
| active@lastbite.com | Test1234! | active | active | Acceso completo: agregar, consumir, eliminar |
| admin@lastbite.com | Test1234! | admin | active | Acceso como administrador |
| viewer@lastbite.com | Test1234! | viewer | active | Solo lectura, sin agregar ni eliminar |
| blocked@lastbite.com | Test1234! | active | blocked | Pantalla de acceso bloqueado |
| pending@lastbite.com | Test1234! | active | pendingApproval | Pantalla de cuenta pendiente |

---

## Entidades principales

| Entidad | Descripción |
|---|---|
| `Usuario` | Perfil autenticado con rol y estado de cuenta, almacenado en Firestore |
| `Producto` | Ítem de despensa con nombre, categoría, cantidad, fecha de caducidad y syncStatus |
| `Alerta` | Notificación generada automáticamente según días restantes del producto |
| `Consumo` | Registro de productos marcados como consumidos (salvados) |
| `EstadísticasDespensa` | Resumen de productos salvados por usuario |

---

## Modelado en Firestore

```
users/{uid}
  - uid, name, email, role, status, createdAt, lastLoginAt

users/{uid}/productos/{productoId}
  - id, nombre, emoji, categoria, cantidad, fechaCaducidad,
    esFresco, codigoBarras, imagenUrl, syncStatus

users/{uid}/estadisticas/resumen
  - salvados

users/{uid}/recetas_sugeridas/{recetaId}
  - ingredientesUrgentesUsados, ...
```

Cada producto pertenece al usuario autenticado. Las estadísticas se actualizan con `FieldValue.increment` para evitar condiciones de carrera. Las recetas sugeridas se invalidan automáticamente cuando se consume un ingrediente urgente.

---

## Reglas de negocio

1. Un usuario `blocked` no puede acceder al módulo principal.
2. Un usuario `pendingApproval` no puede crear ni modificar registros.
3. Un usuario `viewer` solo tiene acceso de lectura.
4. Un producto vencido debe eliminarse, no consumirse.
5. Solo un `admin` puede eliminar productos de otros usuarios.
6. Un producto creado sin conexión queda con `syncStatus = pendingSync`.
7. Al recuperar conexión, los productos pendientes se sincronizan automáticamente con Firestore.
8. Un producto con días restantes negativos cambia automáticamente a estado `vencido`.

---

## Estados de negocio del producto

| Estado | Condición |
|---|---|
| `disponible` | Más de 3 días para vencer |
| `urgente` | Entre 1 y 3 días para vencer |
| `critico` | 1 día o menos para vencer |
| `vencido` | Fecha de caducidad superada |

**Transiciones permitidas:**
- `disponible` → `urgente` → `critico` → `vencido` (automático por fecha)
- `disponible / urgente / critico` → consumido (acción del usuario)
- `vencido` → eliminado (no se puede consumir)

---

## Flujo principal

1. El usuario abre la app y ve la pantalla de login.
2. Ingresa con correo y contraseña (o Google).
3. La app consulta su perfil en Firestore y verifica `status` y `role`.
4. Según el estado: `blocked` → pantalla bloqueado, `pendingApproval` → pantalla espera, `active` → home.
5. En el home ve su despensa ordenada por urgencia.
6. Puede agregar un producto manualmente o escaneando código de barras.
7. Recibe alertas automáticas según días restantes.
8. Puede marcar un producto como consumido (suma a salvados) o eliminarlo.

---

## Autenticación

Se usa Firebase Authentication con correo/contraseña y Google Sign-In. Al iniciar sesión, la app consulta el documento `users/{uid}` en Firestore para obtener el `role` y `status` del usuario. La sesión persiste entre cierres de la app. La protección de pantallas internas se hace mediante redirección en el `authStateProvider` con Riverpod.

---

## Roles y permisos

Los permisos están centralizados en `PermissionService` (`lib/core/services/permission_service.dart`), separado completamente de la interfaz gráfica. Ejemplo:

```dart
bool puedeAgregarProducto(AuthUser user)     // active y admin: sí. viewer, blocked, pending: no
bool puedeConsumirProducto(AuthUser user, Producto producto)  // no si vencido o viewer
bool puedeEliminarCualquierProducto(AuthUser user)  // solo admin
bool puedeAccederModuloPrincipal(AuthUser user)     // no si blocked o pendingApproval
```

---

## Persistencia local

Se usa **Drift** (SQLite) para almacenar los productos localmente en el dispositivo. Esto permite:

- Consultar productos aunque Firebase falle o no haya conexión.
- Guardar registros creados offline con `syncStatus = pendingSync`.
- Identificar qué registros están pendientes de sincronización.

La base de datos local se define en `lib/features/despensa/data/app_database.dart`.

---

## Sincronización con Firebase

Flujo de sincronización:

```
Usuario agrega producto
→ se guarda en DB local (Drift)
→ si hay conexión → se envía a Firestore → syncStatus = synced
→ si no hay conexión → syncStatus = pendingSync
→ al recuperar conexión → sincronizarPendientes() sube los pendientes a Firestore
→ syncStatus se actualiza a synced en local y remoto
```

La lógica de sincronización está en `DespensaRepository.sincronizarPendientes()` y se dispara automáticamente desde el `conectividadProvider` en el notifier.

---

## Instrucciones para ejecutar el proyecto

**Requisitos:** Flutter SDK ^3.11.4, Android Studio o VS Code, emulador Android o dispositivo físico.

```bash
# 1. Clonar el repositorio
git clone <url-del-repositorio>
cd lastbite

# 2. Instalar dependencias
flutter pub get

# 3. Ejecutar en emulador o dispositivo
flutter run
```

El archivo `google-services.json` debe estar en `android/app/`. Si no está incluido por seguridad, solicitarlo al equipo.

---

## Instrucciones para generar el APK

```bash
flutter build apk
```

El APK se genera en:
```
build/app/outputs/flutter-apk/app-release.apk
```

Para instalar directamente en un dispositivo conectado:
```bash
flutter install
```
