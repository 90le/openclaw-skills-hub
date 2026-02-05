# OpenClaw 技能开发指南

欢迎来到 OpenClaw 技能开发指南！本指南将帮助你创建高质量的 OpenClaw 技能。

## 📚 什么是技能？

**技能 (Skill)** 是 OpenClaw AI 助手的功能扩展。每个技能都提供特定的能力，比如：
- 语音转文字（Whisper）
- 任务管理（Things 3）
- 天气查询（Weather）

## 🎯 技能设计原则

### 1. 单一职责
每个技能只做一件事，并且做好。

❌ 不好：一个技能同时管理邮件、日历和提醒
✅ 好：三个独立的技能分别处理

### 2. AI 友好
设计时要考虑 AI 如何使用你的技能：
- 提供清晰的输入输出说明
- 有明确的触发条件
- 返回结构化的结果

### 3. 文档优先
好的文档是技能成功的关键：
- 简洁的描述
- 清晰的安装步骤
- 丰富的使用示例

## 📁 技能结构

```
skill-name/
├── SKILL.md           # 必需：技能元数据（OpenClaw 读取）
├── README.md          # 必需：用户文档（人类阅读）
├── install.sh         # 可选：自动化安装
├── scripts/           # 可选：脚本文件
│   ├── install.sh
│   └── main.sh
└── assets/            # 可选：资源文件
    ├── icon.png
    └── config.json
```

## 📝 SKILL.md 详解

SKILL.md 是 OpenClaw 识别和使用技能的核心文件。

### 最小示例

```markdown
---
name: hello-world
description: 一个简单的 Hello World 技能
metadata:
  {
    "openclaw":
      {
        "emoji": "👋",
        "requires": { "bins": ["echo"] },
      }
  }
---

# Hello World

这是一个示例技能。
```

### 完整示例

```markdown
---
name: my-skill
description: 技能的简短描述（会被显示在技能列表中）
homepage: https://github.com/user/my-skill
metadata:
  {
    "openclaw":
      {
        "emoji": "⭐",
        "version": "1.0.0",
        "author": "Your Name",
        "requires": {
          "bins": ["python3", "ffmpeg"],
          "env": ["OPENAI_API_KEY"]
        },
        "install": [
          {
            "id": "brew",
            "kind": "brew",
            "formula": "ffmpeg",
            "bins": ["ffmpeg"],
            "label": "Install FFmpeg via Homebrew"
          },
          {
            "id": "pip",
            "kind": "pip",
            "package": "requests",
            "python": "python3",
            "label": "Install Python requests package"
          }
        ]
      }
  }
---

# 技能名称

## 功能描述

详细说明技能的功能和用途。

## 使用方法

\`\`\`bash
# 示例命令
python3 scripts/main.py --input file.txt --output result.txt
\`\`\`

## 参数说明

- `--input`: 输入文件路径
- `--output`: 输出文件路径

## 输出格式

技能返回的数据格式...

## 注意事项

任何需要注意的事项...
```

### 字段说明

#### Frontmatter (YAML)

| 字段 | 必需 | 说明 |
|------|------|------|
| `name` | ✅ | 技能的唯一标识符（小写、连字符） |
| `description` | ✅ | 简短描述（<100字符） |
| `homepage` | ❌ | 项目主页 URL |
| `metadata.openclaw.emoji` | ❌ | 技能图标（emoji） |
| `metadata.openclaw.version` | ❌ | 版本号（语义化版本） |
| `metadata.openclaw.author` | ❌ | 作者名 |
| `metadata.openclaw.requires.bins` | ❌ | 依赖的命令行工具 |
| `metadata.openclaw.requires.env` | ❌ | 需要的环境变量 |
| `metadata.openclaw.install` | ❌ | 安装配置 |

#### requires.bins
列出技能依赖的外部命令。OpenClaw 会检查这些命令是否存在。

```yaml
"requires": {
  "bins": ["ffmpeg", "whisper", "python3"]
}
```

#### requires.env
列出需要的环境变量。这些变量需要在用户配置中设置。

```yaml
"requires": {
  "env": ["OPENAI_API_KEY", "GEMINI_API_KEY"]
}
```

#### install
自动化安装配置。支持多种安装方式：

**Homebrew:**
```yaml
{
  "id": "brew",
  "kind": "brew",
  "formula": "ffmpeg",
  "bins": ["ffmpeg", "ffprobe"],
  "label": "Install FFmpeg via Homebrew"
}
```

**npm:**
```yaml
{
  "id": "npm",
  "kind": "npm",
  "package": "@openai/whisper",
  "global": true,
  "bins": ["whisper"],
  "label": "Install Whisper via npm"
}
```

**pip:**
```yaml
{
  "id": "pip",
  "kind": "pip",
  "package": "requests",
  "python": "python3",
  "label": "Install Python requests"
}
```

**自定义脚本:**
```yaml
{
  "id": "custom",
  "kind": "script",
  "script": "./scripts/install.sh",
  "label": "Run custom installation"
}
```

## 📖 README.md 详解

README.md 是给用户看的文档，要清晰易懂。

### 结构模板

```markdown
# 技能名称

一句话描述技能的核心功能。

## 功能特性

- ✅ 功能1
- ✅ 功能2
- ✅ 功能3

## 安装

### 前置要求

- macOS / Linux
- Python 3.8+
- FFmpeg

### 安装步骤

1. 复制技能到 OpenClaw 技能目录

2. 运行安装脚本（可选）
   \`\`\`bash
   cd skills/my-skill
   ./install.sh
   \`\`\`

3. 配置环境变量（如果需要）
   \`\`\`bash
   export OPENAI_API_KEY="your-api-key"
   \`\`\`

4. 重启 OpenClaw
   \`\`\`bash
   openclaw gateway restart
   \`\`\`

## 使用方法

### 基础用法

\`\`\`bash
# 示例 1
my-skill --input file.txt

# 示例 2
my-skill --url https://example.com --format json
\`\`\`

### 高级用法

\`\`\`bash
# 更多选项
my-skill \
  --input file.txt \
  --output result.json \
  --mode advanced \
  --verbose
\`\`\`

## 配置选项

| 参数 | 说明 | 默认值 |
|------|------|--------|
| `--input` | 输入文件或 URL | - |
| `--output` | 输出文件 | stdout |
| `--format` | 输出格式 | text |
| `--mode` | 运行模式 | normal |

## 示例

### 示例 1：基础转换

\`\`\`bash
my-skill --input video.mp4 --output audio.wav
\`\`\`

### 示例 2：批量处理

\`\`\`bash
for file in *.mp4; do
  my-skill --input "$file" --output "${file%.mp4}.txt"
done
\`\`\`

## 输出格式

### 普通模式

\`\`\`
文本内容...
\`\`\`

### JSON 模式

\`\`\`json
{
  "status": "success",
  "data": {
    "result": "..."
  },
  "metadata": {
    "duration": 12.5
  }
}
\`\`\`

## 故障排除

### 问题：找不到命令

**解决方案：**
检查是否正确安装了依赖
\`\`\`bash
which my-skill
\`\`\`

### 问题：权限错误

**解决方案：**
给脚本添加执行权限
\`\`\`bash
chmod +x scripts/main.sh
\`\`\`

## 常见问题

<details>
<summary>技能支持哪些平台？</summary>

目前支持 macOS 和 Linux。Windows 支持正在开发中。
</details>

<details>
<summary>如何卸载？</summary>

删除技能目录即可：
\`\`\`bash
rm -rf /path/to/openclaw/skills/my-skill
\`\`\`
</details>

## 限制与注意事项

- 仅支持特定格式
- 需要网络连接
- API 有调用限制

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 PR！

## 作者

Your Name

## 致谢

感谢以下项目...
```

## 🔧 开发最佳实践

### 1. 错误处理

```bash
#!/bin/bash

set -e  # 遇到错误立即退出

# 检查依赖
command -v python3 >/dev/null 2>&1 || {
  echo "❌ 错误：需要 Python 3"
  exit 1
}

# 检查环境变量
if [ -z "$OPENAI_API_KEY" ]; then
  echo "❌ 错误：需要设置 OPENAI_API_KEY"
  exit 1
fi
```

### 2. 日志输出

```bash
# 使用颜色区分日志级别
log_info()    { echo -e "\033[36mℹ\033[0m $*"; }
log_success() { echo -e "\033[32m✅\033[0m $*"; }
log_warning() { echo -e "\033[33m⚠\033[0m $*"; }
log_error()   { echo -e "\033[31m❌\033[0m $*"; }

log_info "正在处理..."
log_success "处理完成！"
```

### 3. 输入验证

```python
def validate_input(input_data):
    if not input_data:
        raise ValueError("输入不能为空")
    if len(input_data) > 10000:
        raise ValueError("输入过长")
    return True
```

### 4. 结构化输出

```json
{
  "status": "success|error",
  "data": {...},
  "error": {
    "code": "ERROR_CODE",
    "message": "错误信息"
  },
  "metadata": {
    "version": "1.0.0",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

## 🧪 测试技能

### 本地测试

```bash
# 测试基本功能
./scripts/main.sh --input test.txt

# 测试错误处理
./scripts/main.sh --input nonexistent.txt

# 测试不同参数
./scripts/main.sh --input test.txt --mode verbose
```

### 测试清单

- [ ] 功能正常工作
- [ ] 错误处理正确
- [ ] 文档完整准确
- [ ] 安装脚本正常
- [ ] 跨平台兼容（如适用）

## 📤 提交技能

### 提交前检查清单

- [ ] SKILL.md 格式正确
- [ ] README.md 完整清晰
- [ ] 安装脚本可执行
- [ ] 代码无语法错误
- [ ] 测试通过
- [ ] 添加了必要的注释

### 提交 PR

1. Fork 仓库
2. 创建分支：`git checkout -b add/my-skill`
3. 提交代码
4. 开启 Pull Request
5. 等待审核

## 💡 技能创意

需要灵感？看看这些方向：

### 内容处理
- OCR（图片转文字）
- PDF 解析和提取
- 文档格式转换
- 批量重命名

### 自动化
- 定时任务
- 文件同步
- 备份工具
- 系统监控

### 社交媒体
- YouTube 下载器
- Telegram 机器人
- 邮件管理
- 微信助手

### 数据处理
- Excel 处理
- 数据可视化
- API 调用
- 数据清洗

## 📚 参考资料

- [OpenClaw 官方文档](https://docs.openclaw.ai)
- [技能规范文档](skill-spec.md)
- [现有技能示例](../skills/)

## 🆘 获取帮助

- 查看 [GitHub Issues](https://github.com/qingchencloud/openclaw-skills-hub/issues)
- 在 [Discussions](https://github.com/qingchencloud/openclaw-skills-hub/discussions) 提问
- 加入社区讨论

---

**祝开发愉快！** 🎉
