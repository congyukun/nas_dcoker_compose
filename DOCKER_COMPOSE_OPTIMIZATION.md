# Docker Compose 配置优化报告

## 📋 当前配置分析

### ✅ 优点
1. **结构清晰**：服务按功能分类（影视核心、实用工具、管理面板、音乐服务、网络代理）
2. **健康检查完善**：大部分服务都配置了健康检查
3. **资源限制**：设置了内存限制和预留
4. **日志管理**：统一配置了日志轮转（10MB，保留3个文件）
5. **网络隔离**：使用自定义网络 `app-network`
6. **依赖管理**：正确使用 `depends_on` 和健康检查条件

### ⚠️ 发现的问题

#### 1. 服务编号重复
- **问题**：第 19 号同时分配给 `solara-music` 和 `clash`
- **位置**：第 671 行和第 709 行
- **建议**：将 `clash` 改为第 20 号

#### 2. 注释服务中的语法错误
- **Alist 服务**（第 788 行）：
  ```yaml
  - Ttart: always
  ```
  应该改为：
  ```yaml
  - TZ=${TZ}
  #   restart: always
  ```

- **Lucky 服务**（第 853 行）：
  ```yaml
  - TZ=${Tlumes:
  ```
  应该改为：
  ```yaml
  - TZ=${TZ}
  #   volumes:
  ```

#### 3. 端口冲突风险
- **MoviePilot** 和 **Solara-Music** 都使用端口 3001
  - MoviePilot: `${MOVIEPILOT_API_PORT}:3001`
  - Solara-Music: `3001:3001`（硬编码）
- **建议**：将 Solara-Music 改为使用环境变量或不同端口

## 🔧 优化建议

### 1. 统一配置风格

#### 端口配置
将所有硬编码端口改为环境变量：
```yaml
# solara-music 当前配置
ports:
  - "3001:3001"

# 建议改为
ports:
  - "${SOLARA_MUSIC_PORT}:3001"
```

#### 环境变量
将硬编码的密码和密钥移到 .env 文件：
```yaml
# 当前配置
environment:
  - SOLARA_PASSWORD=solara123
  - SESSION_SECRET=KLmlKDruIBRYjrT5ct7B3xqG25ZF2p59

# 建议改为
environment:
  - SOLARA_PASSWORD=${SOLARA_PASSWORD}
  - SESSION_SECRET=${SOLARA_SESSION_SECRET}
```

### 2. 添加缺失的健康检查

以下服务缺少健康检查：
- `autoheal`
- `clash`

建议添加：
```yaml
clash:
  healthcheck:
    test: ["CMD-SHELL", "nc -z localhost 7890 || exit 1"]
    interval: 30s
    timeout: 10s
    retries: 3
    start_period: 30s
```

### 3. 优化资源配置

#### 数据库服务优化
PostgreSQL 和 MySQL 可以添加性能优化参数：

```yaml
postgresql:
  environment:
    - POSTGRES_SHARED_BUFFERS=256MB
    - POSTGRES_MAX_CONNECTIONS=100
    - POSTGRES_WORK_MEM=4MB

mysql:
  command: >
    --character-set-server=utf8mb4
    --collation-server=utf8mb4_unicode_ci
    --max_connections=200
    --innodb_buffer_pool_size=512M
```

### 4. 安全性增强

#### 敏感信息保护
确保 `.env` 文件在 `.gitignore` 中：
```gitignore
.env
*.env
!env.sample
```

#### 只读挂载
对于不需要写入的卷，使用只读模式：
```yaml
volumes:
  - ${MUSIC_PATH}:/music:ro  # ✅ 已正确使用
  - ${MEDIA_PATH}:/media:ro  # 建议添加
```

### 5. 服务启动顺序优化

建议的启动顺序：
1. **基础服务**：PostgreSQL, MySQL, Redis
2. **核心服务**：MoviePilot, Qbittorrent
3. **辅助服务**：其他应用服务
4. **监控服务**：AutoHeal

可以通过调整 `depends_on` 来优化。

### 6. 备份策略

建议添加备份服务或脚本：
```yaml
# 数据库备份示例
backup:
  image: prodrigestivill/postgres-backup-local
  restart: always
  volumes:
    - ./backups:/backups
  environment:
    - POSTGRES_HOST=postgresql
    - POSTGRES_DB=${POSTGRES_DB}
    - POSTGRES_USER=${POSTGRES_USER}
    - POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
    - SCHEDULE=@daily
    - BACKUP_KEEP_DAYS=7
  depends_on:
    - postgresql
  networks:
    - app-network
```

### 7. 监控和日志

#### 添加监控服务
考虑添加 Prometheus + Grafana 进行监控：
```yaml
prometheus:
  image: prom/prometheus:latest
  container_name: prometheus
  volumes:
    - ./prometheus/config:/etc/prometheus
    - ./prometheus/data:/prometheus
  ports:
    - "9090:9090"
  networks:
    - app-network
```

#### 集中日志管理
考虑使用 Loki 或 ELK 栈进行日志聚合。

### 8. 网络优化

#### 子网配置
当前配置使用 `/16` 子网，可能过大：
```yaml
# 当前配置
config:
  - subnet: ${NETWORK_SUBNET}/16

# 建议改为
config:
  - subnet: ${NETWORK_SUBNET}/24
```

#### 服务间通信
对于不需要外部访问的服务，可以不暴露端口：
```yaml
# PostgreSQL 和 MySQL 不需要暴露到主机
postgresql:
  # ports:  # 注释掉，只在容器网络内访问
  #   - "5432:5432"
```

## 📝 立即需要修复的问题

### 优先级 1（高）
1. ✅ 修复服务编号重复（solara-music 和 clash）
2. ⚠️ 修复端口冲突（MoviePilot 和 Solara-Music 的 3001 端口）
3. ⚠️ 修复注释服务中的语法错误

### 优先级 2（中）
1. 将 Solara-Music 的硬编码配置改为环境变量
2. 为 Clash 添加健康检查
3. 优化数据库性能参数

### 优先级 3（低）
1. 添加备份策略
2. 添加监控服务
3. 优化网络子网配置

## 🚀 实施步骤

1. **备份当前配置**
   ```bash
   cp docker-compose.yaml docker-compose.yaml.backup
   ```

2. **修复高优先级问题**
   - 修改服务编号
   - 解决端口冲突
   - 修复语法错误

3. **更新 .env 文件**
   添加新的环境变量

4. **测试配置**
   ```bash
   docker-compose config
   ```

5. **逐步重启服务**
   ```bash
   docker-compose up -d --no-deps <service_name>
   ```

## 📊 性能建议

### 内存分配建议
根据服务器总内存调整：

| 服务 | 当前限制 | 建议（16GB 服务器） | 建议（32GB 服务器） |
|------|---------|-------------------|-------------------|
| MoviePilot | 变量 | 2GB | 4GB |
| PostgreSQL | 变量 | 1GB | 2GB |
| MySQL | 变量 | 1GB | 2GB |
| Redis | 变量 | 512MB | 1GB |
| PanSou | 2GB | 2GB | 4GB |
| Qbittorrent | 变量 | 2GB | 4GB |

### 磁盘 I/O 优化
对于数据库服务，考虑使用 SSD 存储：
```yaml
volumes:
  - type: bind
    source: ./postgresql/data
    target: /var/lib/postgresql/data
    bind:
      propagation: rprivate
```

## 🔍 监控指标

建议监控以下指标：
- CPU 使用率
- 内存使用率
- 磁盘 I/O
- 网络流量
- 容器健康状态
- 日志错误率

## 📚 参考资源

- [Docker Compose 最佳实践](https://docs.docker.com/compose/production/)
- [容器安全指南](https://docs.docker.com/engine/security/)
- [性能调优指南](https://docs.docker.com/config/containers/resource_constraints/)
