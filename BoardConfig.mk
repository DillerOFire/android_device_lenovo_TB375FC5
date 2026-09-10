#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

DEVICE_PATH := device/lenovo/peridotl

# Partition layout: real /vendor, /product, /system_ext as own partitions
# (not legacy /system/vendor nested). Required for BUILDING_VENDOR_IMAGE.
TARGET_COPY_OUT_VENDOR     := vendor
TARGET_COPY_OUT_PRODUCT    := product
TARGET_COPY_OUT_SYSTEM_EXT := system_ext
# /odm is a real dynamic partition: fstab.mt6897 requires it, vintf fragments
# at proprietary/odm/etc/vintf/ need it, and /vendor/odm -> /odm symlink
# relies on it.
TARGET_COPY_OUT_ODM        := odm
TARGET_COPY_OUT_VENDOR_DLKM := vendor_dlkm
TARGET_COPY_OUT_ODM_DLKM    := odm_dlkm
TARGET_COPY_OUT_SYSTEM_DLKM := system_dlkm

# Architecture
TARGET_ARCH                := arm64
TARGET_ARCH_VARIANT        := armv8-a
TARGET_CPU_ABI             := arm64-v8a
TARGET_CPU_ABI2            :=
TARGET_CPU_VARIANT         := generic
# ART in this branch supports up to cortex-a76; the stock vendor also uses a
# conservative cortex-a55 runtime variant.  A715 makes dex2oat reject every
# post-OTA dexopt request, so use the stock, ART-supported value.
TARGET_CPU_VARIANT_RUNTIME := cortex-a55

TARGET_2ND_ARCH            := arm
TARGET_2ND_ARCH_VARIANT    := armv8-2a
TARGET_2ND_CPU_ABI         := armeabi-v7a
TARGET_2ND_CPU_ABI2        := armeabi
TARGET_2ND_CPU_VARIANT     := generic
TARGET_2ND_CPU_VARIANT_RUNTIME := cortex-a55

# Bootloader / SoC
TARGET_BOARD_PLATFORM           := mt6897
TARGET_BOOTLOADER_BOARD_NAME    := mt6897
TARGET_NO_BOOTLOADER            := true

# One OTA serves the peridotl target and both retail SKU identities. Keep the
# former peridot alias for compatibility with already-generated metadata.
TARGET_OTA_ASSERT_DEVICE := TB375FC,TB373FU,peridotl,peridot

# Kernel
BOARD_KERNEL_BASE             := 0x40000000
BOARD_KERNEL_PAGESIZE         := 4096
BOARD_KERNEL_TAGS_OFFSET      := 0x07c80000
BOARD_KERNEL_OFFSET           := 0x00000000
BOARD_RAMDISK_OFFSET          := 0x26f00000
BOARD_DTB_OFFSET              := 0x07c80000
BOARD_KERNEL_IMAGE_NAME       := Image.gz
BOARD_BOOT_HEADER_VERSION     := 4
BOARD_INIT_BOOT_HEADER_VERSION   := 4
BOARD_VENDOR_BOOT_HEADER_VERSION := 4

# DTB. 411 KB verbatim from stock TB375FC's vendor_boot dtb section
# (md5 f004340d171f5b8c7ea28c9313c3b55d). dtb_offset is stock's
# `dtb address 0x47c80000` minus `kernel load address 0x40000000`.
TARGET_PREBUILT_DTB           := $(DEVICE_PATH)/prebuilts/dtb/dtb.img

# LineageOS 23 kati doesn't auto-inject --header_version (only newer Soong
# filesystem modules do). Pass it explicitly via BOARD_MKBOOTIMG_ARGS, which
# kati appends to both boot.img and vendor_boot.img mkbootimg invocations.
# All four address offsets must be passed explicitly because the AOSP
# Makefile only auto-injects --base and --pagesize; without them mkbootimg
# uses defaults (kernel_offset=0x8000, ramdisk_offset=0x1000000, tags_offset=0x100),
# the encoded vendor_boot header carries the wrong tags_addr, and on MTK the
# kernel parses garbage where dtb should be. Stock TB375FC layout:
# kernel@0x40000000, ramdisk@0x66f00000, tags@0x47c80000, dtb@0x47c80000.
BOARD_MKBOOTIMG_ARGS := --header_version $(BOARD_BOOT_HEADER_VERSION) \
    --kernel_offset  $(BOARD_KERNEL_OFFSET) \
    --ramdisk_offset $(BOARD_RAMDISK_OFFSET) \
    --tags_offset    $(BOARD_KERNEL_TAGS_OFFSET) \
    --dtb_offset     $(BOARD_DTB_OFFSET) \
    --dtb            $(TARGET_PREBUILT_DTB)

# init_boot.img args. AOSP builds init_boot.img with BOARD_MKBOOTIMG_INIT_ARGS
# (not BOARD_MKBOOTIMG_ARGS). Without --header_version, mkbootimg defaults to
# v0 which the bootloader rejects on a v4 GKI device. Stock init_boot.img is v4.
BOARD_MKBOOTIMG_INIT_ARGS := --header_version $(BOARD_INIT_BOOT_HEADER_VERSION)

BOARD_KERNEL_SEPARATED_DTBO   := true
BOARD_USES_GENERIC_KERNEL_IMAGE := true

# Image build switches mirroring the stock TB375FC pattern. Declarative,
# but several Soong/kati modules gate on them. BOARD_USES_INIT_BOOT_IMAGE
# pairs with BOARD_INIT_BOOT_HEADER_VERSION above; without it the init_boot.img
# build rule isn't always emitted depending on inheritance order.
BOARD_USES_VENDOR_BOOTIMAGE := true
BOARD_USES_INIT_BOOT_IMAGE  := true
BOARD_USES_SNAPUSERD        := true
BOARD_VIRTUAL_AB_ENABLE     := true

# Ramdisk compression: stock TB375FC vendor_boot ramdisks are LZ4 (v0.1-v0.9).
# Default Soong is gzip; stick to stock to minimize surprise.
BOARD_RAMDISK_USE_LZ4 := true

# Mountpoints first-stage init expects to find in / when ramdisks unpack.
# Without these the cpio archive lands without the empty directories and
# init's `mkdir /metadata 0700 root root` stanzas may fail. This trio is
# needed on MTK.
BOARD_ROOT_EXTRA_FOLDERS := metadata vendor acct

# Vendor cmdline (header v4 vendor_boot.img cmdline field) from stock
# vendor_boot_a header readback. The "vendor bootconfig" section is size 0
# on stock, so BOARD_BOOTCONFIG stays empty.
#
# The long stock cmdline (firmware_class.path, androidboot.hardware=mt6897,
# vmalloc=400M, disable_dma32, swiotlb=noforce, transparent_hugepage=never,
# cgroup.memory, allow_mismatched_32bit_el0, 8250.nr_uarts=4, nosoftlockup,
# kasan.page_alloc.sample=1) comes from the DTB's /chosen/bootargs, shipped
# intact at prebuilts/dtb/dtb.img. Duplicating those params in
# BOARD_KERNEL_CMDLINE overflows / confuses the kernel parser.
#
# SELinux runs enforcing. The androidboot.selinux=permissive crutch used
# while bringing up post-fs-data / installkey / VINTF was removed once the
# policy was complete and verified clean (0 enforced denials).
#
# firmware_class.path tells the kernel where to look for /lib/firmware first.
# Novatek NT36532 touch IC firmware lives at /vendor/firmware/; pointing the
# kernel there makes it find firmware on the first attempt (touch works
# instantly in recovery). Without it the kernel searches /lib/firmware/*
# (empty), times out after ~15s, then userspace ueventd-firmware-loader
# picks it up via /vendor/firmware.
BOARD_KERNEL_CMDLINE := bootopt=64S3,32N2,64N2 firmware_class.path=/vendor/firmware
BOARD_BOOTCONFIG :=

TARGET_KERNEL_CONFIG    :=
TARGET_KERNEL_SOURCE    :=
TARGET_PREBUILT_KERNEL  := $(DEVICE_PATH)/prebuilts/Image.gz
TARGET_NEEDS_DTBOIMAGE  := true
BOARD_PREBUILT_DTBOIMAGE := $(DEVICE_PATH)/prebuilts/dtbo_TB375FC.img

# Shared vendor props whose values contain spaces. SKU-specific market identity
# is assigned by libinit after reading the bootloader properties.
TARGET_VENDOR_PROP := $(DEVICE_PATH)/vendor.prop

# Vendor security patch level. The vendor partition is the stock TB375FC PRC A16
# extraction, whose vendor SPL is 2024-10-05. Without this
# ro.vendor.build.security_patch is empty and Settings reports the vendor patch
# level as "Unknown".
VENDOR_SECURITY_PATCH := 2024-10-05

# A/B partition
AB_OTA_UPDATER          := true
AB_OTA_PARTITIONS += \
    boot \
    vendor_boot \
    init_boot \
    dtbo \
    odm \
    odm_dlkm \
    product \
    system \
    system_dlkm \
    system_ext \
    vbmeta \
    vbmeta_system \
    vbmeta_vendor \
    vendor \
    vendor_dlkm

# Partitions / sizes (from stock super.img analysis)
BOARD_BUILD_SUPER_EMPTY_BY_DEFAULT := true
BOARD_USES_METADATA_PARTITION  := true
BOARD_USES_RECOVERY_AS_BOOT    := false

# Every dynamic partition gets built and packed into super.img.
# PRODUCT_USE_DYNAMIC_PARTITIONS lives in device.mk (product-scope, and
# BoardConfig declares it readonly).
BOARD_USES_VENDORIMAGE            := true
BOARD_USES_PRODUCTIMAGE           := true
BOARD_USES_SYSTEM_EXTIMAGE        := true
BOARD_USES_VENDOR_DLKMIMAGE       := true
BOARD_USES_ODM_DLKMIMAGE          := true
BOARD_USES_SYSTEM_DLKMIMAGE       := true
BOARD_USES_ODMIMAGE               := true
BOARD_BOOTIMAGE_PARTITION_SIZE       := 67108864
BOARD_VENDOR_BOOTIMAGE_PARTITION_SIZE := 67108864
BOARD_INIT_BOOT_IMAGE_PARTITION_SIZE := 8388608
BOARD_DTBOIMG_PARTITION_SIZE         := 8388608

# Logical partitions
BOARD_SUPER_PARTITION_SIZE   := 9663676416
BOARD_SUPER_PARTITION_GROUPS := main
# Virtual A/B with retrofit: dynamic-partitions group size must be
# <= BOARD_SUPER_PARTITION_SIZE / 2 so both slot snapshots fit during OTA.
# 9663676416/2 = 4831838208; minus 4MiB metadata overhead.
BOARD_MAIN_SIZE              := 4827643904
BOARD_MAIN_PARTITION_LIST    := system system_ext system_dlkm vendor vendor_dlkm product odm odm_dlkm

# Canonical AOSP variable name is *_FILE_SYSTEM_TYPE, not *_PARTITION_TYPE.
# Setting it flips BUILDING_VENDOR_IMAGE / BUILDING_*_DLKM_IMAGE to true in
# soong vars; otherwise no .img build rules get emitted.
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE     := erofs
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE     := erofs
BOARD_PRODUCTIMAGE_FILE_SYSTEM_TYPE    := erofs
BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODMIMAGE_FILE_SYSTEM_TYPE        := erofs
BOARD_VENDOR_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs
BOARD_ODM_DLKMIMAGE_FILE_SYSTEM_TYPE    := erofs
BOARD_SYSTEM_DLKMIMAGE_FILE_SYSTEM_TYPE := erofs

TARGET_USERIMAGES_USE_F2FS := true
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_EROFS := true

# Per-partition flags
BOARD_USES_SYSTEM_OTHER_ODEX := false

# Partition sizes for img staging
BOARD_FLASH_BLOCK_SIZE := 131072

# AVB (Android Verified Boot). The tree carries the AOSP test key + SHA256_RSA2048;
# LineageOS release signing overrides the keys at sign time, so the tree must not
# ship real keys.
#
# The top-level vbmeta is built with --flags 3 = HASHTREE_DISABLED |
# VERIFICATION_DISABLED. At first-stage boot libavb reads these on the main vbmeta
# and returns without descending into the chained vbmeta_system / vbmeta_vendor
# descriptors, so no partition gets a dm-verity device and none is verified -
# verity is off device-wide. This is the standard LineageOS A/B posture (the
# bootloader runs unlocked, and verity-off lets users flash partitions freely) and
# matches current official LOS A/B trees (oneplus sm8350-common, oneplus billie).
#
# The chained vbmeta_system / vbmeta_vendor are still built (so the image layout
# matches official and each image self-describes its hashtree) but are inert at
# boot while the top-level disables hashtree+verification. /odm is a built EROFS
# image (vintf fragments + passwd/group) kept in vbmeta_vendor for that layout
# parity; with verification disabled it is not enforced at boot. The earlier note
# about /odm dead-locking first-stage mount was an artifact of an old all-chains
# --flags-3 config and no longer applies.
#
# ROLLBACK_INDEX is 0. This MTK preloader/LK enforces AVB anti-rollback even with the main
# vbmeta VERIFICATION_DISABLED (--flags 3): a non-zero rollback index is rejected at boot as
# "incompatible hardware" (a build with index = SPL timestamp fails the LK; the same tree
# with index 0 boots on identical hardware). The SPL-tied rollback index some Qualcomm LOS
# trees use (sm8350, billie) is not safe on this MTK LK.
BOARD_AVB_ENABLE                  := true
BOARD_AVB_ALGORITHM               := SHA256_RSA2048
BOARD_AVB_KEY_PATH                := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_MAKE_VBMETA_IMAGE_ARGS  += --flags 3
BOARD_AVB_ROLLBACK_INDEX                            := 0
BOARD_AVB_ROLLBACK_INDEX_LOCATION                   := 0
BOARD_AVB_VBMETA_SYSTEM := system system_ext product
BOARD_AVB_VBMETA_SYSTEM_KEY_PATH                    := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_SYSTEM_ALGORITHM                   := SHA256_RSA2048
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX              := 0
BOARD_AVB_VBMETA_SYSTEM_ROLLBACK_INDEX_LOCATION     := 1
BOARD_AVB_VBMETA_VENDOR := odm vendor vendor_dlkm odm_dlkm
BOARD_AVB_VBMETA_VENDOR_KEY_PATH                    := external/avb/test/data/testkey_rsa2048.pem
BOARD_AVB_VBMETA_VENDOR_ALGORITHM                   := SHA256_RSA2048
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX               := 0
BOARD_AVB_VBMETA_VENDOR_ROLLBACK_INDEX_LOCATION     := 2
# The chained vbmeta_system / vbmeta_vendor MUST also carry VERIFICATION_DISABLED. The
# top-level --flags 3 only stops stock libavb from descending, but this MTK preloader reads
# the chained vbmeta partitions DIRECTLY and enforces them; without --flags 3 here it verifies
# test-key-signed system/vendor against the fused OEM key and rejects boot as "incompatible
# hardware" (the same AVB mismatch as flashing ROW on CN). Flags 3 makes them inert too.
BOARD_AVB_MAKE_VBMETA_SYSTEM_IMAGE_ARGS += --flags 3
BOARD_AVB_MAKE_VBMETA_VENDOR_IMAGE_ARGS += --flags 3
#
# DTBO is the exception to the "nothing is verified" posture above. The MediaTek LK
# validates the dtbo AVB hash descriptor against the vbmeta copy at boot even with the
# main vbmeta VERIFICATION_DISABLED, and rejects a mismatch as "incompatible hardware".
# avbtool's default random per-run salt makes the standalone dtbo.img and the descriptor
# embedded in vbmeta disagree (they are signed by separate avbtool invocations), which
# bricks boot on a fresh flash. Pin the dtbo salt so both copies carry the same hash. The
# value is the OEM dtbo salt; the device tree being byte-identical to stock, the signed
# dtbo reproduces the stock AVB digest exactly, so vbmeta and the flashed dtbo always agree.
BOARD_AVB_DTBO_ADD_HASH_FOOTER_ARGS += --salt 4e6ccb7d15ef04077beaec9b0bfa9589d57b32eef1f731e4f38cbd4d4119b023

# Recovery (LOS Recovery packed as vendor_boot ramdisk fragment). For A14+
# GKI A/B devices recovery is a fragment inside vendor_boot.img (not its own
# recovery.img). The bootloader switches
# between vendor_ramdisk00 (default) and vendor_ramdisk01 (recovery) based
# on the misc partition's bcb command.
BOARD_MOVE_RECOVERY_RESOURCES_TO_VENDOR_BOOT := true
BOARD_INCLUDE_RECOVERY_RAMDISK_IN_VENDOR_BOOT := true

# Recovery fstab: same as fstab.mt8792 minus the dm-userdata and dm-lenovobackup
# entries. Those map to device-mapper nodes that only come into existence
# after vold decrypts /data; in recovery they never materialise and fs_mgr's
# `wait` flag burns 20 wall-clock seconds per missing dm-* device. Recovery
# still has the `/dev/block/by-name/userdata` entry (line 40), which fails
# fast on the encrypted superblock (correct recovery-time behaviour).
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/rootdir/etc/fstab.recovery
TARGET_RECOVERY_PIXEL_FORMAT := RGBX_8888
TARGET_RECOVERY_DENSITY := xhdpi
# 12.7" tablet at 2944x1840; chunky touch targets compensate for recovery's
# minimal UI scaling.
TARGET_RECOVERY_UI_MARGIN_HEIGHT := 100
TARGET_RECOVERY_UI_MARGIN_WIDTH  := 100

# VINTF / sepolicy / treble
BOARD_USES_GENERIC_AUDIO       := false
BOARD_VNDK_VERSION             := current

# Stock vendor was frozen at API 34 and its HALs link against AIDL backends
# frozen at that point (graphics.common-V4, memtrack-V1, audio.core-V3, etc.).
# For the runtime linker to add /apex/com.android.vndk.v34/lib64/ to the
# vendor namespace search path, linkerconfig has to see VENDOR_VNDK_VERSION=34
# which it derives from ro.vndk.version. Without ro.board.api_level=34 AOSP A16
# treats vendor as "current" and skips the vndk compat path entirely. All three
# props together gate every vendor service that links through
# composer3-V2/memtrack/dolby/codec2/etc.
#
# Property emission (sysprop_config.mk):
#   BOARD_SHIPPING_API_LEVEL    -> ro.board.first_api_level=34
#   BOARD_API_LEVEL_PROP_OVERRIDE -> ro.board.api_level=34
#                                   (overrides RELEASE_BOARD_API_LEVEL=202504)
# ro.vndk.version=34 is forced separately in device.mk because AOSP A16
# clears BOARD_VNDK_VERSION at config.mk:1336.
BOARD_SHIPPING_API_LEVEL       := 34
BOARD_API_LEVEL_PROP_OVERRIDE  := 34

DEVICE_MANIFEST_FILE := $(DEVICE_PATH)/manifest.xml
DEVICE_MATRIX_FILE   := $(DEVICE_PATH)/compatibility_matrix.xml

# Framework compatibility matrix add-ons. Declares every vendor-private HAL
# in vendor.img (53 entries: vendor.lenovo.*, vendor.mediatek.*,
# vendor.microtrust.*, vendor.dolby.*, motorola.*, arm.mali.*, goodix.*,
# interfaces.factory*) plus non-default instance names for AOSP-name radio
# HALs (android.hardware.radio.{modem,network,sim,voice}/imsSlot1 and /se1).
# assemble_vintf strips optional="true" on emission, but checkvintf passes
# because vendor manifest provides every listed HAL.
DEVICE_FRAMEWORK_COMPATIBILITY_MATRIX_FILE += \
    $(DEVICE_PATH)/framework_compatibility_matrix.xml

BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor
BOARD_VENDOR_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/vendor_mtk_prebuilt

# Device-specific platform sepolicy contributions. Declares the ~250
# vendor_*_prop types that stock TB375FC PRC vendor_sepolicy.cil references
# but LOS plat_sepolicy does not. Otherwise the on-device policy compile
# leaves them "left unmapped" and init fails to initialise the property area
# (signal 6 at ~4s into boot).
SYSTEM_EXT_PRIVATE_SEPOLICY_DIRS += $(DEVICE_PATH)/sepolicy/private
SYSTEM_EXT_PUBLIC_SEPOLICY_DIRS  += $(DEVICE_PATH)/sepolicy/public

# Prebuilt kernel modules. 282 .ko files from the device's own stock A16
# TB375FC PRC build sit under prebuilts/modules/{vendor_ramdisk,vendor_dlkm,
# system_dlkm}/. Load order mirrored from the live stock device's modules.load.
include $(DEVICE_PATH)/tb375fc-kernel-modules.mk

# HALs at the property level (mirror what stock build.props say).
# Properties are baked into device.mk; this exposes the boardconfig knobs.
TARGET_USES_MKE2FS := true

# Misc Lenovo / MediaTek
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_USES_NETWORK := true
# Allow PRODUCT_COPY_FILES of ELF binaries (vendor .so blobs) and VINTF
# metadata (vendor/etc/vintf/manifest fragments + compatibility_matrix.xml).
# The "proper" route is cc_prebuilt_library_shared + vintf_fragments soong
# modules, but for a 2000-blob vendor tree that's a separate refactor.
BUILD_BROKEN_ELF_PREBUILT_PRODUCT_COPY_FILES := true
BUILD_BROKEN_VINTF_PRODUCT_COPY_FILES := true

# WiFi. AOSP external/wpa_supplicant_8 builds a wpa_supplicant cc_binary that
# lands at /vendor/bin/hw/wpa_supplicant. extract-files left this unwired:
# proprietary tree has Lenovo's blob at the same path but no Android.bp entry.
# /vendor/etc/init's android.hardware.wifi.supplicant-service.rc references
# the file, so without an install init can't ctl.interface_start the lazy HAL.
#
# Declaring NL80211 driver backend (same as every modern MTK device) makes
# wpa_supplicant_8 compile in nl80211 support; PRODUCT_PACKAGES += wpa_supplicant
# in device.mk installs it.
BOARD_WPA_SUPPLICANT_DRIVER := NL80211
BOARD_HOSTAPD_DRIVER        := NL80211
WPA_SUPPLICANT_VERSION      := VER_0_8_X
# AOSP wpa_supplicant runs in the vendor namespace, whose v34 libcrypto keeps
# Lenovo blobs working. Bridge its renamed stack API through a device-only lib.
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := libtb375fc_wpa_v34_crypto_compat

# Ship AOSP supplicant init rc from the soong wpa_supplicant module itself.
# The stock rc (no user/group/capabilities) must NOT override it: stock binary
# runs as root, tries setuid/setgid, AOSP sepolicy denies, config write fails,
# supplicant addStaInterface throws -> no scan results.
WIFI_HIDL_UNIFIED_SUPPLICANT_SERVICE_RC_ENTRY := true
# BOARD_WLAN_DEVICE intentionally NOT set. Setting it to MediaTek makes
# libwifi_hal_vendor_impl_defaults demand libwifi-hal-mediatek which only
# exists inside proprietary MTK source we don't have. The wifi vendor HAL
# runs via AIDL through vendor.mediatek.hardware.wifi-service-lazy, so the
# legacy libwifi-hal-mediatek path isn't needed. Unset falls back to
# libwifi-hal-fallback (no-op), harmless because the AIDL service handles
# all real work.

# Inherit shared MTK + Lenovo common config when those land.
# include device/lenovo/common/BoardConfigCommon.mk

# PixelOS/LOS partition reserved-size helpers (no-op when WITH_GMS=true).
-include vendor/lineage/config/BoardConfigReservedSize.mk

# Vendor board fragments (may be empty; keep the include for extract-utils).
include vendor/lenovo/TB375FC/BoardConfigVendor.mk
