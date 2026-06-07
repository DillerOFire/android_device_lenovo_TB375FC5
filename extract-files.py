#!/usr/bin/env -S PYTHONPATH=../../../tools/extract-utils python3
#
# SPDX-FileCopyrightText: The LineageOS Project
# SPDX-License-Identifier: Apache-2.0
#
# TB375FC blob extraction + makefile generation entry point. Sources are
# the stock A16 TB375FC PRC firmware pulled directly off the device after
# OTA to ZUI 17.5.10.060. Run with no arg to (re)generate makefiles from
# the already-extracted proprietary/ tree; run with a dump path to
# re-extract from source.

from extract_utils.main import (
    ExtractUtils,
    ExtractUtilsModule,
)

module = ExtractUtilsModule(
    'TB375FC',
    'lenovo',
)

if __name__ == '__main__':
    utils = ExtractUtils.device(module)
    utils.run()

    # extract-utils has no overlay/ handler (its write_product_packages
    # categorises lib/app/priv-app/framework/etc/bin/apex only), so the
    # prebuilt RRO overlay APKs are supplemented after the standard pass.
    # See tools/gen_overlay_bp.py.
    import os
    import sys

    sys.path.insert(
        0, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'tools')
    )
    import gen_overlay_bp

    gen_overlay_bp.main()
