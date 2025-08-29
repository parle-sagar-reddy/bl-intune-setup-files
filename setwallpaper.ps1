# Configuration
$ImageUrl = "https://raw.githubusercontent.com/Crypto0203/Intune-lockscreen/main/BL%20Lockscreen.png"   
#Replace with your hosted image URL
$LocalPath = "C:\ProgramData\CustomWallpaper\BL_Lockscreen.png"

# Check for existing wallpaper
If (Test-Path $LocalPath) {
    Write-Output "Wallpaper already exists. Skipping download and setup."
    Exit
}

# Create directory if missing
$Dir = Split-Path $LocalPath
If (!(Test-Path $Dir)) {
    New-Item -ItemType Directory -Path $Dir -Force
}

# Download wallpaper
Write-Output "Downloading wallpaper from $ImageUrl ..."
Invoke-WebRequest -Uri $ImageUrl -OutFile $LocalPath

# Apply Lock Screen wallpaper via registry
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
New-Item -Path $RegPath -Force | Out-Null

Set-ItemProperty -Path $RegPath -Name "LockScreenImagePath"     -Value $LocalPath
Set-ItemProperty -Path $RegPath -Name "LockScreenImageUrl"      -Value $LocalPath
Set-ItemProperty -Path $RegPath -Name "LockScreenImageStatus"   -Value 1

Write-Output "Lock screen wallpaper applied successfully."
