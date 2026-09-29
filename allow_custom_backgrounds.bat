echo allow_custom_backgrounds
reg delete "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0allow_custom_backgrounds.ps1"
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Wallpapers" /v BackgroundType /t REG_DWORD /d 2 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\ActiveDesktop" /v NoChangingWallPaper /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v NoDispBackgroundPage /t REG_DWORD /d 0 /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /f
reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v WallpaperStyle /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v Wallpaper /f
reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Policies\System" /v WallpaperStyle /f
del %APPDATA%\Microsoft\Windows\Themes\TranscodedWallpaper
del C:\Windows\System32\background.jpg
del C:\Windows\System32\lockscreen.jpg
RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters 1
