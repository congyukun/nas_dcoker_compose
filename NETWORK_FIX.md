# 网络冲突解决方案

## 问题原因
旧的 `nas_dcoker_compose_app-network` 网络与新配置的 `app-network` 使用相同的子网段 `172.20.0.0/16`，导致冲突。

## 解决方案 1：删除旧网络并重新创建（推荐）

### 步骤：
```bash
# 1. 停止所有使用旧网络的容器
sudo docker-compose down

# 2. 删除旧网络
sudo docker network rm nas_dcoker_compose_app-network

# 3. 重新启动服务（会自动创建新网络）
sudo docker-compose up -d
```

## 解决方案 2：使用现有网络

修改 `docker-compose.yaml`，使用外部网络：

```yaml
networks:
  app-network:
    external: true
    name: nas_dcoker_compose_app-network
```

然后运行：
```bash
sudo docker-compose up -d
```

## 解决方案 3：更改子网段

修改 `.env` 文件中的 `NETWORK_SUBNET`：

```bash
# 原值
NETWORK_SUBNET=172.20.0.0

# 改为其他未使用的子网段，例如：
NETWORK_SUBNET=172.20.0.0
# 或
NETWORK_SUBNET=172.21.0.0
# 或
NETWORK_SUBNET=10.10.0.0
```

然后运行：
```bash
sudo docker-compose up -d
```

## 推荐方案
**使用方案 1**，因为：
- 清理旧配置，避免混乱
- 使用新的优化配置
- 网络名称更简洁（app-network vs nas_dcoker_compose_app-network）
