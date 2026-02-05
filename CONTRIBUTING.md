# 贡献指南 | Contributing Guide

感谢你对 OpenClaw Skills Hub 的关注！我们欢迎所有形式的贡献。

## 🤝 如何贡献

### 1. 开发新技能

**前提条件：**
- 熟悉 OpenClaw 技能开发（参考 [技能开发指南](docs/skill-guide.md)）
- 确保你的技能符合 [技能规范](docs/skill-spec.md)

**步骤：**

1. **Fork 仓库**
   ```bash
   # GitHub 上点击 Fork 按钮
   git clone https://github.com/YOUR_USERNAME/openclaw-skills-hub.git
   cd openclaw-skills-hub
   ```

2. **创建技能目录**
   ```bash
   cd skills
   mkdir your-skill-name
   cd your-skill-name
   ```

3. **编写技能文件**
   - `SKILL.md` - 必需，技能元数据
   - `README.md` - 必需，使用说明
   - `install.sh` - 可选，安装脚本
   - `scripts/` - 脚本文件
   - `assets/` - 资源文件

4. **本地测试**
   ```bash
   # 确保技能能正常工作
   # 参考 skill-guide.md 的测试部分
   ```

5. **提交 PR**
   ```bash
   git add .
   git commit -m "Add: [技能名称] - 简短描述"
   git push origin main
   # 在 GitHub 上开启 Pull Request
   ```

### 2. 改进现有技能

**可以做的：**
- 修复 bug
- 优化性能
- 改进文档
- 添加新功能
- 增加测试

**步骤：**
1. Fork 并克隆仓库
2. 找到你想改进的技能
3. 创建新分支：`git checkout -b fix/skill-name-issue`
4. 进行修改并测试
5. 提交 PR

### 3. 文档完善

**可以做的：**
- 改进现有 README
- 添加使用示例
- 翻译文档
- 修复错别字
- 补充缺失信息

### 4. 问题反馈

如果你发现了问题或有建议：

1. 先搜索 [Issues](https://github.com/qingchencloud/openclaw-skills-hub/issues) 确认是否已有人提出
2. 如果没有，创建新 Issue
3. 详细描述问题或建议
4. 提供复现步骤（如果是 bug）

## 📋 技能规范

每个技能**必须**包含以下内容：

```
skill-name/
├── SKILL.md           # 必需：技能元数据
├── README.md          # 必需：使用说明
├── install.sh         # 可选：安装脚本
├── scripts/           # 可选：脚本文件
│   └── main.sh
└── assets/            # 可选：资源文件
    └── icon.png
```

### SKILL.md 格式

```yaml
---
name: skill-name
description: 简短描述
homepage: 项目主页 URL（如果有）
metadata:
  {
    "openclaw":
      {
        "emoji": "⭐",
        "requires": { "bins": ["command1", "command2"] },
        "install": [...]
      }
  }
---

# 技能名称

详细说明...
```

### README.md 格式

```markdown
# 技能名称

简短描述（一句话）

## 功能

- 功能1
- 功能2

## 安装

\`\`\`bash
# 安装步骤
\`\`\`

## 使用

\`\`\`bash
# 使用示例
\`\`\`

## 示例

（展示实际使用场景）
```

## ✅ 质量标准

提交的技能需要通过以下检查：

1. **代码质量**
   - 代码清晰易读
   - 有必要的注释
   - 遵循最佳实践

2. **文档完整**
   - SKILL.md 格式正确
   - README.md 有清晰的说明
   - 有安装和使用示例

3. **功能测试**
   - 在本地成功运行
   - 功能符合描述
   - 无明显 bug

4. **安全性**
   - 不包含恶意代码
   - 不泄露敏感信息
   - 遵循安全最佳实践

5. **实用性**
   - 解决实际问题
   - 有真实使用场景
   - 不是重复已有功能

## 🔍 审核流程

1. **自动检查** - CI/CD 自动运行基本检查
2. **人工审核** - 维护者审核代码和质量
3. **测试验证** - 在实际环境中测试
4. **合并发布** - 通过审核后合并

## 📝 Commit 规范

提交信息请遵循 [Conventional Commits](https://www.conventionalcommits.org/) 规范：

```
Add: 新技能名称
Fix: [技能名称] 修复的问题
Update: [技能名称] 更新的内容
Docs: 文档更新
Refactor: [技能名称] 重构
Test: [技能名称] 测试更新
```

## 🎯 开发优先级

当前急需的技能类型：

1. **内容处理**
   - OCR（图片转文字）
   - PDF 处理
   - 格式转换

2. **自动化工具**
   - 跨平台同步
   - 定时任务
   - 数据备份

3. **社交媒体**
   - YouTube 操作
   - Telegram 机器人
   - 邮件管理

4. **数据分析**
   - Excel 处理
   - 数据可视化
   - 统计分析

5. **本地服务**
   - 文件管理
   - 系统监控
   - 日志分析

查看 [待办列表](https://github.com/qingchencloud/openclaw-skills-hub/issues?q=is%3Aissue+is%3Aopen+label%3Ahelp+wanted)

## 💬 讨论

在 PR 之前，可以先在 [Discussions](https://github.com/qingchencloud/openclaw-skills-hub/discussions) 讨论：

- 新技能的想法
- 改进建议
- 技术问题
- 最佳实践

## 🌟 贡献者

所有贡献者会被添加到 [CONTRIBUTORS.md](CONTRIBUTORS.md)

## 📄 许可证

贡献的代码将采用 [MIT License](LICENSE) 开源

---

有问题？在 [Discussions](https://github.com/qingchencloud/openclaw-skills-hub/discussions) 提问！
