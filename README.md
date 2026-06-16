[🇨🇴 Español](#español) · [🇺🇸 English](#english)

---

## <a name="español">🇨🇴 Español</a>

# LastBite 🌿

Aplicación móvil desarrollada en Flutter que ayuda a los usuarios a gestionar los productos de su despensa, reduciendo el desperdicio de alimentos mediante alertas de vencimiento, persistencia local y sincronización con Firebase.

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

---

## <a name="english">🇺🇸 English</a>

# LastBite 🌿

A mobile app developed in Flutter that helps users manage the items in their pantry, reducing food waste through expiration alerts, local storage, and synchronization with Firebase.

## Problem Description

Food waste at home occurs mainly because people do not keep track of what they have in their pantry or of expiration dates. LastBite allows users to log items, receive alerts before they expire, and mark them as consumed, encouraging the use of food.

---

## Implemented Roles

| Role | Description |
|---|---|
| `admin` | Can view all pantry items |
| `active` | Can add, view, and consume their own items |
| `viewer` | Can only view items; cannot add or remove them |

---

## Test Users

| Email | Password | Role | Status | What it allows |
|---|---|---|---|---|
| active@lastbite.com | Test1234! | active | active | Full access: add, consume, delete |
| admin@lastbite.com | Test1234! | admin | active | Administrator access |
| viewer@lastbite.com | Test1234! | viewer | active | Read-only, cannot add or delete |
| blocked@lastbite.com | Test1234! | active | blocked | Login screen blocked |
| pending@lastbite.com | Test1234! | active | pendingApproval | Account pending screen |

---

## Main Entities

| Entity | Description |
|---|---|
| `User` | Authenticated profile with role and account status, stored in Firestore |
| `Product` | Pantry item with name, category, quantity, expiration date, and syncStatus |
| `Alert` | Notification automatically generated based on the product's remaining days |
| `Consumption` | Record of products marked as consumed (saved) |
| `PantryStatistics` | Summary of products saved by user |

---

## Modeling in Firestore

```
users/{uid}
  - uid, name, email, role, status, createdAt, lastLoginAt

users/{uid}/products/{productId}
  - id, name, emoji, category, quantity, expirationDate,
    isFresh, barcode, imageUrl, syncStatus

users/{uid}/statistics/summary
  - saved

users/{uid}/suggestedRecipes/{recipeId}
  - urgentIngredientsUsed, ...
```

Each product belongs to the authenticated user. Statistics are updated with `FieldValue.increment` to avoid race conditions. Suggested recipes are automatically invalidated when an urgent ingredient is consumed.

---

## Business Rules

1. A `blocked` user cannot access the main module.
2. A `pendingApproval` user cannot create or modify records.
3. A `viewer` user has read-only access.
4. An expired product must be deleted, not consumed.
5. Only an `admin` can delete other users' products.
6. A product created offline has `syncStatus = pendingSync`.
7. When the connection is restored, pending products are automatically synced with Firestore.
8. A product with negative days remaining automatically changes to `expired` status.

---

## Product Business Statuses

| Status | Condition |
|---|---|
| `available` | More than 3 days until expiration |
| `urgent` | Between 1 and 3 days until expiration |
| `critical` | 1 day or less until expiration |
| `expired` | Expiration date passed |

**Allowed transitions:**
- `available` → `urgent` → `critical` → `expired` (automatic by date)
- `available / urgent / critical` → consumed (user action)
- `expired` → deleted (cannot be consumed)

---

## Main Flow

1. The user opens the app and sees the login screen.
2. The user logs in with their email and password (or Google).
3. The app retrieves the user’s profile from Firestore and checks the `status` and `role`.
4. Depending on the status: `blocked` → blocked screen, `pendingApproval` → waiting screen, `active` → home screen.
5. On the home screen, they see their pantry sorted by urgency.
6. They can add a product manually or by scanning a barcode.
7. They receive automatic alerts based on days remaining.
8. They can mark a product as consumed (add to saved items) or delete it.

---

## Authentication

Firebase Authentication is used with email/password and Google Sign-In. Upon login, the app queries the `users/{uid}` document in Firestore to obtain the user’s `role` and `status`. The session persists across app closures. Internal screen protection is handled via redirection in the `authStateProvider` using Riverpod.

---

## Roles and Permissions

Permissions are centralized in `PermissionService` (`lib/core/services/permission_service.dart`), completely separate from the user interface. Example:

```dart
bool canAddProduct(AuthUser user)     // active and admin: yes. viewer, blocked, pending: no
bool canConsumeProduct(AuthUser user, Product product)  // no if expired or viewer
bool canDeleteAnyProduct(AuthUser user)  // admin only
bool canAccessMainModule(AuthUser user)     // no if blocked or pendingApproval
```

---

## Local Persistence

**Drift** (SQLite) is used to store products locally on the device. This allows you to:

- View products even if Firebase fails or there is no connection.
- Save records created offline with `syncStatus = pendingSync`.
- Identify which records are pending synchronization.

The local database is defined in `lib/features/despensa/data/app_database.dart`.

---

## Synchronization with Firebase

Synchronization flow:

```
User adds product
→ saved to local DB (Drift)
→ if connected → sent to Firestore → syncStatus = synced
→ if not connected → syncStatus = pendingSync
→ upon regaining connection → syncPending() uploads pending items to Firestore
→ syncStatus is updated to synced locally and remotely
```

The synchronization logic is in `DespensaRepository.sincronizarPendientes()` and is automatically triggered from the `conectividadProvider` in the notifier.

---

## Instructions for running the project

**Requirements:** Flutter SDK ^3.11.4, Android Studio or VS Code, Android emulator or physical device.

```bash
# 1. Clone the repository
git clone <repository-url>
cd lastbite

# 2. Install dependencies
flutter pub get

# 3. Run on emulator or device
flutter run
```

The `google-services.json` file must be in `android/app/`. If it is not included for security reasons, request it from the team.

---

## Instructions for generating the APK

```bash
flutter build apk
```

The APK is generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

To install directly on a connected device:
```bash
flutter install
```
