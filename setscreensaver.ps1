# ---------------------------------------------
# PowerShell Script: Enterprise Screensaver Setup
# ---------------------------------------------

# ------- VARIABLES -------
$destinationFolder = "C:\ProgramData\Screensaver"

$zipUrl = "https://github.com/tonyfederer/EasyVideoScreensaver/releases/download/v1.2/EasyVideoScreensaverSetup.zip"
$zipPath = "$destinationFolder\EasyVideoScreensaverSetup.zip"
$extractPath = "$destinationFolder\Extracted"
$installerPath = "$extractPath\EasyVideoScreensaverSetup.msi"

$mp4Url = "https://raw.githubusercontent.com/Crypto0203/Intune-lockscreen/main/better_lending_screensaver_v2.scr.mp4"
$mp4Path = "$destinationFolder\better_lending_screensaver_v2.mp4"

$xmlPath = "$env:APPDATA\VideoScreensaver.xml"

# ------- Step 0: Create Destination Folder -------
if (-Not (Test-Path $destinationFolder)) {
    Write-Host "Creating Screensaver folder: $destinationFolder..." -ForegroundColor Cyan
    New-Item -Path $destinationFolder -ItemType Directory | Out-Null
}

# ------- Step 1: Download Screensaver ZIP if not already exists -------
if (-Not (Test-Path $zipPath)) {
    Write-Host "Downloading EasyVideoScreensaver ZIP..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath
} else {
    Write-Host "ZIP already exists at $zipPath, skipping download." -ForegroundColor Yellow
}

# ------- Step 2: Extract ZIP -------
if (Test-Path $extractPath) {
    Remove-Item -Path $extractPath -Recurse -Force
}
Write-Host "Extracting ZIP to $extractPath..." -ForegroundColor Cyan
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# ------- Step 3: Install Screensaver (Silent MSI) -------
if (-Not (Test-Path "C:\Windows\SysWOW64\EasyVideoScreensaver.scr")) {
    Write-Host "Installing EasyVideoScreensaver..." -ForegroundColor Cyan
    Start-Process msiexec.exe -ArgumentList "/i `"$installerPath`" /qn" -Wait
} else {
    Write-Host "EasyVideoScreensaver is already installed." -ForegroundColor Yellow
}

# ------- Step 4: Download MP4 Video -------
Write-Host "Downloading MP4 video..." -ForegroundColor Cyan
Invoke-WebRequest -Uri $mp4Url -OutFile $mp4Path -UseBasicParsing

# ------- Step 5: Create XML Config pointing to MP4 -------
Write-Host "Creating VideoScreensaver.xml with selected MP4..." -ForegroundColor Cyan
$xmlContent = @"
<MySettings xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <VideoFilename>$mp4Path</VideoFilename>
  <StretchMode>Fit</StretchMode>
  <Volume>0.5</Volume>
  <Mute>false</Mute>
  <Resume>false</Resume>
  <ResumePosition>0</ResumePosition>
</MySettings>
"@
Set-Content -Path $xmlPath -Value $xmlContent -Encoding UTF8 -Force

# ------- Step 6: Set Registry: Activate Screensaver Settings -------
Write-Host "Configuring system screensaver settings..." -ForegroundColor Cyan
$scrPath = "C:\Windows\SysWOW64\EasyVideoScreensaver.scr"

if (Test-Path $scrPath) {
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "SCRNSAVE.EXE" -Value $scrPath
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveTimeOut" -Value "180"  # 3 minutes
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaverIsSecure" -Value "1"
    Write-Host "✅ Screensaver configured to: $scrPath" -ForegroundColor Green
} else {
    Write-Host "❌ ERROR: Screensaver SCR file not found. Cannot set registry." -ForegroundColor Red
}

# ------- Completed -------
Write-Host "`n🎉 Setup complete!"
Write-Host "🖥️ Screensaver will activate after 3 minutes of inactivity."
Write-Host "🎬 MP4 Path Set To: $mp4Path"
Write-Host "📄 Config File Saved To: $xmlPath"
