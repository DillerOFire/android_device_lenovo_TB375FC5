# Lenovo peridotl - TB375FC / TB373FU

PixelOS 17 device tree for Lenovo's `peridot` Wi-Fi tablet platform. The ROM
target is named `peridotl` to avoid PixelOS's existing Xiaomi `peridot` target.
One `custom_peridotl` product supports the PRC `TB375FC` and ROW `TB373FU`
retail SKUs through init-time detection. Stock LGSI project properties remain
`peridot`.

## Specifications

| Component | Detail |
|-----------|--------|
| SoC | MediaTek Dimensity 8300 (MT6897) |
| GPU | Mali-G615 |
| RAM / Storage | 8 GB / 128 GB, 8 GB / 256 GB, or 12 GB / 256 GB (UFS) |
| Display | 12.7" 3K (2944 x 1840) IPS LCD, 144 Hz (capped to 120, see Notes) |
| Battery | ~10200 mAh |
| Connectivity | Wi-Fi 6E, Bluetooth 5.4 (MediaTek connsys), no cellular |
| Cameras | 13 MP rear, 8 MP front |
| Fingerprint | Goodix |
| Stylus | Lenovo Tab Pen Plus (active pen) |
| Stock | Android 16 (ZUXOS 1.5.10.060); launched on Android 14 (API 34) |

## Build

```
repo init -u https://github.com/PixelOS-AOSP/android_manifest.git -b seventeen
```

Add the manifest below as `.repo/local_manifests/peridotl.xml`, then:

```
repo sync
source build/envsetup.sh
lunch custom_peridotl-cp2a-user
m bacon
```

Kernel, DTB and modules ship prebuilt in the device tree (`prebuilts/`), so no kernel source is needed to build. The from-source 6.1 kernel that produced them is published separately as `android_device_lenovo_TB375FC-kernel` for reference and reproducibility; the build does not consume it.

### local_manifests/peridotl.xml

```xml
<?xml version="1.0" encoding="UTF-8"?>
<manifest>
  <project name="DillerOFire/android_device_lenovo_peridotl" path="device/lenovo/peridotl" remote="github" revision="lineage-23.2" />
  <project name="DillerOFire/android_vendor_lenovo_TB375FC" path="vendor/lenovo/TB375FC" remote="github" revision="lineage-23.2" />
  <project name="LineageOS/android_hardware_mediatek" path="hardware/mediatek" remote="github" revision="lineage-23.2" />
</manifest>
```

`hardware/mediatek` is the upstream LineageOS common tree inherited by this
target. The older separate TB373FU wrapper is not used by the unified build.

## Runtime SKU detection

Init treats `ro.boot.region` as authoritative and uses `ro.boot.boardid` only
as a fallback. `PRC` / `P98300DA2` selects TB375FC; `ROW` / `P98300DA1`
selects TB373FU. Conflicts are logged and the region wins. Missing or unknown
identifiers use a clearly logged neutral `peridotl` identity.

The TB375FC values have been captured from hardware. The TB373FU region value
remains an expected stock mapping until it is captured from a live device. A
physical TB373FU has booted the same signed PixelOS DTBO used by TB375FC
(`sha256 fe5e7bc48f030bf343e6376bacea6a49ea463c256f880f4f190b7becfcd27be8`).

## Notes

### Display capped at 120 Hz
The panel advertises 144 Hz, but the NVT touch controller cannot scan the active pen inside a 144 Hz frame (6.94 ms), so the stylus stops working above 120 Hz while finger touch still works. Stock steps the panel down to 120 Hz whenever the pen is active (`set_pen_timer` in MediaTek's SurfaceFlinger, which AOSP does not implement), so 120 Hz is the real pen rate. The panel is capped there and the refresh-rate picker is removed.

### Patched prebuilt modules
Two stock kernel modules are modified; both are required, and extracting from a stock device gives the unpatched versions.

| Module | Change |
|--------|--------|
| `nt36532.ko` | Touch firmware loads on the first attempt in recovery instead of timing out for ~15 s |
| `wlan_drv_gen4m_6897.ko` | Fixes a WPA3 association failure in the stock driver |

### Signing
Builds from this tree are signed with the public AOSP test keys, which is fine for personal use but not something to trust for anything security sensitive. Generate your own keys and sign your own build.

## Technical

- Boot image header v4: split `boot` / `vendor_boot` / `init_boot`
- erofs on the super sub-partitions, f2fs on `/data` and `/metadata`
- VINTF target level 8
- TEE: beanpod (MediaTek); EGL: meow (MediaTek)

## License

Apache-2.0. See file headers for details.
