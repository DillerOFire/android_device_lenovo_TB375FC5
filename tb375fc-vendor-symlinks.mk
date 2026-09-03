#
# Stock TB375FC vendor.img keeps MT6897 libraries in arch-specific subdirs
# and exposes canonical /vendor/lib{,64}/ paths as relative symlinks. Vendor
# DT_NEEDED entries use bare SONAMEs, so both link sets are runtime-critical.
# extract-files captures only the real files and drops these symlinks.
#
# Manifests contain <link-rel-path>|<target-rel-path>, relative to each ABI dir:
#   configs/vendor_lib_symlinks.txt       -> /vendor/lib/
#   configs/vendor_lib64_symlinks.txt     -> /vendor/lib64/
# Regenerate them from a mounted stock vendor image when refreshing blobs.

_tb375fc_lib_symlink_manifest := $(LOCAL_PATH)/configs/vendor_lib_symlinks.txt
_tb375fc_lib64_symlink_manifest := $(LOCAL_PATH)/configs/vendor_lib64_symlinks.txt

# $(1)=ABI dir (lib or lib64), $(2)=link path, $(3)=relative stock target.
# Double-$ defers TARGET_OUT_VENDOR until kati's image-rule pass.
define tb375fc-vendor-symlink
$$(TARGET_OUT_VENDOR)/$(1)/$(2): | $(4)
	@mkdir -p $$(dir $$@)
	@rm -f $$@
	$$(hide) ln -sfn $(3) $$@
ALL_DEFAULT_INSTALLED_MODULES += $$(TARGET_OUT_VENDOR)/$(1)/$(2)
INTERNAL_VENDORIMAGE_FILES   += $$(TARGET_OUT_VENDOR)/$(1)/$(2)
endef

_tb375fc_lib_symlink_pairs := $(shell cat $(_tb375fc_lib_symlink_manifest))
_tb375fc_lib64_symlink_pairs := $(shell cat $(_tb375fc_lib64_symlink_manifest))

$(foreach _pair,$(_tb375fc_lib_symlink_pairs),$(eval $(call tb375fc-vendor-symlink,lib,$(strip $(word 1,$(subst |, ,$(_pair)))),$(strip $(word 2,$(subst |, ,$(_pair)))),$(_tb375fc_lib_symlink_manifest))))
$(foreach _pair,$(_tb375fc_lib64_symlink_pairs),$(eval $(call tb375fc-vendor-symlink,lib64,$(strip $(word 1,$(subst |, ,$(_pair)))),$(strip $(word 2,$(subst |, ,$(_pair)))),$(_tb375fc_lib64_symlink_manifest))))

_tb375fc_lib_symlink_manifest :=
_tb375fc_lib64_symlink_manifest :=
_tb375fc_lib_symlink_pairs :=
_tb375fc_lib64_symlink_pairs :=
