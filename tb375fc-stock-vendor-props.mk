# Auto-generated from stock TB375FC PRC A16 vendor/build.prop. Properties
# referenced by Mali libGLES (EGL config table), MTK HALs, surfaceflinger
# phase offsets, Lenovo init triggers. build.prop content isn't a blob;
# extract-files doesn't replicate it. Without these libGLES_mali
# eglInitialize aborts (no EGL configs advertised).
#
# Stock vendor/build.prop has some keys listed twice with different values
# (layered sources, later wins). Last value wins to match runtime prop-loader
# semantics.
#
# Derived from the stock vendor/build.prop. Manual edits below are preserved.
#   - ro.vendor.magt.mtk_magt_support=1 removed. device.mk sets =0. magt
#     links android.hardware.thermal@2.0.so which AOSP A16 no longer ships.
#   - ro.surface_flinger.primary_display_orientation=ORIENTATION_270: kept.
#     The kernel touch driver is hard-wired to the 270 deg panel mount;
#     overriding SF orientation without retuning touch transforms breaks
#     input alignment.
#   - Telephony/radio props removed. Device is WiFi-only. Removed set:
#       ro.telephony.default_network, ro.telephony.iwlan_operation_mode,
#       ro.vendor.md_auto_setup_ims, ro.vendor.md_prop_ver,
#       ro.vendor.mtk_c2k_lte_mode, ro.vendor.mtk_eccci_c2k,
#       ro.vendor.mtk_external_sim_only_slots,
#       ro.vendor.mtk_md_world_mode_support,
#       ro.vendor.mtk_protocol1_rat_config, ro.vendor.mtk_ps1_rat,
#       ro.vendor.mtk_ril_mode, ro.vendor.mtk_sim_card_onoff,
#       ro.vendor.mtk_single_bin_modem_support,
#       ro.vendor.mtk_thin_md_telephony_support_mode,
#       ro.vendor.mtk_world_phone_policy, ro.vendor.ril.set_sbp_place,
#       ro.vendor.sim_me_lock_mode, ro.vendor.vt.mtk_thin_md_support_mode,
#       persist.vendor.md_c2k_cap_dep_check, persist.vendor.mims_support,
#       persist.vendor.mtk_sim_switch_policy,
#       persist.vendor.radio.mtk_ps2_rat, persist.vendor.radio.mtk_ps3_rat,
#       persist.vendor.radio.smart.data.switch,
#       persist.vendor.vilte_support, persist.vendor.viwifi_support,
#       ro.com.android.dataroaming.
#     Cleanup of cellular binaries/libs/init.rc files is NOT done here;
#     those stay at stock because the libs cross-link with non-cellular
#     subsystems via libmipc.
#
# Bluetooth note: these props are read literally by the AOSP Bluetooth stack
# (not the stock ZUI MTK vendor stack). Additions below this header:
#   - bluetooth.profile.a2dp.source.enabled=true / hfp.ag / hfp.hf: classic
#     A2DP source + HFP headset profiles. Without them A2DP/HEADSET never start
#     -> earbuds pair (GATT/SMP) but produce no audio (l2c_link_timeout).
#   - persist.bluetooth.a2dp_offload.disabled=true: KEEP stock. ON THIS MTK
#     DEVICE the A2DP hardware-offload datapath cannot establish under the AOSP
#     stack (the offload session ends immediately), so forcing offload OFF
#     (=true, or the dev-setting toggle) is what makes the software datapath
#     actually play audio. Do NOT flip this to false — verified silent.

PRODUCT_VENDOR_PROPERTIES += \
    aaudio.mmap_exclusive_policy=2 \
    aaudio.mmap_policy=2 \
    apexd.config.dm_create.timeout=5000 \
    audio.deep_buffer.media=true \
    audio.offload.min.duration.secs=30 \
    audio.offload.video=true \
    bluetooth.profile.bap.broadcast.assist.enabled=false \
    bluetooth.profile.bap.broadcast.source.enabled=false \
    bluetooth.profile.bap.unicast.client.enabled=false \
    bluetooth.profile.bas.client.enabled=false \
    bluetooth.profile.bass.client.enabled=false \
    bluetooth.profile.ccp.server.enabled=false \
    bluetooth.profile.csip.set_coordinator.enabled=false \
    bluetooth.profile.hap.client.enabled=false \
    bluetooth.profile.mcp.server.enabled=false \
    bluetooth.profile.sap.server.enabled=true \
    bluetooth.profile.vcp.controller.enabled=false \
    bluetooth.profile.a2dp.source.enabled=true \
    bluetooth.profile.hfp.ag.enabled=true \
    bluetooth.profile.hfp.hf.enabled=true \
    camera.disable_zsl_mode=1 \
    dalvik.vm.dex2oat64.enabled=true \
    dalvik.vm.finalizer-timeout-ms=40000 \
    dalvik.vm.heapgrowthlimit=256m \
    dalvik.vm.heapmaxfree=32m \
    dalvik.vm.heapminfree=8m \
    dalvik.vm.heapsize=512m \
    dalvik.vm.heapstartsize=16m \
    dalvik.vm.heaptargetutilization=0.5 \
    dalvik.vm.mtk-stack-trace-file=/data/anr/mtk_traces.txt \
    debug.mediatek.appgamepq_compress=1 \
    debug.mediatek.disp_decompress=1 \
    debug.mtk_tflite.target_nnapi=29 \
    debug.renderengine.backend=skiagl \
    debug.sf.disable_backpressure=1 \
    debug.sf.early.app.duration=20000000 \
    debug.sf.early.sf.duration=27600000 \
    debug.sf.earlyGl.app.duration=20000000 \
    debug.sf.earlyGl.sf.duration=27600000 \
    debug.sf.enable_gl_backpressure=0 \
    debug.sf.enable_hwc_vds=0 \
    debug.sf.hwc.min.duration=2000000 \
    debug.sf.ignore_hwc_physical_display_orientation=true \
    debug.sf.late.app.duration=20000000 \
    debug.sf.late.sf.duration=15600000 \
    debug.sf.set_binder_thread_rt=1 \
    debug.sf.use_phase_offsets_as_durations=1 \
    debug.stagefright.c2inputsurface=-1 \
    drm.service.enabled=true \
    external_storage.casefold.enabled=1 \
    external_storage.projid.enabled=1 \
    external_storage.sdcardfs.enabled=0 \
    graphics.gpu.profiler.support=true \
    init.userspace_reboot.is_supported=true \
    media.c2.dmabuf.padding=3072 \
    ro.apex.updatable=true \
    ro.arm64.memtag.bootctl_supported=1 \
    ro.audio.spatializer_enabled=true \
    ro.bluetooth.a2dp_offload.supported=true \
    ro.bluetooth.leaudio_offload.supported=false \
    ro.config.lgsi.cpuinfo=MediaTek Dimensity 8300 \
    ro.config.zuk.cpuinfo=MediaTek Dimensity 8300 \
    ro.control_privapp_permissions=enforce \
    ro.cp_system_other_odex=0 \
    ro.frp.pst=/dev/block/by-name/frp \
    ro.gfx.driver.0=com.mediatek.mt6897.gamedriver \
    ro.incremental.enable=yes \
    ro.lmk.kill_timeout_ms=100 \
    ro.lmk.psi_complete_stall_ms=500 \
    ro.lmk.swap_free_low_percentage=10 \
    ro.lmk.swap_util_max=100 \
    ro.lmk.thrashing_limit=100 \
    ro.lmk.thrashing_limit_decay=10 \
    ro.logd.kernel=false \
    ro.mtk_key_manager_support=1 \
    ro.netflix.bsp_rev=MTK6897-37606-1 \
    ro.odm.lenovo.cpuinfo=MediaTek Dimensity 8300 \
    ro.odm.lenovo.series=Lenovo Idea Tab Pro \
    ro.odm.lenovo.supported_csr_type=tee,widevine \
    ro.oem_unlock_supported=1 \
    ro.opengles.version=196610 \
    ro.sf.lcd_density=340 \
    ro.surface_flinger.enable_frame_rate_override=false \
    ro.surface_flinger.force_hwc_copy_for_virtual_displays=true \
    ro.surface_flinger.game_default_frame_rate_override=120 \
    ro.surface_flinger.has_wide_color_display=true \
    ro.surface_flinger.max_frame_buffer_acquired_buffers=4 \
    ro.surface_flinger.primary_display_orientation=ORIENTATION_270 \
    ro.surface_flinger.protected_contents=true \
    ro.surface_flinger.uclamp.min=120 \
    ro.vendor.afbc.enable=3 \
    ro.vendor.ap_info_monitor=0 \
    ro.vendor.arm.egl.configs.nv12.hal_format=0x200 \
    ro.vendor.arm.egl.configs.nv12.recordable=true \
    ro.vendor.arm.egl.configs.nv16.hal_format=0x10 \
    ro.vendor.arm.egl.configs.nv16.recordable=true \
    ro.vendor.arm.egl.configs.nv21.hal_format=0x201 \
    ro.vendor.arm.egl.configs.nv21.recordable=true \
    ro.vendor.arm.egl.configs.p010.hal_format=0x204 \
    ro.vendor.arm.egl.configs.p010.recordable=true \
    ro.vendor.arm.egl.configs.p210.hal_format=0x205 \
    ro.vendor.arm.egl.configs.p210.recordable=true \
    ro.vendor.arm.egl.configs.r10_g10_b10_a2_32bit_fixed.framebuffer_target=false \
    ro.vendor.arm.egl.configs.r10_g10_b10_a2_32bit_fixed.hal_format=0x2b \
    ro.vendor.arm.egl.configs.r10_g10_b10_a2_32bit_fixed.recordable=false \
    ro.vendor.arm.egl.configs.r16_g16_b16_a16_64bit_float.framebuffer_target=false \
    ro.vendor.arm.egl.configs.r16_g16_b16_a16_64bit_float.hal_format=0x16 \
    ro.vendor.arm.egl.configs.r16_g16_b16_a16_64bit_float.recordable=false \
    ro.vendor.arm.egl.configs.r5_g6_b5_a0_16bit_fixed.framebuffer_target=false \
    ro.vendor.arm.egl.configs.r5_g6_b5_a0_16bit_fixed.hal_format=0x4 \
    ro.vendor.arm.egl.configs.r5_g6_b5_a0_16bit_fixed.recordable=false \
    ro.vendor.arm.egl.configs.r8_g8_b8_a0_24bit_fixed.framebuffer_target=false \
    ro.vendor.arm.egl.configs.r8_g8_b8_a0_24bit_fixed.hal_format=0x2 \
    ro.vendor.arm.egl.configs.r8_g8_b8_a0_24bit_fixed.recordable=false \
    ro.vendor.arm.egl.configs.r8_g8_b8_a0_24bit_yuv_special.framebuffer_target=false \
    ro.vendor.arm.egl.configs.r8_g8_b8_a0_24bit_yuv_special.hal_format=0x23 \
    ro.vendor.arm.egl.configs.r8_g8_b8_a0_32bit_fixed.framebuffer_target=false \
    ro.vendor.arm.egl.configs.r8_g8_b8_a0_32bit_fixed.hal_format=0x2 \
    ro.vendor.arm.egl.configs.r8_g8_b8_a0_32bit_fixed.recordable=false \
    ro.vendor.arm.egl.configs.r8_g8_b8_a8_32bit_fixed.framebuffer_target=false \
    ro.vendor.arm.egl.configs.r8_g8_b8_a8_32bit_fixed.hal_format=0x1 \
    ro.vendor.arm.egl.configs.r8_g8_b8_a8_32bit_fixed.recordable=true \
    ro.vendor.arm.egl.configs.y0l2.hal_format=0x203 \
    ro.vendor.arm.egl.configs.y0l2.recordable=true \
    ro.vendor.arm.egl.configs.y210.hal_format=0x206 \
    ro.vendor.arm.egl.configs.y210.recordable=true \
    ro.vendor.arm.egl.configs.y410.hal_format=0x207 \
    ro.vendor.arm.egl.configs.y410.recordable=true \
    ro.vendor.arm.egl.configs.yuv420.hal_format=0x208 \
    ro.vendor.arm.egl.configs.yuv420.recordable=true \
    ro.vendor.arm.egl.configs.yuyv.hal_format=0x202 \
    ro.vendor.arm.egl.configs.yuyv.recordable=true \
    ro.vendor.arm.egl.configs.yvu420.hal_format=0x20e \
    ro.vendor.arm.egl.configs.yvu420.recordable=true \
    ro.vendor.arm.gralloc.afrc_chroma_usage_flags=0x100000000000000,0x80000000000000,0x180000000000000 \
    ro.vendor.arm.gralloc.afrc_chroma_usage_mask=0x180000000000000 \
    ro.vendor.arm.gralloc.afrc_luma_usage_flags=0x50000000,0x60000000,0x40000000 \
    ro.vendor.arm.gralloc.afrc_luma_usage_mask=0x70000000 \
    ro.vendor.arm.gralloc.afrc_rgba_usage_flags=0x50000000,0x60000000,0x40000000 \
    ro.vendor.arm.gralloc.afrc_rgba_usage_mask=0x70000000 \
    ro.vendor.arm.gralloc.force_back_buffer_usage_flags=0x40000000000000 \
    ro.vendor.arm.gralloc.force_back_buffer_usage_mask=0x40000000000000 \
    ro.vendor.arm.gralloc.no_afbc_usage_flags=0x200000000000000 \
    ro.vendor.arm.gralloc.no_afbc_usage_mask=0x1200000000000000 \
    ro.vendor.arm.gralloc.shared_access_usage_flags=0x10000000 \
    ro.vendor.arm.gralloc.shared_access_usage_mask=0x50000000 \
    ro.vendor.bt.connac3=no \
    ro.vendor.bt.platform=6897 \
    ro.vendor.camera.directfdyuv.support=1 \
    ro.vendor.camera.insensorzoom.support=0 \
    ro.vendor.camera.isp.support.colorspace=0 \
    ro.vendor.camera3.zsl.default=260 \
    ro.vendor.com.zui.version=16.0 \
    ro.vendor.composer_version=3.2 \
    ro.vendor.connsys.dedicated.log.port=bt,wifi,ics,btmcu,wifimcu \
    ro.vendor.connsys.dedicated.log=1 \
    ro.vendor.dolby.dax.version=DAX3_3.13.0.9_r1 \
    ro.vendor.efuse_writer_enable=1 \
    ro.vendor.fm.platform=connac2x \
    ro.vendor.gps.chrdev=gps_drv_dl_v051 \
    ro.vendor.hdr10plus.enable=1 \
    ro.vendor.init.sensor.rc=init.sensor_2_0.rc \
    ro.vendor.jpeg_decode_sw_opt=2 \
    ro.vendor.magt.mtk_magt_version=2 \
    ro.vendor.mgk_name=mgk_64_k61_wifi \
    ro.vendor.mgvi_name=mgvi_t_64_wifi_armv82 \
    ro.vendor.mml.mtk_mml_support=1 \
    ro.vendor.mtk.c2.vdec.fmt.support.level=2 \
    ro.vendor.mtk.c2.vdec.vpp.turnkey.memc=1 \
    ro.vendor.mtk.gpud.mm.fbc.disable=false \
    ro.vendor.mtk.sensor.support=yes \
    ro.vendor.mtk_aal_support=1 \
    ro.vendor.mtk_audio_tuning_tool_ver=V1 \
    ro.vendor.mtk_backlight_hwc_support=1 \
    ro.vendor.mtk_blulight_def_support=1 \
    ro.vendor.mtk_cam_security_support=1 \
    ro.vendor.mtk_camera_app_version=3 \
    ro.vendor.mtk_chameleon_support=1 \
    ro.vendor.mtk_config_max_dram_size= \
    ro.vendor.mtk_cuva_hdr_support=1 \
    ro.vendor.mtk_data_config=1 \
    ro.vendor.mtk_dre30_support=1 \
    ro.vendor.mtk_emmc_support=1 \
    ro.vendor.mtk_f2fs_enable=1 \
    ro.vendor.mtk_fast_charging_support=1 \
    ro.vendor.mtk_gps_support=1 \
    ro.vendor.mtk_hdr10p_adaptive_support=1 \
    ro.vendor.mtk_hdr_video_support=1 \
    ro.vendor.mtk_hifiaudio_support=1 \
    ro.vendor.mtk_log_hide_gps=1 \
    ro.vendor.mtk_mcf_support=1 \
    ro.vendor.mtk_microtrust_tee_support=1 \
    ro.vendor.mtk_mvpu_security_support=0 \
    ro.vendor.mtk_mvpu_support=1 \
    ro.vendor.mtk_nn.option=A,B,C,D,E,F,G,Z \
    ro.vendor.mtk_nn_baseline_support=1 \
    ro.vendor.mtk_nn_quant_preferred=1 \
    ro.vendor.mtk_nn_support=1 \
    ro.vendor.mtk_ovl_bringup=0 \
    ro.vendor.mtk_pq_color_mode=3 \
    ro.vendor.mtk_pq_support=2 \
    ro.vendor.mtk_prefer_64bit_proc=1 \
    ro.vendor.mtk_sec_video_path_support=1 \
    ro.vendor.mtk_slow_motion_support=1 \
    ro.vendor.mtk_tee_gp_support=1 \
    ro.vendor.mtk_thermal_2_0=1 \
    ro.vendor.mtk_video_hevc_enc_support=1 \
    ro.vendor.mtk_wapi_support=1 \
    ro.vendor.mtk_wappush_support=1 \
    ro.vendor.mtk_wfd_support=1 \
    ro.vendor.mtk_widevine_drm_l1_support=1 \
    ro.vendor.pq.mtk_aal_support=1 \
    ro.vendor.pq.mtk_ai_hdr_model_dq=0 \
    ro.vendor.pq.mtk_ai_region_pq_support=0 \
    ro.vendor.pq.mtk_ai_scence_pq_support=0 \
    ro.vendor.pq.mtk_ai_sdr_to_hdr_support=0 \
    ro.vendor.pq.mtk_backlight_smooth_support=0 \
    ro.vendor.pq.mtk_blulight_def_support=1 \
    ro.vendor.pq.mtk_caltm_support=0 \
    ro.vendor.pq.mtk_clearzoom_support=0 \
    ro.vendor.pq.mtk_dc_support=0 \
    ro.vendor.pq.mtk_disp_c3d_support=1 \
    ro.vendor.pq.mtk_disp_ccorr_support=1 \
    ro.vendor.pq.mtk_disp_color_support=1 \
    ro.vendor.pq.mtk_disp_game_pq_support=1 \
    ro.vendor.pq.mtk_disp_gamma_support=1 \
    ro.vendor.pq.mtk_disp_tdshp_support=1 \
    ro.vendor.pq.mtk_dre30_support=1 \
    ro.vendor.pq.mtk_dre_cap=0 \
    ro.vendor.pq.mtk_ds_support=1 \
    ro.vendor.pq.mtk_hdr10_panel_dtmo_support=0 \
    ro.vendor.pq.mtk_hdr10_plus_recording_support=1 \
    ro.vendor.pq.mtk_hfg_support=0 \
    ro.vendor.pq.mtk_libaibld_name=libaibld.nn6.so \
    ro.vendor.pq.mtk_mdp_ccorr_support=0 \
    ro.vendor.pq.mtk_mdp_lite_pq_support=0 \
    ro.vendor.pq.mtk_mml_c3d_support=0 \
    ro.vendor.pq.mtk_mmlpq_support=1 \
    ro.vendor.pq.mtk_pq_interface_support=0 \
    ro.vendor.pq.mtk_pq_video_whitelist_support=0 \
    ro.vendor.pq.mtk_scltm_support=0 \
    ro.vendor.pq.mtk_silky_brigtness_support=0 \
    ro.vendor.pq.mtk_ultra_dimming_support=0 \
    ro.vendor.pq.mtk_ultra_resolution_support=1 \
    ro.vendor.pq.mtk_video_transition=0 \
    ro.vendor.pref_scale_enable_cfg=1 \
    ro.vendor.rc=/vendor/etc/init/hw/ \
    ro.vendor.usb.kpoc_adb=0 \
    ro.vendor.vt_hevc_support=1 \
    ro.vendor.wfd.dummy.enable=0 \
    ro.vendor.wfd.iframesize.level=0 \
    ro.vendor.wifi.sap.concurrent.iface=ap1 \
    ro.vendor.wifi.sap.interface=ap0 \
    ro.vendor.wlan.chrdev=wmt_chrdev_wifi_connac2 \
    ro.vendor.wlan.gen=gen4m_6897 \
    ro.vendor.wlan.standalone.log=y \
    ro.virtual_ab.compression.threads=true \
    ro.virtual_ab.compression.xor.enabled=true \
    vendor.audio.powerhal.power.dl=true \
    vendor.audio.powerhal.power.ul=true \
    vendor.audio.usb.iems.period_us=5000 \
    vendor.audio.usb.super_hifi=true \
    vendor.bluetooth.ldac.abr=true \
    vendor.boostfwk.scroll.policy.mode=1 \
    vendor.boostfwk.version=3 \
    vendor.camera.mdp.cz.enable=1 \
    vendor.camera.mdp.dre.enable=1 \
    vendor.connsys.driver.ready=no \
    vendor.debug.sf.cpupolicy.base_min_bl=314 \
    vendor.debug.sf.cpupolicy.foreground=1 \
    vendor.debug.sf.cpupolicy.hw_comp_suspend=1 \
    vendor.debug.sf.cpupolicy.lowbound_uclamp_min=113 \
    vendor.debug.sf.cpupolicy.max_correct_offset=290 \
    vendor.debug.sf.cpupolicy.min_120=88 \
    vendor.debug.sf.cpupolicy.min_144=113 \
    vendor.debug.sf.cpupolicy.min_30_mml=88 \
    vendor.debug.sf.cpupolicy.min_60=88 \
    vendor.debug.sf.cpupolicy.min_60_mml=88 \
    vendor.debug.sf.cpupolicy.min_90=88 \
    vendor.debug.sf.cpupolicy.min_boost=122 \
    vendor.debug.sf.cpupolicy.power_down_120=600000 \
    vendor.debug.sf.cpupolicy.power_up_120=-600000 \
    vendor.debug.sf.cpupolicy.re_hfr=1 \
    vendor.debug.sf.cpupolicy.rt_bl_min=190 \
    vendor.debug.sf.cpupolicy.sf_cpu_thres=160 \
    vendor.debug.sf.cpupolicy.sus_correct_max=25 \
    vendor.debug.sf.cpupolicy.sus_correct_min=-15 \
    vendor.debug.sf.cpupolicy.upbound_uclamp_max_ll=156 \
    vendor.debug.sf.cpupolicy.upbound_uclamp_min=496 \
    vendor.debug.sf.cpupolicy.upbound_uclamp_ret_sys=152 \
    vendor.debug.sf.cpupolicy.xgf_min=25 \
    vendor.debug.sf.dynamic_duration.app.decouple=20000000 \
    vendor.debug.sf.dynamic_duration.app.early.120=11600000 \
    vendor.debug.sf.dynamic_duration.app.early.60=16600000 \
    vendor.debug.sf.dynamic_duration.app.early.90=14600000 \
    vendor.debug.sf.dynamic_duration.app.early=18000000 \
    vendor.debug.sf.dynamic_duration.app.earlyGl.120=11600000 \
    vendor.debug.sf.dynamic_duration.app.earlyGl.60=16600000 \
    vendor.debug.sf.dynamic_duration.app.earlyGl.90=14600000 \
    vendor.debug.sf.dynamic_duration.app.earlyGl=18000000 \
    vendor.debug.sf.dynamic_duration.app.late.120=11600000 \
    vendor.debug.sf.dynamic_duration.app.late.60=16600000 \
    vendor.debug.sf.dynamic_duration.app.late.90=14600000 \
    vendor.debug.sf.dynamic_duration.app.late=18000000 \
    vendor.debug.sf.dynamic_duration.sf.decouple=27600000 \
    vendor.debug.sf.dynamic_duration.sf.early.120=12300000 \
    vendor.debug.sf.dynamic_duration.sf.early.60=15600000 \
    vendor.debug.sf.dynamic_duration.sf.early.90=13100000 \
    vendor.debug.sf.dynamic_duration.sf.early=14600000 \
    vendor.debug.sf.dynamic_duration.sf.earlyGl.120=12300000 \
    vendor.debug.sf.dynamic_duration.sf.earlyGl.60=15600000 \
    vendor.debug.sf.dynamic_duration.sf.earlyGl.90=13100000 \
    vendor.debug.sf.dynamic_duration.sf.earlyGl=14600000 \
    vendor.debug.sf.dynamic_duration.sf.late.120=12300000 \
    vendor.debug.sf.dynamic_duration.sf.late.60=15600000 \
    vendor.debug.sf.dynamic_duration.sf.late.90=13100000 \
    vendor.debug.sf.dynamic_duration.sf.late=14600000 \
    vendor.debug.sf.dynamic_duration.switch=1 \
    vendor.debug.sf.fbthint=1 \
    vendor.mbrain.build.version= \
    vendor.mtk.camera.app.fd.video=1 \
    vendor.mtk.vdec.decode.error.handle.mode=1 \
    vendor.mtk.vdec.waitkeyframeforplay=9 \
    vendor.performance.frs.tz_name=vtskin-max \
    vendor.video.framework.thumbnail.SurfaceMode=1 \
    persist.adb.nonblocking_ffs=0 \
    persist.sys.dalvik.vm.lib.2=libart.so \
    persist.system.powerhal.applist_enable=1 \
    persist.bluetooth.a2dp_offload.cap=sbc-aac \
    persist.bluetooth.a2dp_offload.disabled=true \
    persist.bluetooth.leaudio_offload.disabled=true \
    persist.vendor.audio.usb.offload=false \
    persist.vendor.bluetooth.broadcaster.enabled=false \
    persist.vendor.bluetooth.broadcaster.tx_pwr=10 \
    persist.vendor.bluetooth.connection_improve=yes \
    persist.vendor.bluetooth.leaudio_mode=off \
    persist.vendor.bluetooth.supportopphdt=no \
    persist.vendor.camera3.pipeline.bufnum.base.imgo=4 \
    persist.vendor.camera3.pipeline.bufnum.base.lcso=4 \
    persist.vendor.camera3.pipeline.bufnum.base.rrzo=4 \
    persist.vendor.camera3.pipeline.bufnum.base.rsso=5 \
    persist.vendor.camera3.pipeline.bufnum.min.high_ram.fdyuv=5 \
    persist.vendor.camera3.pipeline.bufnum.min.high_ram.imgo=7 \
    persist.vendor.camera3.pipeline.bufnum.min.high_ram.lcso=7 \
    persist.vendor.camera3.pipeline.bufnum.min.high_ram.rrzo=6 \
    persist.vendor.camera3.pipeline.bufnum.min.high_ram.rsso=7 \
    persist.vendor.camera3.pipeline.bufnum.min.low_ram.fdyuv=5 \
    persist.vendor.camera3.pipeline.bufnum.min.low_ram.imgo=6 \
    persist.vendor.camera3.pipeline.bufnum.min.low_ram.lcso=6 \
    persist.vendor.camera3.pipeline.bufnum.min.low_ram.rrzo=6 \
    persist.vendor.camera3.pipeline.bufnum.min.low_ram.rsso=6 \
    persist.vendor.connsys.chipid=-1 \
    persist.vendor.connsys.dynamic.dump=0 \
    persist.vendor.connsys.fm_chipid=connac2x \
    persist.vendor.connsys.patch.version=-1 \
    persist.vendor.factory.GB2312=yes \
    persist.vendor.sys.pq.disp.ccorr.silky.brightness=0 \
    persist.vendor.sys.pq.disp.gamma.silky.brightness=0 \
    persist.vendor.sys.pq.disp_gamma_silky_brightness_by_hwc=0 \
    persist.vendor.sys.pq.mtk_disp_clarity_support=0 \
    persist.log.tag.MTK_APPList=I \
    persist.log.tag.PowerHalAddressUitls=I \
    persist.log.tag.PowerHalMgrImpl=I \
    persist.log.tag.PowerHalMgrServiceImpl=I \
    persist.log.tag.PowerHalWifiMonitor=I \
    persist.log.tag.UxUtility=I \
    persist.log.tag.libPowerHal=I \
    persist.log.tag.mipc_lib=I \
    persist.log.tag.mtkpower_client=I \
    persist.log.tag.trm_lib=I
