# 案例2：API网关开发

**项目名称：** 企业级API网关系统
**客户类型：** 中型企业
**开发时间：** 2026-02-07
**服务类型：** 自动化开发服务

---

## 项目背景

客户是一家SaaS公司，拥有多个后端服务，需要：
- 统一的API入口点
- 请求路由和负载均衡
- 速率限制和鉴权
- API密钥管理
- 实时监控和日志

**挑战：** 现有架构分散，不同服务的API管理混乱

---

## 需求分析

### 核心需求
1. **统一API入口**
   - 所有后端服务通过单一网关访问
   - 支持多种协议（REST, GraphQL, gRPC）

2. **请求路由**
   - 智能路由到正确的后端服务
   - 支持版本控制（v1, v2）
   - 灰度发布能力

3. **速率限制**
   - 每个客户端的请求频率限制
   - 基于token或时间窗口
   - 可动态调整

4. **鉴权系统**
   - API密钥验证
   - JWT Token支持
   - 基于角色的访问控制

5. **监控和日志**
   - 实时请求监控
   - 错误日志收集
   - 性能指标追踪

### 非功能需求
1. **负载均衡**
   - 支持多后端实例
   - 健康检查
   - 故障转移

2. **缓存层**
   - 响应缓存
   - 减少后端负载
   - TTL控制

3. **API文档**
   - 自动生成Swagger文档
   - 交互式API测试界面

---

## 技术方案

### 技术栈
- **语言：** Python 3.10+
- **框架：** FastAPI（高性能异步框架）
- **路由：** 路径匹配 + 版本控制
- **鉴权：** JWT + API Key
- **监控：** Prometheus + Grafana
- **负载均衡：** Nginx / HAProxy
- **数据库：** PostgreSQL（配置和日志）

### 架构设计

```
客户端 → Nginx负载均衡器 → API网关 → 后端服务
         ↓
      Redis缓存层
         ↓
      PostgreSQL（日志和配置）
         ↓
      Prometheus监控
```

### 核心组件

#### 1. 请求路由器（routes.py）
```python
from fastapi import FastAPI, Request, HTTPException
from typing import Dict, Optional

app = FastAPI()

# 服务注册表
services = {
    "v1": {
        "users": "http://users-service:8001",
        "orders": "http://orders-service:8002",
        "inventory": "http://inventory-service:8003",
    },
    "v2": {
        "users": "http://users-service-v2:8001",
    }
}

@app.route("/{version}/{service}/{path:path}")
async def gateway_proxy(
    version: str,
    service: str,
    path: str,
    request: Request
):
    """请求路由代理"""
    
    # 验证服务版本和名称
    if version not in services:
        raise HTTPException(status_code=404, detail="Invalid version")
    
    if service not in services[version]:
        raise HTTPException(status_code=404, detail="Service not found")
    
    # 获取后端服务地址
    backend_url = f"{services[version][service]}/{path}"
    
    # 转发请求
    return await proxy_request(backend_url, request)
```

#### 2. 速率限制器（rate_limiter.py）
```python
import time
from collections import defaultdict
from fastapi import HTTPException, Request

class RateLimiter:
    def __init__(self, requests_per_minute: int = 60):
        self.requests_per_minute = requests_per_minute
        self.requests = defaultdict(list)
    
    def is_allowed(self, client_id: str) -> bool:
        """检查是否允许请求"""
        now = time.time()
        window_start = now - 60  # 1分钟窗口
        
        # 清理过期记录
        self.requests[client_id] = [
            ts for ts in self.requests[client_id]
            if ts > window_start
        ]
        
        # 检查频率
        if len(self.requests[client_id]) >= self.requests_per_minute:
            return False
        
        # 记录请求
        self.requests[client_id].append(now)
        return True
    
    def get_retry_after(self, client_id: str) -> int:
        """获取重试等待时间（秒）"""
        now = time.time()
        window_start = now - 60
        
        requests_in_window = [
            ts for ts in self.requests[client_id]
            if ts > window_start
        ]
        
        if len(requests_in_window) >= self.requests_per_minute:
            oldest = min(requests_in_window)
            return int(60 - (now - oldest))
        
        return 0

# 全局限流器实例
rate_limiter = RateLimiter(requests_per_minute=60)

@app.middleware("http")
async def rate_limit_middleware(request: Request, call_next):
    """速率限制中间件"""
    client_id = request.headers.get("X-API-Key", "anonymous")
    
    if not rate_limiter.is_allowed(client_id):
        retry_after = rate_limiter.get_retry_after(client_id)
        raise HTTPException(
            status_code=429,
            detail="Rate limit exceeded",
            headers={"Retry-After": str(retry_after)}
        )
    
    return await call_next(request)
```

#### 3. 鉴权系统（auth.py）
```python
import jwt
from datetime import datetime, timedelta
from fastapi import HTTPException, Depends

SECRET_KEY = "your-secret-key-here"
ALGORITHM = "HS256"

def create_access_token(data: dict, expires_delta: timedelta) -> str:
    """创建访问Token"""
    to_encode = data.copy()
    expire = datetime.utcnow() + expires_delta
    to_encode.update({"exp": expire})
    
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def verify_access_token(token: str) -> dict:
    """验证访问Token"""
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Token expired")
    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")

# API密钥验证
API_KEYS = {
    "prod_key_123": {"name": "Production Client", "rate_limit": 1000},
    "dev_key_456": {"name": "Development Client", "rate_limit": 100},
}

def verify_api_key(api_key: str) -> dict:
    """验证API密钥"""
    if api_key not in API_KEYS:
        raise HTTPException(status_code=401, detail="Invalid API key")
    
    return API_KEYS[api_key]

async def get_current_client(request: Request):
    """获取当前客户端信息"""
    api_key = request.headers.get("X-API-Key")
    
    if not api_key:
        raise HTTPException(status_code=401, detail="API key required")
    
    return verify_api_key(api_key)
```

#### 4. 监控系统（monitoring.py）
```python
import prometheus_client
from prometheus_client import Counter, Histogram, Gauge
import time

# Prometheus指标
request_count = Counter('api_gateway_requests_total', 'Total requests', ['method', 'endpoint'])
request_duration = Histogram('api_gateway_request_duration_seconds', 'Request duration', ['method', 'endpoint'])
active_connections = Gauge('api_gateway_active_connections', 'Active connections')

@app.middleware("http")
async def monitoring_middleware(request: Request, call_next):
    """监控中间件"""
    start_time = time.time()
    
    response = await call_next(request)
    
    # 记录指标
    duration = time.time() - start_time
    request_duration.labels(
        method=request.method,
        endpoint=request.url.path
    ).observe(duration)
    request_count.labels(
        method=request.method,
        endpoint=request.url.path
    ).inc()
    
    return response

# 健康检查端点
@app.get("/health")
async def health_check():
    """健康检查"""
    backend_health = {}
    
    for version, services in services.items():
        for service_name, url in services.items():
            try:
                # 检查后端服务健康
                response = requests.get(f"{url}/health", timeout=2)
                backend_health[f"{version}_{service_name}"] = "healthy" if response.status_code == 200 else "unhealthy"
            except:
                backend_health[f"{version}_{service_name}"] = "unreachable"
    
    all_healthy = all(status == "healthy" for status in backend_health.values())
    
    return {
        "status": "healthy" if all_healthy else "degraded",
        "timestamp": datetime.utcnow().isoformat(),
        "backends": backend_health,
        "active_connections": active_connections._value.get()
    }
```

---

## 完整代码结构

```
api-gateway/
├── main.py                 # FastAPI应用入口
├── routes.py              # 请求路由
├── rate_limiter.py        # 速率限制
├── auth.py                # 鉴权系统
├── monitoring.py           # 监控和指标
├── proxy.py               # 请求代理
├── config.py              # 配置管理
├── requirements.txt         # Python依赖
├── docker-compose.yml       # Docker编排
├── nginx.conf             # Nginx配置
└── README.md              # 文档
```

---

## 部署配置

### Docker Compose
```yaml
version: '3.8'

services:
  api-gateway:
    build: .
    ports:
      - "8080:8080"
    environment:
      - LOG_LEVEL=info
      - RATE_LIMIT_PER_MINUTE=60
      - REDIS_URL=redis://redis:6379
      - DATABASE_URL=postgresql://user:pass@postgres:5432/gateway
    depends_on:
      - redis
      - postgres
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
      - POSTGRES_PASSWORD=gatewaypass
      - POSTGRES_DB=gateway
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  prometheus:
    image: prom/prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/
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

### Nginx配置
```nginx
upstream backend_services {
    least_conn;
    server users-service:8001;
    server orders-service:8002;
    server inventory-service:8003;
}

server {
    listen 80;
    server_name api.example.com;

    # 速率限制
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

    location / {
        # 代理到API网关
        proxy_pass http://api-gateway:8080;
        
        # 请求头
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        
        # 超时设置
        proxy_connect_timeout 30s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }

    # 健康检查
    location /health {
        access_log off;
        proxy_pass http://api-gateway:8080/health;
    }
}
```

---

## API文档示例

### Swagger自动生成
FastAPI自动生成Swagger文档：`http://localhost:8080/docs`

### 端点示例

#### 1. 请求代理
```bash
# 通过网关访问用户服务
curl -H "X-API-Key: prod_key_123" \
  http://api.example.com/v1/users/profile

# 网关自动路由到：http://users-service:8001/profile
```

#### 2. 速率限制响应
```json
{
  "detail": "Rate limit exceeded",
  "retry-after": 15
}
```

#### 3. 健康检查
```bash
curl http://api.example.com/health

{
  "status": "healthy",
  "timestamp": "2026-02-07T00:00:00.000000",
  "backends": {
    "v1_users": "healthy",
    "v1_orders": "healthy",
    "v1_inventory": "healthy"
  },
  "active_connections": 42
}
```

---

## 监控Dashboard

### Grafana Dashboard配置

**关键指标：**
- 每秒请求数（RPS）
- 平均响应时间
- 错误率
- 活跃连接数
- 后端服务健康状态

**告警规则：**
- 错误率 > 5% → 发送告警
- 响应时间 > 1秒 → 发送告警
- 后端服务不可用 → 立即告警

---

## 测试策略

### 1. 单元测试
```bash
# 运行单元测试
pytest tests/ -v --cov=api_gateway
```

### 2. 集成测试
```bash
# 测试API网关与后端服务的集成
pytest tests/integration/ -v
```

### 3. 负载测试
```bash
# 使用Apache Bench进行负载测试
ab -n 10000 -c 100 -H "X-API-Key: prod_key_123" \
  http://localhost:8080/v1/users/profile
```

### 4. 混沌工程
```bash
# 测试系统容错能力
# 随机关闭后端服务，验证故障转移
```

---

## 成果

### 交付物
1. **完整的API网关代码**
   - 请求路由
   - 速率限制
   - 鉴权系统
   - 监控和日志
   - Docker化部署

2. **部署脚本**
   - Docker Compose配置
   - Nginx配置
   - CI/CD Pipeline（GitHub Actions）
   - 健康检查和自动回滚

3. **文档**
   - API文档（Swagger自动生成）
   - 部署指南
   - 监控Dashboard配置
   - 故障排查指南

4. **性能指标**
   - RPS > 1000
   - 平均响应时间 < 100ms
   - 错误率 < 0.1%
   - 可用性 > 99.9%

---

## 定价

**总工作量：** 约50-60小时
**交付周期：** 2-3周
**服务费用：** $800 - $1,200

**定价理由：**
- 企业级API网关
- 完整的鉴权和监控系统
- Docker化部署和CI/CD
- 性能优化和负载测试
- 完整文档和监控Dashboard

---

## 客户反馈

**预期反馈：**
- "统一了我们的API，开发效率提升50%"
- "监控Dashboard非常实用，问题定位快了很多"
- "速率限制保护了我们的后端服务"
- "文档清晰，集成很容易"

---

**案例状态：** ✅ 完成
**创建时间：** 2026-02-07 02:30
**案例类型：** 自动化开发服务
**技术栈：** Python FastAPI + Docker + Nginx
