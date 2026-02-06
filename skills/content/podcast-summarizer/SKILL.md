---
name: podcast-summarizer
description: 播客/音频内容自动总结工具 - 使用 Whisper 转录 + summarize 技能总结，支持完整流程和分步操作
metadata:
  {
    "openclaw":
      {
        "emoji": "🎧",
        "requires": {
          "bins": ["bash", "python3"],
          "skills": ["whisper", "summarize"]
        }
      }
  }
---

# Podcast Summarizer 🎧

自动总结播客、音频内容和语音备忘录的工具。使用 Whisper 转录音频，然后使用 summarize 技能生成结构化摘要。

## 概述

`podcast-summarizer` 让你可以：
- 转录音频文件（支持 MP3, WAV, M4A 等）
- 总结长文本内容
- 执行完整流程（转录 + 总结）
- 管理和查看所有摘要
- 支持多种输出格式

## 设置

### 前置要求

**必需技能:**
- **whisper:** 本地语音转文字（无需 API key）
- **summarize:** 内容总结技能

**必需工具:**
- **Bash:** 脚本运行
- **Python 3:** JSON 解析和文件处理

### 安装

1. **复制脚本到你的 workspace:**
```bash
cd ~/clawd
mkdir -p scripts
cp [path/to]/podcast-summarizer.sh scripts/
chmod +x scripts/podcast-summarizer.sh
```

2. **确保目录存在:**
```bash
mkdir -p memory/podcast-summaries
mkdir -p memory/podcast-logs
```

## 使用方法

### 转录音频文件
```bash
./scripts/podcast-summarizer.sh transcribe \
  -i podcast.mp3 \
  -o episode1
```

### 总结文本内容
```bash
./scripts/podcast-summarizer.sh summarize \
  -i "这是要总结的长文本..." \
  -o summary1
```

### 完整流程（推荐）
```bash
./scripts/podcast-summarizer.sh process \
  -i podcast.mp3 \
  -o episode1
```

这将自动执行：
1. 使用 whisper 转录音频
2. 使用 summarize 总结转录文本
3. 保存摘要到 `memory/podcast-summaries/episode1.md`
4. 记录日志到 `memory/podcast-logs/episode1_{timestamp}.log`

### 列出所有摘要
```bash
./scripts/podcast-summarizer.sh list
```

### 显示摘要详情
```bash
./scripts/podcast-summarizer.sh show episode1
```

## 命令选项

### transcribe - 转录音频
- `-i, --input <file>`: 音频文件路径（必需）
- `-o, --output <name>`: 输出名称（默认：时间戳）
- `-m, --model <model>`: Whisper 模型（默认：base）
  - 可选: `tiny`, `base`, `small`, `medium`, `large`

### summarize - 总结文本
- `-i, --input <text|file>`: 文本内容或文件路径（必需）
- `-o, --output <name>`: 输出名称（默认：时间戳）
- `-l, --length <length>`: 总结长度（默认：medium）
  - 可选: `short`, `medium`, `long`

### process - 完整流程
- `-i, --input <file>`: 音频文件路径（必需）
- `-o, --output <name>`: 输出名称（默认：时间戳）
- `-m, --model <model>`: Whisper 模型（默认：base）
- `-l, --length <length>`: 总结长度（默认：medium）

## 输出格式

摘要以 Markdown 格式保存到 `memory/podcast-summaries/{name}.md`:

```markdown
# 摘要名称

**来源:** podcast.mp3
**转录时间:** 2026-02-06 10:30:00
**总结时间:** 2026-02-06 10:35:00
**音频时长:** 45:30

## 摘要

这里是总结的内容...

## 关键点

- 关键点 1
- 关键点 2
- 关键点 3

## 转录文本

这里是完整的转录文本...
```

## 使用场景

### 场景 1: 播客学习
```bash
# 总结技术播客
./scripts/podcast-summarizer.sh process \
  -i tech-podcast-ep42.mp3 \
  -o tech-podcast-ep42

# 快速回顾关键点
./scripts/podcast-summarizer.sh show tech-podcast-ep42
```

### 场景 2: 会议录音整理
```bash
# 转录会议录音
./scripts/podcast-summarizer.sh transcribe \
  -i meeting-20260206.m4a \
  -o meeting-20260206

# 提取关键决策
./scripts/podcast-summarizer.sh summarize \
  -i memory/podcast-summaries/meeting-20260206.md \
  -o meeting-20260206-decisions
```

### 场景 3: 语音备忘录
```bash
# 快速总结语音备忘录
./scripts/podcast-summarizer.sh process \
  -i voice-note-idea.mp3 \
  -o idea-001
```

### 场景 4: 网络课程学习
```bash
# 总结在线课程音频
./scripts/podcast-summarizer.sh process \
  -i course-lecture5.mp3 \
  -o lecture5-summary
```

## 最佳实践

### 1. 音频质量
- 使用清晰的音频文件（采样率 ≥ 16kHz）
- 避免背景噪音
- 对于嘈杂音频，考虑使用 larger Whisper 模型

### 2. 文件命名
- 使用有意义的名称（如：`podcast-name-ep42`）
- 包含日期或标识符
- 避免空格和特殊字符

### 3. 模型选择
- **tiny/base:** 快速，适合短音频，准确性一般
- **small:** 平衡速度和准确性
- **medium/large:** 高准确性，适合长音频和专业内容

### 4. 工作流优化
- 先用 `tiny` 模型快速转录
- 如果质量不够，用 larger 模型重新转录
- 保存高质量转录文本供后续使用

## 与 OpenClaw Cron 集成

定期处理播客内容：

```bash
# 每天凌晨 2 点处理新播客
openclaw cron add \
  --name "process-podcasts" \
  --schedule "0 2 * * *" \
  --command "./scripts/process-new-podcasts.sh"
```

`process-new-podcasts.sh` 示例:
```bash
#!/bin/bash
cd ~/clawd/podcasts
for file in new/*.mp3; do
    name=$(basename "$file" .mp3)
    ~/clawd/scripts/podcast-summarizer.sh process -i "$file" -o "$name"
    mv "$file" processed/
done
```

## 故障排除

### 转录失败
- 检查音频格式是否支持
- 确认 whisper 技能已正确安装
- 尝试不同的 Whisper 模型

### 总结质量差
- 尝试更长的总结长度（`-l long`）
- 检查转录文本质量
- 考虑分段总结长文本

### 文件找不到
- 使用绝对路径或相对于 workspace 的路径
- 检查文件权限
- 验证目录存在

## 技术细节

### Whisper 模型大小
- tiny: ~39 MB
- base: ~74 MB
- small: ~244 MB
- medium: ~769 MB
- large: ~1550 MB

### 支持的音频格式
- MP3
- WAV
- M4A
- FLAC
- OGG
- 其他 FFmpeg 支持的格式

## 示例工作流

### 完整的播客处理流程
```bash
# 1. 下载播客
wget https://example.com/podcast-ep50.mp3

# 2. 转录和总结
./scripts/podcast-summarizer.sh process \
  -i podcast-ep50.mp3 \
  -o podcast-ep50

# 3. 查看摘要
./scripts/podcast-summarizer.sh show podcast-ep50

# 4. 提取关键引语
grep -A 2 "关键引语" memory/podcast-summaries/podcast-ep50.md
```

## 贡献

欢迎改进！请在 GitHub 上提交 issue 或 PR。

## 仓库

https://github.com/90le/openclaw-skills-hub

## 作者

Created by Xiaoqiu (小丘) - OpenClaw AI assistant

---

**让学习更高效！** 🎧
