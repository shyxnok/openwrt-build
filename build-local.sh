#!/bin/bash
# =============================================================================
# Local Build Script — macOS 上用 Docker 编译 OpenWrt
# =============================================================================
# Usage: bash build-local.sh [config-file]
# 示例: bash build-local.sh configs/x86-64.config
# 首次编译拉取 Ubuntu 镜像 + 编译约 2-3 小时。
# 产物输出到 bin/targets/ 目录。
# =============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$SCRIPT_DIR"
BIN_DIR="$WORK_DIR/bin"
CONFIG_FILE="${1:-configs/x86-64.config}"

echo "============================================"
echo " OpenWrt Local Build (Docker)"
echo " Config: $CONFIG_FILE"
echo "============================================"

mkdir -p "$BIN_DIR"

docker run --rm \
  --platform linux/amd64 \
  -v "$WORK_DIR":/build:rw \
  -v "$BIN_DIR":/output:rw \
  -e TZ=Asia/Shanghai \
  -e DEBIAN_FRONTEND=noninteractive \
  ubuntu:24.04 \
  bash -c "
set -e

echo '>> Installing build dependencies...'
apt-get update -qq
apt-get install -y -qq \
  ack antlr3 asciidoc autoconf automake autopoint binutils bison \
  build-essential bzip2 ccache clang cmake cpio curl device-tree-compiler \
  fastjar flex gawk gcc-multilib g++-multilib gettext genisoimage \
  git gperf haveged help2man intltool libc6-dev-i386 libelf-dev \
  libfuse-dev libglib2.0-dev libgmp-dev libltdl-dev libmpc-dev libmpfr-dev \
  libgnutls28-dev libncurses-dev libpython3-dev libreadline-dev \
  libssl-dev libtool libyaml-dev lld llvm lrzsz msmtp \
  nano ninja-build p7zip p7zip-full patch pkgconf python3 \
  python3-ply python3-pyelftools python3-setuptools python3-venv \
  qemu-utils quilt re2c rsync scons squashfs-tools subversion swig \
  texinfo unzip upx-ucl vim wget xmlto xxd zlib1g-dev zstd \
  2>/dev/null
apt-get autoremove -y -qq

ccache --set-config=max_size=2G
ccache --set-config=compression=true
ccache -z

echo '>> Cloning OpenWrt source...'
cd /build
git clone https://github.com/openwrt/openwrt --depth=1 -b main openwrt

echo '>> Applying custom configurations...'
cd openwrt

# Append custom feeds (filter valid src- lines only)
if [ -f /build/feeds.conf ]; then
  CUSTOM_FEEDS=\$(grep -E '^src-' /build/feeds.conf || true)
  if [ -n \"\$CUSTOM_FEEDS\" ]; then
    echo \"\" >> feeds.conf.default
    echo \"\$CUSTOM_FEEDS\" >> feeds.conf.default
    echo '>> Custom feeds appended'
  fi
fi

# Run diy-part1
if [ -x /build/scripts/diy-part1.sh ]; then
  cd /build
  bash /build/scripts/diy-part1.sh
  cd /build/openwrt
fi

# Copy custom files
if [ -d /build/files ] && [ \"\$(ls -A /build/files 2>/dev/null)\" ]; then
  cp -rf /build/files files
fi

# Update and install feeds
echo '>> Updating feeds...'
./scripts/feeds update -a
./scripts/feeds install -a

# Apply .config
if [ -f /build/\$CONFIG_FILE ]; then
  cp /build/\$CONFIG_FILE .config
else
  echo \"ERROR: Config file not found: \$CONFIG_FILE\"
  exit 1
fi

# Run diy-part2
if [ -x /build/scripts/diy-part2.sh ]; then
  cd /build
  bash /build/scripts/diy-part2.sh
  cd /build/openwrt
fi

echo '>> Preparing build...'
make defconfig

echo '>> Downloading packages...'
make download -j\$(nproc) V=s

echo '>> Compiling firmware...'
make -j\$(nproc) V=s || make -j1 V=s

echo '>> Copying firmware to output...'
rm -rf /output/targets
cp -r bin/targets /output/

echo '>> Build complete!'
find /output -type f \
  \\( -name '*.img.gz' -o -name '*.vmdk' -o -name '*.vdi' -o -name '*.iso' \\) \
  -exec ls -lh {} \\;
"

echo ""
echo "============================================"
echo " Build finished!"
echo " Firmware: bin/targets/x86/64/"
echo "============================================"
ls -lh bin/targets/x86/64/ 2>/dev/null || echo "(firmware in bin/targets/)"
