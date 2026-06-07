#
# Copyright (C) 2026 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#
LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),TB375FC)
# 381 vendor/lib64 -> mt6897/* symlinks. Rules reference $(TARGET_OUT_VENDOR),
# which is only set after envsetup.mk runs - device.mk is parsed during
# product-config (too early).
include $(LOCAL_PATH)/tb375fc-vendor-symlinks.mk

# 192 vendor/bin and vendor/bin/hw symlinks (toybox aliases plus 6 critical
# HAL service redirectors). Without the V2 allocator redirector at
# /vendor/bin/hw/vendor.gralloc-v2 (real binary at .../mt6897/X.mt6897), init
# never starts the service, IAllocator never registers, IComposer chain stalls,
# surfaceflinger sits idle, boot hangs.
include $(LOCAL_PATH)/tb375fc-vendor-bin-symlinks.mk

# v34 VNDK apex overlay onto /vendor/lib64/{libui,libbinder,...}.so. Same
# placement reason as the symlinks: needs TARGET_OUT_VENDOR.
include $(LOCAL_PATH)/tb375fc-vndk-overlay.mk

# Blank the Soong-built /odm/etc/selinux/precompiled_sepolicy.*.sha256 so init's hash
# check fails and it falls back to runtime secilc compile, which loads the stock
# vendor_sepolicy.cil (all ~250 MTK domains). Without this init loads the LOS-built
# /odm precompiled which lacks the MTK domains, MTK HAL services exec into init:s0,
# NULL-deref, and boot hangs at "Powered by Android". This include was dropped during
# the sepolicy de-hack; the de-hacked policy still ships the MTK domains only in the
# proprietary vendor_sepolicy.cil, so the runtime-compile fallback is still required.
include $(LOCAL_PATH)/tb375fc-sepolicy-precompiled.mk

include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
