echo allow_changing_power_settings
reg delete "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Power" /f
reg add "Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\PolicyManager\current\device\Power"
powershell.exe -ExecutionPolicy Bypass -File "%~dp0allow_changing_power_settings.ps1"
