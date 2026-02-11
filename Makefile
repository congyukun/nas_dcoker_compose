# NAS Docker Compose Makefile
# 用于管理 Docker Compose 服务

# 颜色定义
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[1;33m
BLUE := \033[0;34m
NC := \033[0m # No Color

# 配置文件
COMPOSE_FILE := docker-compose.yaml
CLASH_FILE := docker-compose.clash.yaml
DOCKER_CMD := $(shell command -v docker 2>/dev/null || echo /usr/bin/docker)
COMPOSE := $(DOCKER_CMD) compose

# 默认目标
.DEFAULT_GOAL := help

# 检查 Docker 是否安装
.PHONY: check-docker
check-docker:
	@if ! command -v $(DOCKER_CMD) >/dev/null 2>&1 && ! [ -x "/usr/bin/docker" ]; then \
		echo "$(RED)[ERROR]$(NC) Docker 未安装"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 使用 Docker: $(DOCKER_CMD)"

##@ 服务控制

.PHONY: start
start: check-docker ## 启动所有服务（不包括 Clash）
	@echo "$(BLUE)[INFO]$(NC) 启动所有服务（不包括 Clash）..."
	@$(COMPOSE) -f $(COMPOSE_FILE) up -d
	@echo "$(GREEN)[SUCCESS]$(NC) 服务启动完成"

.PHONY: start-all
start-all: check-docker ## 启动所有服务（包括 Clash）
	@echo "$(BLUE)[INFO]$(NC) 启动所有服务（包括 Clash）..."
	@if [ -f "$(CLASH_FILE)" ]; then \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) up -d; \
		echo "$(GREEN)[SUCCESS]$(NC) 所有服务启动完成"; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) 未找到 $(CLASH_FILE)，仅启动普通服务"; \
		$(COMPOSE) -f $(COMPOSE_FILE) up -d; \
	fi

.PHONY: start-clash
start-clash: check-docker ## 仅启动 Clash 服务
	@if [ ! -f "$(CLASH_FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 启动 Clash 服务..."
	@$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) up -d clash
	@echo "$(GREEN)[SUCCESS]$(NC) Clash 服务启动完成"

.PHONY: stop
stop: check-docker ## 停止所有服务
	@echo "$(BLUE)[INFO]$(NC) 停止所有服务..."
	@if [ -f "$(CLASH_FILE)" ]; then \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) down; \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) down; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 所有服务已停止"

.PHONY: stop-clash
stop-clash: check-docker ## 仅停止 Clash 服务
	@if [ ! -f "$(CLASH_FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 停止 Clash 服务..."
	@$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) stop clash
	@echo "$(GREEN)[SUCCESS]$(NC) Clash 服务已停止"

.PHONY: restart
restart: check-docker ## 重启所有服务（不包括 Clash）
	@echo "$(BLUE)[INFO]$(NC) 重启所有服务（不包括 Clash）..."
	@$(COMPOSE) -f $(COMPOSE_FILE) restart
	@echo "$(GREEN)[SUCCESS]$(NC) 服务重启完成"

.PHONY: restart-all
restart-all: check-docker ## 重启所有服务（包括 Clash）
	@echo "$(BLUE)[INFO]$(NC) 重启所有服务（包括 Clash）..."
	@if [ -f "$(CLASH_FILE)" ]; then \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) restart; \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) restart; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 服务重启完成"

.PHONY: restart-clash
restart-clash: check-docker ## 仅重启 Clash 服务
	@if [ ! -f "$(CLASH_FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 重启 Clash 服务..."
	@$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) restart clash
	@echo "$(GREEN)[SUCCESS]$(NC) Clash 服务重启完成"

##@ 监控和查看

.PHONY: status
status: check-docker ## 查看所有服务状态
	@echo "$(BLUE)[INFO]$(NC) 查看服务状态..."
	@if [ -f "$(CLASH_FILE)" ]; then \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) ps; \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) ps; \
	fi

.PHONY: stats
stats: check-docker ## 查看服务资源使用情况
	@echo "$(BLUE)[INFO]$(NC) 服务资源使用情况："
	@$(DOCKER_CMD) stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

.PHONY: list
list: check-docker ## 列出所有可用服务
	@echo "$(BLUE)[INFO]$(NC) 可用的服务列表："
	@echo ""
	@$(COMPOSE) -f $(COMPOSE_FILE) config --services | sort | sed 's/^/  - /'
	@echo ""
	@if [ -f "$(CLASH_FILE)" ]; then \
		echo "$(BLUE)[INFO]$(NC) Clash 服务（需使用 make start-all）："; \
		echo "  - clash"; \
		echo ""; \
	fi

.PHONY: logs
logs: check-docker ## 查看所有服务日志
	@echo "$(BLUE)[INFO]$(NC) 查看服务日志（Ctrl+C 退出）..."
	@if [ -f "$(CLASH_FILE)" ]; then \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) logs -f; \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) logs -f; \
	fi

.PHONY: logs-clash
logs-clash: check-docker ## 查看 Clash 服务日志
	@if [ ! -f "$(CLASH_FILE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 查看 Clash 日志（Ctrl+C 退出）..."
	@$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) logs -f clash

##@ 维护操作

.PHONY: pull
pull: check-docker ## 拉取最新镜像
	@echo "$(BLUE)[INFO]$(NC) 拉取最新镜像..."
	@$(COMPOSE) -f $(COMPOSE_FILE) pull
	@if [ -f "$(CLASH_FILE)" ]; then \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) pull clash; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 镜像拉取完成"

.PHONY: update
update: pull ## 更新并重启服务
	@echo "$(BLUE)[INFO]$(NC) 重启服务以应用更新..."
	@if [ -f "$(CLASH_FILE)" ]; then \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) up -d; \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) up -d; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 服务更新完成"

.PHONY: clean
clean: check-docker ## 清理未使用的容器、镜像和卷
	@echo "$(YELLOW)[WARNING]$(NC) 此操作将清理未使用的容器、镜像、网络和卷"
	@read -p "确认继续？(y/N): " confirm && [ "$$confirm" = "y" ] || [ "$$confirm" = "Y" ] || exit 1
	@echo "$(BLUE)[INFO]$(NC) 清理未使用的资源..."
	@$(DOCKER_CMD) system prune -a --volumes -f
	@echo "$(GREEN)[SUCCESS]$(NC) 清理完成"

.PHONY: backup
backup: ## 备份服务配置和数据
	@BACKUP_DIR="backups"; \
	TIMESTAMP=$$(date +%Y%m%d_%H%M%S); \
	BACKUP_FILE="$$BACKUP_DIR/nas_backup_$$TIMESTAMP.tar.gz"; \
	echo "$(BLUE)[INFO]$(NC) 开始备份服务配置和数据..."; \
	mkdir -p "$$BACKUP_DIR"; \
	tar -czf "$$BACKUP_FILE" \
		--exclude='services/*/cache' \
		--exclude='services/*/logs' \
		--exclude='services/*/temp' \
		services/ .env 2>/dev/null || true; \
	if [ -f "$$BACKUP_FILE" ]; then \
		echo "$(GREEN)[SUCCESS]$(NC) 备份完成: $$BACKUP_FILE"; \
		echo "$(BLUE)[INFO]$(NC) 备份大小: $$(du -h "$$BACKUP_FILE" | cut -f1)"; \
	else \
		echo "$(RED)[ERROR]$(NC) 备份失败"; \
		exit 1; \
	fi

##@ 单个服务管理

.PHONY: service-start
service-start: check-docker ## 启动单个服务 (用法: make service-start SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-start SERVICE=服务名"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 启动服务: $(SERVICE)"
	@$(COMPOSE) -f $(COMPOSE_FILE) up -d $(SERVICE)
	@echo "$(GREEN)[SUCCESS]$(NC) 服务 $(SERVICE) 启动完成"

.PHONY: service-stop
service-stop: check-docker ## 停止单个服务 (用法: make service-stop SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-stop SERVICE=服务名"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 停止服务: $(SERVICE)"
	@$(COMPOSE) -f $(COMPOSE_FILE) stop $(SERVICE)
	@echo "$(GREEN)[SUCCESS]$(NC) 服务 $(SERVICE) 已停止"

.PHONY: service-restart
service-restart: check-docker ## 重启单个服务 (用法: make service-restart SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-restart SERVICE=服务名"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 重启服务: $(SERVICE)"
	@$(COMPOSE) -f $(COMPOSE_FILE) restart $(SERVICE)
	@echo "$(GREEN)[SUCCESS]$(NC) 服务 $(SERVICE) 重启完成"

.PHONY: service-logs
service-logs: check-docker ## 查看单个服务日志 (用法: make service-logs SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-logs SERVICE=服务名"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 查看服务日志: $(SERVICE)（Ctrl+C 退出）"
	@$(COMPOSE) -f $(COMPOSE_FILE) logs -f $(SERVICE)

.PHONY: service-exec
service-exec: check-docker ## 进入服务容器 (用法: make service-exec SERVICE=服务名 [CMD=命令])
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-exec SERVICE=服务名 [CMD=命令]"; \
		exit 1; \
	fi
	@if [ -z "$(CMD)" ]; then \
		echo "$(BLUE)[INFO]$(NC) 进入服务容器: $(SERVICE)"; \
		$(COMPOSE) -f $(COMPOSE_FILE) exec $(SERVICE) /bin/sh || \
		$(COMPOSE) -f $(COMPOSE_FILE) exec $(SERVICE) /bin/bash; \
	else \
		echo "$(BLUE)[INFO]$(NC) 在服务 $(SERVICE) 中执行命令: $(CMD)"; \
		$(COMPOSE) -f $(COMPOSE_FILE) exec $(SERVICE) $(CMD); \
	fi

##@ 帮助信息

.PHONY: help
help: ## 显示此帮助信息
	@echo "$(GREEN)NAS Docker Compose Makefile$(NC)"
	@echo ""
	@echo "$(YELLOW)用法:$(NC)"
	@echo "  make <target>"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf ""} /^[a-zA-Z_-]+:.*?##/ { printf "  $(GREEN)%-18s$(NC) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(NC)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)单个服务管理示例:$(NC)"
	@echo "  make service-start SERVICE=qbittorrent"
	@echo "  make service-stop SERVICE=moviepilot"
	@echo "  make service-restart SERVICE=navidrome"
	@echo "  make service-logs SERVICE=sqmusic_web"
	@echo "  make service-exec SERVICE=mysql"
	@echo "  make service-exec SERVICE=mysql CMD=bash"
	@echo ""

.PHONY: version
version: ## 显示版本信息
	@echo "NAS Docker Compose Makefile v1.0.0"
