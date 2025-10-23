# 王者荣耀快速充值助手 (WangZhe Helper)

一个用于王者荣耀的 iOS 越狱插件，可以快速充值点券，跳过繁琐的广告弹窗。

## ✨ 功能特性

- 🎮 **悬浮按钮**: 在游戏中显示可拖动的悬浮按钮
- 💎 **快速充值**: 点击按钮即可快速选择充值档位，一键支付
- 🚫 **自动关闭广告**: 可选择自动关闭游戏内的广告弹窗
- ⚙️ **灵活配置**: 通过设置面板自定义插件行为
- 🔒 **安全支付**: 使用官方 StoreKit API，安全可靠

## 📋 支持的充值档位

- 60 点券 (¥6)
- 450 点券 (¥45)
- 900 点券 (¥90)
- 1800 点券 (¥180)
- 3000 点券 (¥300)
- 6000 点券 (¥600)

## 🔧 环境要求

- 已越狱的 iOS 设备 (iOS 11.0+)
- 已安装 Cydia Substrate / Substitute
- 已安装 PreferenceLoader
- 开发编译需要 Theos 环境

## 📦 安装方法

### 方法一: 通过 deb 包安装

1. 下载最新的 `.deb` 文件
2. 使用 Filza 或其他文件管理器打开
3. 点击安装
4. 注销或重启设备

### 方法二: 从源代码编译

```bash
# 克隆仓库
git clone https://github.com/yourusername/wangzhehelper.git
cd wangzhehelper

# 设置 Theos 环境 (如果没有设置)
export THEOS=/opt/theos

# 编译
make clean
make

# 打包
make package

# 安装到已连接的设备 (需要通过 SSH)
make install THEOS_DEVICE_IP=设备IP THEOS_DEVICE_PORT=22
```

## 🎯 使用说明

### 基本使用

1. 安装插件后，打开王者荣耀
2. 等待几秒钟，屏幕右侧会出现一个蓝色的 💎 悬浮按钮
3. 点击悬浮按钮打开充值面板
4. 选择要充值的档位
5. 确认购买并完成支付

### 悬浮按钮操作

- **点击**: 打开充值面板
- **拖动**: 移动按钮位置，松手后会自动贴边
- 按钮可以在设置中开启/关闭

### 设置选项

在 iOS 设置 → 王者助手中可以配置：

- **启用插件**: 总开关，关闭后插件不工作
- **显示悬浮按钮**: 控制是否显示悬浮按钮
- **自动关闭广告弹窗**: 自动关闭检测到的广告弹窗
- **按钮透明度**: 调整悬浮按钮的透明度 (0.3-1.0)

## 🛠️ 开发说明

### 项目结构

```
wangzhehelper/
├── Tweak.x                    # 主要 Hook 代码
├── Makefile                   # 编译配置
├── control                    # deb 包信息
├── WangZheHelper.plist       # Bundle 过滤器
├── wzhelperprefs/            # 设置界面 Bundle
│   ├── Makefile
│   ├── WZHelperPrefsRootListController.m
│   ├── Resources/
│   │   └── Root.plist
│   └── entry.plist
└── README.md
```

### 核心技术

- **Theos**: iOS 越狱开发框架
- **Cydia Substrate**: Hook 框架
- **StoreKit**: 苹果官方应用内购买 API
- **PreferenceLoader**: 设置面板加载器

### Hook 原理

插件通过 Hook `UIWindow` 的 `makeKeyAndVisible` 方法来注入悬浮按钮，并使用 StoreKit 框架直接调用苹果的 IAP API 进行充值。

### 自定义修改

如果需要修改充值档位或添加新功能：

1. 编辑 `Tweak.x` 中的 `setupRechargeOptions` 方法
2. 修改产品 ID 和价格信息
3. 重新编译安装

```objective-c
NSArray *products = @[
    @{@"title": @"60点券", @"productId": @"com.tencent.smoba60_60", @"price": @6.0},
    // 添加更多档位...
];
```

## 🔍 调试方法

### 查看日志

通过 SSH 连接到设备，查看系统日志：

```bash
# 实时查看日志
ssh root@设备IP
tail -f /var/log/syslog | grep WZHelper

# 或使用 Console.app (macOS)
# 连接设备后搜索 "WZHelper"
```

### 常见问题

**Q: 悬浮按钮没有出现？**
- 检查设置中是否启用了插件
- 确认已重启过 SpringBoard 或设备
- 查看系统日志是否有报错

**Q: 点击充值没有反应？**
- 确认设备已登录 Apple ID
- 检查网络连接
- 确认产品 ID 是否正确

**Q: 编译失败？**
- 确认已正确安装 Theos
- 检查 iOS SDK 版本
- 运行 `make clean` 后重新编译

## 🔒 安全说明

- 本插件使用苹果官方的 StoreKit API，不涉及任何破解或修改游戏逻辑
- 所有支付流程通过苹果服务器完成，安全可靠
- 插件仅用于学习交流，请勿用于非法用途
- 使用插件产生的任何后果由用户自行承担

## ⚠️ 免责声明

1. 本插件仅供学习和研究 iOS 越狱开发技术使用
2. 使用本插件可能违反王者荣耀的服务条款
3. 使用本插件可能导致账号被封禁等风险
4. 作者不对使用本插件造成的任何损失负责
5. 请在法律允许的范围内使用本插件

## 📝 更新日志

### v1.0.0 (2025-10-23)

- 🎉 首次发布
- ✨ 支持悬浮按钮快速充值
- ✨ 支持 6 种充值档位
- ✨ 可选的自动关闭广告功能
- ⚙️ 完整的设置界面

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

如果你有任何建议或发现了 bug，请在 GitHub 上提交 Issue。

## 📄 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 👤 作者

- GitHub: [@yourusername](https://github.com/yourusername)
- Twitter: [@yourhandle](https://twitter.com/yourhandle)

## 🙏 致谢

- [Theos](https://theos.dev/) - iOS 越狱开发框架
- [Cydia Substrate](http://www.cydiasubstrate.com/) - Hook 框架
- 感谢所有为 iOS 越狱社区做出贡献的开发者

---

**⚡ 如果这个项目对你有帮助，请给一个 Star ⭐**

