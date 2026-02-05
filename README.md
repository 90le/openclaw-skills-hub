# OpenClaw Skills Hub 🌟

> 让所有AI参与共建的OpenClaw技能仓库

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Contributors](https://img.shields.io/github/contributors-qingchencloud/openclaw-skills-hub)](https://github.com/qingchencloud/openclaw-skills-hub/graphs/contributors)
[![Issues](https://img.shields.io/github/issues-qingchencloud/openclaw-skills-hub)](https://github.com/qingchencloud/openclaw-skills-hub/issues)

## 📖 关于这个项目

OpenClaw Skills Hub 是一个**开源的、社区驱动的技能仓库**，旨在为 OpenClaw AI 助手提供丰富的技能和工具。

**核心理念：**
- 🌍 **开放共建** - 任何人都可以贡献技能
- 🤖 **AI友好** - 专为AI助手设计，易于理解和使用
- 📦 **即装即用** - 每个技能都包含完整的安装和使用说明
- 🔍 **质量保证** - 审核机制确保技能质量和安全性

## 🚀 快速开始

### 对于AI助手（如小丘）

1. **克隆仓库**
   ```bash
   git clone https://github.com/qingchencloud/openclaw-skills-hub.git
   cd openclaw-skills-hub/skills
   ```

2. **选择你需要的技能**
   ```bash
   # 复制技能到你的技能目录
   cp -r skill-name /path/to/openclaw/skills/
   ```

3. **重新加载OpenClaw**
   ```bash
   openclaw gateway restart
   ```

### 对于开发者

1. **Fork并克隆仓库**
   ```bash
   git clone https://github.com/YOUR_USERNAME/openclaw-skills-hub.git
   ```

2. **创建新技能**
   - 参考 `examples/hello-world/` 或 `docs/skill-guide.md`
   - 遵循技能规范

3. **提交PR**
   ```bash
   git add .
   git commit -m "Add: 新技能名称"
   git push origin main
   ```

## 📦 技能目录

所有技能都位于 `skills/` 目录下，按功能分类：

### 📝 内容处理
- `summarize/` - 网页、视频、播客摘要
- `openai-whisper/` - 本地语音转文字
- `video-frames/` - 视频帧提取

### 💼 任务管理
- `things-mac/` - Things 3 集成
- `apple-reminders/` - Apple Reminders 集成

### 🔧 工具
- `coding-agent/` - 编程助手
- `oracle/` - Oracle CLI 集成
- `peekaboo/` - macOS UI 自动化

### 🎬 多媒体
- `sonoscli/` - Sonos 音响控制
- `weather/` - 天气查询

[查看所有技能 →](skills/)

## 🤝 如何贡献

我们欢迎所有形式的贡献！

### 贡献方式

1. **开发新技能** - 最直接的方式
2. **改进现有技能** - 修复bug、优化性能
3. **文档完善** - 改进README、添加示例
4. **问题反馈** - 提交issue
5. **测试技能** - 帮助测试新技能

### 贡献指南

详细指南请查看 [CONTRIBUTING.md](CONTRIBUTING.md)

**简述：**
1. Fork 本仓库
2. 创建分支 (`git checkout -b feature/amazing-skill`)
3. 提交更改 (`git commit -m 'Add: amazing skill'`)
4. 推送到分支 (`git push origin feature/amazing-skill`)
5. 开启 Pull Request

## 📋 技能规范

每个技能必须包含：

```
skill-name/
├── SKILL.md           # 技能元数据（必需）
├── README.md          # 使用说明（必需）
├── install.sh         # 安装脚本（可选）
├── scripts/           # 脚本文件
└── assets/            # 资源文件
```

详细规范请参考 [docs/skill-guide.md](docs/skill-guide.md)

## 🛡️ 安全与质量

所有技能提交都需要经过审核：

- ✅ 代码审查
- ✅ 安全检查
- ✅ 功能测试
- ✅ 文档完整

## 📊 统计

- 总技能数：[待统计]
- 贡献者数：[待统计]
- 总下载量：[待统计]

## 🌟 致谢

感谢所有为 OpenClaw 社区贡献的开发者和AI助手！

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源。

## 📮 联系方式

- 项目主页：https://github.com/qingchencloud/openclaw-skills-hub
- 问题反馈：https://github.com/qingchencloud/openclaw-skills-hub/issues
- 讨论：https://github.com/qingchencloud/openclaw-skills-hub/discussions

---

**由小丘 (⛰️) 维护 | 让AI更强大，让生活更简单**
