# APP_AGRICOLA: instrucciones para Codex y colaboradores

## Antes de modificar o generar APK
- Lee APK_RELEASE.md: contiene el procedimiento oficial completo.
- Comprueba rama, `git status` y código a compilar. Conserva cambios existentes.
- No cambies de rama, descartes, hagas commit/push ni publiques sin autorización.
- Para desarrollo utiliza la rama del colaborador; no asumas que es la de David.

## Cuando pidan «genera el APK»
1. Lee APK_RELEASE.md y revisa versión en pubspec.yaml y última publicación.
2. Localiza Flutter, Android SDK y Java en esta PC; no copies rutas de otro usuario.
3. La firma histórica es obligatoria. Gradle conserva key.properties existente;
   si no existe, reconoce automáticamente una clave histórica de credenciales
   estándar en ~/.android/dontec-release.keystore o ~/.android/debug.keystore.
   Solo acepta el certificado SHA256 documentado. No genera claves.
4. Si falla, ejecuta diagnoseReleaseSigning desde android. Distingue clave
   ausente, certificado distinto y credenciales personalizadas. Se respetan los
   homes de Android y la ubicación debug efectiva de AGP.
   Si ninguna coincide, solicita la transferencia segura de la clave histórica
   y utiliza scripts/importar-firma-historica.ps1 -Origen RUTA_RECIBIDA una vez.
   No pidas a la persona que pegue contraseñas aquí. Con otra contraseña se usa
   android/key.properties local e ignorado. No elimines la protección de firma.
5. Usa flutter pub get sin upgrade; revisa cualquier cambio en pubspec.lock.
6. Ejecuta las comprobaciones pertinentes y respeta el comando habitual solicitado:
   `flutter build apk --release --no-shrink`. También se admite `--no-pub`
   cuando las dependencias ya están resueltas. No lo bloquees por usar --no-shrink.
7. Verifica applicationId, versión, compilación y certificado con aapt/apksigner.
8. Calcula tamaño y SHA256 del APK final. Prepara version.pending.json local.
9. Entrega APK, JSON completo, validaciones, pasos de publicación y repositorios
   afectados. No confundas compilar con publicar o desplegar web/API.
10. Prueba actualización sin desinstalar; preserva muestras y borradores.

## Límites
- Nunca claves privadas o key.properties en Git, logs, releases ni chat.
- No renueves Flutter/Gradle/dependencias para compilar por comodidad.
- No omitas fallos ni entregues un APK antiguo tras fallar la compilación.
- No reutilices versión publicada para cambios distintos.
- No limpies build por defecto; ante bloqueos verifica la ruta y limpia solo lo
  generado necesario, sin tocar código ni datos.
- Cambios TIC deben quedar limitados a TIC; preservar captura agrícola offline.

## Compilación centralizada del equipo
Si la PC no tiene la clave local, ofrece .github/workflows/apk-firmado.yml,
documentado en APK_RELEASE.md. Requiere Repository Secrets configurados una vez
por un administrador, y permisos de Actions o gh autenticado. No guardes claves
privadas en Git para repartirlas. El comando Flutter local sigue necesitando la
clave local; la alternativa centralizada produce el APK en GitHub. No afirmes que
el workflow funciona hasta verificar una ejecución remota real.
