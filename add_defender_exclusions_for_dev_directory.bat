echo add_defender_exclusions_for_dev_directory
set "DEV_DIR=C:\LocalData\\"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\ASROnlyExclusions" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

set "DEV_DIR=C:\Program Files (x86)\\"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\ASROnlyExclusions" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

set "DEV_DIR=C:\Program Files\\"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\ASROnlyExclusions" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

set "DEV_DIR=C:\Users\rafal.grasman\AppData\\"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\ASROnlyExclusions" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f

set "DEV_DIR=C:\Python314\\"
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Exclusions\Paths" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Windows Defender Exploit Guard\ASR\ASROnlyExclusions" /v "%DEV_DIR%" /t REG_SZ /d "%DEV_DIR%" /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v SubmitSamplesConsent /t REG_DWORD /d 2 /f
