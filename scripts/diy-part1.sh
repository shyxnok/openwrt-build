#!/bin/bash
# =============================================================================
# DIY Part 1 — 在 feeds 更新之前执行（源码级别修改）
# =============================================================================
# 此脚本在 OpenWrt 源码 clone 完成后、feeds 更新之前运行。
# 修改 openwrt/ 目录下的源码文件。
# =============================================================================

set -e

echo "============================================"
echo "  DIY Part 1 — Source-Level Customization"
echo "============================================"

# ---- 修改默认路由器 IP (192.168.1.1 → 192.168.2.1) ----
sed -i 's/192.168.1.1/192.168.2.1/g' openwrt/package/base-files/files/bin/config_generate
echo ">> Default router IP changed to 192.168.2.1"

# ---- 修改默认主机名 ----
# sed -i "s/hostname='OpenWrt'/hostname='MyRouter'/g" openwrt/package/base-files/files/bin/config_generate

# ---- 修改默认时区 ----
# sed -i "s/timezone='UTC'/timezone='CST-8'/g" openwrt/package/base-files/files/bin/config_generate
# sed -i "s/zonename='UTC'/zonename='Asia\/Shanghai'/g" openwrt/package/base-files/files/bin/config_generate

# ---- 添加自定义 feed 源 ----
# echo "src-git myfeed https://github.com/myuser/myfeed.git;main" >> openwrt/feeds.conf.default

echo "DIY Part 1 complete."
