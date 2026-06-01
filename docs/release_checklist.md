# ✅ Release Checklist — LastBite v1.0.0

## Código
- [x] `flutter analyze` sin errores críticos
- [x] `flutter test` — todos los tests pasan (unit + widget)
- [x] No hay errores de compilación
- [x] Archivos `.g.dart` de Drift generados con `build_runner`

## Firebase / Firestore
- [x] Proyecto Firebase configurado con nuevo `firebase_options.dart`
- [x] Authentication habilitado: email/contraseña y Google
- [x] SHA-1 configurado en Firebase Console para Google Sign-In
- [x] Reglas de Firestore publicadas
- [x] Los 4 usuarios de prueba creados y verificados
- [x] Campo `status` y `role` en documentos de Firestore

## UI / Funcionalidad
- [x] Estado vacío se muestra cuando no hay productos
- [x] Estado de error se muestra cuando Firestore falla
- [x] Skeleton de carga visible durante la carga inicial
- [x] Banner "Sin conexión" visible al desconectar internet
- [x] Badge `pendingSync` visible en cards
- [x] SnackBar verde al guardar/consumir producto
- [x] `_AuthGate` redirige correctamente según `status`
- [x] Logout funciona desde `BlockedScreen` y `PendingScreen`
- [x] Botón guardar se bloquea después del primer clic

## Roles y permisos
- [x] `PermissionService` implementado con 8 reglas
- [x] 3 roles funcionales: admin, active, viewer
- [x] 3 estados de cuenta: active, blocked, pendingApproval
- [x] Roles afectan comportamiento real de la app

## Offline-first
- [x] Producto se guarda localmente aunque Firestore falle
- [x] `syncStatus = pendingSync` sin conexión
- [x] Retry automático al recuperar conexión
- [x] Producto synced no se reintenta

## Tests
- [x] 10 unit tests pasan
- [x] 6 widget tests pasan
- [x] `flutter test` corre sin errores

## Documentación
- [x] `README.md` completo con todos los campos requeridos
- [x] `docs/pruebas.md` con evidencia de pruebas manuales y automatizadas
- [x] `docs/rc_candidate.md` con funcionalidades y riesgos
- [x] `docs/release_checklist.md` (este archivo)
- [x] `docs/bugs-backlog.md` con bugs documentados

## APK
- [x] `flutter build apk --debug` corre sin errores
- [x] APK instalada en dispositivo físico (moto g 60, Android 12)
- [x] App abre correctamente sin crashear
- [x] Login funciona con los 4 usuarios de prueba
- [x] Flujo completo probado en dispositivo físico

---

**Responsables: Isabella, Sofía y Aaron
