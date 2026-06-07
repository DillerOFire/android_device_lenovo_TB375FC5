#
# v34 VNDK apex overlay for vendor-side libui.so / libbinder.so / libutils.so /
# libbase.so / libcutils.so / libhidlbase.so / libtinyxml2.so / libfmq.so /
# libgralloctypes.so / libhardware.so / libhardware_legacy.so / libcrypto.so /
# libssl.so / libnl.so.
#
# Stock TB375FC PRC vendor binaries were compiled against the v34-frozen ABI
# of these libs. Examples:
#   - GraphicBufferMapper::lock(native_handle*, uint32_t, Rect&, void**, int*, int*)
#     (6-arg form, present in v34 libui.so only)
#   - android::binder::atrace_begin(unsigned long, char const*)
#     (present in v34 libbinder.so only; removed/renamed in A16)
#   - sk_dup, sk_pop, sk_value (unprefixed BoringSSL stack API, present in
#     v34 libcrypto.so only; A16 libcrypto.so exports only OPENSSL_sk_dup etc.).
#     wpa_supplicant from stock A16 vendor links against the unprefixed names
#     and refuses to start without v34's libcrypto.
#
# AOSP A16 Soong installs LOS-built A16-current vendor variants to
# /vendor/lib64/ even though VNDK is deprecated. Those variants are missing
# the v34-frozen symbols. linkerconfig DOES emit a [vendor] -> vndk link
# routing lookups to /apex/com.android.vndk.v34/lib64, but bionic's linker
# checks the current namespace's search paths first, so /vendor/lib64/libui.so
# (LOS A16) wins over /apex/com.android.vndk.v34/lib64/libui.so.
#
# Crash chain at ~T+5s post-fs:
#   F linker: CANNOT LINK EXECUTABLE "/vendor/bin/hw/<stock-blob>":
#     cannot locate symbol "..." referenced by "/vendor/lib64/<dep>.so"
# Affected services restart-loop until init gives up, downstream HALs
# (composer, audio policy) never resolve dependencies, and boot hangs at
# the "Powered by Android" splash.
#
# Fix: override Soong's install rule for these libs so the /vendor/lib64
# copy is sourced from the v34 apex variant. The apex .apex file still
# ships normally for processes that take the /apex/ path; this overlay
# additionally makes /vendor/lib64 serve the v34 variant so the linker's
# first-hit lookup gives the right symbols regardless of namespace path.
#
# Risk audit (verified):
#   - 29 libui A16-new symbols not in v34: 0 referenced by any vendor lib
#   - 100 libbinder A16-new symbols not in v34: 0 referenced by any vendor lib
#   - libcrypto.so / libssl.so consumers (wpa_supplicant, hostapd,
#     libkeymaster_portable, vendor.microtrust.hardware.soter-service,
#     libaudiosmartpamtk, libdecrypt, libmtk-fusion-ril, libmtk-ril,
#     libdrmclearkeyplugin, etc.) link the v34 unprefixed stack API
#     (sk_num, sk_dup, sk_value). A16 BoringSSL no longer exports those
#     (A16 has only OPENSSL_sk_*), so /vendor/lib64/libcrypto.so and
#     libssl.so must stay v34 or WiFi and keymaster fail to link.
#   - libcurl.so is the one exception and is overlaid below for the same
#     reason in reverse. The A16 /vendor/lib64/libcurl.so blob (pulled by
#     mnld for SUPL) imports the A16 OPENSSL_sk_* prefixed API and cannot
#     resolve against v34 libcrypto, so mnld crash-loops and GPS never
#     starts. The v34 apex libcurl uses the unprefixed API and links
#     against v34 libcrypto. It is byte-identical (sha256 3116ae41...) to
#     the libcurl a running stock mnld maps from
#     /apex/com.android.vndk.v34/lib64/, so overlaying it reproduces the
#     stock crypto stack exactly: one v34 set for WiFi, keymaster, and GPS.
#   - libnl.so consumers (wpa_supplicant, hostapd, wifi_dump, wlan_assistant,
#     gps_dump, bt_dump, libwifi-hal, mtk_storageproxyd): libnl ABI hasn't
#     changed between v34 and A16, but vendor was built against v34 so the
#     soname expectations are aligned. Overlay is safe.
# All overlay candidates verified by nm cross-check across all
# /vendor/lib64/*.so and /vendor/lib64/hw/*.so.
#
# Mechanism: the rules below redefine the recipe for $(TARGET_OUT_VENDOR)/lib64/<lib>.
# Soong's installs-lineage_TB375FC.mk already declared these targets; Make
# resolves the conflict by using the recipe defined last (our Android.mk-included
# file is processed after Soong's generated installs.mk), emitting a harmless
# "overriding commands for target ... ignoring old commands" warning at parse
# time. Documented AOSP-supported way to replace a Soong-installed file from
# a device makefile.

LOCAL_PATH := $(call my-dir)

# Libs to overlay. Add more only if symbol analysis confirms zero regressions.
# Stock mtkpower-service /proc/self/maps shows these libs loaded from
# /apex/com.android.vndk.v34/lib64/. AOSP A16 Soong rebuilds them against the
# current ABI for VNDK=current devices, and bionic prefers /vendor/lib64/
# over /apex/.../lib64/ in the vendor namespace, so vendor binaries load
# A16-current variants instead of v34. ABI-mismatched libutils/libcutils etc.
# leads to struct layout drift and silent corruption of caller registers
# across BL boundaries.
TB375FC_VNDK_OVERLAY_LIBS := \
    libui.so \
    libbinder.so \
    libbase.so \
    libcutils.so \
    libutils.so \
    libhidlbase.so \
    libtinyxml2.so \
    libfmq.so \
    libgralloctypes.so \
    libhardware.so \
    libhardware_legacy.so \
    libcrypto.so \
    libssl.so \
    libcurl.so \
    libnl.so

# libc++.so is intentionally NOT in the overlay list. The v34 libc++.so (754K)
# predates LLVM 15's __libcpp_verbose_abort hook; that symbol literally doesn't
# exist in it. A16 libc++.so (1.1MB) exports it as a weak symbol. 18+ A16-built
# vendor libraries (libaudioutils, libdmabufheap, android.system.suspend-V1-ndk,
# android.hardware.common-V2-ndk, libpower, libstagefright_*, libhidlmemory,
# libunwindstack, etc.) reference it; without it surfaceflinger and the whole
# graphics/audio HAL stack fail to dlopen at startup. The libpowerhal crash
# the rest of this overlay addresses is driven by struct/symbol drift in
# libutils/libcutils/libbase/libhidlbase/etc., not libc++.

# Per-lib override rule. $(1) is the bare library filename.
define tb375fc-vndk-overlay-rule
$$(TARGET_OUT_VENDOR)/lib64/$(1): $$(PRODUCT_OUT)/apex/com.android.vndk.v34/lib64/$(1)
	@echo "VNDK_OVERLAY: vendor/lib64/$(1) <- v34 apex variant"
	@mkdir -p $$(dir $$@)
	$$(hide) cp -f $$< $$@
endef

# Use $(eval) so the rule template expands with $(1) substituted, then parses
# as Make syntax. Double-dollared variables ($$(TARGET_OUT_VENDOR), $$@) defer
# to recipe-execution time. The 32-bit /vendor/lib/<lib> install is left alone:
# stock blobs are all 64-bit on tb375fc and no 32-bit vendor binary references
# the v34-only symbols.
$(foreach _lib,$(TB375FC_VNDK_OVERLAY_LIBS),$(eval $(call tb375fc-vndk-overlay-rule,$(_lib))))
