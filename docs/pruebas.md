# 🧪 Pruebas — LastBite

## Pruebas manuales por rol y estado de cuenta

| # | Usuario | Acción | Resultado esperado | ✅/❌ |
|---|---------|--------|--------------------|-------|
| 1 | `active@lastbite.com` | Iniciar sesión | Accede a MainShell (despensa) | ✅ |
| 2 | `blocked@lastbite.com` | Iniciar sesión | Muestra BlockedScreen | ✅ |
| 3 | `pending@lastbite.com` | Iniciar sesión | Muestra PendingScreen | ✅ |
| 4 | `admin@lastbite.com` | Iniciar sesión | Accede a MainShell | ✅ |
| 5 | `blocked@lastbite.com` | Cerrar sesión desde BlockedScreen | Redirige a LoginScreen | ✅ |
| 6 | `pending@lastbite.com` | Cerrar sesión desde PendingScreen | Redirige a LoginScreen | ✅ |

## Pruebas de despensa

| # | Acción | Resultado esperado | ✅/❌ |
|---|--------|--------------------|-------|
| 7 | Abrir app sin productos | Muestra "No tienes productos aún" | ✅ |
| 8 | Simular error de Firestore | Muestra ErrorDespensaState con botón reintentar | ✅ |
| 9 | Cargar despensa | Aparece skeleton animado mientras carga | ✅ |
| 10 | Agregar producto exitosamente | Aparece SnackBar verde de confirmación | ✅ |
| 11 | Dar clic dos veces en guardar | El botón se bloquea al primer clic | ✅ |
| 12 | Producto con syncStatus = pendingSync | Muestra PendingSyncBadge naranja | ✅ |

## Flujo sin conexión

| # | Paso | Resultado esperado | ✅/❌ |
|---|------|--------------------|-------|
| 13 | Desactivar WiFi y datos | Aparece OfflineBanner gris en la parte superior | ✅ |
| 14 | Agregar producto sin conexión | Producto queda con syncStatus = pendingSync | ✅ |
| 15 | Botón guardar sin conexión | Se bloquea después del primer clic | ✅ |
| 16 | Reconectar WiFi | Producto se sincroniza y badge desaparece | ✅ |
| 17 | Producto synced | No genera nueva llamada a Firestore | ✅ |

## Flujo principal completo

```
1. Usuario abre la app
2. Inicia sesión con active@lastbite.com
3. AuthService lee status y role desde Firestore
4. _AuthGate redirige a MainShell
5. DespensaScreen carga productos desde Firestore
6. Usuario agrega un producto manualmente
7. Producto se guarda en Firestore con syncStatus = synced
8. Aparece SnackBar verde "producto agregado"
9. Usuario desactiva internet
10. Banner "Sin conexión" aparece
11. Usuario intenta agregar otro producto
12. Producto se guarda con syncStatus = pendingSync
13. Badge naranja aparece en la card
14. Usuario reactiva internet
15. Producto se sincroniza automáticamente
16. Badge desaparece
```

---

## Evidencia de unit tests

```bash
flutter test test/unit_test.dart
```

Resultado:
```
✅ TEST 1: Usuario active puede agregar producto
✅ TEST 2: Usuario blocked NO puede agregar producto
✅ TEST 3: Usuario pendingApproval NO puede agregar producto
✅ TEST 4: Producto sin conexión queda como pendingSync
✅ TEST 5: Producto synced no necesita reintento
✅ TEST 6a: 5 días → aviso5
✅ TEST 6b: 3 días → aviso3
✅ TEST 6c: 1 día → aviso1
✅ TEST 6d: vencido → alerta vencido
✅ TEST 6e: 10 días → sin alerta
✅ TEST 7: Viewer no puede agregar producto
✅ TEST 8: Admin puede eliminar cualquier producto
✅ TEST 9: Producto vencido debe eliminarse no consumirse
✅ TEST 10: Estados de negocio del producto correctos

00:02 +10: All tests passed!
```

## Evidencia de widget tests

```bash
flutter test test/widget_test.dart
```

Resultado:
```
✅ TEST 1: Estado vacío se muestra correctamente
✅ TEST 2: Estado de error se muestra correctamente
✅ TEST 3: BlockedScreen se muestra correctamente
✅ TEST 4: PendingScreen se muestra correctamente
✅ TEST 5: PendingSyncBadge se muestra correctamente
✅ TEST 6: OfflineBanner se muestra correctamente

00:01 +6: All tests passed!
```
