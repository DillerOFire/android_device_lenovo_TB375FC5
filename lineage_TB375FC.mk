#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#


# AOSP base inheritance. core_64_bit + full_base MUST come before vendor/device
# makefiles, otherwise you end up with a 256 MB system image of 16 binaries.
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
# WiFi-only tablet: full_base.mk (generic_no_telephony) instead of
# full_base_telephony.mk. The telephony variant unconditionally adds Dialer +
# TeleService + TelephonyProvider + Telecom + MmsService + CarrierDefaultApp +
# SimAppDialog + apns-conf.xml. common_full_tablet_wifionly.mk (inherited
# below) only adds EmergencyInfo, it doesn't remove already-pulled-in
# telephony packages.
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Virtual A/B + vendor_ramdisk + compression. Pulls in snapuserd /
# snapuserd.vendor_ramdisk / snapuserd.recovery, plus linker.vendor_ramdisk +
# e2fsck.vendor_ramdisk + fsck.f2fs.vendor_ramdisk under TARGET_VENDOR_RAMDISK_OUT,
# and ro.virtual_ab.* sysprops. Otherwise vendor_ramdisk00 is 1.4 KB of just
# fstab files and first-stage init has no snapuserd to bind dm-snapshot.
# Inherits launch_with_vendor_ramdisk.mk underneath.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

# Sounds
$(call inherit-product-if-exists, frameworks/base/data/sounds/AllAudio.mk)

# LineageOS common add-ons
$(call inherit-product, vendor/lineage/config/common.mk)

# Device-specific
$(call inherit-product, device/lenovo/TB375FC/device.mk)

# Vendor blobs
$(call inherit-product-if-exists, vendor/lenovo/TB375FC/TB375FC-vendor.mk)
$(call inherit-product-if-exists, vendor/lenovo/TB375FC/TB375FC-overlays.mk)

# Tablet wifi-only base
$(call inherit-product, vendor/lineage/config/common_full_tablet_wifionly.mk)

PRODUCT_DEVICE := TB375FC
PRODUCT_NAME := lineage_TB375FC
PRODUCT_BRAND := Lenovo
PRODUCT_MODEL := TB375FC

# PRC SKU identity. The lgsi block MUST agree with PRODUCT_DEVICE (see the note
# in device.mk) - these are the PRC-region counterparts of the ROW values in
# lineage_TB373FU.mk.
PRODUCT_VENDOR_PROPERTIES += \
    ro.vendor.config.lgsi.hw.version=TB375FC \
    ro.vendor.config.lgsi.ota.model=TB375FC_PRC
PRODUCT_MANUFACTURER := Lenovo
PRODUCT_CHARACTERISTICS := tablet

PRODUCT_GMS_CLIENTID_BASE := android-lenovo-rev2
