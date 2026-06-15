# LastBite

App de gestión inteligente de despensa que reduce desperdicios de alimentos mediante alertas de vencimiento, sugerencia automática de recetas y escaneo de códigos de barras.

## 🎯 Concepto

LastBite ayuda a usuarios a **aprovechar completamente sus alimentos** antes de que se vuelvan inadecuados para el consumo. La app sugiere recetas automáticamente basadas en ingredientes próximos a vencer, considerando las fechas de caducidad y categorías de productos.

---

## ✨ Funcionalidades Principales

### 1. **Gestión de Despensa**
- Visualización de todos los alimentos agregados
- Información clara de cantidad, categoría y días restantes hasta vencimiento
- Clasificación automática por nivel de urgencia
- Estados visuales para productos: frescos, próximos a vencer, vencidos

### 2. **Agregación de Productos**

#### Escaneo de Códigos de Barras
- Integración con **OpenFoodFacts API** para obtener información automática del producto
- Búsqueda en orden: Colombia → Base mundial
- Campos capturados: nombre, categoría, cantidad, imagen
- Fallback a ingreso manual si el código no se encuentra

#### Ingreso Manual
- Formulario para agregar productos sin código de barras
- Selección de categoría con emojis descriptivos
- Especificación manual de cantidad

### 3. **Cálculo Automático de Fechas de Vencimiento**
La app utiliza la tabla `vida_util` que define días recomendados por categoría:
- Verduras/Frutas/Hierbas: 5-7 días
- Proteínas (Carne/Pollo/Pescado): 2-3 días
- Lácteos (Leche/Yogur/Queso): 8-30 días
- Granos/Conservas: 180-365 días
- Y más categorías...

Estos valores se calculan automáticamente desde la fecha de agregación.

### 4. **Motor de Recetas Inteligente** 🚀

#### Generación Automática
- Usa **Spoonacular API** para obtener recetas basadas en ingredientes disponibles
- Prioriza automáticamente productos próximos a vencer
- Genera recetas solo cuando existen ingredientes de la despensa actual
- Caché inteligente: evita llamadas innecesarias si los ingredientes urgentes no cambian

#### Traducción Contextual
- **MyMemory Translation API** para traducción de recetas del inglés al español
- Contexto culinario para mejorar precisión de traducción
- Traduce ingredientes, títulos e instrucciones en paralelo
- Caché de traducciones para optimizar rendimiento
- Avisos al usuario si hay limitaciones en la traducción

#### Búsqueda Manual
- Búsqueda por nombre de receta
- Búsqueda por ingrediente específico
- Información detallada: instrucciones, tiempo de preparación, porciones, likes

### 5. **Notificaciones y Alertas**
- Alertas en 4 niveles:
  - ⚠️ **Aviso 1 día**: "vence mañana"
  - 🕐 **Aviso 3 días**: "planifica una receta"
  - 🚨 **Vencido**: "retíralo de tu despensa"
  - Aviso 5 días: sin push (solo en app)
- Notificaciones solo si hay cambios en los productos urgentes
- Deep linking: toca la notificación para ir a la pantalla de alertas
- Permisos de notificaciones solicitados al iniciar sesión

---

## 🏗️ Arquitectura Técnica

### Stack Tecnológico
- **Framework**: Flutter (Dart 3.11.4+)
- **State Management**: Flutter Riverpod
- **Backend**: Firebase (Auth, Firestore, Cloud Messaging)
- **Networking**: Dio
- **Escaneo**: mobile_scanner
- **Autenticación**: Google Sign-In
- **Notificaciones**: firebase_messaging + flutter_local_notifications

### APIs Externas
| Servicio | Propósito | Base URL |
|----------|-----------|----------|
| **OpenFoodFacts** | Búsqueda de productos por barcode | `api.openfoodfacts.org` |
| **Spoonacular** | Búsqueda de recetas por ingredientes | `api.spoonacular.com` |
| **MyMemory** | Traducción de recetas al español | `api.mymemory.translated.net` |

### Estructura de Carpetas
```
lib/
├── core/
│   ├── navigation/          # Rutas y navegación
│   ├── notifications/       # Servicio de notificaciones y verificación de vencimientos
│   ├── theme/              # Tema de la app (colores, tipografía)
│   └── constants/          # Constantes globales (vida_util)
│
├── features/
│   ├── auth/               # Autenticación con Firebase + Google Sign-In
│   ├── despensa/           # Gestión de productos en despensa
│   ├── agregar/            # Escaneo de códigos + ingreso manual
│   ├── recetas/            # Motor de recetas con traducción
│   └── alertas/            # Pantalla de alertas de vencimiento
│
└── main.dart              # Entry point de la app
```

### Flujo de Datos
1. **Usuario inicia sesión** → Firebase Auth (Google Sign-In)
2. **App solicita permisos** → Notificaciones locales
3. **Verifica vencimientos** → VencimientoChecker ejecuta cada 3 segundos
4. **Usuario agrega producto**:
   - Escanea código → OpenFoodFacts extrae info
   - O ingresa manualmente
5. **Calcula vencimiento** → usa tabla vida_util
6. **En pantalla Recetas**:
   - Lee productos urgentes de Firestore
   - Busca recetas en Spoonacular
   - Traduce ingredientes/instrucciones vía MyMemory
   - Cachea resultados para optimizar
7. **Genera alertas** → NotificationService notifica solo si hay cambios

---

## 📱 Pantallas Principales

- **Despensa**: Lista de todos los alimentos con estado de urgencia
- **Agregar**: Escaneo de código de barras + formulario manual
- **Recetas**: Motor de recetas con búsqueda y filtros
- **Alertas**: Historial de notificaciones y productos vencidos

---

## 🔐 Autenticación y Datos

- **Firebase Authentication**: Solo Google Sign-In
- **Cloud Firestore**: Almacena productos por usuario
  - Colección: `users/{userId}/despensa/`
  - Colección: `users/{userId}/alertas/`
  - Colección: `users/{userId}/recetas_cache/`

---

## 🚀 Configuración y Variables de Entorno

### Variables Requeridas
```bash
# Ejecutar con Spoonacular API Key
flutter run --dart-define=SPOONACULAR_API_KEY=tu_api_key_aqui
```

Si no se proporciona la key, la app lanzará excepción:
```
'Falta SPOONACULAR_API_KEY. Usa --dart-define=SPOONACULAR_API_KEY=...'
```

### Configuración de Firebase
1. Crear proyecto en Firebase Console
2. Descargar `google-services.json` (Android) y `GoogleService-Info.plist` (iOS)
3. Configurar OAuth con Google (credenciales OAuth)

---

## 📊 Estado del Proyecto
- ✅ Escaneo y búsqueda de productos (OpenFoodFacts)
- ✅ Gestión de despensa en Firestore
- ✅ Motor de recetas con Spoonacular
- ✅ Traducción contextual de recetas
- ✅ Sistema de alertas de vencimiento
- ✅ Autenticación con Google
- 🔄 En desarrollo: Mejoras UI/UX, optimizaciones de caché

---

## 🎨 Diseño y UX

- Tema personalizado con colores accent, surface y paleta de peligro
- Fuente: Montserrat (weights: Regular, Medium, SemiBold, Bold, Black)
- Bottom navigation bar flotante con 4 pestañas
- Emojis descriptivos para categorías de productos

---

## 🛠️ Instalación y Ejecución

### Requisitos
- Flutter SDK 3.11.4+
- Dart 3.11.4+
- Android SDK (para Android) / Xcode (para iOS)

### Pasos
```bash
# Clonar repositorio
git clone https://github.com/aaronHenao/LastBite.git
cd LastBite

# Instalar dependencias
flutter pub get

# Configurar Firebase (descargar archivos de configuración)
# Ver sección "Configuración y Variables de Entorno"

# Ejecutar en desarrollo
flutter run --dart-define=SPOONACULAR_API_KEY=tu_api_key_aqui
```

---

## 📚 Recursos y Documentación

- [Flutter Docs](https://flutter.dev)
- [Firebase for Flutter](https://firebase.flutter.dev)
- [Riverpod State Management](https://riverpod.dev)
- [OpenFoodFacts API](https://world.openfoodfacts.org/api)
- [Spoonacular API](https://spoonacular.com/food-api)
- [MyMemory Translation API](https://mymemory.translated.net)

---

## 👨‍💻 Autores y Contribuidores

Desarrollado por Aaron Henao

---

## 📄 Licencia

Este proyecto se distribuye bajo licencia privada. No está publicado en pub.dev.
