# Emülatörü doğru saat dilimiyle başlatır.
# Emülatörün otomatik saat dilimi tespiti bu makinede başarısız olup GMT'ye düşüyor;
# bu betik `-timezone` ile Europe/Istanbul'u açıkça verir.
# Kullanım (depo kökünden): powershell -File tool\emulator-baslat.ps1 [-Avd namaz_test]
param(
    [string]$Avd = "namaz_test",
    [string]$TimeZone = "Europe/Istanbul"
)

$sdk = Join-Path $env:LOCALAPPDATA "Android\Sdk"
$emulator = Join-Path $sdk "emulator\emulator.exe"
$adb = Join-Path $sdk "platform-tools\adb.exe"

Start-Process -FilePath $emulator -ArgumentList @("-avd", $Avd, "-timezone", $TimeZone) -WindowStyle Hidden

& $adb wait-for-device
do {
    Start-Sleep -Seconds 3
    $boot = (& $adb shell getprop sys.boot_completed 2>$null)
} until ($boot -and $boot.Trim() -eq "1")

# Snapshot'tan açıldıysa saat dilimini yine de sabitle.
& $adb shell cmd alarm set-timezone $TimeZone
Write-Host "Emülatör hazır. Saat dilimi: $((& $adb shell getprop persist.sys.timezone).Trim())"
