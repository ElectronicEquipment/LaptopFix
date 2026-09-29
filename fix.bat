@echo off
setlocal EnableExtensions

if /I "%~1"=="--scheduled" (
    set "RUN_MODE=scheduled"
) else (
    set "RUN_MODE=interactive"
)

set "ROOT=%~dp0"
set "LOG=%ROOT%fix.log"

> "%LOG%" echo Setup started: %DATE% %TIME%

REM Remove Mark of the Web from all files in the setup directory.
>> "%LOG%" echo Remove internet mark
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-ChildItem -LiteralPath $env:ROOT -Recurse -File -ErrorAction SilentlyContinue | Unblock-File" >> "%LOG%" 2>&1

if errorlevel 1 (
    echo ERROR: Failed to unblock setup files. See "%LOG%".
    exit /b 1
)

>> "%LOG%" echo Ensure Fix task
powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%ROOT%ensure_fix_task.ps1" >> "%LOG%" 2>&1

if errorlevel 1 (
    echo ERROR: Failed to install the Fix scheduled task. See fix.log.
    exit /b 1
)
REM preface anything you don't want with REM

>> "%LOG%" echo Run mode: %RUN_MODE%

if /I "%RUN_MODE%"=="scheduled" (
    >> "%LOG%" echo Running from Task Scheduler
) else (
    >> "%LOG%" echo Running interactively

    powershell.exe -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -File "%ROOT%create_make_admin.ps1" >> "%LOG%" 2>&1
)

call "%ROOT%make_admin.bat" >> "%LOG%" 2>&1
call "%ROOT%allow_custom_backgrounds.bat" >> "%LOG%" 2>&1
call "%ROOT%allow_changing_power_settings.bat" >> "%LOG%" 2>&1
call "%ROOT%add_console_lock_display_off_timeout_to_power_settings.bat" >> "%LOG%" 2>&1
call "%ROOT%link_elevated_and_unelevated_mappings.bat" >> "%LOG%" 2>&1
call "%ROOT%make_sure_network_drives_are_mapped_after_any_user_login.bat" >> "%LOG%" 2>&1
call "%ROOT%allow_custom_firewall_rules.bat" >> "%LOG%" 2>&1
call "%ROOT%allow_rdp.bat" >> "%LOG%" 2>&1
call "%ROOT%add_defender_exclusions_for_dev_directory.bat" >> "%LOG%" 2>&1
call "%ROOT%disable_5min_lock.bat" >> "%LOG%" 2>&1
call "%ROOT%allow_powershell_script_execution.bat" >> "%LOG%" 2>&1
call "%ROOT%keep_alive.bat" >> "%LOG%" 2>&1

>> "%LOG%" echo Setup finished: %DATE% %TIME%

timeout /t 2 /nobreak >nul
endlocal
exit /b 0
