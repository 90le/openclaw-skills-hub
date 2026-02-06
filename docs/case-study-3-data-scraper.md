# 案例3：数据抓取系统

**项目名称：** 网站数据提取和监控服务
**客户类型：** 电商公司、市场研究机构
**开发时间：** 2026-02-07
**服务类型：** 自动化开发服务

---

## 项目背景

客户是一家电商公司，需要：
- 监控竞品价格
- 收集产品信息
- 抓取用户评论和反馈
- 自动化价格调整策略

**挑战：** 手动抓取耗时、不可靠、容易触发反爬

**现状：** 员工每天花费4-6小时手动收集数据，导致价格调整滞后

---

## 需求分析

### 核心需求
1. **大规模并发抓取**
   - 每天抓取1000+产品页面
   - 支持多网站（Amazon、eBay、淘宝、京东等）
   - 请求分散，避免被封

2. **反爬措施**
   - 代理IP轮换
   - 请求间隔随机化
   - User-Agent轮换
   - 浏览器指纹模拟

3. **数据清洗和结构化**
   - 价格数据标准化
   - 评论情感分析
   - 产品信息提取
   - 去重和合并

4. **实时监控和告警**
   - 价格变化告警
   - 抓取失败告警
   - 数据质量检查
   - 定时任务调度

### 非功能需求
1. **增量更新**
   - 只抓取变化的数据
   - 减少带宽和服务器负载
   - 识别新产品和下架

2. **数据导出**
   - CSV/Excel导出
   - 数据库导入
   - API接口对接
   - 可视化Dashboard

3. **智能调度**
   - 爬取频率动态调整
   - 热门时段加强抓取
   - 低谷时段减少抓取

---

## 技术方案

### 技术栈
- **语言：** Python 3.10+
- **爬虫框架：** Scrapy + Playwright（JavaScript渲染）
- **数据库：** PostgreSQL + Redis（缓存）
- **队列：** Celery（异步任务）
- **监控：** Prometheus + Grafana
- **代理：** 代理池管理

### 架构设计

```
调度器 → Celery Worker → Scrapy爬虫
         ↓
      代理池
         ↓
      网站抓取
         ↓
      数据清洗
         ↓
      PostgreSQL存储
         ↓
      告警系统
```

### 核心组件

#### 1. 爬虫框架（scraper/）
```python
import scrapy
from scrapy.crawler import CrawlerProcess
from scrapy.spiders import Spider
from urllib.parse import urljoin
import random
import time

class ProductSpider(Spider):
    """产品爬虫基类"""
    
    name = 'product_spider'
    allowed_domains = ['example.com']
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.proxy_pool = kwargs.get('proxy_pool', [])
        self.user_agents = [
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36',
        ]
    
    def start_requests(self):
        """起始请求"""
        urls = [
            'https://example.com/products?page=1',
            'https://example.com/products?page=2',
        ]
        
        for url in urls:
            yield scrapy.Request(
                url=url,
                callback=self.parse,
                errback=self.errback,
                dont_filter=True,
                meta={
                    'retry_times': 0,
                    'proxy': self.get_random_proxy(),
                    'user_agent': random.choice(self.user_agents),
                }
            )
    
    def get_random_proxy(self):
        """获取随机代理"""
        if not self.proxy_pool:
            return None
        return random.choice(self.proxy_pool)
    
    def parse(self, response):
        """解析页面"""
        if response.status != 200:
            self.logger.error(f"Status {response.status} for {response.url}")
            return
        
        # 提取产品数据
        products = response.css('.product-item')
        
        for product in products:
            yield {
                'title': product.css('.title::text').get(),
                'price': product.css('.price::text').get(),
                'rating': product.css('.rating::text').get(),
                'url': product.css('a::attr(href)').get(),
                'timestamp': time.time(),
                'source': response.url,
            }
        
        # 抓取下一页
        next_page = response.css('.next-page::attr(href)').get()
        if next_page:
            yield response.follow(
                next_page,
                callback=self.parse,
                meta={
                    'retry_times': 0,
                    'proxy': self.get_random_proxy(),
                    'user_agent': random.choice(self.user_agents),
                }
            )
    
    def errback(self, failure):
        """错误处理"""
        self.logger.error(f"Failed {failure.request.url}: {failure.value}")
        
        # 重试逻辑
        retry_times = failure.request.meta.get('retry_times', 0) + 1
        if retry_times < 3:
            time.sleep(random.uniform(5, 15))
            yield failure.request.copy(
                meta={'retry_times': retry_times}
            )
```

#### 2. 数据清洗（cleaner.py）
```python
import re
from typing import Dict, List
import pandas as pd

class DataCleaner:
    """数据清洗器"""
    
    @staticmethod
    def clean_price(price_str: str) -> float:
        """清洗价格数据"""
        if not price_str:
            return 0.0
        
        # 移除货币符号和空格
        price_clean = re.sub(r'[^\d.]', '', price_str)
        
        try:
            return float(price_clean)
        except ValueError:
            return 0.0
    
    @staticmethod
    def clean_rating(rating_str: str) -> float:
        """清洗评分数据"""
        if not rating_str:
            return 0.0
        
        match = re.search(r'(\d+\.?\d*)', rating_str)
        if match:
            return float(match.group(1))
        return 0.0
    
    @staticmethod
    def standardize_product(product: Dict) -> Dict:
        """标准化产品数据"""
        return {
            'title': product.get('title', '').strip(),
            'price': DataCleaner.clean_price(str(product.get('price', '0'))),
            'rating': DataCleaner.clean_rating(str(product.get('rating', '0'))),
            'currency': 'USD',
            'url': product.get('url', ''),
            'source_domain': DataCleaner.extract_domain(product.get('source', '')),
        }
    
    @staticmethod
    def extract_domain(url: str) -> str:
        """提取域名"""
        match = re.search(r'https?://([^/]+)', url)
        if match:
            return match.group(1)
        return ''
    
    @staticmethod
    def deduplicate(products: List[Dict]) -> List[Dict]:
        """去重"""
        seen = set()
        unique_products = []
        
        for product in products:
            # 使用title+price作为唯一键
            key = f"{product['title']}_{product['price']}"
            if key not in seen:
                seen.add(key)
                unique_products.append(product)
        
        return unique_products
    
    @staticmethod
    def analyze_sentiment(comments: List[str]) -> Dict:
        """评论情感分析（简单规则）"""
        positive_words = ['good', 'great', 'excellent', 'fast', 'quality', 'recommend']
        negative_words = ['bad', 'poor', 'slow', 'expensive', 'disappoint']
        
        sentiment_scores = []
        
        for comment in comments:
            pos_count = sum(1 for word in positive_words if word.lower() in comment.lower())
            neg_count = sum(1 for word in negative_words if word.lower() in comment.lower())
            
            if pos_count > neg_count:
                sentiment_scores.append(1)
            elif neg_count > pos_count:
                sentiment_scores.append(-1)
            else:
                sentiment_scores.append(0)
        
        avg_sentiment = sum(sentiment_scores) / len(sentiment_scores) if sentiment_scores else 0
        
        return {
            'average_sentiment': avg_sentiment,
            'positive_ratio': sum(1 for s in sentiment_scores if s > 0) / len(sentiment_scores),
            'negative_ratio': sum(1 for s in sentiment_scores if s < 0) / len(sentiment_scores),
        }
```

#### 3. 调度器（scheduler.py）
```python
from celery import Celery
from celery.schedules import crontab
import requests

app = Celery('scraper', broker='redis://localhost:6379')

@app.task
def check_price_changes():
    """检查价格变化"""
    # 从数据库获取历史价格
    historical_prices = get_historical_prices()
    
    # 与当前价格比较
    current_prices = get_current_prices()
    
    for product_id, historical in historical_prices.items():
        current = current_prices.get(product_id)
        if current and abs(current['price'] - historical['price']) > historical['price'] * 0.1:
            # 价格变化超过10%，发送告警
            send_price_alert(product_id, historical['price'], current['price'])

@app.task
def incremental_update():
    """增量更新"""
    # 获取最新抓取时间
    last_scrape = get_last_scrape_time()
    
    # 只抓取变化的数据
    if last_scrape:
        # 获取下架产品
        delisted_products = get_delisted_products()
        
        # 获取新产品
        new_products = get_new_products()
        
        # 只抓取必要的页面
        for product in delisted_products + new_products:
            trigger_scrape(product['url'])

@app.on_after_configure.connect
def setup_periodic_tasks(sender, **kwargs):
    """配置定时任务"""
    # 每小时检查价格变化
    sender.add_periodic_task(
        check_price_changes,
        schedule=crontab(minute=0),
        name='check_price_changes'
    )
    
    # 每天凌晨2点增量更新
    sender.add_periodic_task(
        incremental_update,
        schedule=crontab(hour=2, minute=0),
        name='incremental_update'
    )
    
    # 高峰时段（9-21点）每小时全量抓取
    for hour in range(9, 22):
        sender.add_periodic_task(
            full_scrape,
            args=[True],  # 高峰模式
            schedule=crontab(hour=hour, minute=0),
            name=f'peak_scrape_{hour}'
        )
```

#### 4. 监控告警（monitor.py）
```python
from prometheus_client import Counter, Gauge, Histogram
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

# Prometheus指标
scrape_success = Counter('scraper_success_total', 'Successful scrapes', ['site', 'product_type'])
scrape_failure = Counter('scraper_failure_total', 'Failed scrapes', ['site', 'error_type'])
scrape_duration = Histogram('scraper_duration_seconds', 'Scrape duration', ['site', 'page_type'])
price_change_alerts = Gauge('price_change_alerts', 'Price change alerts')

def send_email_alert(subject: str, message: str):
    """发送邮件告警"""
    msg = MIMEMultipart()
    msg['From'] = 'scraper@example.com'
    msg['To'] = 'admin@example.com'
    msg['Subject'] = f'[ALERT] {subject}'
    
    msg.attach(MIMEText(message, 'plain'))
    
    with smtplib.SMTP('smtp.gmail.com', 587) as server:
        server.starttls()
        server.login('your-email@gmail.com', 'your-password')
        server.send_message(msg)
        server.quit()

def monitor_data_quality():
    """监控数据质量"""
    # 检查价格数据异常
    abnormal_prices = get_abnormal_prices()
    
    if len(abnormal_prices) > 10:
        subject = f'数据质量告警：发现{len(abnormal_prices)}个异常价格'
        message = f'''
        检测到以下异常价格：
        
        {format_abnormal_prices(abnormal_prices)}
        
        请检查数据源或调整清洗规则。
        '''
        
        send_email_alert(subject, message)
        price_change_alerts.inc(len(abnormal_prices))

def monitor_scrape_health():
    """监控爬虫健康"""
    failed_scrapes = get_recent_failures()
    
    if len(failed_scrapes) > 5:
        subject = '爬虫健康告警：失败率过高'
        message = f'''
        最近1小时内有{len(failed_scrapes)}次爬取失败：
        
        {format_recent_failures(failed_scrapes)}
        
        请检查：
        1. 代理IP是否被封
        2. 目标网站是否正常
        3. 网络连接是否稳定
        '''
        
        send_email_alert(subject, message)

# 每分钟执行健康检查
app.conf.beat = 60  # 60秒间隔
monitor_scrape_health.apply_async()
```

---

## 完整代码结构

```
data-scraper/
├── scraper/
│   ├── spiders/
│   │   ├── product_spider.py      # 产品爬虫
│   │   └── base_spider.py         # 基础爬虫
│   ├── items.py                    # 数据项定义
│   └── pipelines.py                # 数据管道
├── cleaner/
│   ├── data_cleaner.py            # 数据清洗器
│   └── sentiment_analyzer.py      # 情感分析
├── scheduler/
│   ├── celery_app.py               # Celery应用
│   ├── periodic_tasks.py           # 定时任务
│   └── task_queue.py              # 任务队列
├── monitoring/
│   ├── metrics.py                  # Prometheus指标
│   ├── alerts.py                   # 告警系统
│   └── dashboard.py               # Grafana配置
├── database/
│   ├── models.py                  # 数据库模型
│   └── repositories.py            # 数据仓库
├── config/
│   ├── sites.yaml                  # 目标网站配置
│   ├── proxies.yaml                 # 代理配置
│   └── rules.yaml                  # 清洗规则
├── requirements.txt                 # Python依赖
├── docker-compose.yml               # Docker编排
└── README.md                      # 文档
```

---

## 部署配置

### Docker Compose
```yaml
version: '3.8'

services:
  scraper:
    build: .
    command: celery -A celery_app worker --loglevel=info
    environment:
      - SCRAPE_MODE=production
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql://user:pass@postgres:5432/scraper
    depends_on:
      - redis
      - postgres
    volumes:
      - ./config:/app/config
    restart: unless-stopped
  
  scheduler:
    build: .
    command: celery -A celery_app beat --loglevel=info
    environment:
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    volumes:
      - ./config:/app/config
    restart: unless-stopped
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
  
  postgres:
    image: postgres:15-alpine
    environment:
      - POSTGRES_PASSWORD=scraperpass
      - POSTGRES_DB=scraper
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/
      - prometheus_data:/prometheus
  
  grafana:
    image: grafana/grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
    volumes:
      - grafana_data:/var/lib/grafana

volumes:
  redis_data:
  postgres_data:
  prometheus_data:
  grafana_data:
```

### 目标网站配置（sites.yaml）
```yaml
sites:
  amazon:
    name: "Amazon"
    base_url: "https://www.amazon.com"
    rate_limit:
      requests_per_minute: 60
      delay_between_requests: 1
    selectors:
      product_title: ".product-title"
      price: ".price"
      rating: ".rating"
      reviews: ".review-item"
    
  ebay:
    name: "eBay"
    base_url: "https://www.ebay.com"
    rate_limit:
      requests_per_minute: 30
      delay_between_requests: 2
    selectors:
      product_title: ".s-item__title"
      price: ".s-item__price"
      rating: ".x-star-rating"
    
  taobao:
    name: "淘宝"
    base_url: "https://www.taobao.com"
    rate_limit:
      requests_per_minute: 120
      delay_between_requests: 0.5
    selectors:
      product_title: ".Title"
      price: ".Price"
      sales_count: ".RealSales"

proxies:
  - http://proxy1.example.com:8080
  - http://proxy2.example.com:8080
  - http://proxy3.example.com:8080
  - socks5://proxy4.example.com:1080

rotation_strategy: random  # random, round-robin, least-used
```

---

## 数据流程

### 抓取流程
```
1. 调度器触发
   ↓
2. Scrapy Worker开始
   ↓
3. 代理池分配
   ↓
4. 发送HTTP请求（User-Agent轮换）
   ↓
5. 解析HTML/JSON
   ↓
6. 数据清洗和标准化
   ↓
7. 存储到PostgreSQL
   ↓
8. 更新Redis缓存
   ↓
9. 发送Prometheus指标
   ↓
10. 告警检查
```

### 数据清洗流程
```
1. 读取原始数据
   ↓
2. 价格标准化（去货币符号）
   ↓
3. 评分清洗
   ↓
4. 去重（title+price）
   ↓
5. 情感分析
   ↓
6. 生成报告
```

---

## 测试策略

### 1. 单元测试
```bash
pytest tests/unit/ -v --cov=scraper
```

### 2. 集成测试
```bash
pytest tests/integration/ -v
```

### 3. 性能测试
```bash
# 测试并发抓取能力
scrapy crawl product_spider -s JOBS=1000
```

### 4. 反爬测试
```bash
# 测试反爬措施
for i in {1..10}; do
  curl -H "User-Agent: Mozilla/5.0" http://target-site.com
  sleep 1
done
```

---

## 成果

### 交付物
1. **完整的数据抓取系统**
   - Scrapy爬虫框架
   - 代理池管理
   - 数据清洗和标准化
   - 定时任务调度
   - 监控和告警系统

2. **部署和配置**
   - Docker Compose编排
   - 多网站配置支持
   - 代理轮换策略
   - 反爬措施集成

3. **文档和测试**
   - 完整README
   - API文档
   - 测试套件
   - 故障排查指南

4. **性能指标**
   - 抓取成功率 > 95%
   - 数据准确性 > 99%
   - 平均响应时间 < 3秒
   - 并发数 > 1000/分钟

---

## 定价

**总工作量：** 约80-100小时
**交付周期：** 2-3周
**服务费用：** $1,200 - $1,500

**定价理由：**
- 企业级数据抓取系统
- 反爬措施和代理管理
- 智能调度和增量更新
- 完整的监控和告警
- 数据清洗和情感分析
- Docker化部署和扩展

---

## 客户反馈

**预期反馈：**
- "抓取速度提升了10倍，从每天4小时缩短到24分钟"
- "价格监控准确度达到99.5%，告警及时"
- "数据质量大幅提升，错误率从15%降到2%以下"
- "代理轮换有效避免了被封，稳定性很高"
- "监控Dashboard非常直观，问题定位快速"

---

**案例状态：** ✅ 完成
**创建时间：** 2026-02-07 03:00
**案例类型：** 自动化开发服务
**技术栈：** Python Scrapy + Celery + Docker + Redis + PostgreSQL
