# Publicación de DonTec App

## Inicio rápido para David, Yerson y Javier

Después de descargar estos cambios, cualquier Codex debe leer AGENTS.md y este
archivo antes de generar APK. Basta pedir: «Genera el APK siguiendo AGENTS.md y
APK_RELEASE.md; verifica la firma histórica y entrega el JSON de publicación».

En el servidor 3 ya se verificó que su debug.keystore original tiene el
certificado correcto. No es necesario reemplazarlo ni crear otra clave. El
comando habitual seguirá siendo:

```powershell
flutter build apk --release --no-shrink
```

En otra PC se necesita Flutter/Android SDK/Java compatibles y una copia segura
de la misma clave. No se distribuyen claves privadas mediante GitHub. Esto se
prepara una sola vez; no hay una contraseña nueva por cada versión o cartilla.


## Firma histórica obligatoria

Las actualizaciones deben conservar el certificado utilizado en las versiones 1.0.32
y 1.0.43 (compilación 44, comprobado en el APK extraído del celular).
SHA256 del certificado (no confundir con el hash del archivo APK):
`cf604910dddfe0bc4c885faa1b87c369585d6b19228332a190f9e6f153ce5f3b`.
El usuario confirmó el 21/10/2026 que la actualización a 1.0.46 (47) funcionó con
esta firma. No borrar datos pendientes ni desinstalar para resolver conflictos.

El primer APK 1.0.46 se generó con otra firma y NO debe reutilizarse. La copia
corregida de esta publicación está en
`build/app/outputs/flutter-apk/firma-servidor/app-release.apk`, mide 82456684 bytes
y tiene SHA256 `174f4df9a11d29968ea4425e3e0879b0ce11a1cf2bf703fc3ccab0377bc37be5`.
Estos valores identifican únicamente ese archivo, no futuras compilaciones.

La clave histórica es de tipo debug, pero debe conservarse para actualizar las
instalaciones existentes. No reemplazarla por una clave nueva ni por el debug.keystore
automático de otra computadora. La compilación release comprueba su certificado.

## Reconocimiento automático de la clave original

El 29/10/2026 se comprobó que el debug.keystore original del servidor 3 coincide
exactamente con el certificado histórico. No hace falta generar otra clave ni
renombrarla. El nombre `dontec-release.keystore` usado en la laptop es solo el
nombre de una copia compatible, no una nueva identidad de firma.

Si android/key.properties existe, tiene prioridad y se valida como antes.
Si no existe, Gradle comprueba estas rutas del usuario que ejecuta la compilación:

- ~/.android/dontec-release.keystore
- ~/.android/debug.keystore

Solo reutiliza una clave si su certificado coincide y conserva las credenciales
estándar originales de Android. Una clave automática de otra computadora NO sirve
si su certificado es distinto. No se genera ni reemplaza ningún archivo de firma.
Con contraseñas personalizadas se mantiene la configuración explícita siguiente.

La primera vez en una PC nueva, un responsable debe transferir la clave privada
por un medio seguro. Ni GitHub ni Codex pueden reconstruirla a partir del hash.
Nunca se debe compartir la clave o contraseñas dentro del chat o del repositorio.

## Configuración explícita por computadora (si es necesaria)

1. Obtener la clave histórica desde un respaldo seguro autorizado.
2. Guardarla fuera del repositorio, por ejemplo en
   `C:/Users/DCULQUI/.android/dontec-release.keystore` en esta laptop.
3. Crear `android/key.properties` con las siguientes propiedades, completando los
   datos de la clave (no publicar contraseñas):

```properties
storeFile=C:/ruta/segura/dontec-release.keystore
storePassword=CONTRASENA_DEL_ALMACEN
keyAlias=ALIAS_DE_LA_CLAVE
keyPassword=CONTRASENA_DE_LA_CLAVE
```

Usar barras `/` en las rutas de Windows. `android/key.properties` está ignorado por
Git; las claves no deben adjuntarse en commits ni releases. Mantener un respaldo
seguro separado: el chat y GitHub no respaldan la clave privada.

## Cada nueva versión

1. Incrementar versión y compilación en `pubspec.yaml`; nunca reutilizar una
   compilación para una nueva funcionalidad.
2. Ejecutar `flutter build apk --release --no-shrink`. El proceso debe rechazar una clave
   distinta o la ausencia de una clave histórica compatible, incluso con
   reconocimiento automático. No quitar esta validación.
3. El instalador final queda en `build/app/outputs/flutter-apk/app-release.apk`.
   La configuración actual lo firma directamente con la clave histórica; no hace
   falta repetir la firma manual ni reutilizar la carpeta `firma-servidor`.
4. Probar primero una actualización sobre un celular existente sin desinstalar.
5. Obtener tamaño y SHA256 del APK FINAL firmado con `Get-Item` y `Get-FileHash`.
6. Preparar `version.pending.json` con versión, compilación, mejoras, URL de release,
   tamaño y SHA256 del archivo exacto que se va a subir. Es solo un borrador local:
   no activa actualizaciones por sí mismo.
7. Publicar el APK como asset `app-release.apk` en una nueva release del repositorio
   `PORTALDONLUIS/app-agricola-releases`. No adjuntarlo al cuadro de descripción.
8. Después de publicar, actualizar `main/version.json` de ese repositorio con los
   valores del borrador y probar Buscar actualización en otro celular.

No hace falta publicar el APK en el servidor web. Desplegar cambios web/API es un
procedimiento independiente. No hay publicación automática a GitHub configurada.

El nombre de la etiqueta de GitHub no determina la versión interna: la versión
1.0.43 se distribuía desde la etiqueta v1.0.1. Para próximas versiones usar una
etiqueta nueva por versión. `release_notes` controla el comentario del app; ni el
JSON ni el enlace pueden corregir una firma incompatible.

## Flujo de consola reutilizable

Desde APP_AGRICOLA, revisar `git status` y `git branch --show-current`. No descartar
pubspec.lock por aparecer modificado; comparar su diff antes de decidir.

```powershell
flutter --version
flutter doctor -v
flutter pub get
flutter build apk --release --no-shrink
```

Continuar solo si cada comando termina correctamente. Java debe ser compatible;
en Windows puede configurarse JAVA_HOME con el jbr de Android Studio instalado.
No asumir nombres de usuario o rutas de otra PC. La salida sigue siendo
build/app/outputs/flutter-apk/app-release.apk; no requiere detener web/API.
El comando habitual `flutter build apk --release --no-shrink` está permitido:
la selección y comprobación de la firma es la misma con o sin `--no-shrink`.
Para compilación tras resolver dependencias también puede usarse
`flutter build apk --release --no-shrink --no-pub`.
`--no-shrink` controla la optimización; no sustituye la clave de firma.
El SDK Flutter instalado debe admitir esa opción; mantener la versión compatible
del equipo sin actualizar herramientas automáticamente.

Verificar el archivo final con las herramientas del SDK Android local:

```powershell
& "RUTA_SDK/build-tools/VERSION/aapt.exe" dump badging .\build\app\outputs\flutter-apk\app-release.apk
& "RUTA_SDK/build-tools/VERSION/apksigner.bat" verify --print-certs .\build\app\outputs\flutter-apk\app-release.apk
(Get-Item .\build\app\outputs\flutter-apk\app-release.apk).Length
(Get-FileHash .\build\app\outputs\flutter-apk\app-release.apk -Algorithm SHA256).Hash.ToLowerInvariant()
```

Debe conservar applicationId com.example.donluis_forms. El hash del certificado
identifica la firma y permanece; el hash del archivo identifica ese APK exacto.
No copiar tamaños/hashes de mensajes o compilaciones anteriores.

## JSON y enlaces de publicación

Preparar localmente build/app/outputs/flutter-apk/version.pending.json:

```json
{
  "latest_version": "VERSION",
  "build_number": 0,
  "minimum_build": 1,
  "is_mandatory": false,
  "release_notes": "Mejoras incluidas",
  "download_url": "https://github.com/PORTALDONLUIS/app-agricola-releases/releases/download/vVERSION/app-release.apk",
  "file_size_bytes": 0,
  "sha256": "HASH_REAL"
}
```

Sustituir versión, compilación, tamaño y hash por los reales; revisar el manifiesto
publicado y conservar minimum_build/is_mandatory salvo cambio autorizado.

1. Crear release normal, no pre-release, con etiqueta vVERSION y adjuntar el asset
   app-release.apk: https://github.com/PORTALDONLUIS/app-agricola-releases/releases/new
2. Solo después de que el asset esté disponible, guardar el JSON en main:
   https://github.com/PORTALDONLUIS/app-agricola-releases/edit/main/version.json
3. Probar Buscar actualización en otro celular con versión anterior.
4. Desplegar web/API por separado cuando los cambios de esa versión lo requieran.

No publicar automáticamente. Informar qué se verificó y qué falta probar en un
celular físico. Este procedimiento aplica a David, Yerson, Javier y sus Codex;
no depende del contexto de un chat anterior.
