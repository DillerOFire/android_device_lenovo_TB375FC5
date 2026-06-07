#
# Stock TB375FC vendor.img puts arm64 HAL binaries under /vendor/bin/hw/mt6897/
# with a .mt6897 suffix and exposes them at the canonical /vendor/bin/hw/<name>
# path via symlinks. Init's service directives in /vendor/etc/init/*.rc
# reference the canonical (no-suffix) path; without these symlinks init can't
# find the binary and never starts the service. The V2 allocator service was
# the symptom: init never even attempted "starting service vendor.gralloc-v2",
# IAllocator/default never registered, IComposer/default chained off that
# never registered, surfaceflinger sat waiting, device hung at "Powered by
# Android".
#
# 6 critical bin/hw symlinks plus 186 toybox aliases under /vendor/bin/.
# The aliases aren't strictly required for boot but stock has them.
#
# Manifest: configs/vendor_bin_symlinks.txt, lines of
#   <link-rel-to-/vendor>|<target-as-stored-in-stock-symlink>
#
# Regenerate via tools/gen_vendor_symlinks.sh against a fresh stock dump.

_tb375fc_bin_symlink_manifest := $(LOCAL_PATH)/configs/vendor_bin_symlinks.txt

define tb375fc-vendor-bin-symlink
$$(TARGET_OUT_VENDOR)/$(1): | $(_tb375fc_bin_symlink_manifest)
	@mkdir -p $$(dir $$@)
	@rm -f $$@
	$$(hide) ln -sfn $(2) $$@
ALL_DEFAULT_INSTALLED_MODULES += $$(TARGET_OUT_VENDOR)/$(1)
INTERNAL_VENDORIMAGE_FILES   += $$(TARGET_OUT_VENDOR)/$(1)
endef

_tb375fc_bin_symlink_pairs := $(shell cat $(_tb375fc_bin_symlink_manifest))

$(foreach _pair,$(_tb375fc_bin_symlink_pairs),$(eval $(call tb375fc-vendor-bin-symlink,$(strip $(word 1,$(subst |, ,$(_pair)))),$(strip $(word 2,$(subst |, ,$(_pair)))))))

_tb375fc_bin_symlink_manifest :=
_tb375fc_bin_symlink_pairs :=
