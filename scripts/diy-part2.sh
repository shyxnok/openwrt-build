#!/bin/bash
# =============================================================================
# DIY Part 2 — 在生成 .config 之前执行
# =============================================================================
# 此脚本在 .config 文件复制到 openwrt/ 目录之后、make defconfig 之前运行。
# 用途：
#   1. 修改 .config 中的编译选项（增删包、修改分区大小等）
#   2. 补充默认设置文件
#   3. 最后的编译前调整
#
# 注意：OpenWrt 源码在 ./openwrt/ 目录下。
# =============================================================================

set -e

echo "============================================"
echo "  DIY Part 2 — Pre-Compile Customization"
echo "============================================"

# ---- 示例：添加软件包到固件 ----
# cd openwrt
# echo "CONFIG_PACKAGE_luci=y" >> .config
# echo "CONFIG_PACKAGE_luci-i18n-base-zh-cn=y" >> .config

# ---- 示例：修改路由器默认 IP ----
# sed -i 's/192.168.1.1/192.168.2.1/g' openwrt/package/base-files/files/bin/config_generate

# ---- 示例：修改默认主题 ----
# cd openwrt
# echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config

# ---- 示例：修改分区大小 (x86) ----
# cd openwrt
# echo "CONFIG_TARGET_ROOTFS_PARTSIZE=1024" >> .config    # RootFS 大小 (MB)

# ---- 示例：添加内核模块 ----
# cd openwrt
# echo "CONFIG_PACKAGE_kmod-usb3=y" >> .config
# echo "CONFIG_PACKAGE_kmod-fs-ext4=y" >> .config

# ---- 示例：添加包列表 ----
# cd openwrt
# cat >> .config << 'CONFIGEOF'
# CONFIG_PACKAGE_curl=y
# CONFIG_PACKAGE_htop=y
# CONFIG_PACKAGE_nano=y
# CONFIG_PACKAGE_iperf3=y
# CONFIGEOF

# ---- 示例：预设网络配置 ----
# mkdir -p openwrt/files/etc/config
# cat > openwrt/files/etc/config/network << 'EOF'
# config interface 'lan'
#     option type 'bridge'
#     option ifname 'eth0'
#     option proto 'static'
#     option ipaddr '192.168.1.1'
#     option netmask '255.255.255.0'
#     option ip6assign '60'
# EOF

cd openwrt 2>/dev/null || true
echo "DIY Part 2 complete."
