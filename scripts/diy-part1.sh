#!/bin/bash
# =============================================================================
# DIY Part 1 — 在 feeds 更新之前执行
# =============================================================================
# 此脚本在 OpenWrt 源码 clone 完成后、feeds 更新之前运行。
# 用途：
#   1. 添加/修改 feeds 源
#   2. 打补丁修改源码
#   3. 替换/删除特定文件
#   4. 修改编译工具链设置
#
# 注意：此脚本在仓库根目录执行，OpenWrt 源码在 ./openwrt/ 目录下。
# =============================================================================

set -e

echo "============================================"
echo "  DIY Part 1 — Pre-Feed Customization"
echo "============================================"

# ---- 示例：添加自定义 feed ----
# echo "src-git myfeed https://github.com/myuser/myfeed.git;main" >> openwrt/feeds.conf.default

# ---- 示例：修改默认路由器 IP ----
# sed -i 's/192.168.1.1/192.168.2.1/g' openwrt/package/base-files/files/bin/config_generate

# ---- 示例：打补丁 ----
# cd openwrt
# patch -p1 < ../patches/my-custom-patch.patch
# cd ..

# ---- 示例：替换 DTS 文件 ----
# cp custom-files/my-device.dts openwrt/target/linux/ath79/dts/

echo "DIY Part 1 complete."
