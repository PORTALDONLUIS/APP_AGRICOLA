param([Parameter(Mandatory=$true)][string]$Origen)
$ErrorActionPreference = 'Stop'
$expected = 'cf604910dddfe0bc4c885faa1b87c369585d6b19228332a190f9e6f153ce5f3b'
$source = (Resolve-Path -LiteralPath $Origen).Path
if (-not (Test-Path -LiteralPath $source -PathType Leaf)) { throw 'Selecciona el archivo original de firma.' }
$keytool = if ($env:JAVA_HOME -and (Test-Path "$env:JAVA_HOME/bin/keytool.exe")) {
    "$env:JAVA_HOME/bin/keytool.exe"
} elseif (Get-Command keytool -ErrorAction SilentlyContinue) { (Get-Command keytool).Source
} elseif (Test-Path 'C:/Program Files/Android/Android Studio/jbr/bin/keytool.exe') {
    'C:/Program Files/Android/Android Studio/jbr/bin/keytool.exe'
} else { throw 'No se encontró keytool. Configura JAVA_HOME con el Java de Android Studio.' }
# Credenciales estándar de la clave original; no se piden ni imprimen secretos.
$output = & $keytool -list -v -keystore $source -alias androiddebugkey -storepass android 2>&1
if ($LASTEXITCODE -ne 0) { throw 'No se pudo verificar con credenciales estándar. Si tiene contraseña personalizada, configura key.properties local; no pegues contraseñas en el chat.' }
$normalized = ($output | Out-String).Replace(':','').ToLowerInvariant()
if (-not $normalized.Contains($expected)) { throw 'El certificado no coincide con el histórico. No se copió ningún archivo.' }
$destinationDir = Join-Path ([Environment]::GetFolderPath('UserProfile')) '.android'
$destination = Join-Path $destinationDir 'dontec-release.keystore'
if (Test-Path -LiteralPath $destination) {
    if ((Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $destination).Hash) {
        throw 'Ya hay una clave distinta en el destino. No se reemplazó; revisa la configuración existente.'
    }
} else {
    New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
    Copy-Item -LiteralPath $source -Destination $destination
    if ((Get-FileHash -LiteralPath $source).Hash -ne (Get-FileHash -LiteralPath $destination).Hash) { throw 'La copia no coincide con el origen.' }
}
Write-Output 'Firma histórica verificada y disponible para este usuario. No se modificó el debug.keystore propio.'
Write-Output 'Ya puedes ejecutar: flutter build apk --release --no-shrink'
