#
# Stock TB375FC vendor.img keeps the bulk of arm64 vendor libraries in
# /vendor/lib64/mt6897/ and exposes them at the canonical /vendor/lib64/
# location via symlinks. The arch subdir lets Lenovo reuse one image across
# mt6897-class boards; vendor binaries DT_NEEDED bare basenames, not subdir
# paths, so the top-level path is what the linker resolves against.
#
# extract-files only captures the real files (in mt6897/) and drops the
# symlinks. This makefile materialises all 381 stock symlinks into
# $(TARGET_OUT_VENDOR)/lib64/ as real symlinks (relative targets so they
# resolve inside the partition). vendor.img packaging preserves symlinks,
# so the on-device layout matches stock. The targets are added to
# ALL_DEFAULT_INSTALLED_MODULES so vendor.img picks them up; INTERNAL_VENDORIMAGE_FILES
# ensures the image-build rule waits for them.
#
# Manifest format (configs/vendor_lib64_symlinks.txt):
#   <link-rel-path>|<target-rel-path>
# e.g.
#   arm.graphics-V4-ndk.so|mt6897/arm.graphics-V4-ndk.so
#   egl/libGLES_mali.so|mt6897/libGLES_mali.so
#   hw/audio.primary.mt6897.so|audio.primary.mediatek.so
#
# Regenerate with tools/gen_vendor_symlinks.sh against a freshly mounted
# stock vendor.img.

_tb375fc_symlink_manifest := $(LOCAL_PATH)/configs/vendor_lib64_symlinks.txt

# Per-symlink rule. $(1)=link path relative to /vendor/lib64,
# $(2)=symlink target (relative path stored verbatim from stock).
#
# Whitespace and expansion gotchas:
#  1. $(strip) around $(call) args: Make doesn't trim whitespace from arg
#     values; without strip the line-continuation indentation leaves a leading
#     space in $(1), making the rule target "<path>/lib64/ <name>".
#  2. $$(TARGET_OUT_VENDOR), not $(TARGET_OUT_VENDOR). device.mk is processed
#     during product-config, BEFORE envsetup.mk sets TARGET_OUT_VENDOR. The
#     double-$ defers the variable to kati's second pass.
define tb375fc-vendor-lib64-symlink
$$(TARGET_OUT_VENDOR)/lib64/$(1): | $(_tb375fc_symlink_manifest)
	@mkdir -p $$(dir $$@)
	@rm -f $$@
	$$(hide) ln -sfn $(2) $$@
ALL_DEFAULT_INSTALLED_MODULES += $$(TARGET_OUT_VENDOR)/lib64/$(1)
INTERNAL_VENDORIMAGE_FILES   += $$(TARGET_OUT_VENDOR)/lib64/$(1)
endef

# Expand the manifest at parse time via $(shell) so kati reads it once during
# analysis rather than per-rule.
_tb375fc_symlink_pairs := $(shell cat $(_tb375fc_symlink_manifest))

$(foreach _pair,$(_tb375fc_symlink_pairs),$(eval $(call tb375fc-vendor-lib64-symlink,$(strip $(word 1,$(subst |, ,$(_pair)))),$(strip $(word 2,$(subst |, ,$(_pair)))))))

_tb375fc_symlink_manifest :=
_tb375fc_symlink_pairs :=
