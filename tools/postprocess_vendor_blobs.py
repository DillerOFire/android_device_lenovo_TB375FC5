#!/usr/bin/env python3
"""Keep generated TB375FC blobs compatible with the local MTK HAL choice."""
from pathlib import Path
import re

DEVICE_DIR = Path(__file__).resolve().parent.parent
VENDOR_DIR = DEVICE_DIR.parents[2] / 'vendor' / 'lenovo' / 'TB375FC'

# hardware/mediatek has thermal/memtrack/vibrator explicitly disabled for this
# device; the Lenovo prebuilts are required. chipinfo alone is byte-identical to
# the source script, so keep its make copy and drop the duplicate Soong module.
DROP_MODULES = {'chipinfo'}


def remove_bp_modules(path: Path) -> int:
    text = path.read_text()
    out, pos, removed = [], 0, 0
    pattern = re.compile(r'^[A-Za-z0-9_]+\s*\{', re.M)
    while (match := pattern.search(text, pos)):
        start = match.start()
        depth, i = 0, match.end() - 1
        while i < len(text):
            if text[i] == '{':
                depth += 1
            elif text[i] == '}':
                depth -= 1
                if depth == 0:
                    i += 1
                    break
            i += 1
        block = text[start:i]
        name = re.search(r'^\s*name:\s*"([^"]+)"', block, re.M)
        if name and name.group(1) in DROP_MODULES:
            out.append(text[pos:start])
            removed += 1
        else:
            out.append(text[pos:i])
        pos = i
    out.append(text[pos:])
    path.write_text(''.join(out))
    return removed


def remove_stock_boot_imports(path: Path) -> int:
    text = path.read_text()
    cleaned, count = re.subn(
        r'^import /vendor/etc/init/android\.hardware\.boot-service\.mtk(?:-service-lazy)?\.rc\n',
        '', text, flags=re.M)
    path.write_text(cleaned)
    return count


def drop_mali_stale_graphics_dep(path: Path) -> int:
    """Avoid mixing graphics.common NDK V4 and V7 in libGLES_mali's graph.

    The ZUI blob needs V4 at runtime, but the current MTK gralloc stack pulls
    V7 transitively.  Soong rejects both interface versions in one module;
    the prebuilt has check_elf_files disabled, so retain the runtime SONAME
    while omitting the stale build-graph edge.
    """
    text = path.read_text()
    target = '                "android.hardware.graphics.common-V4-ndk",\n'
    pattern = re.compile(
        r'(cc_prebuilt_library_shared\s*\{.*?^\s*name:\s*"libGLES_mali".*?^\})',
        re.M | re.S,
    )
    match = pattern.search(text)
    if not match:
        raise SystemExit('missing generated libGLES_mali module')
    block = match.group(1)
    cleaned = block.replace(target, '')
    removed = block.count(target)
    if removed != 2:
        raise SystemExit(f'expected two libGLES_mali V4 graph deps, found {removed}')
    path.write_text(text[:match.start()] + cleaned + text[match.end():])
    return removed


def main() -> None:
    bp = VENDOR_DIR / 'Android.bp'
    init = VENDOR_DIR / 'proprietary/vendor/etc/init/hw/meta_init.vendor.rc'
    if not bp.is_file() or not init.is_file():
        raise SystemExit('missing generated vendor Android.bp or meta_init.vendor.rc')
    removed = remove_bp_modules(bp)
    imports = remove_stock_boot_imports(init)
    mali_deps = drop_mali_stale_graphics_dep(bp)
    print(
        f'pruned {removed} duplicate chipinfo module, {imports} obsolete stock boot-HAL imports, '
        f'and {mali_deps} stale libGLES_mali graphics-common V4 graph deps; '
        'retained required Lenovo thermal/memtrack/vibrator prebuilts'
    )


if __name__ == '__main__':
    main()
