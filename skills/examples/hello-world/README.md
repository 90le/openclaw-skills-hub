---
name: hello-world
description: 一个简单的 Hello World 示例技能
homepage: https://github.com/qingchencloud/openclaw-skills-hub
metadata:
  {
    "openclaw":
      {
        "emoji": "👋",
        "version": "1.0.0",
        "author": "小丘",
        "category": "examples",
        "tags": ["example", "demo", "getting-started"],
        "requires": { "bins": ["echo"] }
      }
  }
---

# Hello World 示例技能

这是一个简单的 Hello World 技能，用于展示 OpenClaw 技能的基本结构。

## 功能

- 打印 Hello World 消息
- 支持自定义问候语
- 演示技能基本结构

## 安装

这个技能不需要任何额外的安装步骤，因为它只使用系统自带的 `echo` 命令。

## 使用

### 基础用法

```bash
# 打印 Hello World
./scripts/hello.sh

# 使用自定义消息
./scripts/hello.sh "你好，世界！"
```

### 在 OpenClaw 中使用

```
你好，用 hello-world 技能打印一条消息
```

## 输出示例

```
👋 Hello World!
```

## 文件结构

```
hello-world/
├── SKILL.md           # 技能元数据
├── README.md          # 本文件
└── scripts/
    └── hello.sh       # 主脚本
```

## 学习目标

通过这个简单示例，你将学到：

1. ✅ 技能的基本结构
2. ✅ SKILL.md 的格式
3. ✅ README.md 的写法
4. ✅ 脚本的放置位置
5. ✅ 如何在 OpenClaw 中使用技能

## 下一步

查看完整的技能开发指南：

- [技能开发指南](../../docs/skill-guide.md)
- [技能规范文档](../../docs/skill-spec.md)
- [更多示例](../)

## 许可证

MIT License

## 作者

小丘 ⛰️

---

**这是你的第一个 OpenClaw 技能！** 🎉
