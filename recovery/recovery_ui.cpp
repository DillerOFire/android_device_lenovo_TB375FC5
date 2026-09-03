/*
 * Device recovery extension for Lenovo TB375FC.
 *
 * Adds a "Mount metadata" action to the Advanced menu so diagnostic boot logs
 * written to /metadata (see vendor/etc/init/loggy.rc) can be inspected after
 * a boot failure, without needing root ADB in recovery. The metadata partition
 * is not mounted by default in this recovery; the button mounts it explicitly.
 */

#include <errno.h>
#include <stdlib.h>
#include <sys/mount.h>
#include <sys/stat.h>
#include <string.h>

#include <string>
#include <vector>

#include <recovery_ui/device.h>
#include <recovery_ui/screen_ui.h>

namespace {

constexpr const char* kMetadataSource = "/dev/block/by-name/metadata";
constexpr const char* kMetadataTarget = "/metadata";

bool IsAdvancedMenu(::Device* device) {
    const auto& headers = device->GetMenuHeaders();
    return headers.size() == 1 && headers[0] == "Advanced";
}

}  // namespace

class TB375FCDevice : public ::Device {
  public:
    explicit TB375FCDevice(::ScreenRecoveryUI* ui) : ::Device(ui) {}

    const std::vector<std::string>& GetMenuItems() override {
        const auto& base_items = ::Device::GetMenuItems();
        menu_items_.assign(base_items.begin(), base_items.end());
        if (IsAdvancedMenu(this)) {
            menu_items_.push_back("Mount metadata");
        }
        return menu_items_;
    }

    ::Device::BuiltinAction InvokeMenuItem(size_t menu_position) override {
        if (IsAdvancedMenu(this)) {
            // The custom entry is the one appended after the base Advanced items.
            if (menu_position >= ::Device::GetMenuItems().size()) {
                MountMetadata();
                return ::Device::NO_ACTION;
            }
        }
        return ::Device::InvokeMenuItem(menu_position);
    }

  private:
    void MountMetadata() {
        ::RecoveryUI* ui = GetUI();
        ui->Print("Mounting /metadata ...\n");

        // The partition is F2FS (see rootdir/etc/fstab.recovery). A raw mount()
        // bypasses the toybox fstab user-mountable check that rejected a shell
        // mount earlier; recovery runs as root in the (debug) permissive domain.
        const int flags = MS_NOATIME | MS_NOSUID | MS_NODEV;
        if (mount(kMetadataSource, kMetadataTarget, "f2fs", flags, "discard") != 0) {
            ui->Print("Failed to mount /metadata: %s\n", strerror(errno));
            return;
        }

        // Make the boot logs readable by non-root recovery ADB (shell).
        ::chmod(kMetadataTarget, 0755);
        ::chmod("/metadata/boot_log_full.txt", 0644);
        ::chmod("/metadata/boot_log_crash.txt", 0644);
        ::chmod("/metadata/boot_log_kernel.txt", 0644);
        ::chmod("/metadata/boot_log_avc.txt", 0644);
        ui->Print("Mounted /metadata.\n");
    }

    std::vector<std::string> menu_items_;
};

Device* make_device() {
    return new ::TB375FCDevice(new ::ScreenRecoveryUI);
}
