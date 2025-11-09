@echo off
REM ==================================================
REM Advanced Windows Defender Management Script
REM Created by Yaxploit
REM For Educational Malware Analysis in Controlled Labs
REM ==================================================
setlocal EnableDelayedExpansion

title Windows Defender Manager - Created by Yaxploit

:: Enhanced Admin Check
echo Checking administrator privileges...
fsutil dirty query %SystemDrive% >nul 2>&1
if errorlevel 1 (
    echo.
    echo [ERROR] Administrator privileges required!
    echo Please right-click and "Run as administrator"
    echo.
    pause
    exit /b 1
)

:: Initialize variables
set "defenderService=WinDefend"
set "defenderProcess=MsMpEng.exe"
set "exclusionList="

:: Logging function
set "logFile=%temp%\DefenderManager_%date:~-4,4%%date:~-10,2%%date:~-7,2%_%time:~0,2%%time:~3,2%.log"
set "logFile=%logFile: =0%"
echo [%date% %time%] Script started by %username% >> "%logFile%"

:main_menu
cls
echo ========================================
echo    ADVANCED WINDOWS DEFENDER MANAGER
echo      Created by Yaxploit
echo    Educational Use - Controlled Lab Only
echo ========================================
echo.
echo Current Status:
call :check_defender_status
echo.
echo Available Actions:
echo 1. DISABLE Windows Defender Completely
echo 2. Disable Real-time Protection Only
echo 3. Enable Windows Defender
echo 4. Add Folder/File Exclusion
echo 5. Remove All Exclusions
echo 6. Tamper Protection Bypass
echo 7. Service Management
echo 8. Create Restore Point
echo 9. View Log
echo 0. EXIT
echo.
set /p choice="Enter your choice (0-9): "

if "%choice%"=="1" goto disable_complete
if "%choice%"=="2" goto disable_realtime
if "%choice%"=="3" goto enable_defender
if "%choice%"=="4" goto add_exclusion
if "%choice%"=="5" goto remove_exclusions
if "%choice%"=="6" goto tamper_protection
if "%choice%"=="7" goto service_management
if "%choice%"=="8" goto create_restore
if "%choice%"=="9" goto view_log
if "%choice%"=="0" goto exit_script

echo Invalid choice. Please try again.
timeout /t 2 >nul
goto main_menu

:disable_complete
echo.
echo [STEP 1/7] Stopping Windows Defender services...
sc stop %defenderService% >nul 2>&1
sc stop "WdNisSvc" >nul 2>&1
sc stop "Sense" >nul 2>&1
timeout /t 1 >nul

echo [STEP 2/7] Killing running processes...
taskkill /f /im %defenderProcess% >nul 2>&1
taskkill /f /im "NisSrv.exe" >nul 2>&1
taskkill /f /im "MsMpEng.exe" >nul 2>&1

echo [STEP 3/7] Disabling via Group Policy...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v ServiceKeepAlive /t REG_DWORD /d 0 /f >nul 2>&1

echo [STEP 4/7] Configuring Real-time Protection registry...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableBehaviorMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableOnAccessProtection /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableScanOnRealtimeEnable /t REG_DWORD /d 1 /f >nul 2>&1

echo [STEP 5/7] Applying PowerShell configurations...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true -DisableIOAVProtection $true -DisablePrivacyMode $true -DisableBlockAtFirstSeen $true -DisableScriptScanning $true -DisableArchiveScanning $true -DisableCatchupFullScan $true -DisableCatchupQuickScan $true -ErrorAction SilentlyContinue" >nul 2>&1

echo [STEP 6/7] Disabling services...
sc config %defenderService% start= disabled >nul 2>&1
sc config "WdNisSvc" start= disabled >nul 2>&1
sc config "Sense" start= disabled >nul 2>&1

echo [STEP 7/7] Final cleanup...
timeout /t 2 >nul
taskkill /f /im %defenderProcess% >nul 2>&1
taskkill /f /im "NisSrv.exe" >nul 2>&1

echo [SUCCESS] Windows Defender completely disabled!
echo [%date% %time%] Defender completely disabled by %username% >> "%logFile%"
echo.
echo Note: Some components may require reboot to fully take effect.
timeout /t 3 >nul
goto main_menu

:disable_realtime
echo.
echo Disabling Real-time Protection...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /v DisableRealtimeMonitoring /t REG_DWORD /d 1 /f >nul 2>&1
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $true -ErrorAction SilentlyContinue" >nul 2>&1
echo [SUCCESS] Real-time protection disabled
echo [%date% %time%] Real-time protection disabled by %username% >> "%logFile%"
timeout /t 2 >nul
goto main_menu

:enable_defender
echo.
echo [STEP 1/4] Enabling via Group Policy...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender" /v DisableAntiSpyware /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Real-Time Protection" /f >nul 2>&1

echo [STEP 2/4] Applying PowerShell configurations...
powershell -Command "Set-MpPreference -DisableRealtimeMonitoring $false -DisableBehaviorMonitoring $false -DisableIOAVProtection $false -DisableBlockAtFirstSeen $false -DisableScriptScanning $false -DisableArchiveScanning $false -ErrorAction SilentlyContinue" >nul 2>&1

echo [STEP 3/4] Enabling and starting services...
sc config %defenderService% start= auto >nul 2>&1
sc config "WdNisSvc" start= auto >nul 2>&1
sc config "Sense" start= auto >nul 2>&1
sc start %defenderService% >nul 2>&1
sc start "WdNisSvc" >nul 2>&1

echo [STEP 4/4] Resetting exclusions...
powershell -Command "Remove-MpPreference -ExclusionPath (Get-MpPreference).ExclusionPath -ErrorAction SilentlyContinue" >nul 2>&1

echo [SUCCESS] Windows Defender enabled and reset!
echo [%date% %time%] Defender enabled by %username% >> "%logFile%"
timeout /t 3 >nul
goto main_menu

:add_exclusion
echo.
set /p "exclusionPath=Enter folder or file path to exclude: "
if "!exclusionPath!"=="" (
    echo No path specified.
    goto main_menu
)

if not exist "!exclusionPath!" (
    echo [WARNING] Path does not exist: !exclusionPath!
    echo Would you like to create it? (Y/N)
    set /p "createChoice="
    if /i "!createChoice!"=="Y" (
        mkdir "!exclusionPath!" >nul 2>&1
        if errorlevel 1 (
            echo [ERROR] Failed to create directory!
            goto main_menu
        )
    ) else (
        goto main_menu
    )
)

powershell -Command "Add-MpPreference -ExclusionPath '!exclusionPath!' -ErrorAction SilentlyContinue" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to add exclusion!
) else (
    echo [SUCCESS] Added exclusion: !exclusionPath!
    echo [%date% %time%] Exclusion added: !exclusionPath! by %username% >> "%logFile%"
)
timeout /t 2 >nul
goto main_menu

:remove_exclusions
echo.
echo Removing all exclusions...
powershell -Command "Remove-MpPreference -ExclusionPath (Get-MpPreference).ExclusionPath -ErrorAction SilentlyContinue" >nul 2>&1
echo [SUCCESS] All exclusions removed!
echo [%date% %time%] All exclusions removed by %username% >> "%logFile%"
timeout /t 2 >nul
goto main_menu

:tamper_protection
echo.
echo [INFO] Attempting to disable Tamper Protection...
echo This may require multiple methods...

echo Method 1: Registry modification...
reg add "HKLM\SOFTWARE\Microsoft\Windows Defender\Features" /v TamperProtection /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender\Spynet" /v DisableBlockAtFirstSeen /t REG_DWORD /d 1 /f >nul 2>&1

echo Method 2: Security Center...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows Defender Security Center\App and Browser protection" /v DisallowWindowsSecurityAppBrowserProtection /t REG_DWORD /d 1 /f >nul 2>&1

echo Method 3: Service restart...
sc stop %defenderService% >nul 2>&1
timeout /t 2 >nul
sc start %defenderService% >nul 2>&1

echo [SUCCESS] Tamper Protection bypass attempted!
echo [%date% %time%] Tamper Protection bypass attempted by %username% >> "%logFile%"
echo Note: Tamper Protection may require reboot or additional steps on Windows 11.
timeout /t 2 >nul
goto main_menu

:service_management
cls
echo ========================================
echo         SERVICE MANAGEMENT
echo ========================================
echo.
echo 1. Stop Defender Services
echo 2. Start Defender Services  
echo 3. Set Services to Disabled
echo 4. Set Services to Automatic
echo 5. Back to Main Menu
echo.
set /p serviceChoice="Select option: "

if "!serviceChoice!"=="1" (
    sc stop %defenderService% >nul 2>&1
    sc stop "WdNisSvc" >nul 2>&1
    sc stop "Sense" >nul 2>&1
    echo [SUCCESS] Defender services stopped!
) else if "!serviceChoice!"=="2" (
    sc start %defenderService% >nul 2>&1
    sc start "WdNisSvc" >nul 2>&1
    sc start "Sense" >nul 2>&1
    echo [SUCCESS] Defender services started!
) else if "!serviceChoice!"=="3" (
    sc config %defenderService% start= disabled >nul 2>&1
    sc config "WdNisSvc" start= disabled >nul 2>&1
    sc config "Sense" start= disabled >nul 2>&1
    echo [SUCCESS] Defender services set to disabled!
) else if "!serviceChoice!"=="4" (
    sc config %defenderService% start= auto >nul 2>&1
    sc config "WdNisSvc" start= auto >nul 2>&1
    sc config "Sense" start= auto >nul 2>&1
    echo [SUCCESS] Defender services set to automatic!
) else if "!serviceChoice!"=="5" (
    goto main_menu
) else (
    echo Invalid choice!
)
if not "!serviceChoice!"=="5" (
    echo [%date% %time%] Service management: Option !serviceChoice! by %username% >> "%logFile%"
    timeout /t 2 >nul
)
goto main_menu

:create_restore
echo.
echo Creating system restore point...
powershell -Command "Checkpoint-Computer -Description 'Pre-Defender-Disabled-by-Yaxploit-Script' -RestorePointType 'MODIFY_SETTINGS'" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to create restore point!
    echo.
    echo Possible solutions:
    echo 1. Run this in PowerShell as Admin: Enable-ComputerRestore -Drive "C:\"
    echo 2. System Protection may be disabled for C: drive
    echo 3. Check available disk space
) else (
    echo [SUCCESS] Restore point created successfully!
    echo [%date% %time%] Restore point created by %username% >> "%logFile%"
)
timeout /t 3 >nul
goto main_menu

:view_log
cls
echo ========================================
echo              ACTIVITY LOG
echo ========================================
echo.
if exist "%logFile%" (
    echo Log file: %logFile%
    echo.
    type "%logFile%"
) else (
    echo [INFO] No log file found at: %logFile%
    echo Logging starts when script is run as administrator.
)
echo.
pause
goto main_menu

:check_defender_status
set "defenderEnabled=0"
sc query %defenderService% | findstr "RUNNING" >nul && set "defenderEnabled=1"

powershell -Command "Get-MpComputerStatus | Select-Object AntivirusEnabled, RealTimeProtectionEnabled" | findstr "True" >nul && set "defenderEnabled=1"

if !defenderEnabled!==1 (
    echo [STATUS: ENABLED] - Windows Defender is active
) else (
    echo [STATUS: DISABLED] - Windows Defender is inactive
)
goto :eof

:exit_script
echo.
echo [%date% %time%] Script exited by user %username% >> "%logFile%"
echo Thank you for using Advanced Defender Manager by Yaxploit
echo Remember to re-enable protection after testing!
echo.
pause
exit /b 0
