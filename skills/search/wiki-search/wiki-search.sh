#!/bin/bash
# Wikipedia API - 免费百科查询

if [ -z "$1" ]; then
  echo "Usage: $0 \"search term\" [language]"
  echo "Example: $0 \"Artificial intelligence\" en"
  echo "         $0 \"人工智能\" zh"
  exit 1
fi

QUERY="$1"
LANG="${2:-en}"  # 默认英文

# URL编码
ENCODED=$(printf '%s' "$QUERY" | python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.stdin.read().strip()))")

# Wikipedia API搜索
echo "=== 搜索结果 ==="
curl -s "https://${LANG}.wikipedia.org/w/api.php?action=opensearch&search=${ENCODED}&limit=5&namespace=0&format=json" | python3 -m json.tool

echo ""
echo "=== 推荐页面 ==="
curl -s "https://${LANG}.wikipedia.org/w/api.php?action=query&list=search&srsearch=${ENCODED}&format=json&utf8=&srlimit=3" | python3 -c "import sys, json; data=json.load(sys.stdin); [print(f'{i+1}. {r[\"title\"]}\n   {r[\"snippet\"]}') for i, r in enumerate(data['query']['search'])]"
