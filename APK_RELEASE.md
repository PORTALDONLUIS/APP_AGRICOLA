# Publicación de DonTec App

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

## Configuración por computadora (solo una vez)

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
2. Ejecutar `flutter build apk --release`. El proceso debe rechazar una clave
   distinta o la ausencia de configuración. No quitar esta validación.
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
