/*
 * SPDX-FileCopyrightText: The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 *
 * Device-specific power mode extension for TB375FC (mt6897).
 * Wired into android.hardware.power-service.lineage-libperfmgr via
 * soong_config_set(power_libperfmgr, mode_extension_lib, ...).
 *
 * Mode.DOUBLE_TAP_TO_WAKE -> /proc/gesture_control (enable/disable).
 * Replaces the TapToWakeService app bridge: the Power HAL now receives
 * Mode.DOUBLE_TAP_TO_WAKE from PowerManagerService directly, so the
 * Settings.Secure observer app is no longer needed.
 */

#include <aidl/android/hardware/power/BnPower.h>
#include <android-base/file.h>
#include <android-base/logging.h>

#define GESTURE_CONTROL_PATH "/proc/gesture_control"

namespace aidl {
namespace google {
namespace hardware {
namespace power {
namespace impl {
namespace pixel {

using ::aidl::android::hardware::power::Mode;

bool isDeviceSpecificModeSupported(Mode type, bool* _aidl_return) {
    switch (type) {
        case Mode::DOUBLE_TAP_TO_WAKE:
            *_aidl_return = true;
            return true;
        default:
            return false;
    }
}

bool setDeviceSpecificMode(Mode type, bool enabled) {
    switch (type) {
        case Mode::DOUBLE_TAP_TO_WAKE:
            return ::android::base::WriteStringToFile(
                    enabled ? "enable" : "disable", GESTURE_CONTROL_PATH);
        default:
            return false;
    }
}

}  // namespace pixel
}  // namespace impl
}  // namespace power
}  // namespace hardware
}  // namespace google
}  // namespace aidl
