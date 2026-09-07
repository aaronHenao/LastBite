# Auditoría de UI/UX — LastBite

Seis auditorías en paralelo sobre las doce pantallas de la app. 145 hallazgos.
Este documento no los repite todos: agrupa lo que se repite entre pantallas,
separa lo que está funcionalmente roto de lo que está feo, y ordena por dónde
conviene empezar.

Cada hallazgo está verificado contra el código con archivo y línea.

---

## Lo más importante en cuatro frases

1. **La app tiene escrita la lógica de urgencia y no la usa.** `AppTheme.diasColor`
   y `Alerta.prioridad` tienen **cero usos** en todo el repositorio. Cada pantalla
   reimplementó una escala binaria por su cuenta.
2. **Los tokens de color no se distinguen entre sí.** `AppColors.yellow` es byte a
   byte igual a `surface`, y `accent` da 2.01:1 sobre el fondo. Tres de los cinco
   colores de marca no se pueden leer.
3. **Hay 18 fallas funcionales**, no visuales: datos que se guardan mal, listas
   que mienten sobre su contenido, llamadas duplicadas a una API paga.
4. **La misma decisión se resolvió distinto en cada pantalla**: ocho radios, cinco
   implementaciones del botón "volver", tres copias divergentes del mapa de
   emojis.

---

## Parte 1 — Patrones transversales

Lo que aparece en tres o más pantallas. Arreglar acá rinde más que arreglar
pantalla por pantalla.

### 1.1 La escala de urgencia no existe

| Dónde | Qué pasa |
|---|---|
| `app_theme.dart:105-119` | `diasColor`, `diasBackground` y `diasLabel` no se llaman desde ningún archivo. |
| `producto_card.dart:20` | Reimplementa una escala binaria `danger`/`green`: salto seco del día 3 al 4. |
| `alerta_card.dart:109-119` | `aviso1` y `vencido` devuelven el mismo `danger`. |
| `alertas_provider.dart:101` | Ordena por `creadaEn`; `Alerta.prioridad` (`alerta.dart:31-42`) no se usa. |
| `consulta_rapida_screen.dart:262-272` | Tercera escala, con `switch` sobre strings y `default` verde. |
| `receta_card.dart:99-103` | Cuarta escala, para el porcentaje de match. |

Consecuencia: la información más importante de la app —cuánto le queda a un
alimento— se comunica de cuatro maneras distintas, ninguna completa.

### 1.2 Contraste por debajo del mínimo

Todos medidos sobre el fondo real de cada caso.

| Elemento | Ratio | Ubicación |
|---|---|---|
| Botón primario, texto blanco sobre `accent` | **2.10:1** | `login:155`, `register:194`, `perfil_screen:381` |
| Etiqueta de campo (`green` α0.7) | **2.40:1** | `auth_field.dart:46-52` |
| Placeholder (`green` α0.5) | **1.80:1** | `auth_field.dart:46-52` |
| Código de invitación (`green` sobre `surface`) | **2.80:1** | `compartida_screen.dart:342` |
| `CircularProgressIndicator` (`accent` sobre `bg`) | **2.01:1** | despensa, alertas, consulta rápida, recetas |
| Chip "próximo a vencer" (`accent` sobre `accent` α0.14) | **1.90:1** | `consulta_rapida_screen.dart:202-224` |
| Badge de match 50-79% (`yellow` sobre blanco) | **1.30:1** | `receta_card.dart:193-199` |
| Aviso de traducción (`yellow` α0.16) | **1.33:1** | `alertas_screen.dart:129-143` |
| Alerta de 5 días (`yellow`) | **1.33:1** | `alerta_card.dart:52-56` |

Mínimo WCAG AA para texto normal: 4.5:1. Para texto grande: 3:1.

**Bug de alpha**: `AppColors.textMuted.withValues(alpha: 0.9)` aparece en tres
pantallas. `textMuted` ya trae alpha 0.6, y `withValues` **reemplaza** el valor
en vez de multiplicarlo: el texto sale más oscuro que `textMuted`, lo contrario
de lo buscado. `compartida_screen.dart:72`, `perfil_screen.dart:55`,
`despensa_screen.dart`.

### 1.3 El tema tipográfico no gobierna nada

`fontSize` y `fontWeight` escritos a mano en las seis pantallas. Casos donde se
reinventa un escalón que ya existe:

- `bodyLarge.copyWith(fontSize: 24, fontWeight: w800)` en `recetas_screen.dart:396`
  y `alertas_screen.dart:95` — `displaySmall` ya es 24/w700.
- `fontSize: 28` a mano en `register_screen.dart:104` — `displayMedium` es 28/w700.
- `alerta_card.dart` no llama a `Theme.of(context)` ni una vez.
- Tamaños por debajo del escalón mínimo del tema (11px): 8, 9 y 10 en
  `miembro_tile.dart:120`, `despensa_screen.dart:889`, `perfil_screen.dart:512`.

### 1.4 Ocho radios para las mismas superficies

10, 12, 14, 16, 18, 20, 22 y 24 conviviendo. La tarjeta de producto usa 20, la de
alerta 18, la de stats 12, la de acción en compartida 18, la de miembro 14. La
misma pastilla de estado tiene radio 12 en `alerta_card` y 999 en
`consulta_rapida`.

### 1.5 Zonas de toque por debajo de 44x44

| Control | Tamaño | Ubicación |
|---|---|---|
| Botón invisible que salta a Despensa | **~8x8** | `agregar_screen.dart:97-106` |
| Check de "comprado" | 24 | `perfil_screen.dart:420-439` |
| Conmutador de orden de recetas | ~27 alto | `recetas_screen.dart:765-806` |
| "← Volver" | ~28 alto | `compartida:66`, `perfil:44`, `register:88` |
| Botones del conmutador de modo | ~36 | `agregar_screen.dart:223` |
| "Borrar todo" | 36 | `alertas_screen.dart:106-117` |
| Avatar (único acceso a perfil y ajustes) | 40x40 | `despensa_screen.dart:103-135` |

### 1.6 Responsive incompleto

- **Sin `ResponsiveContainer`**: `despensa_screen.dart:64` y
  `consulta_rapida_screen.dart:64`. Son las dos únicas pantallas de las doce que
  no lo usan; en web se estiran a todo el viewport.
- **`Responsive.gridColumns` ignorado**: `recetas_screen.dart:110` fija
  `crossAxisCount: 2` y `alertas_screen.dart:199` no cambia en ningún ancho.
- **Columna única a 1440px**: perfil y alertas dejan dos tercios de pantalla vacíos.
- **140px de vacío** al final del formulario de agregar en tablet y web: reservan
  espacio para una barra flotante que en esos anchos no existe
  (`agregar_screen.dart:93`).

### 1.7 Movimiento ausente

Cero `Animated*` y cero `Curves` en despensa, alertas, compartida y perfil. La
lista aparece de golpe, un producto consumido se esfuma sin transición, un
miembro expulsado desaparece sin que el ojo lo registre.

`agregar_screen.dart:130` ya lo resuelve bien —`AnimatedSwitcher` de 240ms con
`easeOut`— y es el patrón a replicar. El único movimiento fuera de ahí,
`recetas_screen.dart:778`, usa la curva por defecto (`linear`) en vez de `ease`.

### 1.8 Errores crudos sin salida

Las seis pantallas muestran `'$e'` directo: el usuario lee excepciones de
Firestore y códigos HTTP. Solo recetas ofrece "Reintentar". El caso más visible:
cerrar la hoja de Google en el login muestra un recuadro rojo que dice
`Exception: Login cancelado`, como si el usuario hubiera roto algo
(`login_screen.dart:59`).

### 1.9 Acciones destructivas escondidas

- **Borrar una alerta**: `onHorizontalDragEnd` con velocidad negativa. Sin indicio,
  sin confirmación, sin deshacer, sin alternativa. En web solo se puede
  arrastrando con el mouse (`alertas_screen.dart:204-212`).
- **Borrar un ítem de compras**: `onLongPress`, sin confirmación
  (`perfil_screen.dart:405`). Mientras tanto "Limpiar comprados" sí confirma:
  borrar uno es más fácil y más peligroso que borrar todos.

### 1.10 El mismo control, cinco implementaciones

"← Volver" está copiado en `register:91`, `compartida:69`, `perfil:53` y
`perfil_nutricional:66`, con tres calidades distintas: unos con `InkWell` y
padding, otro con `GestureDetector` desnudo. `compartida_screen.dart:58-79` ya
tiene un `_BotonVolver` privado que podría ser el único.

Lo mismo con `_emojiParaCategoria`: tres copias divergentes
(`agregar_screen.dart:560`, `:895`, `open_food_facts_service.dart:68`). La
misma mantequilla sale 🧈 si la escaneás y 🥫 si la escribís.

---

## Parte 2 — Fallas funcionales

No son de diseño. Conviene arreglarlas antes de rediseñar encima.

| # | Falla | Ubicación |
|---|---|---|
| 1 | **Todo producto escaneado se guarda como no fresco.** Compara contra `'fruta'`/`'verdura'` en minúscula; las categorías son `'Fruta'`/`'Verdura'`. La ruta manual compara bien. | `agregar_screen.dart:1112` |
| 2 | **El detalle de receta miente sobre los ingredientes.** Se reemplaza la lista por la del detalle (otro orden) pero se conserva el conteo del buscador: las marcas "✓ Tienes / Falta" señalan ingredientes al azar. | `recetas_screen.dart:747` + `receta_card.dart:538` |
| 3 | **Un producto vencido muestra `-3d`.** El badge no trata negativos; `diasLabel` devuelve "¡Vencido!" y no se llama. | `producto_card.dart:94` |
| 4 | **Las alertas se ordenan por fecha de creación, no por urgencia.** | `alertas_provider.dart:101` |
| 5 | **El formulario de agregar no se limpia al guardar** y `IndexedStack` lo mantiene vivo: el siguiente guardado repite el producto. | `agregar_screen.dart:147` |
| 6 | **Un fallo de red se muestra como "producto no encontrado"** y empuja a tipear todo a mano, sin reintento. | `open_food_facts_service.dart:58` |
| 7 | **Cada edición de la despensa convierte la pantalla de alertas en un spinner.** `refrescar()` pone `AsyncLoading` y el `ref.listen` compara por identidad; `Producto` no define `operator ==`. Se agravó al pasar la despensa a stream. | `alertas_screen.dart:39-45` |
| 8 | **Dos llamadas a Spoonacular por cada cambio de despensa.** Dos suscripciones disparan la carga en el mismo evento, sin guarda de carrera. Es una API paga. | `recetas_screen.dart:65-74` + `:361-367` |
| 9 | **Desborde de layout garantizado en tablet.** `childAspectRatio: 1.8` da 180px de alto a una tarjeta que necesita ~255. | `recetas_screen.dart:108-113` |
| 10 | **La X del buscador no resetea la búsqueda**: campo vacío con resultados viejos y debounce pendiente que igual se dispara. | `recetas_screen.dart:430` |
| 11 | **`catch (_) {}` vacío** al cargar el detalle de receta: si falla, queda para siempre con datos parciales y sin mensaje. | `receta_card.dart:347` |
| 12 | **"¡Vamos a cocinar!" solo hace `Navigator.pop`.** No consume, no marca, no lleva a ningún lado. | `receta_card.dart:612` |
| 13 | **Fallback inseguro**: cualquier estado no reconocido se pinta como "vigente". | `consulta_rapida_screen.dart:262-272` |
| 14 | **Se pregunta por la migración antes de validar el código.** El error del código inválido llega tres pasos tarde. | `compartida_screen.dart:496-521` |
| 15 | **El admin no tiene forma de salir** de su despensa sin destruirla para todos. | `compartida_screen.dart:306-317` |
| 16 | **El perfil nutricional sobrescribe la selección del usuario** si toca un desplegable antes de que cargue el provider. | `perfil_nutricional_screen.dart:37-46` |
| 17 | **Se pueden disparar dos autenticaciones a la vez**: cada botón se bloquea con su propia bandera. | `login_screen.dart:153` y `:205` |
| 18 | **Un botón invisible de 8x8** abandona el formulario de agregar a medio llenar. | `agregar_screen.dart:97-106` |

---

## Parte 3 — Por pantalla

### Despensa y navegación — 25 hallazgos

Lo peor: ordena por urgencia pero no la muestra. Urgente y en buen estado
comparten fondo, radio, padding y tipografía; el único refuerzo del urgente es
una sombra teñida de **verde**, que contradice el badge rojo de la misma tarjeta.

Además: si no hay urgentes, la columna "en buen estado" es un `Expanded` que se
lleva los 1300px enteros (`:273`); los encabezados de sección no tienen guardia
de lista vacía (`:364`); en tablet/web las listas se construyen sin lazy loading
(`:251`, `:299`); la navegación no tiene `label`, `Tooltip` ni `Semantics`
(`main_shell.dart:250`).

Lo que funciona y hay que conservar: la partición en "PRÓXIMOS A VENCER" / "EN
BUEN ESTADO" con orden ascendente. Es la mejor decisión de jerarquía de la app y
no depende del color.

### Agregar y escáner — 25 hallazgos

Lo peor: los estados del escaneo mienten. Hasta 20 segundos de espera (dos URLs
con 10s de timeout) bajo un texto que sigue diciendo "toca para abrir la cámara".

Además: el sheet de confirmación arrastra `imagenUrl` y `cantidad` y no muestra
ninguno de los dos (`:1105`); al no encontrar el producto se pasa a modo manual
y el código escaneado desaparece justo cuando se necesita (`:54`); el marco del
escáner es decorativo —`MobileScanner` no recibe `scanWindow`— así que la
instrucción "alinea el código dentro del marco" es falsa
(`scan_producto_screen.dart:131`); dos `showDatePicker` con esquemas distintos
en el mismo flujo.

Lo que funciona: el padding fijo dentro del `ResponsiveContainer`, la dependencia
unidad→categoría, y las animaciones que sí existen ya respetan la tabla.

### Recetas — 24 hallazgos

Lo peor: el desborde de la grilla y las marcas de ingredientes desalineadas
(fallas 9 y 2).

Además: el hint dice "Buscar por nombre" pero la consulta se manda como búsqueda
por ingrediente (`:415` vs `:301`); el bloque rojo "Priorizando ingredientes
urgentes" se muestra siempre, incluso diciendo "No hay productos urgentes"
(`:458`); el badge de match está fijo en verde en el detalle sin importar el
porcentaje (`receta_card.dart:469`).

Lo que funciona, y es lo mejor de la app: `_explicacionOrden()` le dice al
usuario **por qué** la lista quedó en ese orden, con el icono cambiando según el
criterio. Y ante un fallo de la API cae al caché en vez de quedar vacía.

### Alertas y consulta rápida — 24 hallazgos

Lo peor: la severidad no se distingue de un vistazo, por triple motivo — la
tarjeta es idéntica en los cuatro niveles, el color colapsa (1d y vencido son el
mismo `danger`) y en los dos niveles bajos es invisible.

Además: el glifo grande es el emoji del producto, no un icono de severidad;
`consulta_rapida` ordena alfabéticamente con todas las tarjetas del mismo peso,
mientras despensa resuelve lo mismo ordenando por días; el estado vacío no dice
si es buena noticia o si falta agregar productos.

### Perfil y autenticación — 22 hallazgos

Lo peor de auth: el botón principal de la primera pantalla de la app es blanco
sobre `accent`, 2.1:1. Lo peor de perfil: identidad, estadística y lista de
compras usan el mismo radio, borde y padding, y solo una de las tres zonas tiene
rótulo.

Además: el registro no tiene botón de Google, así que quien llegó por ahí pierde
la opción sin explicación (`register:188`); la cifra de "alimentos salvados"
muestra 0 mientras carga y después salta al número real (`perfil:22`); el logo
de Google es la letra "G" en un `TextStyle` de 18px (`login:215`);
`_buildImageProvider` existe muerto en el archivo justo para el caso que no
resuelve (`perfil:528`).

Lo que funciona: `AuthField` centraliza de verdad el campo de texto, y el estado
vacío de la lista de compras es el mejor de la app — explica cómo se llena, no
solo que está vacía.

### Despensa compartida — 21 hallazgos

Lo peor: el código de invitación —el objeto entero de la pantalla— está en verde
sobre verde a 2.8:1, no es seleccionable, y su única vía de salida es un botón
de copiar.

Además: "Cancelar" y "No migrar" son dos botones idénticos con consecuencias
opuestas (`:548`); cancelar cualquier diálogo hace `return` mudo y parece que la
app no respondió (`:481`); `_confirmar` da el mismo tratamiento a eliminar la
despensa de todos que a salirse uno (`:642`); cuando sos el único miembro no hay
ninguna guía que diga "comparte el código".

Lo que funciona: `_SinDespensa` es un estado vacío correcto con jerarquía
primaria/secundaria real, y las reglas responsive del `CLAUDE.md` están
respetadas y comentadas.

---

## Parte 4 — Por dónde empezar

**Fase 0 — Fallas funcionales.** Las 18 de la parte 2. Son bugs, no diseño, y
rediseñar encima de ellos las esconde en vez de arreglarlas. Las 1, 2, 3, 4 y 7
afectan datos o mienten al usuario.

**Fase 1 — El sistema.** Reescribir `app_theme.dart` con la paleta del manual de
estilos: tokens de marca separados de los semánticos, escala de urgencia
conectada de verdad, `inputDecorationTheme`, `snackBarTheme`, escala de espaciado
y una sola escala de radios. Esto solo ya resuelve las secciones 1.1 a 1.4.

**Fase 2 — Los componentes compartidos.** Un solo `BotonVolver`, una sola tarjeta
de producto, una sola pastilla de estado, un solo mapa de emojis. Resuelve 1.5 y
1.10.

**Fase 3 — Pantalla por pantalla**, en orden de daño: despensa, alertas,
recetas, agregar, perfil, compartida.

**Fase 4 — Movimiento**, ya con el sistema puesto.

Cada fase cierra con `flutter analyze`, `flutter test` y un widget test que monte
la pantalla en móvil y en web.
