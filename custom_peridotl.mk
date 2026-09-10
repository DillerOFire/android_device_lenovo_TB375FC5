#
# SPDX-FileCopyrightText: 2026 The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#

ZYGOTE_FORCE_64 := true
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/full_base.mk)

# Virtual A/B with vendor ramdisk support for this GKI MTK tablet.
$(call inherit-product, $(SRC_TARGET_DIR)/product/virtual_ab_ota/compression.mk)

TARGET_FACE_UNLOCK_SUPPORTED := false

$(call inherit-product, device/lenovo/peridotl/device.mk)
$(call inherit-product, vendor/custom/config/common_full_tablet_wifionly.mk)

# Use peridotl for the ROM target; Lenovo's stock LGSI project remains peridot.
# PRODUCT_DEVICE must match this repository's directory so build/make can find
# BoardConfig.mk. Libinit replaces these values with the detected retail SKU.
PRODUCT_NAME := custom_peridotl
PRODUCT_DEVICE := peridotl
PRODUCT_MANUFACTURER := Lenovo
PRODUCT_BRAND := Lenovo
PRODUCT_MODEL := peridotl
PRODUCT_CHARACTERISTICS := tablet

PRODUCT_GMS_CLIENTID_BASE := android-lenovo-rev2

PRODUCT_PACKAGES += Updater

# Keep PixelOS's build identifier tied to the common product name. Its build
# property generator otherwise derives ro.custom.device from PRODUCT_DEVICE,
# which must remain TB375FC so build/make can locate this device tree.
PRODUCT_BUILD_PROP_OVERRIDES += \
    CustomDevice=peridotl

PRODUCT_SYSTEM_PROPERTIES += \
    ro.lineage.device=peridotl \
    ro.lineage.releasetype=UNOFFICIAL \
    ro.lineage.build.version=17.0
