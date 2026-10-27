# Brix Moscatel: captura masiva sin conexión

Implementación del 26/10/2026, en `feature/david-culqui` de APP_AGRICOLA y API_AGRICOLA.

## Captura y almacenamiento

- `+1` guarda la muestra terminada y el siguiente borrador en una sola transacción SQLite. Un fallo revierte ambas escrituras y el formulario conserva sus datos.
- El siguiente borrador replica lote, campaña, hilera, planta, variedad y corresponde. Brix y observaciones se completan nuevamente. Cada muestra conserva un UUID independiente.
- No espera internet ni una búsqueda GPS nueva. Usa el fix reciente disponible con su fecha y precisión; no inventa ubicaciones ni redondea el JSON para reducir el tamaño.
- Se bloquea la edición mientras se confirma el guardado. Continuar desde una muestra enviada crea un borrador nuevo y conserva intacta la original.
- La lista suspende su suscripción mientras está abierto el formulario. Sólo construye tarjetas próximas a la pantalla; la tabla muestra páginas de 25 o 50 filas.
- Se añaden dos índices locales al abrir SQLite. No se cambian columnas, no se borra la base existente y no se requiere reinstalar la aplicación.

## Subida

- La cola Brix incluye pendientes de días anteriores del mismo usuario y plantilla. La fecha visible de la lista no descarta muestras pendientes.
- Lee un bloque de hasta 50 muestras y 512 KiB cada vez. Agrupa los campos repetidos en contextos dentro de ese bloque; la API reconstruye el JSON individual habitual.
- Sólo marca una muestra como enviada cuando la API confirma su UUID y revisión. Si el contenido local cambió mientras viajaba, permanece pendiente.
- Una respuesta perdida permite repetir el bloque: el UUID evita duplicados. Una muestra retirada en la nube no vuelve a crearse. Los conflictos conservan la copia local y muestran el error.
- Tras un corte de red reintenta el mismo bloque una vez y pausa. Al pulsar subir nuevamente retoma la cola persistida, incluso después de reiniciar la app.

## Orden para publicar

1. Publicar primero los cambios de API_AGRICOLA y reiniciar su servicio. La ruta nueva es `POST /api/registros/sync-batch/`; requiere JWT y asignación de Brix al usuario.
2. Verificar la API en el entorno de pruebas. No se requiere migración SQL Server ni cambiar tablas de reportes.
3. Generar después el APK desde APP_AGRICOLA, conservando el applicationId y la firma de actualización existentes. Esta implementación no modifica versión, clave ni configuración de firma.
4. Probar captura y subida con cuenta y datos de prueba en un teléfono de gama baja antes de distribuirlo.

Si el servidor aún no tiene la ruta, la app conserva las muestras y explica que falta actualizar la API. No vuelve automáticamente al endpoint antiguo.

## Verificación reproducible

Desde APP_AGRICOLA:

```powershell
flutter test --no-pub test/brix_offline_storage_test.dart test/brix_sync_batch_test.dart test/registros_page_sampling_test.dart test/brix_moscatel_report_metrics_test.dart
```

Desde API_AGRICOLA:

```powershell
python -m unittest api.test_brix_batch -v
python manage.py check
```

Las pruebas usan SQLite temporal/en memoria y respuestas de red simuladas. Incluyen 1.500 muestras, reapertura de la base, rollback, doble toque, pérdida de ACK, edición durante envío, límites de bloques y muestras retiradas.

En la simulación de escritorio, 1.500 muestras mantienen sólo cuatro tarjetas montadas; con el formulario encima hay cero suscripciones y lecturas JSON de la lista. La subida sintética normal utiliza 30 solicitudes de 50 muestras. Estos resultados no son tiempos medidos en Android.

## Prueba física pendiente

Medir en profile/release con un equipo de gama baja: captura a 100, 300, 1.000 y 1.500 muestras, cambio de hilera/planta, doble toque, cierre/reapertura, modo avión y corte/restablecimiento de señal durante la subida. Revisar respuesta de `+1`, memoria y coincidencia de UUID/cantidad/Brix/fecha/GPS. El objetivo de respuesta p95 de `+1` es 200 ms; debe medirse en el equipo real.

No se enviaron muestras ficticias a producción ni se generó un APK durante estas verificaciones. Las escrituras de la API se probaron con SQLite aislado; transacciones y fechas deben verificarse también en SQL Server de pruebas.
