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

启动所有服务：

```bash
docker compose up -d
```

启动特定服务：

```bash
docker compose up -d qbittorrent moviepilot
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
- **Qbittorrent**: BT/PT 下载器
- **MoviePilot v2**: 自动化媒体管理中心
- **PostgreSQL**: MoviePilot 数据库
- **Redis**: 缓存服务（MoviePilot + PanCheck 共享）

### 音乐服务
- **Navidrome**: 音乐流媒体服务器
- **Music-Scraper**: 音乐元数据刮削器
- **XiaoMusic**: 小爱同学本地音乐服务
- **PlaylistDL**: 音乐歌单批量下载工具
- **Solara-Music**: 在线音乐流媒体服务
- **QM-Music**: 私人音乐服务器，支持Subsonic API和中文曲库

### 云盘工具
- **Quark-auto-save**: 夸克网盘自动转存
- **CloudSaver**: 云盘资源保存工具
- **PanCheck**: 网盘链接检测系统
- **PanSou**: 多网盘资源聚合搜索
- **CloudNAS**: CloudDrive2 云盘挂载

### 实用工具
- **Omnibox**: Lampon 全能工具箱
- **OpenList**: 文件列表服务
- **Sun-Panel**: 导航面板

### 网络服务
- **Clash**: 网络代理服务

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

## 🔐 安全建议

1. 修改 `.env` 文件中的默认密码
2. 不要将 `.env` 文件提交到公共仓库
3. 定期备份 `services/` 目录下的重要数据
4. 使用强密码保护各服务的 Web 界面

## 📄 许可证

本项目仅供个人学习和使用。
