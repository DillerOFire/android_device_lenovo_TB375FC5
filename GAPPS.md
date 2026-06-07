# Google Apps on TB375FC

This LineageOS build ships without Google Mobile Services (GMS). The MindTheGapps
project, NikGapps, and similar gapps projects provide GMS as a separate flashable
package after install.

## Install gapps (recommended: MindTheGapps)

1. Boot LineageOS, complete the setup wizard.
2. Reboot to recovery (`adb reboot recovery` or hold power+volume up).
3. Sideload MindTheGapps for Android 16 (Core or Full variant):
   ```
   adb sideload MindTheGapps-16.0.0-arm64-YYYYMMDD.zip
   ```
4. Reboot, sign in to your Google account.

NikGapps Core, OpenGApps Pico, and similar work the same way. Pick whichever
matches your preferred GApps weight.

## Play Integrity for apps that require it

Some apps (banking, GPay, Netflix HDR, certain games) call the Play Integrity
API and refuse to run if it doesn't return `MEETS_DEVICE_INTEGRITY`. On an
unlocked-bootloader LineageOS install Play Integrity reports `MEETS_BASIC_INTEGRITY`
only, because hardware-backed key attestation includes the verified-boot state
(orange/unlocked on LineageOS) which the TEE reports faithfully regardless of
build.prop spoofing.

The standard workaround is Magisk + the Play Integrity Fix Zygisk module:

1. Pull `init_boot.img` from the ROM zip (or `fastboot getvar partition-size:init_boot`
   reads the partition).
2. Patch it with the Magisk app (Install -> Select and Patch a File).
3. Flash the patched image: `fastboot flash init_boot magisk_patched.img`
4. Reboot, open Magisk, install the **PlayIntegrityFix** module
   (chiteroman on GitHub, maintained).
5. Reboot. Apps that gate on Play Integrity now work.

## Why this is the LineageOS norm

GMS requires a paid OEM license from Google to distribute, and that license
doesn't transfer to community ROMs. LineageOS upstream and every device tree
that follows their conventions ship gapps-free for this reason. Users install
gapps from a separate project (MindTheGapps, NikGapps, etc.) that handles its
own legal posture.

The Magisk + PIF flow is the standard answer for Play Integrity on any
LineageOS device; it's been the community norm since SafetyNet tightened in 2020.
