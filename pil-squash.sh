#!/bin/bash

SOC=7325

chmod +x tools/pil-squasher

# ADSP
mkdir -p output/Subsystems/ADSP
echo "Converting Analog DSP Image..."
./tools/pil-squasher ./output/Subsystems/ADSP/qcadsp${SOC}.mbn ./extracted/NON-HLOS/image/adsp.mdt

# CDSP
mkdir -p output/Subsystems/CDSP
echo "Converting Compute DSP Image..."
./tools/pil-squasher ./output/Subsystems/CDSP/qccdsp${SOC}.mbn ./extracted/NON-HLOS/image/cdsp.mdt

# MPSS
mkdir -p output/Subsystems/MPSS
echo "Converting Modem Processor Subsystem DSP Image..."
./tools/pil-squasher ./output/Subsystems/MPSS/qcmpss${SOC}.mbn ./extracted/modem/image/modem.mdt

# MPSS
mkdir -p output/Subsystems/VENUS
echo "Converting Video Encoding Subsystem DSP Image..."
./tools/pil-squasher ./output/Subsystems/VENUS/qcvss${SOC}.mbn ./extracted/NON-HLOS/image/vpu20_1v.mdt

# ZAP
mkdir -p output/Subsystems/ZAP
echo "Converting GPU ZAP Shader Micro Code DSP Image..."
./tools/pil-squasher ./output/Subsystems/ZAP/qcdxkmsuc${SOC}.mbn ./extracted/NON-HLOS/image/a660_zap.mdt

# WCNSS
mkdir -p output/Subsystems/WCNSS
echo "Converting Wireless Processor Subsystem Image..."
./tools/pil-squasher ./output/Subsystems/WCNSS/wpss.mbn ./extracted/vendor/firmware/wpss.mdt


# TrEE
mkdir -p output/TrEE
echo "Converting engmode (n=engmode;p=8:c477a8cf3e4089,61,82:6004,b4) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/engmode.mbn ./extracted/NON-HLOS/image/engmode.mdt

echo "Converting fingerpr (n=fingerprint;p=8:cc7728cf3ec089,61,82:6004,b4) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/fingerpr.mbn ./extracted/NON-HLOS/image/fingerpr.mdt

echo "Converting hdcp1 (n=hdcp1;p=8:c477a8cf3e40893,61,82:6004,b4;s=55) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/hdcp1.mbn ./extracted/NON-HLOS/image/hdcp1.mdt

echo "Converting hdcp2p2 (n=qcom.tz.hdcp2p2;p=8:c47728cf3e408911,5a:94,82:6004,b4;s=43,56) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/hdcp2p2.mbn ./extracted/NON-HLOS/image/hdcp2p2.mdt

echo "Converting hdcpsrm (n=hdcpsrm;p=8:c47728cf3e4089,5d:8,82:6004,b4;s=5e) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/hdcpsrm.mbn ./extracted/NON-HLOS/image/hdcpsrm.mdt

echo "Converting tz_hdm (n=tz_hdm;p=8:c47728cf3e4089,61,80:a1001,b4,106:81;s=122) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/tz_hdm.mbn ./extracted/NON-HLOS/image/tz_hdm.mdt

echo "Converting tz_iccc (n=tz_iccc;p=8:c477a8cf3ec089,61,80:a1001,b4,400;s=106:81) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/tz_iccc.mbn ./extracted/NON-HLOS/image/tz_iccc.mdt

echo "Converting tz_kg (n=tz_kg;p=8:c477a8cf3e4089,61,80:a1001,b4,122,1036640) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/tz_kg.mbn ./extracted/NON-HLOS/image/tz_kg.mdt

echo "Converting vaultkeeper (n=vaultkeeper;p=8:c477a8cf3e4089,61,82:6004,b4,1036640) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/vaultkeeper.mbn ./extracted/NON-HLOS/image/vaultkeeper.mdt

echo "Converting voicepri (n=voiceprint;p=8:c47728cf3e4089,61,82:6004,b4) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/voicepri.mbn ./extracted/NON-HLOS/image/voicepri.mdt

echo "Converting winsecap (n=qcom.tz.winsecapp;p=8:c47728cf3e5089,51:8108,82:6404,b4) QSEE Applet..."
./tools/pil-squasher ./output/TrEE/winsecap.mbn ./extracted/NON-HLOS/image/winsecap.mdt
