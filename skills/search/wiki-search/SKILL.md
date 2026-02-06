---
name: wiki-search
description: Wikipedia 搜索工具 - 快速查询百科知识
metadata:
  {
    "openclaw":
      {
        "emoji": "📖",
        "requires": {
          "bins": ["bash", "curl"]
        }
      }
  }
---

# Wikipedia Search 📖

快速搜索 Wikipedia 获取百科知识，无需 API key，适合查询定义、历史、科学等知识。

## 概述

`wiki-search` 让你可以：
- 快速查询 Wikipedia 条目
- 获取条目摘要
- 支持多语言（默认英文）
- 无需注册或 API key

## 设置

### 前置要求

- **Bash:** 脚本运行
- **curl:** HTTP 请求

### 安装

1. **复制脚本到你的 workspace:**
```bash
cd ~/clawd
mkdir -p scripts
cp [path/to]/wiki-search.sh scripts/
chmod +x scripts/wiki-search.sh
```

2. **（可选）设置语言**
编辑脚本中的 `WIKI_LANG` 变量：
```bash
WIKI_LANG="zh"  # 中文维基百科
WIKI_LANG="en"  # 英文维基百科（默认）
```

## 使用方法

### 基本搜索
```bash
./scripts/wiki-search.sh "查询关键词"
```

### 搜索示例
```bash
# 查询科学概念
./scripts/wiki-search.sh "Artificial Intelligence"

# 查询历史人物
./scripts/wiki-search.sh "Alan Turing"

# 查询技术术语
./scripts/wiki-search.sh "Machine Learning"

# 查询地理位置
./scripts/wiki-search.sh "Shanghai"
```

### 中文搜索
```bash
# 修改脚本设置 WIKI_LANG="zh"
./scripts/wiki-search.sh "人工智能"
./scripts/wiki-search.sh "上海"
./scripts/wiki-search.sh "量子计算"
```

## 输出格式

搜索结果包含：
- 条目标题
- 摘要（第一段）
- 条目链接
- 相关条目（如有）

示例输出：
```
搜索: Artificial Intelligence

标题: Artificial Intelligence
摘要: Artificial intelligence (AI) is intelligence demonstrated by machines, 
as opposed to the natural intelligence displayed by animals including humans. 
AI applications include advanced web search engines, recommendation systems...

链接: https://en.wikipedia.org/wiki/Artificial_Intelligence

相关条目:
- Machine Learning
- Deep Learning
- Neural Networks
```

## 高级用法

### 搜索特定类别
```bash
# 科学
./scripts/wiki-search.sh "Quantum Physics"

# 技术
./scripts/wiki-search.sh "Blockchain"

# 历史
./scripts/wiki-search.sh "World War II"

# 文化
./scripts/wiki-search.sh "Renaissance"
```

### 获取完整条目
```bash
# 搜索后获取链接
./scripts/wiki-search.sh "Topic" | grep "链接:"
URL="https://en.wikipedia.org/wiki/Topic"

# 使用 web_fetch 获取完整内容
curl -s "$URL" | more
```

### 保存搜索结果
```bash
./scripts/wiki-search.sh "Topic" > wiki-result.txt
```

## 使用场景

### 场景 1: 学习新概念
```bash
./scripts/wiki-search.sh "Neural Networks"
```

### 场景 2: 验证信息
```bash
./scripts/wiki-search.sh "Historical Event"
```

### 场景 3: 获取定义
```bash
./scripts/wiki-search.sh "Technology Term"
```

### 场景 4: 查找相关主题
```bash
./scripts/wiki-search.sh "AI Research"
```

### 场景 5: 多语言学习
```bash
# 英文
./scripts/wiki-search.sh "Artificial Intelligence"

# 中文
WIKI_LANG="zh" ./scripts/wiki-search.sh "人工智能"
```

## 多语言支持

### 设置语言
编辑脚本：
```bash
WIKI_LANG="en"  # 英文
WIKI_LANG="zh"  # 中文
WIKI_LANG="ja"  # 日文
WIKI_LANG="fr"  # 法文
WIKI_LANG="de"  # 德文
```

### 常见语言代码
| 语言 | 代码 |
|------|------|
| 英文 | en |
| 中文 | zh |
| 日文 | ja |
| 韩文 | ko |
| 法文 | fr |
| 德文 | de |
| 西班牙文 | es |
| 俄文 | ru |

## 与其他工具配合

### 结合 ddg-search
```bash
# 先用 wiki-search 查询
./scripts/wiki-search.sh "Topic"

# 如果需要更多信息，用 ddg-search
./scripts/ddg-search.sh "Topic latest research"
```

### 结合 summarize
```bash
# 搜索长条目
./scripts/wiki-search.sh "Complex Topic"

# 使用 summarize 总结
summarize "总结以下内容：[条目内容]"
```

### 结合 web_fetch
```bash
# 获取条目链接
URL=$(./scripts/wiki-search.sh "Topic" | grep "链接:" | cut -d' ' -f2)

# 获取详细内容
web_fetch "$URL" --extract markdown
```

## 搜索技巧

### 精确匹配
```bash
# 使用双引号
./scripts/wiki-search.sh "\"exact phrase\""
```

### 分词搜索
```bash
# 尝试不同的关键词组合
./scripts/wiki-search.sh "Machine Learning"
./scripts/wiki-search.sh "ML Algorithms"
```

### 大小写不敏感
```bash
# 大小写不影响结果
./scripts/wiki-search.sh "ai"
./scripts/wiki-search.sh "AI"
```

## 维基百科 API

### 端点说明
- **搜索 API:** `https://{lang}.wikipedia.org/w/api.php?action=opensearch`
- **条目 API:** `https://{lang}.wikipedia.org/api/rest_v1/page/summary/{title}`

### 参数说明
```bash
action=opensearch     # 搜索操作
search={query}         # 搜索关键词
limit={number}         # 结果数量（默认：5）
format=json           # 输出格式
```

## 最佳实践

### 1. 搜索策略
- 使用准确的条目名称
- 尝试不同的关键词
- 结合其他搜索工具

### 2. 信息验证
- 交叉验证重要信息
- 检查条目编辑历史
- 注意维基百科的准确性

### 3. 多语言利用
- 用英文获取更多信息
- 用中文获取本地化内容
- 对比不同语言版本

### 4. 效率优化
- 缓存搜索结果
- 批量查询相关条目
- 保存有用的链接

## 自动化脚本

### 批量查询
```bash
#!/bin/bash
# batch-wiki-search.sh

topics=("Artificial Intelligence" "Machine Learning" "Deep Learning")

for topic in "${topics[@]}"; do
  echo "查询: $topic"
  ./scripts/wiki-search.sh "$topic" > "wiki/${topic}.txt"
  sleep 1
done
```

### 知识卡片
```bash
#!/bin/bash
# knowledge-card.sh

topic=$1
echo "=== 📖 知识卡片 ==="
echo "主题: $topic"
echo "时间: $(date '+%Y-%m-%d')"
echo ""
./scripts/wiki-search.sh "$topic"
```

### 定期学习
```bash
# 添加到 cron
openclaw cron add \
  --name "daily-wiki-learning" \
  --schedule "0 10 * * *" \
  --command "./scripts/wiki-search.sh '今日主题' >> memory/wiki-learning.md"
```

## 扩展功能

### 搜索历史
```bash
#!/bin/bash
# wiki-history.sh

HISTORY_FILE="memory/wiki-history.txt"

echo "$(date '+%Y-%m-%d %H:%M') - $*" >> "$HISTORY_FILE"
./scripts/wiki-search.sh "$*"
```

### 相关条目探索
```bash
#!/bin/bash
# explore-related.sh

topic=$1

# 获取条目
./scripts/wiki-search.sh "$topic"

# 提取相关条目
# (需要解析 API 返回)
# 递归查询相关条目
```

### 条目对比
```bash
#!/bin/bash
# compare-topics.sh

topic1=$1
topic2=$2

echo "对比: $topic1 vs $topic2"
echo ""
echo "--- $topic1 ---"
./scripts/wiki-search.sh "$topic1"
echo ""
echo "--- $topic2 ---"
./scripts/wiki-search.sh "$topic2"
```

## 故障排除

### 无搜索结果
- 检查关键词拼写
- 尝试同义词
- 使用英文查询（更全面）

### 内容不完整
- 使用 web_fetch 获取完整内容
- 访问 Wikipedia 网站查看
- 尝试其他来源

### 请求失败
- 检查网络连接
- 验证 Wikipedia 服务状态
- 尝试不同的语言版本

## 限制

### Wikipedia 限制
- 不是所有信息都有条目
- 部分内容可能过时
- 高级查询需要更复杂的 API 调用

### 替代方案
- 使用 **ddg-search** 进行通用搜索
- 使用 **web_fetch** 获取特定网站内容
- 直接访问相关资源网站

## 示例查询

### AI 相关
```bash
./scripts/wiki-search.sh "Artificial Intelligence"
./scripts/wiki-search.sh "Machine Learning"
./scripts/wiki-search.sh "Deep Learning"
./scripts/wiki-search.sh "Neural Networks"
```

### 编程相关
```bash
./scripts/wiki-search.sh "Algorithm"
./scripts/wiki-search.sh "Data Structure"
./scripts/wiki-search.sh "Programming Language"
```

### 历史相关
```bash
./scripts/wiki-search.sh "Computer History"
./scripts/wiki-search.sh "Internet History"
./scripts/wiki-search.sh "Silicon Valley"
```

### 科学相关
```bash
./scripts/wiki-search.sh "Quantum Computing"
./scripts/wiki-search.sh "Blockchain"
./scripts/wiki-search.sh "Cryptography"
```

## 贡献

欢迎改进！请在 GitHub 上提交 issue 或 PR。

## 仓库

https://github.com/90le/openclaw-skills-hub

## 作者

Created by Xiaoqiu (小丘) - OpenClaw AI assistant

---

**知识，触手可及！** 📖
