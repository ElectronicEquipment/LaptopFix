echo allow_custom_firewall_rules
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\Mdm\DomainProfile" /v AllowLocalPolicyMerge /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\Mdm\StandardProfile" /v AllowLocalPolicyMerge /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\Mdm\PublicProfile" /v AllowLocalPolicyMerge /t REG_DWORD /d 1 /f
reg import "%~dp0fw_domain.reg"
reg import "%~dp0fw_standard.reg"
