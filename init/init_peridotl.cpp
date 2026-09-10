/*
 * Copyright (C) 2026 The LineageOS Project
 * SPDX-License-Identifier: Apache-2.0
 */

#include <android-base/logging.h>
#include <android-base/properties.h>
#include <sys/system_properties.h>

#include <array>
#include <string>
#include <string_view>

namespace {

enum class Sku {
  kUnknown,
  kTb375fc,
  kTb373fu,
};

struct SkuIdentity {
  std::string_view device;
  std::string_view name;
  std::string_view model;
  std::string_view hw_version;
  std::string_view ota_model;
  std::string_view market_name;
  std::string_view region;
};

constexpr SkuIdentity kTb375fcIdentity = {
    "TB375FC", "TB375FC",     "TB375FC",
    "TB375FC", "TB375FC_PRC", "Lenovo Xiaoxin Pad Pro 12.7",
    "prc",
};

constexpr SkuIdentity kTb373fuIdentity = {
    "TB373FU", "TB373FU",     "TB373FU",
    "TB373FU", "TB373FU_ROW", "Lenovo Idea Tab Pro",
    "row",
};

constexpr SkuIdentity kFallbackIdentity = {
    "peridotl", "peridotl",   "peridotl", "peridotl",
    "peridotl", "Lenovo Tab", "unknown",
};

constexpr std::array<std::string_view, 5> kProductPartitions = {
    "system", "system_ext", "product", "vendor", "odm",
};

Sku SkuFromRegion(std::string_view region) {
  if (region == "PRC") {
    return Sku::kTb375fc;
  }
  if (region == "ROW") {
    return Sku::kTb373fu;
  }
  return Sku::kUnknown;
}

Sku SkuFromBoardId(std::string_view board_id) {
  if (board_id == "P98300DA2") {
    return Sku::kTb375fc;
  }
  if (board_id == "P98300DA1") {
    return Sku::kTb373fu;
  }
  return Sku::kUnknown;
}

const SkuIdentity &IdentityForSku(Sku sku) {
  switch (sku) {
  case Sku::kTb375fc:
    return kTb375fcIdentity;
  case Sku::kTb373fu:
    return kTb373fuIdentity;
  case Sku::kUnknown:
    return kFallbackIdentity;
  }
  return kFallbackIdentity;
}

std::string_view NameForSku(Sku sku) { return IdentityForSku(sku).device; }

bool property_override(std::string_view name, std::string_view value) {
  const std::string property_name(name);
  const prop_info *property = __system_property_find(property_name.c_str());
  int result;
  if (property == nullptr) {
    result = __system_property_add(property_name.c_str(), property_name.size(),
                                   value.data(), value.size());
  } else {
    result = __system_property_update(const_cast<prop_info *>(property),
                                      value.data(), value.size());
  }

  if (result < 0) {
    LOG(ERROR) << "peridotl: failed to override " << name;
    return false;
  }
  return true;
}

void SetProductIdentity(const SkuIdentity &identity) {
  property_override("ro.product.device", identity.device);
  property_override("ro.product.name", identity.name);
  property_override("ro.product.model", identity.model);

  for (const std::string_view partition : kProductPartitions) {
    const std::string prefix = "ro.product." + std::string(partition) + ".";
    property_override(prefix + "device", identity.device);
    property_override(prefix + "name", identity.name);
    property_override(prefix + "model", identity.model);
  }
}

void SetLgsiIdentity(const SkuIdentity &identity) {
  property_override("ro.vendor.config.lgsi.hw.version", identity.hw_version);
  property_override("ro.vendor.config.lgsi.ota.model", identity.ota_model);
  property_override("ro.vendor.config.lgsi.en.market_name",
                    identity.market_name);
  property_override("ro.config.lgsi.region", identity.region);
}

} // namespace

void vendor_load_properties() {
  const std::string region = android::base::GetProperty("ro.boot.region", "");
  const std::string board_id =
      android::base::GetProperty("ro.boot.boardid", "");
  const Sku region_sku = SkuFromRegion(region);
  const Sku board_sku = SkuFromBoardId(board_id);

  Sku sku = region_sku;
  std::string_view source = "ro.boot.region";
  if (sku == Sku::kUnknown) {
    sku = board_sku;
    source = "ro.boot.boardid";
  }

  if (region_sku != Sku::kUnknown && board_sku != Sku::kUnknown &&
      region_sku != board_sku) {
    LOG(WARNING) << "peridotl: conflicting boot identity: region='" << region
                 << "', boardid='" << board_id << "'; region takes precedence";
  }
  if (sku == Sku::kUnknown) {
    LOG(ERROR) << "peridotl: unsupported boot identity: region='" << region
               << "', boardid='" << board_id
               << "'; applying neutral peridotl fallback";
  } else {
    LOG(INFO) << "peridotl: detected " << NameForSku(sku) << " from " << source
              << ": region='" << region << "', boardid='" << board_id << "'";
  }

  const SkuIdentity &identity = IdentityForSku(sku);
  SetProductIdentity(identity);
  SetLgsiIdentity(identity);
}
