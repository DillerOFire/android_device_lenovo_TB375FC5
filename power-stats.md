# Power Stats support

Measured-energy accounting remains unsupported by this port. The current
product has a Power HAL for performance hints, but no Power Stats HAL.
Battery accounting therefore relies on framework estimates where no measured
energy data is available. This is an unresolved bring-up limitation.

The September 2026 source and read-only device inspection found:

- The prebuilt and running kernel both report
  `6.1.173-android14-11-g2cb2e678e9eb`. Its embedded configuration enables
  `CONFIG_MTK_SWPM_MODULE=m` and `CONFIG_MTK_SWPM_MT6897=m`.
- The device packages MediaTek SWPM modules, and the live kernel has them
  loaded. `/proc/swpm` exposes software power-model debug nodes, including
  `dump_power`. The Android shell cannot read that node. No permissions or
  debug controls were changed during inspection.
- `/sys/bus/iio/devices` exposes four MediaTek ADC devices. No cumulative
  rail-energy meter was established, and no Power Stats HAL is registered.
  The packaged vendor inputs and the `full-ZUI-17.5.10.103`
  dump's vendor, ODM and system_ext VINTF/init files contain no Power Stats
  HAL declaration or named Power Stats service payload.

SWPM's presence does not establish a calibrated energy-meter interface or a
compatible Android HAL. A real implementation requires documented data units,
cumulative-counter semantics, reset behavior, supported rails or residency
states, and device validation. Do not install an empty/example HAL to silence
framework errors or present software-model estimates as measured rail energy.

The absence of a service in the inspected inputs does not prove that Lenovo
hardware lacks all measurement capability. Integrating a verified provider,
its service and its VINTF declaration remains future work. Manifest changes
were excluded from this audit fix pass.
