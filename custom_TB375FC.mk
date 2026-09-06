#
# SPDX-FileCopyrightText: 2026 The PixelOS Project
# SPDX-License-Identifier: Apache-2.0
#

# AOSP base. core_64_bit + full_base MUST come before vendor/device
# makefiles, otherwise you end up with a 256 MB system image of 16 binaries.
#
# Stock last-wins ro.zygote=zygote64. Keep TARGET_2ND_ARCH for 32-bit vendor
# HALs, but do not start zygote32: ZUI ships no /vendor/lib/egl/libMEOW_data.so,
# and 32-bit libGLES_meow SIGSEGVs on DDKHook fail (bootloop). 64-bit MEOW
# loads mali + libMEOW_data.so and is the actual GPU wrapper.
ZYGOTE_FORCE_64 := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
# WiFi-only tablet: full_base.mk (generic_no_telephony) instead of
# full_base_telephony.mk. The telephony variant unconditionally adds Dialer +
# TeleService + TelephonyProvider + Telecom + MmsService + CarrierDefaultApp +
# SimAppDialog + apns-conf.xml. common_full_tablet_wifionly.mk only adds
# EmergencyInfo; it does not remove already-pulled-in telephony packages.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Virtual A/B + vendor_ramdisk + compression. Pulls in snapuserd /
# snapuserd.vendor_ramdisk / snapuserd.recovery, plus linker.vendor_ramdisk +
# e2fsck.vendor_ramdisk + fsck.f2fs.vendor_ramdisk under TARGET_VENDOR_RAMDISK_OUT,
# and ro.virtual_ab.* sysprops. Otherwise vendor_ramdisk00 is 1.4 KB of just
# fstab files and first-stage init has no snapuserd to bind dm-snapshot.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Sounds
$(call inherit-product-if-exists, frameworks/base/data/sounds/AllAudio.mk)

# Device-specific
$(call inherit-product, device/lenovo/TB375FC/device.mk)

# Vendor blobs
$(call inherit-product-if-exists, vendor/lenovo/TB375FC/TB375FC-vendor.mk)
$(call inherit-product-if-exists, vendor/lenovo/TB375FC/TB375FC-overlays.mk)

# Must be set before vendor/custom common (bootanimation + face unlock gates).
# 12.7" 2944x1840 panel — shorter edge for bootanimation_res.
TARGET_SCREEN_WIDTH := 1840
# No face unlock hardware on this tablet.
TARGET_FACE_UNLOCK_SUPPORTED := false

# PixelOS tablet wifi-only (Lineage tablet base + vendor/custom GMS/overlays).
$(call inherit-product, vendor/custom/config/common_full_tablet_wifionly.mk)

PRODUCT_DEVICE := TB375FC
PRODUCT_NAME := custom_TB375FC
PRODUCT_BRAND := Lenovo
PRODUCT_MODEL := TB375FC
PRODUCT_MANUFACTURER := Lenovo
PRODUCT_CHARACTERISTICS := tablet

# PRC SKU identity. The lgsi block MUST agree with PRODUCT_DEVICE.
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.config.lgsi.hw.version=TB375FC \
    ro.vendor.config.lgsi.ota.model=TB375FC_PRC

PRODUCT_GMS_CLIENTID_BASE := android-lenovo-rev2

# Self-hosted OTA (brr / ota.splazma.site). Same pattern as custom_audi:
# vendor/custom only ships Updater for IS_OFFICIAL builds.
PRODUCT_PACKAGES += Updater

PRODUCT_SYSTEM_PROPERTIES += \
    lineage.updater.uri=https://ota.splazma.site/u/{device}?t={type}&i={incr} \
    ro.lineage.device=TB375FC \
    ro.lineage.releasetype=UNOFFICIAL \
    ro.lineage.build.version=17.0
