# Mac 最终方案：微信输入法 + BlackHole 2ch + Fn

适用：Apple Silicon Mac / macOS 14+（实机 M1 / 15.5）、G9N9N 家族 `18D1:9450`。Windows 用户请看 `windows/完整指南.md`。

## 最终链路

```text
G9N9N 语音键 → BLE ATVV → Google Remote Voice（本机解码）
→ BlackHole 2ch → 微信输入法「语音输入」→ 当前文本框中文上屏

G9N9N 普通键 → BLE HID → 按 18D1:9450 独占的 IOHIDManager → Mac 快捷键
```

语音键发送裸 `Fn`（keycode `0x3F`）；微信输入法语音输入选 `BlackHole 2ch` 麦克风、按住说话选 `Fn`。系统默认麦克风/扬声器保持不变，系统听写和语音控制关闭。

## 文件

- 固定上游：`zolo1978/google-remote-voice-mac` @ `9f86c378b81c80d2cdaa22589fc0d5c324b7bfdd`（MIT）。
- 补丁：`patches/mac-verified-final.patch`，SHA256 `a0c2c685312af7ba1c984e08af96d97f3c7e0543336e68bf1f9cbd774ad7ffb6`。
- Finder 双击入口：`mac/安装G9N9N-Mac.command`（也可在干净 checkout 应用补丁后使用工程内同名文件）。
- 只读自检：`scripts/check-mac-runtime.sh`（也可在补丁应用后于工程 `scripts/` 下使用）。
- BlackHole 2ch 0.7.1：从 [官方下载页](https://existential.audio/blackhole) 获取，SHA256 `57b540f27a3e29c37e310e01bee0fdfab76733087e47f997ef9dccf851400dcf`；官方项目 [ExistentialAudio/BlackHole](https://github.com/ExistentialAudio/BlackHole)，GPL-3.0。安装器不随本仓库分发。
- 微信输入法：[官方入口](https://z.weixin.qq.com/)，按腾讯官方许可使用。

## 执行顺序

```sh
git clone https://github.com/zolo1978/google-remote-voice-mac.git g9n9n-mac
cd g9n9n-mac
git checkout --detach 9f86c378b81c80d2cdaa22589fc0d5c324b7bfdd
git apply --check /path/to/patches/mac-verified-final.patch
git apply /path/to/patches/mac-verified-final.patch

sh scripts/run-tests.sh
zsh -n install.sh scripts/check-mac-runtime.sh
./install.sh
sh scripts/check-mac-runtime.sh
```

`install.sh` 要求 `downloads/BlackHole2ch-0.7.1.pkg` 或 `BLACKHOLE_PKG` 环境变量；它会核对 SHA256 与 Apple 开发者签名。BlackHole 已安装时跳过驱动安装。编译结果只写到 `/Applications/Google Remote Voice.app`；脚本不会替换现有验签通过的 `0.2.0`，以免重置 TCC 权限。

应用装好后，机主本人完成：蓝牙连接、权限授权、关闭系统听写、微信输入法麦克风/快捷键设置、真实中文上屏测试。详见 `docs/单文件指南.md` 第 3.3 节。

## 自动验证的边界

干净 checkout 上已验证：`git apply --check`、shell 语法、`103/103 + 46/46 + 8/8 + 83/83 + 8/8 + 8 Python` 定向测试、临时目录 `build.sh` 与 `codesign`。现用 Mac 的只读自检全部 OK；机主已确认真实中文上屏、不是假阳性。基础普通键的真实报告已收到，**逐键全量映射未验收**，不要写成全键完成。

## 不要回到历史弯路

Handy、Qwen3-ASR 模型、右 Command、PacketLogger/root 助手都是探索过程，不是最终依赖。详见 `docs/来源与许可.md` 与补丁内 `docs/HANDY.md` 的历史说明。
