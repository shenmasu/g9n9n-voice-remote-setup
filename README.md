# G9N9N 语音 coding 遥控器接入方案（Windows + Apple Silicon Mac）

> 由 **鹤竹子（竹子）** 整理、实机验证并公开的接入方案。目标是把 Google Chromecast Voice Remote（G9N9N 家族）当作电脑的**语音输入键 + 可映射快捷键遥控器**。

这不是 Google、Apple、腾讯或任何上游项目的官方产品；本仓库只整理已实测的成功路径、固定版本、补丁、来源和验收边界。请把这份仓库链接或 `docs/单文件指南.md` 交给自己的 Agent，让它按对应系统一步一步配置。单文件指南末尾内嵌两份完整补丁，发给朋友时不需要再附私有工程文件。

公开仓库：`https://github.com/shenmasu/g9n9n-voice-remote-setup`。拿到地址后可直接：

```sh
git clone https://github.com/shenmasu/g9n9n-voice-remote-setup.git
cd g9n9n-voice-remote-setup
# 先读 AGENTS.md 与 docs/单文件指南.md，再选 Windows 或 Mac 路线
```


## 两条路线，选一条

| 系统 | 已验证环境 | 语音链路 | 普通键链路 |
| --- | --- | --- | --- |
| Windows 10/11 | Windows 10 22H2 `19045`、BLE、Python 3.14 x64 | G9N9N ATVV → 无线麦Mod → VB-CABLE → 微信输入法 | 设备专属 HID → Windows 快捷键 |
| Apple Silicon Mac | M1、macOS 15.5 `24F74`（要求 macOS 14+） | G9N9N ATVV → Google Remote Voice → BlackHole 2ch → 微信输入法 | IOHIDManager 独占 `18D1:9450` → Mac 快捷键 |

**不要混用两套驱动和补丁。** G9N9N 按单主机手动切换设计，不承诺 Windows 与 Mac 同时连接；切换主机后可能需要重新配对，但应用配置可保留。

两者都已由机主本人确认「按住语音键说话，文本输入框出现真实中文」。Windows 端还逐项验收过基础 coding 映射和音量键；Mac 端基础普通键已收到真实三字节报告，**逐键全量映射未做完整验收**。没有把「蓝牙已连接」「订阅成功」「电平跳动」或自动测试当作最终完成。

## 直接开始

只给 Agent 一个文件也行：[`docs/单文件指南.md`](docs/单文件指南.md)。它把 Windows 与 Mac 的步骤、固定提交、**两份完整补丁**、权限边界和验收方法写在一起；仓库里的 `AGENTS.md` 是更短的操作总入口。

按系统阅读：

- Windows：[`windows/完整指南.md`](windows/完整指南.md)（自包含，补丁也内嵌在文档末尾）；补丁与依赖另见 [`patches/windows-verified-fix.patch`](patches/windows-verified-fix.patch) 和 [`windows/requirements-verified.txt`](windows/requirements-verified.txt)。
- Mac：[`docs/Mac-微信输入法方案.md`](docs/Mac-微信输入法方案.md)；补丁见 [`patches/mac-verified-final.patch`](patches/mac-verified-final.patch)，双击入口见 [`mac/安装G9N9N-Mac.command`](mac/安装G9N9N-Mac.command)。

把仓库地址直接交给 Agent 时，可附这句话：

> 请先完整阅读此仓库的 `AGENTS.md` 和 `docs/单文件指南.md`，确认我用的是 Windows 还是 Apple Silicon Mac，再只执行对应路线。直接克隆仓库使用其中补丁；如果是单独发给你的 Markdown，就从末尾内嵌补丁提取。所有系统授权、配对、管理员密码、物理按键和最终中文上屏由我本人操作；不要改系统默认音频、不要安装 Handy 或其他历史候选、不要上传我的个人配置或录音。完成后分层报告自动测试、真机证据与未完成边界。

Agent 必须遵守的边界：只使用朋友自己电脑上的新工程目录；不复制本仓库作者的 MAC、Container ID、活动设备 key、MMKV、日志、录音或个人配置；不替机主点击系统授权弹窗；不改系统默认麦克风/扬声器；不禁用蓝牙/HID 栈；不自动重启或解除配对；不使用全局低级键盘钩子；不影响现有键鼠。需要机主配合的步骤必须明确叫人。

## 固定版本与校验

| 平台 | 固定源码 | 补丁 | 依赖 |
| --- | --- | --- | --- |
| Windows | `BenjmSek/windows-remote-mic-app` @ `53fa07eb92d4332c202b5351e9b36044c88917b3` | SHA256 `63aa908d0f8baac62f1355290b9c71383103ab7d7d22c87e3ff6698178ee8682` | [`windows/requirements-verified.txt`](windows/requirements-verified.txt)，SHA256 `1c0fe47eceabd44928cb445af8a99e142ee6a704c3b881bfd6be90ed7b43a82a` |
| Mac | `zolo1978/google-remote-voice-mac` @ `9f86c378b81c80d2cdaa22589fc0d5c324b7bfdd` | SHA256 `a0c2c685312af7ba1c984e08af96d97f3c7e0543336e68bf1f9cbd774ad7ffb6` | BlackHole 2ch `0.7.1` 官方 PKG SHA256 `57b540f27a3e29c37e310e01bee0fdfab76733087e47f997ef9dccf851400dcf` |

Mac 补丁已在一台干净上游 checkout 上验证：`git apply --check` 通过，shell 语法通过，定向测试 `103/103 + 46/46 + 8/8 + 83/83 + 8/8 + 8 Python` 通过，临时目录编译与验签通过；**测试绿不等于真机验收**。

## 这套方案里，每个工具做什么

| 工具 / 项目 | 来源 | 许可证 | 本方案中的用途 |
| --- | --- | --- | --- |
| Windows 无线麦Mod（Chromecast 剥离版） | [`BenjmSek/windows-remote-mic-app`](https://github.com/BenjmSek/windows-remote-mic-app) | GPL-3.0-only（见上游 `LICENSE.md` / `NOTICE.md`） | Windows 端读取 ATVV 音频、HID 报告，输出虚拟声卡并映射按键 |
| 上游无线麦 | [`ZSTDJan/windows-remote-mic-app`](https://github.com/ZSTDJan/windows-remote-mic-app) | GPL-3.0 | Windows 修改版的原始项目；补丁基线按固定提交使用 |
| ATVVoice 协议研究 | [`b0o/ATVVoice`](https://github.com/b0o/ATVVoice) | MIT | G9N9N ATVV 语音协议参考，不单独运行 |
| Google Remote Voice | [`zolo1978/google-remote-voice-mac`](https://github.com/zolo1978/google-remote-voice-mac) | MIT | Mac 端解码 ATVV、按 VID/PID 独占 HID、映射普通键 |
| mi-remote-mapper | [`81199000/mi-remote-mapper`](https://github.com/81199000/mi-remote-mapper) | MIT | Google Remote Voice 的 Swift 菜单栏应用与映射基础 |
| BlackHole 2ch | [ExistentialAudio/BlackHole](https://github.com/ExistentialAudio/BlackHole) · [官方下载页](https://existential.audio/blackhole) | GPL-3.0；其他用途请按项目说明联系作者 | Mac 端把遥控器解码音频变成可单独选择的虚拟输入设备 |
| VB-CABLE | [VB-Audio 官网](https://vb-audio.com/Cable/) | 按 VB-Audio 官方许可 | Windows 端虚拟音频线；只从官网下载 |
| 微信输入法 WeType | [官方入口](https://z.weixin.qq.com/) | 按腾讯官方许可 | 两端的中文语音识别与文字上屏；不需要付费 API Key |
| Xcode Command Line Tools | Apple | Apple 许可 | Mac 端编译 Swift 应用 |

完整出处、修改声明、历史弯路和授权边界见 [`docs/来源与许可.md`](docs/来源与许可.md)。本仓库不分发 Windows 无线麦上游完整源码、VB-CABLE、BlackHole PKG、微信输入法、Handy、本地识别模型、Apple PacketLogger 或任何个人配置/录音；通过固定提交和补丁重建修改版源码。

## 历史弯路（不要重复安装）

Mac 端探索过 `Handy 0.10.0 + Qwen3-ASR 本地模型 + 右 Command`；Windows 端探索过多个候选桥接程序。它们帮助定位了问题，但**不是最终链路**。最终两端都使用微信输入法完成语音识别：Mac 用 BlackHole 2ch + Fn，Windows 用 VB-CABLE + Ctrl+Win。不要同时运行两个桥接/识别前端。

## 验收标准

1. 用户按住遥控器语音键，在可编辑文本框说一句中文，松开后看到**真实中文上屏**；
2. 普通视频播放仍有声音，系统默认播放设备未被虚拟声卡替换；
3. 按方向/OK 等基础键，在目标窗口看到预期动作；普通键鼠不受影响；
4. 系统听写 / 语音控制或另一套同热键识别程序没有造成重复出字；
5. 日志、定向测试和补丁哈希只作为过程证据，不替代第 1–4 项。

## 安全与隐私

- 补丁和脚本只连接本机 BLE 遥控器、写本机应用配置；不含遥测、不调用付费 API、不上传音频或日志。
- 微信输入法的转写服务按其官方隐私政策工作；本仓库不控制其云端处理。
- 不要把个人 MMKV、config.json、engine.log、WAV、抓包、设备地址或管理员凭据提交到公开仓库。
- 系统权限、配对、UAC、管理员密码和物理按键测试一律由机主本人完成。

## 许可

本仓库新增的说明文档采用 [CC0-1.0](LICENSE-CC0)；`patches/` 中包含的上游代码补丁仍受各自上游许可证约束，见 [`docs/来源与许可.md`](docs/来源与许可.md)。使用第三方软件前请阅读其官方许可证。

如果这套方案帮你少走弯路，欢迎在 GitHub 上 Star；发现问题请附**脱敏后的**系统版本、固定提交、补丁哈希和失败阶段，不要附设备地址、录音、MMKV 或整份个人日志。
