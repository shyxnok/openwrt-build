#!/bin/bash
# =============================================================================
# DIY Part 2 — 在 make defconfig 之前执行（.config 修改）
# =============================================================================
# 用途：增删软件包、修改分区大小、添加内核模块、预设文件。
# =============================================================================

set -e

echo "============================================"
echo "  DIY Part 2 — Config Customization"
echo "============================================"

cd openwrt

# =========================================================================
# 1. 增加软件包
# =========================================================================
cat >> .config << 'EOF'

# ---- 基础工具 ----
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_lsblk=y
CONFIG_PACKAGE_iperf3=y

# ---- LuCI 中文界面 ----
CONFIG_PACKAGE_luci-i18n-base-zh-cn=y
EOF

# =========================================================================
# 2. 修改默认主题（argon — 简洁现代）
# =========================================================================
cat >> .config << 'EOF'

# ---- 默认主题 ----
CONFIG_PACKAGE_luci-theme-argon=y
CONFIG_PACKAGE_luci-theme-argon-config=y
EOF

# =========================================================================
# 3. 修改分区大小（x86 适用，单位 MB）
# =========================================================================
cat >> .config << 'EOF'

# ---- 分区大小 ----
CONFIG_TARGET_KERNEL_PARTSIZE=64
CONFIG_TARGET_ROOTFS_PARTSIZE=1024
EOF

# =========================================================================
# 4. 添加内核模块
# =========================================================================
cat >> .config << 'EOF'

# ---- USB 支持 ----
CONFIG_PACKAGE_kmod-usb3=y
CONFIG_PACKAGE_kmod-usb-storage=y
CONFIG_PACKAGE_kmod-usb-storage-extras=y

# ---- 文件系统 ----
CONFIG_PACKAGE_kmod-fs-ext4=y
CONFIG_PACKAGE_kmod-fs-exfat=y
CONFIG_PACKAGE_kmod-fs-ntfs=y
CONFIG_PACKAGE_kmod-fs-vfat=y

# ---- 网络 ----
CONFIG_PACKAGE_kmod-wireguard=y
CONFIG_PACKAGE_wireguard-tools=y
CONFIG_PACKAGE_kmod-tun=y

# ---- Docker 支持（如需 Docker 取消注释）----
# CONFIG_PACKAGE_kmod-veth=y
# CONFIG_PACKAGE_kmod-br-netfilter=y
# CONFIG_PACKAGE_kmod-nf-nat6=y
EOF

# =========================================================================
# 5. 预设网络配置 (IP: 192.168.2.1)
# =========================================================================
mkdir -p files/etc/config
cat > files/etc/config/network << 'NETEOF'
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config globals 'globals'
	option ula_prefix 'fd00::/48'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.2.1'
	option netmask '255.255.255.0'
	option ip6assign '60'
NETEOF

echo "DIY Part 2 complete."
