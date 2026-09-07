#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

# Inherit from those products. Most specific first.
#
# Stock last-wins ro.zygote=zygote64. Keep TARGET_2ND_ARCH for 32-bit vendor
# HALs, but do not start zygote32: ZUI ships no /vendor/lib/egl/libMEOW_data.so,
# and 32-bit libGLES_meow SIGSEGVs on DDKHook fail (bootloop).
ZYGOTE_FORCE_64 := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
# WiFi-only tablet: full_base (not full_base_telephony). Telephony would pull
# Dialer/TeleService/etc.; common_full_tablet_wifionly does not strip them.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Virtual A/B + vendor_ramdisk + compression. Required for this GKI MTK tablet:
# without snapuserd on vendor_ramdisk, first-stage init cannot bind dm-snapshot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# No face unlock hardware on this tablet (must be set before vendor/custom).
TARGET_FACE_UNLOCK_SUPPORTED := false

# Inherit from TB375FC device (vendor blobs + TARGET_SCREEN_WIDTH live there).
$(call inherit-product, device/lenovo/TB375FC/device.mk)

# Inherit some common PixelOS stuff (tablet wifi-only).
# Matches PixelOS-Devices caihong (OPD2403) product shape.
$(call inherit-product, vendor/custom/config/common_full_tablet_wifionly.mk)

PRODUCT_NAME := custom_TB375FC
PRODUCT_DEVICE := TB375FC
PRODUCT_MANUFACTURER := Lenovo
PRODUCT_BRAND := Lenovo
PRODUCT_MODEL := TB375FC
# Stock ZUI / LOS: tablet only. This device has a microSD slot — do not set nosdcard.
PRODUCT_CHARACTERISTICS := tablet

PRODUCT_GMS_CLIENTID_BASE := android-lenovo-rev2

# Temporary bring-up bridge: Setup Wizard cannot present the RSA approval UI.
# Expose unauthenticated shell ADB so Wi-Fi can be diagnosed before setup.
# Disable Trade-in Mode too: its foyer domain allows only `adb shell
# tradeinmode`, not normal `adb logcat`. Do not set ro.debuggable or ro.secure: those make user adbd attempt an absent
# su context. Remove this entire block once Wi-Fi and Setup Wizard are healthy.
ifeq ($(TARGET_BUILD_VARIANT),user)
PRODUCT_PRODUCT_PROPERTIES += \
    ro.adb.secure=0 \
    security.adb.require_authenticated=0 \
    persist.adb.tradeinmode=-1 \
    persist.sys.usb.config=adb
endif

# PRC SKU identity. Must agree with PRODUCT_DEVICE (see device.mk note).
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.config.lgsi.hw.version=TB375FC \
    ro.vendor.config.lgsi.ota.model=TB375FC_PRC

# Stock ZUI 17.5.10.103 (full-ZUI-17.5.10.103 dump) identity.
PRODUCT_BUILD_PROP_OVERRIDES += \
    BuildDesc="TB375FC-user 16 BP2A.250605.031.A3 TB375FC_CN_OPEN_USER_M21.814_A16_ZUI_17.5.10.103_ST_260525 release-keys" \
    BuildFingerprint=Lenovo/TB375FC/TB375FC:16/BP2A.250605.031.A3/ZUXOS_1.5.10.103_260525_PRC:user/release-keys \
    DeviceName=TB375FC \
    DeviceProduct=TB375FC \
    SystemDevice=TB375FC \
    SystemName=TB375FC

# Self-hosted OTA (brr / ota.splazma.site). Same pattern as custom_audi:
# vendor/custom only ships Updater for IS_OFFICIAL builds.
PRODUCT_PACKAGES += Updater

PRODUCT_SYSTEM_PROPERTIES += \
    lineage.updater.uri=https://ota.splazma.site/u/{device}?t={type}&i={incr} \
    ro.lineage.device=TB375FC \
    ro.lineage.releasetype=UNOFFICIAL \
    ro.lineage.build.version=17.0
