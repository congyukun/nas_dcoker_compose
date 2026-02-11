# NAS Docker Compose

基于 Docker Compose 的 NAS 服务集合，包含影视管理、音乐服务、云盘工具等多个实用服务。

## 📁 项目结构

```
nas_dcoker_compose/
├── .env                    # 环境变量配置文件
├── docker-compose.yaml     # Docker Compose 配置文件
├── services/               # 所有服务的配置和数据目录
│   ├── qbittorrent/       # 下载器
│   ├── moviepilot/        # 影视自动化管理
│   ├── postgresql/        # PostgreSQL 数据库
│   ├── redis/             # Redis 缓存
│   ├── mysql/             # MySQL 数据库
│   ├── navidrome/         # 音乐服务器
│   ├── music-scraper/     # 音乐刮削器
│   ├── quark-auto-save/   # 夸克自动转存
│   ├── cloudsaver/        # 云盘资源保存
│   ├── pancheck/          # 网盘链接检测
│   ├── omnibox/           # 全能工具箱
│   ├── openlist/          # 文件列表服务
│   ├── clouddrive2/       # 云盘挂载
│   ├── sunpanel/          # 导航面板
│   ├── xiaomusic_conf/    # 小爱音乐配置
│   ├── playlistdl/        # 歌单下载工具
│   ├── solara-music/      # 音乐流媒体
│   ├── qm-music/          # QM音乐服务器
│   ├── qinglong/          # 青龙面板
│   ├── chromium/          # Chromium浏览器
│   └── clash-ui/          # 网络代理
└── storage/               # 通用存储目录
```

## 🚀 快速开始

### 1. 克隆项目

```bash
git clone <repository-url>
cd nas_dcoker_compose
```

### 2. 配置环境变量

复制示例配置文件并根据需要修改：

```bash
cp env.smple .env
```

编辑 `.env` 文件，配置必要的参数：
- 用户 ID 和组 ID (PUID/PGID)
- 时区 (TZ)
- 各服务的端口
- 数据库密码
- 媒体路径等

### 3. 启动服务

启动所有服务（不包括 Clash）：

```bash
docker compose up -d
```

启动特定服务：

```bash
docker compose up -d qbittorrent moviepilot
```

启动包含 Clash 的所有服务：

```bash
docker compose -f docker-compose.yaml -f docker-compose.clash.yaml up -d
```

仅启动 Clash 服务：

```bash
docker compose -f docker-compose.yaml -f docker-compose.clash.yaml up -d clash
```

### 4. 查看服务状态

```bash
docker compose ps
```

查看服务日志：

```bash
docker compose logs -f [service-name]
```

## 📦 服务说明

### 影视核心服务
- **Qbittorrent**: BT/PT 下载器 - `http://your-ip:8080`
- **MoviePilot v2**: 自动化媒体管理中心 - `http://your-ip:3003`
- **PostgreSQL**: MoviePilot 数据库（内部服务）
- **Redis**: 缓存服务（MoviePilot + PanCheck 共享，内部服务）

### 音乐服务
- **Navidrome**: 音乐流媒体服务器 - `http://your-ip:4533`
- **Music-Scraper**: 音乐元数据刮削器 - `http://your-ip:7301`
- **SQMusic**: 简单音乐播放器 - `http://your-ip:8222`
- **XiaoMusic**: 小爱同学本地音乐服务 - `http://your-ip:58090`
- **PlaylistDL**: 音乐歌单批量下载工具 - `http://your-ip:4827`
- **Solara-Music**: 在线音乐流媒体服务 - `http://your-ip:3012`
- **QM-Music**: 私人音乐服务器，支持Subsonic API和中文曲库 - `http://your-ip:6688`

### 云盘工具
- **Quark-auto-save**: 夸克网盘自动转存 - `http://your-ip:5005`
- **CloudSaver**: 云盘资源保存工具 - `http://your-ip:8009`
- **PanCheck**: 网盘链接检测系统 - `http://your-ip:8081`
- **PanSou**: 多网盘资源聚合搜索 - `http://your-ip:8888`
- **CloudNAS**: CloudDrive2 云盘挂载 - `http://your-ip:19798`

### 实用工具
- **Omnibox**: Lampon 全能工具箱 - `http://your-ip:7023`
- **OpenList**: 文件列表服务 - `http://your-ip:5244`
- **Sun-Panel**: 导航面板 - `http://your-ip:13002`
- **Qinglong**: 青龙面板（定时任务管理）- `http://your-ip:15700`
- **AutoHeal**: 自动健康检查和重启服务（后台服务）

### 浏览器服务
- **Chromium**: Web 浏览器 - `http://your-ip:3102` (HTTP) / `https://your-ip:3103` (HTTPS)

### 网络服务
- **Clash**: 网络代理服务 - `http://your-ip:1123` (UI) / `http://your-ip:7890` (代理端口)

### 数据库服务
- **MySQL**: 数据库服务（PanCheck + SQMusic 共享，内部服务）

## 🔧 维护命令

### 停止服务

```bash
docker compose down
```

### 更新服务

```bash
docker compose pull
docker compose up -d
```

### 清理未使用的资源

```bash
docker system prune -a
```

## 📝 注意事项

1. **数据持久化**: 所有服务的配置和数据都存储在 `services/` 目录下
2. **Git 忽略**: `services/` 目录下的所有内容已被 `.gitignore` 忽略，不会提交到版本控制
3. **端口冲突**: 启动前请确保配置的端口未被占用
4. **资源限制**: 已为各服务配置了内存限制，可根据实际情况调整
5. **健康检查**: 大部分服务都配置了健康检查，确保服务正常运行
6. **Clash 独立配置**: Clash 服务已独立到 `docker-compose.clash.yaml`，该文件已添加到 `.gitignore`，不会提交到 Git

## 🌐 Clash 网络代理配置

Clash 服务已独立到 `docker-compose.clash.yaml` 文件中，避免将代理配置提交到 Git。

### 首次使用

1. 复制 Clash 配置文件（如果不存在）：
```bash
cp docker-compose.clash.yaml.example docker-compose.clash.yaml  # 如果有示例文件
```

2. 配置 Clash 订阅或规则文件到 `./services/clash-ui/` 目录

3. 启动 Clash 服务：
```bash
docker compose -f docker-compose.yaml -f docker-compose.clash.yaml up -d clash
```

### 管理 Clash 服务

```bash
# 启动 Clash
docker compose -f docker-compose.yaml -f docker-compose.clash.yaml up -d clash

# 停止 Clash
docker compose -f docker-compose.yaml -f docker-compose.clash.yaml stop clash

# 查看 Clash 日志
docker compose -f docker-compose.yaml -f docker-compose.clash.yaml logs -f clash

# 重启 Clash
docker compose -f docker-compose.yaml -f docker-compose.clash.yaml restart clash
```

### Clash 访问地址

- **Web UI**: `http://your-ip:1123`
- **HTTP 代理**: `http://your-ip:7890`
- **SOCKS5 代理**: `socks5://your-ip:7891`
- **DNS 服务**: `your-ip:1053`

## 🔐 安全建议

1. 修改 `.env` 文件中的默认密码
2. 不要将 `.env` 文件提交到公共仓库
3. 定期备份 `services/` 目录下的重要数据
4. 使用强密码保护各服务的 Web 界面

## 📄 许可证

# 如果对你有用请我喝杯coffee

<img src="微信图片_20260210164647_68_158.png" width="200"/> <img src="微信图片_20260210164646_67_158.jpg" width="200"/>

本项目仅供个人学习和使用。
