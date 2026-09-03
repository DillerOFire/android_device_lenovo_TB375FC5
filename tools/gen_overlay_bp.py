#!/usr/bin/env python3
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# Overlay supplement for extract-utils.
#
# extract-utils (tools/extract-utils/extract_utils/makefiles.py,
# write_product_packages) categorises lib / lib64 / apex / app / priv-app /
# framework / etc / bin only. It has no handler for overlay/ RRO APKs, so any
# overlay listed in proprietary-files.txt trips "does not match known package
# rules" -> AssertionError. The RRO APKs here are prebuilt and presigned, so
# rebuilding them from source is not an option; they ship as android_app_import.
#
# This emits one android_app_import per APK under
# proprietary/{product,vendor}/overlay/ and appends it to the
# extract-utils-generated Android.bp (between markers, so it is idempotent),
# plus a PRODUCT_PACKAGES list in TB375FC-overlays.mk. extract-files.py calls
# main() after utils.run(), so the block regenerates in lock-step with the
# rest of the tree.

import os

DEVICE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
LOS_ROOT = os.path.abspath(os.path.join(DEVICE_DIR, '..', '..', '..'))
VENDOR_DIR = os.path.join(LOS_ROOT, 'vendor', 'lenovo', 'TB375FC')
PROP = os.path.join(VENDOR_DIR, 'proprietary')
ANDROID_BP = os.path.join(VENDOR_DIR, 'Android.bp')
OVERLAYS_MK = os.path.join(VENDOR_DIR, 'TB375FC-overlays.mk')

BEGIN = '// --- BEGIN overlay RRO supplement (gen_overlay_bp.py) ---'
END = '// --- END overlay RRO supplement ---'

PARTITIONS = (
    ('product', 'product_specific: true,'),
    ('vendor', 'vendor: true,'),
)


def collect():
    items = []
    for part, flag in PARTITIONS:
        odir = os.path.join(PROP, part, 'overlay')
        if not os.path.isdir(odir):
            continue
        for sub in sorted(os.listdir(odir)):
            subdir = os.path.join(odir, sub)
            if not os.path.isdir(subdir):
                continue
            for f in sorted(os.listdir(subdir)):
                if f.endswith('.apk'):
                    name = f[:-4]
                    apk_rel = '/'.join(['proprietary', part, 'overlay', sub, f])
                    items.append((name, apk_rel, flag))
    return items


def bp_block(name, apk, flag):
    return (
        '\nandroid_app_import {\n'
        f'    name: "{name}",\n'
        '    owner: "lenovo",\n'
        f'    apk: "{apk}",\n'
        '    presigned: true,\n'
        '    preprocessed: true,\n'
        '    dex_preopt: {\n'
        '        enabled: false,\n'
        '    },\n'
        f'    {flag}\n'
        '}\n'
    )


def main():
    items = collect()

    with open(ANDROID_BP) as f:
        content = f.read()
    head = content.split(BEGIN)[0].rstrip() + '\n' if BEGIN in content else content.rstrip() + '\n'
    # Strip shared_libs deps that have no Soong-module provider anywhere
    # ("depends on undefined module"): compiler-rt sanitizer runtimes
    # (libclang_rt.*) that extract-utils picks up from the .so NEEDED, plus any
    # genuinely-absent libs listed in tools/bp_strip_deps.txt (an OEM impl lib
    # the stock firmware itself does not ship - the dependent is orphaned, but
    # is kept shipped to match the prior PRODUCT_COPY behaviour).
    strip_deps = set()
    strip_file = os.path.join(DEVICE_DIR, 'tools', 'bp_strip_deps.txt')
    if os.path.exists(strip_file):
        strip_deps = {x.strip() for x in open(strip_file) if x.strip() and not x.startswith('#')}

    def keep_dep_line(l):
        st = l.strip()
        if st.startswith('"libclang_rt.'):
            return False
        return st.strip('",') not in strip_deps

    head = '\n'.join(l for l in head.split('\n') if keep_dep_line(l))

    # Disable check_elf_file on every cc_prebuilt blob. A full stock MTK blob set
    # trips check_elf_file in many ways that PRODUCT_COPY never checked and that
    # all resolve correctly at runtime: renamed DT_SONAME; undefined compiler-rt /
    # private-bionic / versioned symbols (__aeabi_*, @LIBC_PRIVATE, @LIBNATIVEWINDOW,
    # _Unwind_*); ubsan-runtime DT_NEEDED not in shared_libs. The bespoke ships the
    # identical blobs and boots, so the runtime is sound; a per-blob allowlist is a
    # losing game across ~1000 blobs. This matches the bespoke (no check) exactly.
    # (tools/bp_check_elf_disable.txt + bp_strip_deps.txt still drive the shared_libs
    # stripping for genuinely-unresolvable MTK-internal deps.)
    ce_lines = []
    in_prebuilt = False
    for l in head.split('\n'):
        st = l.strip()
        if st.startswith('cc_prebuilt_') and st.endswith('{'):
            in_prebuilt = True
        elif st == '}':
            in_prebuilt = False
        ce_lines.append(l)
        if in_prebuilt and st.startswith('name: "') and st.endswith('",'):
            indent = l[:len(l) - len(l.lstrip())]
            ce_lines.append(indent + 'check_elf_files: false,')
    head = '\n'.join(ce_lines)

    with open(ANDROID_BP, 'w') as f:
        f.write(head)
        f.write('\n' + BEGIN + '\n')
        f.write('// extract-utils has no overlay/ handler; these prebuilt RRO APKs\n')
        f.write('// are imported here so the overlays still ship. Do not hand-edit;\n')
        f.write('// regenerated by tools/gen_overlay_bp.py from extract-files.py.\n')
        for name, apk, flag in items:
            f.write(bp_block(name, apk, flag))
        f.write(END + '\n')

    with open(OVERLAYS_MK, 'w') as f:
        f.write('# Auto-generated by tools/gen_overlay_bp.py.\n')
        f.write('# RRO overlay packages (extract-utils has no overlay/ handler; the\n')
        f.write('# matching android_app_import modules are in vendor Android.bp).\n')
        if items:
            f.write('\nPRODUCT_PACKAGES += \\\n')
            f.write(' \\\n'.join('    ' + name for name, _, _ in items) + '\n')
        else:
            f.write('# No extracted RRO overlays.\n')

    print(f'overlay supplement: {len(items)} RRO imports -> Android.bp + TB375FC-overlays.mk')
    for name, _, _ in items:
        print('  ' + name)


if __name__ == '__main__':
    main()
