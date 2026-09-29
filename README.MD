# Introduction

This is a set of scripts to help ease the pain of configured [Intune](https://en.wikipedia.org/wiki/Microsoft_Intune)/[Active Directory](https://en.wikipedia.org/wiki/Active_Directory) [Group Policies](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/group-policy/group-policy-overview) for "office-context" (Sales, powerpoint, word, management) restricted environment configuration on Windows machines, for developers and powerusers.  
  
This offloads some work from IT to keep things running smoothly.  

That being said, remember, with great power comes great responsibility, so use responsibly!  
`</`[insert meme about great power and great electricity bill](https://www.google.com/search?q=with+great+power+comes+great+electricity+bill+funny&udm=2)`>`


# Installation

1) Log in to the account "to be fixed", i.e. "user.name@heavac.nl" into Windows
2) [Download the `.zip`](https://github.com/ElectronicEquipment/LaptopFix/archive/refs/heads/main.zip)  
3) Unpack the contents of the downloaded `.zip` file to `C:\AUNLDEV\Fix\` (or any other location, the files must be kept there!)  
4) Open an [elevated administrator command-prompt](https://learn.microsoft.com/en-us/troubleshoot/windows-server/shell-experience/use-run-as-start-app-admin) (from the account to be fixed Windows Station session!), navigate to `cd /d "C:\AUNLDEV\Fix\"`  
5) Execute the `fix.bat` script once from the command line  
6) That's it, enjoy  

# Notes

## Features

Before executing the `fix.bat` script, you can edit the file and prepend `REM ` before any functionality you do not want or need.

For example, if you do not want custom backgrounds ability:

```
...
call "%ROOT%make_admin.bat" >> "%LOG%" 2>&1
REM call "%ROOT%allow_custom_backgrounds.bat" >> "%LOG%" 2>&1
call "%ROOT%allow_changing_power_settings.bat" >> "%LOG%" 2>&1
...
```
instead of:

```
...
call "%ROOT%make_admin.bat" >> "%LOG%" 2>&1
call "%ROOT%allow_custom_backgrounds.bat" >> "%LOG%" 2>&1
call "%ROOT%allow_changing_power_settings.bat" >> "%LOG%" 2>&1
...
```

## Log file

Execution of the script is logged to `fix.log`. The log is located in the same folder as `fix.bat`.

## Errors

Sometimes, errors are to be expected. 

This occurs and can be normal due to:
- Files/Registry that must be deleted, already deleted (files/keys don't exist)
- Files/Registry where ACLs must be modified/locked, already modified/locked (and thus unable to change them again, on purpose, permission errors)
- Accounts being added to a group to which they already belong
- etc..

The log is created as a debugging aid, not as a "status indication" of "everything went OK".

Example log which is OK:

```
Setup started: 29/09/2026 15:30:41.15
Remove internet mark
Ensure Fix task
Checking scheduled task: \Fix\Fix
Scheduled task '\Fix\Fix' already exists and is enabled.
Run mode: scheduled
Running from Task Scheduler
make_admin
System error 1378 has occurred.

The specified account name is already a member of the group.

allow_custom_backgrounds
ERROR: Access is denied.

ERROR: Access is denied.

You cannot call a method on a null-valued expression.
At C:\LocalData\Fix\allow_custom_backgrounds.ps1:14 char:1
+ $acl.AddAccessRule($rule)
+ ~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidOperation: (:) [], RuntimeException
    + FullyQualifiedErrorId : InvokeMethodOnNull
 
Set-Acl : Cannot bind argument to parameter 'AclObject' because it is null.
At C:\LocalData\Fix\allow_custom_backgrounds.ps1:15 char:14
+ Set-Acl $key $acl
+              ~~~~
    + CategoryInfo          : InvalidData: (:) [Set-Acl], ParameterBindingValidationException
    + FullyQualifiedErrorId : ParameterArgumentValidationErrorNullNotAllowed,Microsoft.PowerShell.Commands.SetAclComma 
   nd
 
The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

ERROR: The system was unable to find the specified registry key or value.
ERROR: The system was unable to find the specified registry key or value.
ERROR: The system was unable to find the specified registry key or value.
ERROR: The system was unable to find the specified registry key or value.
The system cannot find the file specified.
Could Not Find C:\Windows\System32\background.jpg
Could Not Find C:\Windows\System32\lockscreen.jpg
allow_changing_power_settings
ERROR: Invalid key name.
Type "REG DELETE /?" for usage.
ERROR: Invalid key name.
Type "REG ADD /?" for usage.
Set-Acl : Requested registry access is not allowed.
At C:\LocalData\Fix\allow_changing_power_settings.ps1:15 char:1
+ Set-Acl $key $acl
+ ~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (HKEY_LOCAL_MACH...nt\device\Power:String) [Set-Acl], SecurityExceptio 
   n
    + FullyQualifiedErrorId : System.Security.SecurityException,Microsoft.PowerShell.Commands.SetAclCommand
 
add_console_lock_display_off_timeout_to_power_settings
The operation completed successfully.

link_elevated_and_unelevated_mappings
The operation completed successfully.

make_sure_network_drives_are_mapped_after_any_user_login
        1 file(s) copied.
allow_custom_firewall_rules
The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

allow_rdp
The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

add_defender_exclusions_for_dev_directory
The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

The operation completed successfully.

disable_5min_lock
Set-ItemProperty : Requested registry access is not allowed.
At C:\LocalData\Fix\disable_5min_lock.ps1:11 char:1
+ Set-ItemProperty $currentKey  -Name MaxInactivityTimeDeviceLock -Valu ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (HKEY_LOCAL_MACH...vice\DeviceLock:String) [Set-ItemProperty], Securit 
   yException
    + FullyQualifiedErrorId : System.Security.SecurityException,Microsoft.PowerShell.Commands.SetItemPropertyCommand
 
Set-ItemProperty : Requested registry access is not allowed.
At C:\LocalData\Fix\disable_5min_lock.ps1:12 char:1
+ Set-ItemProperty $providerKey -Name MaxInactivityTimeDeviceLock -Valu ...
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (HKEY_LOCAL_MACH...vice\DeviceLock:String) [Set-ItemProperty], Securit 
   yException
    + FullyQualifiedErrorId : System.Security.SecurityException,Microsoft.PowerShell.Commands.SetItemPropertyCommand
 
Set-Acl : Requested registry access is not allowed.
At C:\LocalData\Fix\disable_5min_lock.ps1:31 char:5
+     Set-Acl $key $acl
+     ~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (HKEY_LOCAL_MACH...vice\DeviceLock:String) [Set-Acl], SecurityExceptio 
   n
    + FullyQualifiedErrorId : System.Security.SecurityException,Microsoft.PowerShell.Commands.SetAclCommand
 
Set-Acl : Requested registry access is not allowed.
At C:\LocalData\Fix\disable_5min_lock.ps1:31 char:5
+     Set-Acl $key $acl
+     ~~~~~~~~~~~~~~~~~
    + CategoryInfo          : PermissionDenied: (HKEY_LOCAL_MACH...vice\DeviceLock:String) [Set-Acl], SecurityExceptio 
   n
    + FullyQualifiedErrorId : System.Security.SecurityException,Microsoft.PowerShell.Commands.SetAclCommand
 
allow_powershell_script_execution
The operation completed successfully.

keep_alive
Active console user: CORPAU\***
Scheduled task name: Never Lock (***)
Scheduled task already exists: Never Lock (***)
No changes were made.
Setup finished: 29/09/2026 15:30:51.22
```

# Details of the Fix

## `Fix.xml`
This is a scheduled task in .XML file format, this file is used as the template for new Fix tasks. As such this is an unfinished task and not meant to be imported directly into Task Scheduler.

## `Fix.bat`

`Fix.bat` is the entry point of the fix and bootstraps all fixes.  

- First what the script does: Remove from all files in the current directory the "[internet mark](https://en.wikipedia.org/wiki/Mark_of_the_Web)" alternative NTFS stream. The reason for this is that Windows will block execution of scripts which come from the internet (or copied from a network location).

- Then `ensure_fix_task.ps1` is being run which ensured that `fix.bat` is added to the [Task Scheduler](https://learn.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-start-page) (see below).  

- Then the script checks if it is being run `scheduled` (from [Task Scheduler](https://learn.microsoft.com/en-us/windows/win32/taskschd/task-scheduler-start-page), `--scheduled`) or `interactive`ly.  
Depending on the runmode; if it's `interactive` then a one-time setup is performed in addition to normal execution of the `fix.bat` script.  
  - When `fix.bat` runs `interactive`ly, it executes `create_make_admin.ps1`.  
  - Then execution continues normally and the following scripts are executed:  
    - `make_admin.bat`  
    - `allow_custom_backgrounds.bat`  
    - `allow_changing_power_settings.bat`  
    - `add_console_lock_display_off_timeout_to_power_settings.bat`  
    - `link_elevated_and_unelevated_mappings.bat`  
    - `make_sure_network_drives_are_mapped_after_any_user_login.bat`  
    - `allow_custom_firewall_rules.bat`  
    - `allow_rdp.bat`  
    - `add_defender_exclusions_for_dev_directory.bat`  
    - `disable_5min_lock.bat`  
    - `allow_powershell_script_execution.bat`  
    - `keep_alive.bat`  

## `ensure_fix_task.ps1`

The "Ensure Fix Task" script makes sure that the Fix task is present in the Task Scheduler.  
If the task is not present:  
- `Fix.xml` is read
- `<Command>C:\Somewhere\fix.bat</Command>` is corrected to the correct location (current directory where the [PowerShell](https://learn.microsoft.com/en-us/powershell/) script is), for example `<Command>C:\AUNLDEV\Fix\fix.bat</Command>`
- `<WorkingDirectory>C:\Somewhere\</WorkingDirectory>` is corrected to the correct location (current directory where the PowerShell script is), for example `<WorkingDirectory>C:\AUNLDEV\Fix\</WorkingDirectory>`
- The output is written to `Fix.modified.xml`
- Task Scheduler is instructed to import the Task, the task will be present inside the path: `Task Scheduler Library\Fix\Fix`

The task is set to execute at the following events:
- At log on of any user
- At startup
- On connection to user session
- On disconnect from user session
- On workstation unlock
- On workstation lock

This ensures that any policies applied from Intune/AD, will be overridden as soon as possible, but without overdoing it (e.g. run every 5 minutes).

## `create_make_admin.ps1`

This script determined the current logged on Windows Station (GUI environment) user, and creates a `make_admin.bat` script inside the current directory, which will add the current GUI user to the administrators group. `make_admin.bat` will be created from the following template:

```
@echo off
echo make_admin
net localgroup Administrators "<username>" /add
```

To achieve this, the powershell script utilizes a Win32Api function called [`WTSGetActiveConsoleSessionId`](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-wtsgetactiveconsolesessionid) to determine the active console, and [Cim](https://learn.microsoft.com/en-us/windows/win32/wmisdk/common-information-model) functions to determine the owning user.  

## `make_admin.bat`

This script is auto-generated once and contains a hardcoded account/username which has to be added to the administrators group when the `fix.bat` script is being run.

## `allow_custom_backgrounds.bat`  

This script enables customization of the desktop background. By default this is blocked, this script unblocks it by:  
- Deleting [Cloud Solution Provider](https://learn.microsoft.com/en-us/partner-center/enroll/csp-overview) (CSP) policies related to desktop personalization
- Locking the relevant registry keys such that Intune (or anything else for that matter) cannot apply its own policies (Intune will get Access Denied errors) [This is considered a risky operation]
- Removing any currently applied policies
- Removing the current transcoded wallpapers (although this might be unneeded) in `%APPDATA%\Microsoft\Windows\Themes\TranscodedWallpaper`
- Removing the company locked wallpapers:
  - `C:\Windows\System32\background.jpg`
  - `C:\Windows\System32\lockscreen.jpg`
- Refreshes the desktop session

## `allow_changing_power_settings.bat`  

This script allows changing locked power settings, balances, etc.

The following actions are performed:
- Relevant power settings policies are removed from registry
- The power registry policies keys are locked such that no modifications by anyone or anything are possible (Access Denied to everything) [This is considered a risky operation]

## `add_console_lock_display_off_timeout_to_power_settings.bat`  

This script add the registry key to the power settings to expose the setting "Console Lock Display Off Timeout" in the Power Settings.  
It is hidden by default.

## `link_elevated_and_unelevated_mappings.bat`  

This is a quality-of-life script, which adds the relevant registry keys for making sure that mapped network shares are available in both elevated and unelevated contexts. It can introduce security issues, so tread lightly.  

More information: https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/ee844140(v=ws.10)?redirectedfrom=MSDN

## `make_sure_network_drives_are_mapped_after_any_user_login.bat`  

This script copies `shares.bat` into `C:\ProgramData\Microsoft\Windows\Start Menu\Programs\Startup\`, such that `shared.bat` will run on any user logon.

## `shares.bat`

This script maps `\\AUNLFILE` shares to drive letters inside Windows Explorer.

## `allow_custom_firewall_rules.bat`  

This script adds registry keys to the MDM policies such that merging custom firewall rules is allowed to occur with the Intune policies enabled.  
I chose to allow Intune policies because permanently blocking Defender/Intune from accessing security registry keys makes Windows go into a Blue Screen of Death (security violation).  
If that happens, this can only be resolved by booting into a second clean Windows install/boot disk/recovery environment, unlocking the OS drive, mapping the registry hive, and fixing the permissions on the security registry keys such that Defender and Intune can access them.. so don't do that.  
Merging policies is the only safe option here (also better for security).

In addition it adds some relaxation to the Private and Domain firewall rules, such as allowing UPnP, Remote Desktop, File sharing and Printing, ICMP and merging of custom configured application rules.  
This is done by importing the reg files:
- `fw_domain.reg`
- `fw_standard.reg`

It is possible that this stops working in the future or does not work anymore.

## `allow_rdp.bat` 

Enabled the registry keys to allow RDP.

## `add_defender_exclusions_for_dev_directory.bat`  

This script adds the following directories to Defender exclusions:
- `C:\LocalData\`
- `C:\Program Files (x86)\`
- `C:\Program Files\`
- `C:\Users\rafal.grasman\AppData\`
- `C:\Python314\`

It is recommended to modify the hardcoded paths in this script after adding it to a PC.  

It is possible that this stops working in the future or does not work anymore.  

## `disable_5min_lock.bat`  

This script tries to override the policy for automatic device locking.  
Research shows that this somehow does not override the policy and the laptop still locks after 5 minutes.  
This script is left in here in the eventuality that someone debugs this somehow.  

## `allow_powershell_script_execution.bat`  

This script enabled system wide PowerShell script execution.  
For development scenario's it's quite frustrating when scripts cannot be run.  

## `keep_alive.bat`  

Because the `disable_5min_lock.bat` script does not work, `keep_alive.bat` introduces a different solution.
This will ensure that your Windows session does not automatically lock.  

It checks if the "Never Lock (<username>)" Scheduled Task for the currently logged in user exists.  
If the task does not exist:
- The script `keep_alive_auto_install_once.ps1` is executed, which performs;
- Gathering of the currently logged on user
- Creating a new PowerShell script at `%localappdata%\stay_awake_runner.ps` with a small program that makes Windows think there's activity constantly
- The Keep Alive task is created, Task Scheduler will show a new task named `Task Scheduler Library\Never Lock(<username>)`
- The new Scheduled Task will execute the `%localappdata%\stay_awake_runner.ps` with special parameters (as `conhost.exe --headless`) to now show a window to the user and to keep it hidden, so it does not get closed by accident. `conhost.exe --headless` is an undocumented feature and Microsoft says it's not official and can be removed or changed at any time.
- The script will be executed at log on of the current user

## `setup_git_hooks.bat` / `setup_git_hooks.ps1`

This script must be run manually, once, only if wanted.  
This script creates git commit and push hooks inside the current users configuration (`%userprofile%\.git-hooks\`) that:
- Disallow committing on a detached head
- Disallow pushing from detached head

As this led to small heart-attacks in the past where we thought code was completely gone. Apparently git allows to just work outside of a tree, invisibly, without seeing the changes, but still being somewhere in the git repository. That's ok, but there's so many mini-heart-attacks we can survive, as such I strongly recommend running this script once.  

## `TedNPadSettings.reg`

This is a backup of my [TedNPad](https://jsimlo.sk/notepad/) settings. Sorry ;)

