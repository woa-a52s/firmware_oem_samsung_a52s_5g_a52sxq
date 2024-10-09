# A52sxq Firmware

This repository holds the latest Firmware for A52sxq devices alongside the scripts and tools used to generate the output folder, designed to be used for Windows.

## Script

- Extract vendor.img (contained in AP super.img) into extracted\vendor
- Extract NON-HLOS.bin (contained in BL) into extracted\NON-HLOS
- Extract modem.bin (contained in CP) into extracted\modem
- Extract dspso.bin (contained in BL) into extracted\dsp
- Copy abl.elf (contained in BL) into extracted
- Copy aop.mbn (contained in BL) into extracted
- Copy cpucp.elf (contained in BL) into extracted
- Copy imagefv.elf (contained in BL) into extracted
- Copy qupv3fw.elf (contained in BL) into extracted
- Copy shrm.elf (contained in BL) into extracted
- Copy uefi_sec.mbn (contained in BL) into extracted
- Copy xbl.elf (contained in BL) into extracted
- Run build.cmd

```
  _______        __  _____      _                  _
 |  ___\ \      / / | ____|_  _| |_ _ __ __ _  ___| |_ ___  _ __
 | |_   \ \ /\ / /  |  _| \ \/ / __| '__/ _` |/ __| __/ _ \| '__|
 |  _|   \ V  V /   | |___ >  <| |_| | | (_| | (__| || (_) | |
 |_|      \_/\_/    |_____/_/\_\\__|_|  \__,_|\___|\__\___/|_|


Target: A52sxq
SoC   : SM7325
RKH   : 2169476B5DB4A43D2475C40CA2A3B122CECD15361F437C488D7FE785FB6E8409 (Samsung Firmware Origin Attestation CA)
```