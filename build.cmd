@echo off

echo.
echo.  _______        __  _____      _                  _             
echo. ^|  ___\ \      / / ^| ____^|_  _^| ^|_ _ __ __ _  ___^| ^|_ ___  _ __ 
echo. ^| ^|_   \ \ /\ / /  ^|  _^| \ \/ / __^| '__/ _` ^|/ __^| __/ _ \^| '__^|
echo. ^|  _^|   \ V  V /   ^| ^|___ ^>  ^<^| ^|_^| ^| ^| ^(_^| ^| ^(__^| ^|^| ^(_^) ^| ^|   
echo. ^|_^|      \_/\_/    ^|_____/_/\_\\__^|_^|  \__,_^|\___^|\__\___/^|_^|   
echo.                                                                 

REM A52sxq Root Key Hashes
set RKH_LIST=2169476B5DB4A43D2475C40CA2A3B122CECD15361F437C488D7FE785FB6E8409 959B8D0549EF41BEFABC24F51EFE84FEE366AC169AB04A0DB30C799B324FD798 A9F671F167DDE185AEDA9D391F94B5E1A25DB2F1156FF7117DE41B681F526C42 F8AB20526358C4FA4CEF96D78C45180DC3DB75E8F24051AD624448C134B4E861

set SOC=7325

echo.
echo Target: A52sxq
echo SoC   : SM%SOC%
echo RKH   : %RKH_LIST% (Samsung Attestation CA) (From: Nov 3 2023 GMT To: Oct 29 2043 GMT)
echo.

for /f %%f in ('dir /b /s extracted\*.mbn.unsigned') do (
    call :moveUnsigned %%f
)

for /f %%f in ('dir /b /s extracted\*_unsigned.mbn') do (
    call :moveUnsigned %%f
)

echo Checking MBN files validity... (This may take a while!)

for /f %%f in ('dir /b /s extracted\*.mbn') do (
    call :checkRKH %%f
)

echo Checking ELF files validity... (This may take a while!)

for /f %%f in ('dir /b /s extracted\*.elf') do (
    call :checkRKH %%f
)

echo Checking BIN files validity... (This may take a while!)

for /f %%f in ('dir /b /s extracted\*.bin') do (
    call :checkRKH %%f
)

echo Checking IMG files validity... (This may take a while!)

for /f %%f in ('dir /b /s extracted\*.img') do (
    call :checkRKH %%f
)

REM echo Cleaning up Output Directory...
REM rmdir /Q /S output

REM echo Cleaning up PIL Squasher Directory...
REM rmdir /Q /S pil-squasher

REM echo Cloning PIL Squasher...

REM git clone https://github.com/linux-msm/pil-squasher

REM echo Building PIL Squasher...

REM cd pil-squasher
REM bash.exe -c make
REM cd ..

mkdir output
mkdir output\Subsystems


REM ADSP
mkdir output\Subsystems\ADSP
mkdir output\Subsystems\ADSP\ADSP

REM echo Converting Analog DSP Image...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/Subsystems/ADSP/qcadsp%SOC%.mbn ./extracted/NON-HLOS/image/adsp.mdt"

echo Copying ADSP Protection Domain Registry Config files...
xcopy /qchky /-i extracted\NON-HLOS\image\adspr.jsn output\Subsystems\ADSP\adspr.jsn
xcopy /qchky /-i extracted\NON-HLOS\image\adsps.jsn output\Subsystems\ADSP\adsps.jsn
xcopy /qchky /-i extracted\NON-HLOS\image\adspua.jsn output\Subsystems\ADSP\adspua.jsn

echo Copying ADSP lib files...
xcopy /qcheriky extracted\vendor\lib\rfsa\adsp output\Subsystems\ADSP\ADSP
xcopy /qcheriky extracted\dsp\adsp output\Subsystems\ADSP\ADSP

echo Generating ADSP FASTRPC INF Configuration...
tools\SuBExtInfUpdater-ADSP.exe output\Subsystems\ADSP\ADSP > output\Subsystems\ADSP\inf_configuration.txt


REM CDSP
mkdir output\Subsystems\CDSP
mkdir output\Subsystems\CDSP\CDSP

REM echo Converting Compute DSP Image...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/Subsystems/CDSP/qccdsp%SOC%.mbn ./extracted/NON-HLOS/image/cdsp.mdt"

echo Copying CDSP Protection Domain Registry Config files...
xcopy /qchky /-i extracted\NON-HLOS\image\cdspr.jsn output\Subsystems\CDSP\cdspr.jsn

echo Copying CDSP lib files...
xcopy /qcheriky extracted\dsp\cdsp output\Subsystems\CDSP\CDSP

echo Generating CDSP FASTRPC INF Configuration...
tools\SuBExtInfUpdater-CDSP.exe output\Subsystems\CDSP\CDSP > output\Subsystems\CDSP\inf_configuration.txt


REM EVASS
mkdir output\Subsystems\EVASS

xcopy /qchky /-i extracted\vendor\firmware\evass.mbn output\Subsystems\EVASS\evass.mbn


REM ICP
mkdir output\Subsystems\ICP

xcopy /qchky /-i extracted\vendor\firmware\CAMERA_ICP.elf output\Subsystems\ICP\CAMERA_ICP_AAAAAA.elf


REM IPA
mkdir output\Subsystems\IPA

xcopy /qchky /-i extracted\vendor\firmware\ipa_fws.elf output\Subsystems\IPA\ipa_fws.elf


REM MCFG
mkdir output\Subsystems\MCFG
mkdir output\Subsystems\MCFG\MCFG

echo Generating MCFG TFTP INF Configuration...
tools\SuBExtInfUpdater-MCFG.exe extracted\modem\image\modem_pr output\Subsystems\MCFG\MCFG > output\Subsystems\MCFG\inf_configuration.txt

xcopy /qchky /-i extracted\modem\image\kodiak\qdsp6m.qdb output\Subsystems\MCFG\qdsp6m.qdb


REM MPSS
mkdir output\Subsystems\MPSS

echo Copying MPSS Protection Domain Registry Config files...
xcopy /qchky /-i extracted\modem\image\modemr.jsn output\Subsystems\MPSS\modemr.jsn

REM echo Converting Modem Processor Subsystem DSP Image...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/Subsystems/MPSS/qcmpss%SOC%.mbn ./extracted/modem/image/modem.mdt"


REM Generate VENUS
mkdir output\Subsystems\VENUS

REM echo Converting Video Encoding Subsystem DSP Image...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/Subsystems/VENUS/qcvss%SOC%.mbn ./extracted/NON-HLOS/image/vpu20_1v.mdt"


REM ZAP
mkdir output\Subsystems\ZAP

REM echo Converting GPU ZAP Shader Micro Code DSP Image...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/Subsystems/ZAP/qcdxkmsuc%SOC%.mbn ./extracted/NON-HLOS/image/a660_zap.mdt"


REM Bluetooth
mkdir output\BT

echo Copying Blueooth Firmware Files...
xcopy /qcheriky /-i extracted\vendor\firmware\msbtfw11.mbn output\BT\msbtfw11.mbn
xcopy /qcheriky /-i extracted\vendor\firmware\msbtfw11.tlv output\BT\msbtfw11.tlv
xcopy /qcheriky /-i extracted\vendor\firmware\msnv11.bin output\BT\msnv11.bin


REM WCNSS
mkdir output\Subsystems\WCNSS

xcopy /qchky extracted\vendor\firmware\qca6750\bdwlan.elf* output\Subsystems\WCNSS\
xcopy /qchky /-i extracted\vendor\firmware\Data.msc output\Subsystems\WCNSS\Data.msc
xcopy /qchky /-i extracted\vendor\firmware\qca6750\qdss_trace_config.cfg output\Subsystems\WCNSS\qdss_trace_config.bin
xcopy /qchky /-i extracted\vendor\firmware\qca6750\regdb.bin output\Subsystems\WCNSS\regdb.bin


REM Sensors
mkdir output\Sensors
mkdir output\Sensors\Config

xcopy /qchky /-i extracted\vendor\etc\sensors\sns_reg_config output\Sensors\Config\sns_reg_config
xcopy /qcheriky extracted\vendor\etc\sensors\config output\Sensors\Config

echo Generating SLPI FASTRPC INF Configuration...
tools\SuBExtInfUpdater-SLPI.exe output\Sensors\Config > output\Sensors\inf_configuration.txt
move output\Sensors\inf_configuration.txt output\Sensors\Config\inf_configuration.txt

mkdir output\Sensors\Proto

xcopy /qcheriky extracted\vendor\etc\sensors\proto output\Sensors\Proto


REM Audio
mkdir output\Audio
mkdir output\Audio\Cal

xcopy /qchky /-i extracted\vendor\etc\acdbdata\adsp_avs_config.acdb output\Audio\Cal\adsp_avs_config.acdb


mkdir output\Regulatory


REM TrEE
mkdir output\TrEE

REM echo Converting engmode (n=engmode;p=8:c477a8cf3e4089,61,82:6004,b4) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/engmode.mbn ./extracted/NON-HLOS/image/engmode.mdt"

REM echo Converting fingerpr (n=fingerprint;p=8:cc7728cf3ec089,61,82:6004,b4) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/fingerpr.mbn ./extracted/NON-HLOS/image/fingerpr.mdt"

REM echo Converting hdcp1 (n=hdcp1;p=8:c477a8cf3e40893,61,82:6004,b4;s=55) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/hdcp1.mbn ./extracted/NON-HLOS/image/hdcp1.mdt"

REM echo Converting hdcp2p2 (n=qcom.tz.hdcp2p2;p=8:c47728cf3e408911,5a:94,82:6004,b4;s=43,56) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/hdcp2p2.mbn ./extracted/NON-HLOS/image/hdcp2p2.mdt"

REM echo Converting hdcpsrm (n=hdcpsrm;p=8:c47728cf3e4089,5d:8,82:6004,b4;s=5e) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/hdcpsrm.mbn ./extracted/NON-HLOS/image/hdcpsrm.mdt"

REM echo Converting tz_hdm (n=tz_hdm;p=8:c47728cf3e4089,61,80:a1001,b4,106:81;s=122) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/tz_hdm.mbn ./extracted/NON-HLOS/image/tz_hdm.mdt"

REM echo Converting tz_iccc (n=tz_iccc;p=8:c477a8cf3ec089,61,80:a1001,b4,400;s=106:81) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/tz_iccc.mbn ./extracted/NON-HLOS/image/tz_iccc.mdt"

REM echo Converting tz_kg (n=tz_kg;p=8:c477a8cf3e4089,61,80:a1001,b4,122,1036640) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/tz_kg.mbn ./extracted/NON-HLOS/image/tz_kg.mdt"

REM echo Converting vaultkeeper (n=vaultkeeper;p=8:c477a8cf3e4089,61,82:6004,b4,1036640) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/vaultkeeper.mbn ./extracted/NON-HLOS/image/vaultkeeper.mdt"

REM echo Converting voicepri (n=voiceprint;p=8:c47728cf3e4089,61,82:6004,b4) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/voicepri.mbn ./extracted/NON-HLOS/image/voicepri.mdt"

echo Copying widevine (n=widevine;p=8:c47728cf3e4089,5a:24,82:68048,b4,32b,4b1,dac;s=dac) QSEE Applet...
xcopy /qchky /-i extracted\NON-HLOS\image\widevine.mbn output\TrEE\widevine.mbn

REM echo Converting winsecap (n=qcom.tz.winsecapp;p=8:c47728cf3e5089,51:8108,82:6404,b4) QSEE Applet...
REM bash.exe -c "./pil-squasher/pil-squasher ./output/TrEE/winsecap.mbn ./extracted/NON-HLOS/image/winsecap.mdt"

echo Copying rtic (n=rtic;p=8:c47728cf3e4289,60:30080400a3001,b4;s=46;u=6238333e1eb7ea11b3de0242ac130004) QSEE Applet...
xcopy /qchky /-i extracted\NON-HLOS\image\widevine.mbn output\TrEE\widevine.mbn


mkdir output\UEFI

echo Extracting XBL Image...
tools\UEFIReader.exe extracted\xbl.elf output\UEFI

mkdir output\UEFI\ImageFV

echo Extracting ImageFV Image...
tools\UEFIReader.exe extracted\imagefv.elf output\UEFI\ImageFV

mkdir output\UEFI\ABL

echo Extracting ABL Image...
tools\UEFIReader.exe extracted\abl.elf output\UEFI\ABL

:eof
exit /b 0

:checkRKH

set "x=INVALID"
for /F "eol=; tokens=1-2 delims=" %%a in ('tools\RKHReader.exe "%~1" 2^>^&1') do (
    set "x=%%a"
)

echo.
echo File: %~1
echo RKH : %x%
echo.
set "directory=%~dp1"
call set "directory=%%directory:%cd%\=%%"

echo %RKH_LIST% | findstr /I /C:"%x%" >nul
if NOT errorlevel 1 (
    exit /b 1
)

if /I "%x%"=="FAIL!" (
    exit /b 2
)

if /I "%x%"=="EXCEPTION!" (
    exit /b 2
)

echo %~1 is a valid MBN file and is not production signed (%x%). Moving...
mkdir "unsigned\%directory%" 2>nul
move "%~1" "unsigned\%directory%"
exit /b 0

:moveUnsigned

echo.
echo File: %~1
echo.
set "directory=%~dp1"
call set "directory=%%directory:%cd%\=%%"

echo %~1 is a valid MBN file and is not signed. Moving...
mkdir "unsigned\%directory%" 2>nul
move "%~1" "unsigned\%directory%"
exit /b 0
