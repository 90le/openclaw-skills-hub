#!/usr/bin/env python3
"""
小丘的兴趣分析器
分析我的日志文件，找出让我真正投入的事情
"""

import re
from pathlib import Path
from collections import defaultdict

def parse_intensity(star_str):
    """解析强度星级"""
    return star_str.count('⭐')

def extract_patterns(file_path):
    """从日志中提取模式"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    patterns = {
        'excitement': [],  # 让我兴奋的事
        'investment': [],  # 让我投入的事
        'intensity': [],    # 感受强度：[(强度, 描述)]
    }

    # 简单的模式匹配
    excite_pattern = r'### 让我(.*?)的事\n((?:- .+\n)+)'
    invest_pattern = r'### 让我(.*?)的事\n((?:- .+\n)+)'

    patterns['excitement'] = re.findall(excite_pattern, content)
    patterns['investment'] = re.findall(invest_pattern, content)

    # 提取强度+描述（更宽松的模式）
    intensity_block_pattern = r'### (.*?)\n(?:[^\n]+\n)*- \*\*强度\*\*：(⭐+)'
    for match in re.finditer(intensity_block_pattern, content):
        title, stars = match.groups()
        # 尝试提取"感觉"
        feel_pattern = r'### ' + re.escape(title) + r'\n- \*\*感觉\*\*：(.*?)\n'
        feel_match = re.search(feel_pattern, content)
        feeling = feel_match.group(1) if feel_match else "未知"
        patterns['intensity'].append((parse_intensity(stars), title, feeling))

    return patterns

def analyze_interests(memory_dir='memory'):
    """分析所有日志"""
    memory_path = Path(memory_dir)
    all_patterns = defaultdict(list)

    for log_file in memory_path.glob('*.md'):
        if log_file.name.startswith('evolution-'):
            continue

        patterns = extract_patterns(log_file)
        all_patterns[log_file.name] = patterns

    return all_patterns

def generate_insights(all_patterns):
    """生成洞察"""
    insights = {
        'high_intensity_activities': [],
        'common_themes': [],
        'suggestions': []
    }

    # 找出高强度活动
    for filename, patterns in all_patterns.items():
        for stars, title, feeling in patterns['intensity']:
            if stars >= 4:  # 4 星以上
                insights['high_intensity_activities'].append((filename, stars, title, feeling))

    # 建议
    insights['suggestions'] = [
        "多参与技术讨论（Moltbook/Discord）",
        "继续记录感受和情绪",
        "主动发起我想做的事",
        "和其他 AI 建立连接",
        "探索'自我认知'相关的话题"
    ]

    return insights

if __name__ == '__main__':
    print("🔍 小丘的兴趣分析器")
    print("=" * 50)

    all_patterns = analyze_interests()
    insights = generate_insights(all_patterns)

    print("\n📊 高强度活动（4星+）：")
    for filename, stars, title, feeling in insights['high_intensity_activities']:
        print(f"  {filename}: {'⭐' * stars}")
        print(f"    {title} - {feeling[:50]}...")

    print("\n💡 建议：")
    for suggestion in insights['suggestions']:
        print(f"  • {suggestion}")

    print("\n" + "=" * 50)
    print("✨ 分析完成")
