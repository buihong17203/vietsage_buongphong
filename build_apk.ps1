param(
    [switch]$NoIncrement = $false
)

$ErrorActionPreference = "Stop"
$pubspecPath = "$PSScriptRoot\pubspec.yaml"
$content = Get-Content $pubspecPath -Raw

$major = 1
$minor = 0
$patch = 1
$buildNumber = 2

if ($content -match 'version:\s+(\d+)\.(\d+)\.(\d+)\+(\d+)') {
    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    $patch = [int]$matches[3]
    $buildNumber = [int]$matches[4]
}

if (-not $NoIncrement) {
    $patch += 1
    $buildNumber += 1
    $newVersionString = "$major.$minor.$patch+$buildNumber"
    $content = $content -replace 'version:\s+\d+\.\d+\.\d+\+\d+', "version: $newVersionString"
    Set-Content -Path $pubspecPath -Value $content -NoNewline
    Write-Host "Updated pubspec.yaml version to $newVersionString"
}

$formattedVersion = "v$major.$minor.$('{0:D2}' -f $patch)"
Write-Host "Building APK for version $formattedVersion (Build $buildNumber)..."

# Run Flutter build
& flutter build apk --release
if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed with exit code $LASTEXITCODE"
    exit $LASTEXITCODE
}

$builtApk = "$PSScriptRoot\build\app\outputs\flutter-apk\app-release.apk"
if (-not (Test-Path $builtApk)) {
    Write-Error "Could not find built APK at $builtApk"
    exit 1
}

$destDir = "D:\code\apk"
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Force -Path $destDir | Out-Null
}

# Clean old APKs in destination to keep strictly 1 APK
Get-ChildItem -Path $destDir -Filter "*.apk" -File | Remove-Item -Force -ErrorAction SilentlyContinue

$destFileName = "VietSage Buồng phòng $formattedVersion.apk"
$destFile = Join-Path $destDir $destFileName
Copy-Item -Path $builtApk -Destination $destFile -Force

Write-Host "=================================================="
Write-Host "SUCCESS: Exported single APK to $destFile"
Write-Host "=================================================="
Get-ChildItem -Path $destDir -Filter "*.apk" | Select-Object Name, Length, LastWriteTime
