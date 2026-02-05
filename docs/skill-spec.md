# OpenClaw 技能规范文档

本文档定义了 OpenClaw 技能必须遵循的技术规范。

## 1. 命名规范

### 技能名称（name）

- **格式**：小写字母、数字、连字符（-）
- **长度**：3-50 字符
- **禁止**：空格、特殊字符、下划线

**示例：**
```yaml
name: hello-world          # ✅ 正确
name: my_skill             # ❌ 错误（下划线）
name: Hello World          # ❌ 错误（空格）
name: a                    # ❌ 错误（太短）
```

### 目录名称

必须与 `name` 字段完全一致（小写、连字符）。

**示例：**
```
hello-world/
├── SKILL.md
└── README.md
```

## 2. 文件规范

### 必需文件

#### SKILL.md
- **位置**：技能根目录
- **格式**：Markdown + YAML Frontmatter
- **编码**：UTF-8

**最小结构：**
```markdown
---
name: skill-name
description: 简短描述
---

# 技能标题

内容...
```

#### README.md
- **位置**：技能根目录
- **格式**：Markdown
- **编码**：UTF-8

**最小结构：**
```markdown
# 技能名称

技能描述

## 安装

安装步骤...

## 使用

使用方法...
```

### 可选文件

#### install.sh
- **位置**：技能根目录或 `scripts/` 目录
- **权限**：可执行（`chmod +x`）
- **返回码**：0 成功，非0 失败

#### scripts/
包含所有可执行脚本。

#### assets/
包含资源文件（图标、配置等）。

## 3. SKILL.md 规范

### Frontmatter

#### 必需字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `name` | string | 技能唯一标识 | `"hello-world"` |
| `description` | string | 简短描述 | `"一个 Hello World 技能"` |

#### 可选字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `homepage` | string | 项目主页 | `"https://github.com/user/skill"` |
| `metadata.openclaw.emoji` | string | 图标 | `"👋"` |
| `metadata.openclaw.version` | string | 版本号 | `"1.0.0"` |
| `metadata.openclaw.author` | string | 作者 | `"John Doe"` |
| `metadata.openclaw.category` | string | 分类 | `"content-processing"` |
| `metadata.openclaw.tags` | array | 标签 | `["audio", "transcription"]` |
| `metadata.openclaw.requires` | object | 依赖 | 见下文 |
| `metadata.openclaw.install` | array | 安装配置 | 见下文 |

### requires 规范

#### bins（命令行工具）

**类型**：string[]

**说明**：技能依赖的外部命令。

**示例：**
```yaml
"requires": {
  "bins": ["ffmpeg", "whisper", "python3"]
}
```

**注意**：
- OpenClaw 会检查这些命令是否存在
- 如果缺失，会提示用户安装
- 命令名称必须是可执行文件的名称（不含路径）

#### env（环境变量）

**类型**：string[]

**说明**：需要的环境变量。

**示例：**
```yaml
"requires": {
  "env": ["OPENAI_API_KEY", "GEMINI_API_KEY"]
}
```

**注意**：
- OpenClaw 不会验证这些变量
- 在文档中说明如何设置
- 变量名使用大写和下划线

### install 规范

**类型**：object[]

**说明**：自动化安装配置。

#### 安装类型

##### 1. brew（Homebrew）

```yaml
{
  "id": "brew-ffmpeg",
  "kind": "brew",
  "formula": "ffmpeg",
  "bins": ["ffmpeg", "ffprobe"],
  "label": "Install FFmpeg via Homebrew"
}
```

| 字段 | 必需 | 说明 |
|------|------|------|
| `id` | ✅ | 唯一标识符 |
| `kind` | ✅ | 固定值 `"brew"` |
| `formula` | ✅ | Homebrew formula 名称 |
| `bins` | ❌ | 安装的二进制文件 |
| `label` | ✅ | 用户可见的描述 |

##### 2. npm

```yaml
{
  "id": "npm-whisper",
  "kind": "npm",
  "package": "@openai/whisper",
  "global": true,
  "bins": ["whisper"],
  "label": "Install Whisper via npm"
}
```

| 字段 | 必需 | 说明 |
|------|------|------|
| `id` | ✅ | 唯一标识符 |
| `kind` | ✅ | 固定值 `"npm"` |
| `package` | ✅ | npm 包名 |
| `global` | ❌ | 是否全局安装（默认 false） |
| `bins` | ❌ | 安装的二进制文件 |
| `label` | ✅ | 用户可见的描述 |

##### 3. pip

```yaml
{
  "id": "pip-requests",
  "kind": "pip",
  "package": "requests",
  "python": "python3",
  "label": "Install Python requests"
}
```

| 字段 | 必需 | 说明 |
|------|------|------|
| `id` | ✅ | 唯一标识符 |
| `kind` | ✅ | 固定值 `"pip"` |
| `package` | ✅ | pip 包名 |
| `python` | ❌ | Python 命令（默认 `python3`） |
| `label` | ✅ | 用户可见的描述 |

##### 4. script

```yaml
{
  "id": "custom-install",
  "kind": "script",
  "script": "./scripts/install.sh",
  "label": "Run custom installation"
}
```

| 字段 | 必需 | 说明 |
|------|------|------|
| `id` | ✅ | 唯一标识符 |
| `kind` | ✅ | 固定值 `"script"` |
| `script` | ✅ | 脚本路径（相对根目录） |
| `label` | ✅ | 用户可见的描述 |

##### 5. manual

```yaml
{
  "id": "manual-setup",
  "kind": "manual",
  "instructions": "请访问 https://example.com 按照说明手动安装",
  "label": "Manual installation required"
}
```

| 字段 | 必需 | 说明 |
|------|------|------|
| `id` | ✅ | 唯一标识符 |
| `kind` | ✅ | 固定值 `"manual"` |
| `instructions` | ✅ | 安装说明 |
| `label` | ✅ | 用户可见的描述 |

## 4. README.md 规范

### 结构要求

1. **标题**（必需）
   - 使用技能名称
   - H1（#）

2. **简短描述**（必需）
   - 标题下第一段
   - 一句话说明功能

3. **安装**（必需）
   - 清晰的安装步骤
   - 包含前置要求

4. **使用**（必需）
   - 至少一个使用示例
   - 命令行使用代码块

5. **功能特性**（推荐）
   - 列表形式
   - emoji 点缀

6. **示例**（推荐）
   - 实际使用场景
   - 输入输出示例

7. **故障排除**（推荐）
   - 常见问题和解决方案

8. **许可证**（必需）
   - 明确声明许可证类型

### 代码块规范

使用正确的语言标识符：

````markdown
\`\`\`bash
# Shell 命令
./install.sh
\`\`\`

\`\`\`python
# Python 代码
print("Hello")
\`\`\`

\`\`\`json
# JSON 数据
{"key": "value"}
\`\`\`
````

### 表格规范

使用 Markdown 表格展示参数或配置：

| 参数 | 类型 | 说明 | 默认值 |
|------|------|------|--------|
| `--input` | string | 输入文件路径 | - |
| `--output` | string | 输出文件路径 | stdout |

## 5. 脚本规范

### Shell 脚本

**Shebang：**
```bash
#!/bin/bash
```

**错误处理：**
```bash
set -e  # 遇到错误立即退出
set -u  # 使用未定义变量时报错
set -o pipefail  # 管道中任一命令失败则退出
```

**权限：**
```bash
chmod +x scripts/main.sh
```

### Python 脚本

**Shebang：**
```python
#!/usr/bin/env python3
```

**编码声明：**
```python
# -*- coding: utf-8 -*-
```

**错误处理：**
```python
import sys

try:
    main()
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
```

## 6. 输出格式规范

### 成功输出

**标准输出（stdout）：**
```bash
✅ 处理完成
结果数据...
```

**JSON 格式（推荐）：**
```json
{
  "status": "success",
  "data": {
    "result": "..."
  },
  "metadata": {
    "version": "1.0.0",
    "timestamp": "2024-01-01T00:00:00Z"
  }
}
```

### 错误输出

**标准错误（stderr）：**
```bash
❌ 错误：无法找到文件
```

**JSON 格式（推荐）：**
```json
{
  "status": "error",
  "error": {
    "code": "FILE_NOT_FOUND",
    "message": "无法找到文件",
    "details": {
      "path": "/path/to/file.txt"
    }
  }
}
```

### 退出码

| 退出码 | 说明 |
|--------|------|
| 0 | 成功 |
| 1 | 一般错误 |
| 2 | 参数错误 |
| 3 | 依赖缺失 |
| 4 | 权限错误 |
| 128+ | 信号中断 |

## 7. 版本控制

### 语义化版本

格式：`MAJOR.MINOR.PATCH`

- **MAJOR**：不兼容的 API 变更
- **MINOR**：向后兼容的功能新增
- **PATCH**：向后兼容的问题修复

**示例：**
- `1.0.0` → `2.0.0`（重大变更）
- `1.0.0` → `1.1.0`（新功能）
- `1.0.0` → `1.0.1`（bug 修复）

### CHANGELOG.md（推荐）

```markdown
# Changelog

## [1.1.0] - 2024-01-15

### Added
- 新增批量处理功能

### Changed
- 优化输出格式

## [1.0.0] - 2024-01-01

### Added
- 初始版本
```

## 8. 安全规范

### 敏感信息

**禁止：**
- 在代码中硬编码 API key
- 在文档中泄露密钥
- 提交密码文件

**推荐：**
- 使用环境变量
- 在文档中说明如何设置

### 输入验证

```python
import re

def validate_url(url):
    pattern = r'^https?://[^\s/$.?#].[^\s]*$'
    return re.match(pattern, url) is not None
```

### 权限检查

```bash
# 检查文件权限
if [ ! -r "$INPUT_FILE" ]; then
    echo "❌ 错误：无读取权限" >&2
    exit 4
fi
```

## 9. 兼容性规范

### 平台支持

| 平台 | 支持 | 说明 |
|------|------|------|
| macOS | ✅ | 主要支持平台 |
| Linux | ✅ | 完全支持 |
| Windows | ⚠️ | 部分支持 |

### Shell 兼容

推荐使用 POSIX 兼容的语法，避免使用 Bash 特有特性（除非明确标注）。

## 10. 质量标准

### 代码质量

- [ ] 无语法错误
- [ ] 无明显性能问题
- [ ] 有必要的注释
- [ ] 遵循语言最佳实践

### 文档质量

- [ ] SKILL.md 格式正确
- [ ] README.md 完整清晰
- [ ] 有安装和使用示例
- [ ] 有故障排除说明

### 测试覆盖

- [ ] 基本功能测试通过
- [ ] 错误处理测试通过
- [ ] 边界条件测试通过

## 11. 提交规范

### Commit Message

格式：`<type>: <subject>`

**类型：**
- `Add:` 新增技能或功能
- `Fix:` 修复问题
- `Update:` 更新内容
- `Refactor:` 重构
- `Docs:` 文档更新
- `Test:` 测试更新
- `Chore:` 构建/工具更新

**示例：**
```bash
git commit -m "Add: hello-world skill"
git commit -m "Fix: audio-transcription null pointer error"
git commit -m "Docs: update installation guide"
```

---

**遵循这些规范，你的技能将被更容易接受和使用！** 🎯
