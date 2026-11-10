# 给 Agent 的最短入口：G9N9N 遥控器接入

先完整阅读 [`docs/单文件指南.md`](docs/单文件指南.md)，再让机主明确选择 Windows 或 Apple Silicon Mac；**只执行对应路线**。两份完整补丁同时存在于 `patches/` 和单文件指南末尾，固定提交、哈希、依赖、手动授权与验收边界都在文档里。

## 硬边界

- 在机主电脑新建工程目录；不复制作者的盘符、用户名、设备地址、Container ID、活动设备 key、MMKV、config.json、日志、录音或截图。
- 系统授权、UAC、管理员密码、蓝牙配对、物理按键、真实中文上屏由机主本人操作或确认。Agent 不自动点系统弹窗、不自动重启、不解除配对、不禁用蓝牙/HID 栈、不改系统默认音频、不影响现有键鼠。
- 不同时运行多个桥接/识别程序，不安装 Handy、Qwen3-ASR、右 Command 热键助手或 PacketLogger 这些历史候选，不用全局低级键盘钩子。
- 只从固定提交和官方来源重建程序；校验补丁与 BlackHole PKG 的 SHA256。原始文档/LICENSE 保留在上游仓库。
- 分层报告：自动测试、静态设备枚举、链路日志、机主现场验收。测试绿、已连接、订阅成功、电平跳动都不等于真实中文上屏。
- 语音转写前端以微信输入法（WeType）为实机验收路径。若机主改用其他输入法，至少有「单独选择虚拟麦克风 + 与桥接一致的按住说话快捷键 + 不启用第二个识别前端」才可能沿用同一音频链路；这属于原理迁移，不是已实测支持，必须重新做真实中文上屏验收。

## 选择

- Windows：`windows/完整指南.md`、`patches/windows-verified-fix.patch`、`windows/requirements-verified.txt`。
- Apple Silicon Mac：`docs/Mac-微信输入法方案.md`、`patches/mac-verified-final.patch`、`mac/安装G9N9N-Mac.command`（必须放在应用补丁后的完整源码根目录）、`scripts/check-mac-runtime.sh`。

## 公开仓库链接

仓库地址：{REPO_URL}。拿到后先 `git clone`，再读本文件；不要把作者个人工程、录音或凭据上传到 Issue。最终链路、来源与许可见 `README.md` 和 `docs/来源与许可.md`。
