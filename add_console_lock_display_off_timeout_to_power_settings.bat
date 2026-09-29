echo add_console_lock_display_off_timeout_to_power_settings
REG ADD HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\7516b95f-f776-4464-8c53-06167f40cc99\8EC4B3A5-6868-48c2-BE75-4F3044BE88A7 /v Attributes /t REG_DWORD /d 2 /f
