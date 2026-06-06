# OpenWrt — GitHub Actions 自动编译

利用 GitHub Actions 自动编译定制化的 OpenWrt 固件。你只需修改配置文件并推送代码，固件就会在 GitHub 服务器上自动编译。

## 🚀 快速上手

### 1. 推送到 GitHub

```bash
cd openwrt
git init
git add .
git commit -m "init: OpenWrt build repo"
git remote add origin https://github.com/YOUR_USERNAME/openwrt-build.git
git push -u origin main
```

### 2. 选择编译方式

本仓库提供 **两套编译方案**，可在 GitHub 仓库的 **Actions** 标签页中手动触发：

| 方案 | Workflow | 耗时 | 适用场景 |
|------|----------|------|----------|
| **完整源码编译** | `Build OpenWrt (Full Source)` | 2-3 小时 | 深度定制（改内核、改编译选项、自定义 patch） |
| **快速 ImageBuilder** | `Build OpenWrt (ImageBuilder)` | 15-30 分钟 | 快速迭代（仅增删软件包，不涉及内核修改） |

### 3. 触发编译

1. 打开 GitHub 仓库 → **Actions** 标签
2. 左侧选择 `Build OpenWrt (Full Source)` 或 `Build OpenWrt (ImageBuilder)`
3. 点击 **Run workflow** 按钮
4. 根据需要修改参数，点击绿色 **Run workflow** 开始

### 4. 下载固件

编译完成后，在对应的 workflow run 页面底部 **Artifacts** 区域下载固件文件。

## 📁 仓库结构

```
├── .github/workflows/
│   ├── build-full.yml          # 完整源码编译 Workflow
│   └── build-imagebuilder.yml  # ImageBuilder 快速编译 Workflow
├── configs/                    # 存放不同设备的 .config 文件
│   └── x86-64.config           # 示例: x86_64 平台配置
├── scripts/
│   ├── diy-part1.sh            # 编译前: 修改源码、打补丁、添加 feeds
│   └── diy-part2.sh            # 编译前: 修改 .config、增删包、预设配置
├── files/                      # 自定义文件 (目录结构保持与固件一致)
│   └── etc/
│       └── config/
│           └── custom_config   # 示例占位文件
├── feeds.conf                  # 自定义 feeds 源 (覆盖 OpenWrt 默认)
└── .gitignore
```

## ⚙️ 配置说明

### 选择目标设备

1. 在本地安装 OpenWrt 编译依赖，然后生成 `.config`：

```bash
# 克隆 OpenWrt 源码
git clone https://github.com/openwrt/openwrt
cd openwrt

# 更新 feeds
./scripts/feeds update -a
./scripts/feeds install -a

# 用图形界面选择目标设备和软件包
make menuconfig

# 保存为 .config 文件
cp .config ../configs/my-device.config
```

2. 将 `.config` 文件放入 `configs/` 目录
3. 在 GitHub Actions 触发时，在 `config_file` 参数中指定文件路径

### 添加第三方软件包

编辑 `feeds.conf`，取消注释需要的第三方源：

```
# PassWall
src-git passwall https://github.com/xiaorouji/openwrt-passwall.git;main
```

然后添加对应的包到 `.config` 或在 `diy-part2.sh` 中添加：

```bash
echo "CONFIG_PACKAGE_luci-app-passwall=y" >> openwrt/.config
```

### 添加自定义文件到固件

在 `files/` 目录下按固件目录结构放置文件。例如：

```
files/
├── etc/
│   ├── config/
│   │   └── network          # 预设网络配置
│   └── dropbear/
│       └── authorized_keys  # 预设 SSH 公钥
└── usr/
    └── bin/
        └── my-script.sh     # 自定义脚本
```

## 🎯 常用平台参考

| 目标 | 架构 | 典型设备 |
|------|------|----------|
| `x86/64` | x86_64 | 软路由、虚拟机、PC |
| `armsr/armv8` | ARM64 | ARM 软路由、RPi CM4 |
| `ath79/generic` | MIPS | TP-Link Archer C7 |
| `ipq40xx/generic` | ARM | 竞斗云2.0、GL.iNet GL-B1300 |
| `mediatek/filogic` | ARM64 | 红米 AX6000、TP-Link XDR6088 |
| `rockchip/armv8` | ARM64 | NanoPi R4S/R5S、Orange Pi 5 |
| `bcm27xx/bcm2712` | ARM64 | Raspberry Pi 5 |

## 🔧 自定义脚本

### diy-part1.sh — 源码级别修改

在 feeds 更新前运行，适合：
- 添加额外的 feed 源
- 打补丁修改源码
- 修改默认配置

```bash
# 修改默认路由器 IP
sed -i 's/192.168.1.1/192.168.2.1/g' openwrt/package/base-files/files/bin/config_generate
```

### diy-part2.sh — 编译选项修改

在 `.config` 文件就位后运行，适合：
- 增删软件包
- 修改分区大小
- 预设配置文件到 `openwrt/files/`

```bash
# 添加软件包
cd openwrt
echo "CONFIG_PACKAGE_luci-theme-argon=y" >> .config
echo "CONFIG_TARGET_ROOTFS_PARTSIZE=1024" >> .config
```

## 📦 编译产物

编译完成后，在 Actions Artifacts 中可下载：

| 文件 | 说明 |
|------|------|
| `*-ext4-combined.img.gz` | EXT4 分区镜像 |
| `*-squashfs-combined.img.gz` | SquashFS 分区镜像 |
| `*-vmdk.vmdk` | VMware 虚拟磁盘 |
| `*.iso` | 可引导 ISO |

## 💡 常见问题

### 编译失败怎么办？

1. 查看 workflow run 的日志输出
2. 下载 `Build_Log_*` artifact 查看详细错误
3. 确保 .config 文件与源码版本兼容
4. 常见原因：网络下载失败、包版本冲突、config 缺少必要依赖

### 如何加速编译？

- **首次编译**: 2-3 小时，无法跳过
- **后续编译**: 自动启用 ccache 缓存，可节省 50-70% 时间
- 使用 **ImageBuilder** 方案只需 15-30 分钟

### 可以使用其他源码仓库吗？

可以！在完整源码编译的 `repo_url` 参数中输入任意 OpenWrt 源码仓库：

| 仓库 | URL |
|------|-----|
| 官方主线 | `https://github.com/openwrt/openwrt` |
| Lean 固件 | `https://github.com/coolsnowwolf/lede` |
| ImmortalWrt | `https://github.com/immortalwrt/immortalwrt` |

## 📄 License

MIT License
