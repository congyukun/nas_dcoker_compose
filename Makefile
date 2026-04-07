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

##@ 网络测试

# 默认代理配置（可通过环境变量覆盖）
PROXY_HOST ?= 127.0.0.1
PROXY_HTTP_PORT ?= 7890
PROXY_SOCKS_PORT ?= 7891
CLASH_API_PORT ?= 9090

.PHONY: clash-refresh
clash-refresh: ## 刷新 Clash 代理订阅
	@echo "$(BLUE)[INFO]$(NC) 刷新 Clash 代理订阅..."
	@if ! nc -z $(PROXY_HOST) $(CLASH_API_PORT) 2>/dev/null; then \
		echo "$(RED)[ERROR]$(NC) Clash API 端口 $(CLASH_API_PORT) 未开放，请确认 Clash 服务已启动"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 正在更新订阅: MyProvider"
	@RESULT=$$(curl -s -X PUT "http://$(PROXY_HOST):$(CLASH_API_PORT)/providers/proxies/MyProvider" 2>/dev/null); \
	if [ -z "$$RESULT" ] || [ "$$RESULT" = "{}" ]; then \
		echo "$(GREEN)[SUCCESS]$(NC) 订阅刷新成功"; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) 订阅刷新返回: $$RESULT"; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 等待节点健康检查..."
	@sleep 2
	@echo "$(BLUE)[INFO]$(NC) 获取可用节点数量..."
	@PROXIES=$$(curl -s "http://$(PROXY_HOST):$(CLASH_API_PORT)/providers/proxies/MyProvider" 2>/dev/null | grep -o '"name"' | wc -l); \
	echo "$(GREEN)[INFO]$(NC) 当前可用节点数: $$PROXIES"

.PHONY: clash-nodes
clash-nodes: ## 查看 Clash 代理节点列表
	@echo "$(BLUE)[INFO]$(NC) 获取 Clash 代理节点..."
	@if ! nc -z $(PROXY_HOST) $(CLASH_API_PORT) 2>/dev/null; then \
		echo "$(RED)[ERROR]$(NC) Clash API 端口 $(CLASH_API_PORT) 未开放"; \
		exit 1; \
	fi
	@curl -s "http://$(PROXY_HOST):$(CLASH_API_PORT)/proxies" 2>/dev/null | \
		python3 -c "import sys,json; d=json.load(sys.stdin); proxies=d.get('proxies',{}); \
		print('可用代理组:'); \
		[print(f'  - {k}') for k in proxies.keys() if proxies[k].get('type') in ['Selector','URLTest','Fallback']]" 2>/dev/null || \
		echo "$(YELLOW)[INFO]$(NC) 请访问 http://$(PROXY_HOST):$(CLASH_API_PORT)/ui 查看详细节点信息"

.PHONY: clash-switch
clash-switch: ## 切换 Clash 代理节点 (用法: make clash-switch NODE=节点名)
	@if [ -z "$(NODE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定节点名称"; \
		echo "用法: make clash-switch NODE=节点名"; \
		echo "提示: 使用 make clash-nodes 查看可用节点"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 切换代理节点到: $(NODE)"
	@RESULT=$$(curl -s -X PUT -H "Content-Type: application/json" \
		-d '{"name":"$(NODE)"}' \
		"http://$(PROXY_HOST):$(CLASH_API_PORT)/proxies/🚀 节点选择" 2>/dev/null); \
	if [ -z "$$RESULT" ] || [ "$$RESULT" = "{}" ]; then \
		echo "$(GREEN)[SUCCESS]$(NC) 节点切换成功"; \
	else \
		echo "$(RED)[FAILED]$(NC) 节点切换失败: $$RESULT"; \
	fi

.PHONY: clash-healthcheck
clash-healthcheck: ## 触发 Clash 节点健康检查
	@echo "$(BLUE)[INFO]$(NC) 触发节点健康检查..."
	@curl -s -X GET "http://$(PROXY_HOST):$(CLASH_API_PORT)/providers/proxies/MyProvider/healthcheck" 2>/dev/null
	@echo "$(GREEN)[SUCCESS]$(NC) 健康检查已触发，请稍后查看节点延迟"

.PHONY: test-proxy
test-proxy: ## 测试代理连通性 (用法: make test-proxy [PROXY_HOST=IP] [PROXY_HTTP_PORT=端口])
	@echo "$(BLUE)[INFO]$(NC) 测试代理连通性..."
	@echo "$(BLUE)[INFO]$(NC) 代理地址: $(PROXY_HOST):$(PROXY_HTTP_PORT) (HTTP), $(PROXY_HOST):$(PROXY_SOCKS_PORT) (SOCKS5)"
	@echo ""
	@echo "$(YELLOW)=== 1. 代理端口检测 ===$(NC)"
	@if nc -z $(PROXY_HOST) $(PROXY_HTTP_PORT) 2>/dev/null; then \
		echo "$(GREEN)[OK]$(NC) HTTP 代理端口 $(PROXY_HTTP_PORT) 已开放"; \
	else \
		echo "$(RED)[FAILED]$(NC) HTTP 代理端口 $(PROXY_HTTP_PORT) 未开放"; \
	fi
	@if nc -z $(PROXY_HOST) $(PROXY_SOCKS_PORT) 2>/dev/null; then \
		echo "$(GREEN)[OK]$(NC) SOCKS5 代理端口 $(PROXY_SOCKS_PORT) 已开放"; \
	else \
		echo "$(RED)[FAILED]$(NC) SOCKS5 代理端口 $(PROXY_SOCKS_PORT) 未开放"; \
	fi
	@echo ""
	@echo "$(YELLOW)=== 2. 代理基本功能测试（国内网站）===$(NC)"
	@HTTP_CODE=$$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://www.baidu.com 2>/dev/null); \
	if [ "$$HTTP_CODE" = "200" ]; then \
		echo "$(GREEN)[SUCCESS]$(NC) HTTP 代理正常工作 (baidu.com -> HTTP $$HTTP_CODE)"; \
	else \
		echo "$(RED)[FAILED]$(NC) HTTP 代理无法访问 baidu.com (HTTP $$HTTP_CODE)"; \
	fi
	@SOCKS_CODE=$$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 -x socks5://$(PROXY_HOST):$(PROXY_SOCKS_PORT) https://www.baidu.com 2>/dev/null); \
	if [ "$$SOCKS_CODE" = "200" ]; then \
		echo "$(GREEN)[SUCCESS]$(NC) SOCKS5 代理正常工作 (baidu.com -> HTTP $$SOCKS_CODE)"; \
	else \
		echo "$(RED)[FAILED]$(NC) SOCKS5 代理无法访问 baidu.com (HTTP $$SOCKS_CODE)"; \
	fi
	@echo ""
	@echo "$(YELLOW)=== 3. 代理翻墙功能测试（国外网站）===$(NC)"
	@GOOGLE_CODE=$$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://www.google.com 2>/dev/null); \
	if echo "$$GOOGLE_CODE" | grep -qE "^(200|301|302)$$"; then \
		echo "$(GREEN)[SUCCESS]$(NC) Google 访问成功 (HTTP $$GOOGLE_CODE)"; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) Google 访问失败 (HTTP $$GOOGLE_CODE) - 请检查代理节点配置"; \
	fi
	@GITHUB_CODE=$$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://github.com 2>/dev/null); \
	if echo "$$GITHUB_CODE" | grep -qE "^(200|301|302)$$"; then \
		echo "$(GREEN)[SUCCESS]$(NC) GitHub 访问成功 (HTTP $$GITHUB_CODE)"; \
	else \
		echo "$(YELLOW)[WARNING]$(NC) GitHub 访问失败 (HTTP $$GITHUB_CODE) - 请检查代理节点配置"; \
	fi
	@echo ""
	@echo "$(BLUE)[INFO]$(NC) 提示: 如果国内网站正常但国外网站失败，请检查 Clash 代理节点是否可用"

.PHONY: test-proxy-detail
test-proxy-detail: ## 详细测试代理连通性（显示响应时间）
	@echo "$(BLUE)[INFO]$(NC) 详细代理测试..."
	@echo "$(BLUE)[INFO]$(NC) 代理地址: $(PROXY_HOST):$(PROXY_HTTP_PORT)"
	@echo ""
	@echo "$(YELLOW)--- 测试国内网站 ---$(NC)"
	@echo -n "百度: "; curl -s -o /dev/null -w "HTTP %{http_code}, 耗时 %{time_total}s\n" --connect-timeout 10 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://www.baidu.com 2>/dev/null || echo "连接失败"
	@echo -n "淘宝: "; curl -s -o /dev/null -w "HTTP %{http_code}, 耗时 %{time_total}s\n" --connect-timeout 10 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://www.taobao.com 2>/dev/null || echo "连接失败"
	@echo ""
	@echo "$(YELLOW)--- 测试国外网站 ---$(NC)"
	@echo -n "Google: "; curl -s -o /dev/null -w "HTTP %{http_code}, 耗时 %{time_total}s\n" --connect-timeout 15 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://www.google.com 2>/dev/null || echo "连接失败"
	@echo -n "GitHub: "; curl -s -o /dev/null -w "HTTP %{http_code}, 耗时 %{time_total}s\n" --connect-timeout 15 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://github.com 2>/dev/null || echo "连接失败"
	@echo -n "YouTube: "; curl -s -o /dev/null -w "HTTP %{http_code}, 耗时 %{time_total}s\n" --connect-timeout 15 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://www.youtube.com 2>/dev/null || echo "连接失败"
	@echo -n "Twitter: "; curl -s -o /dev/null -w "HTTP %{http_code}, 耗时 %{time_total}s\n" --connect-timeout 15 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://twitter.com 2>/dev/null || echo "连接失败"
	@echo ""
	@echo "$(YELLOW)--- 获取代理出口 IP ---$(NC)"
	@echo -n "出口 IP: "; curl -s --connect-timeout 10 -x http://$(PROXY_HOST):$(PROXY_HTTP_PORT) https://api.ipify.org 2>/dev/null || echo "获取失败"
	@echo ""

.PHONY: test-direct
test-direct: ## 测试直连网络（不使用代理）
	@echo "$(BLUE)[INFO]$(NC) 测试直连网络..."
	@echo ""
	@echo "$(YELLOW)--- 测试国内网站 ---$(NC)"
	@echo -n "百度: "; curl -s -o /dev/null -w "HTTP %{http_code}, 耗时 %{time_total}s\n" --connect-timeout 10 https://www.baidu.com 2>/dev/null || echo "连接失败"
	@echo ""
	@echo "$(YELLOW)--- 测试国外网站（直连）---$(NC)"
	@echo -n "Google: "; curl -s -o /dev/null -w "HTTP %{http_code}, 耗时 %{time_total}s\n" --connect-timeout 10 https://www.google.com 2>/dev/null || echo "连接失败"
	@echo ""
	@echo "$(YELLOW)--- 获取本机出口 IP ---$(NC)"
	@echo -n "出口 IP: "; curl -s --connect-timeout 10 https://api.ipify.org 2>/dev/null || echo "获取失败"
	@echo ""

##@ 维护操作

.PHONY: pull
pull: check-docker ## 拉取所有最新镜像
	@echo "$(BLUE)[INFO]$(NC) 拉取所有最新镜像..."
	@$(COMPOSE) -f $(COMPOSE_FILE) pull
	@if [ -f "$(CLASH_FILE)" ]; then \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) pull clash; \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 镜像拉取完成"

.PHONY: update
update: pull ## 更新并重启所有服务
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

# 内部函数：获取正确的 compose 命令（支持 Clash 服务）
define get_compose_cmd
$(if $(filter clash,$(SERVICE)),\
	$(if $(shell [ -f "$(CLASH_FILE)" ] && echo yes),\
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE),\
		$(error $(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件)),\
	$(COMPOSE) -f $(COMPOSE_FILE))
endef

.PHONY: service-start
service-start: check-docker ## 启动单个服务 (用法: make service-start SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-start SERVICE=服务名"; \
		echo "提示: 使用 make list 查看所有可用服务"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 启动服务: $(SERVICE)"
	@if [ "$(SERVICE)" = "clash" ]; then \
		if [ ! -f "$(CLASH_FILE)" ]; then \
			echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
			exit 1; \
		fi; \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) up -d $(SERVICE); \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) up -d $(SERVICE); \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 服务 $(SERVICE) 启动完成"

.PHONY: service-stop
service-stop: check-docker ## 停止单个服务 (用法: make service-stop SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-stop SERVICE=服务名"; \
		echo "提示: 使用 make list 查看所有可用服务"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 停止服务: $(SERVICE)"
	@if [ "$(SERVICE)" = "clash" ]; then \
		if [ ! -f "$(CLASH_FILE)" ]; then \
			echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
			exit 1; \
		fi; \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) stop $(SERVICE); \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) stop $(SERVICE); \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 服务 $(SERVICE) 已停止"

.PHONY: service-restart
service-restart: check-docker ## 重启单个服务 (用法: make service-restart SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-restart SERVICE=服务名"; \
		echo "提示: 使用 make list 查看所有可用服务"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 重启服务: $(SERVICE)"
	@if [ "$(SERVICE)" = "clash" ]; then \
		if [ ! -f "$(CLASH_FILE)" ]; then \
			echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
			exit 1; \
		fi; \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) restart $(SERVICE); \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) restart $(SERVICE); \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 服务 $(SERVICE) 重启完成"

.PHONY: service-pull
service-pull: check-docker ## 拉取单个服务的最新镜像 (用法: make service-pull SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-pull SERVICE=服务名"; \
		echo "提示: 使用 make list 查看所有可用服务"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 拉取服务镜像: $(SERVICE)"
	@if [ "$(SERVICE)" = "clash" ]; then \
		if [ ! -f "$(CLASH_FILE)" ]; then \
			echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
			exit 1; \
		fi; \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) pull $(SERVICE); \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) pull $(SERVICE); \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 服务 $(SERVICE) 镜像拉取完成"

.PHONY: service-update
service-update: check-docker ## 更新单个服务（拉取镜像并重启）(用法: make service-update SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-update SERVICE=服务名"; \
		echo "提示: 使用 make list 查看所有可用服务"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 更新服务: $(SERVICE)"
	@echo "$(BLUE)[INFO]$(NC) 步骤 1/2: 拉取最新镜像..."
	@if [ "$(SERVICE)" = "clash" ]; then \
		if [ ! -f "$(CLASH_FILE)" ]; then \
			echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
			exit 1; \
		fi; \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) pull $(SERVICE); \
		echo "$(BLUE)[INFO]$(NC) 步骤 2/2: 重新创建并启动容器..."; \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) up -d $(SERVICE); \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) pull $(SERVICE); \
		echo "$(BLUE)[INFO]$(NC) 步骤 2/2: 重新创建并启动容器..."; \
		$(COMPOSE) -f $(COMPOSE_FILE) up -d $(SERVICE); \
	fi
	@echo "$(GREEN)[SUCCESS]$(NC) 服务 $(SERVICE) 更新完成"

.PHONY: service-logs
service-logs: check-docker ## 查看单个服务日志 (用法: make service-logs SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-logs SERVICE=服务名"; \
		echo "提示: 使用 make list 查看所有可用服务"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 查看服务日志: $(SERVICE)（Ctrl+C 退出）"
	@if [ "$(SERVICE)" = "clash" ]; then \
		if [ ! -f "$(CLASH_FILE)" ]; then \
			echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
			exit 1; \
		fi; \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) logs -f $(SERVICE); \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) logs -f $(SERVICE); \
	fi

.PHONY: service-status
service-status: check-docker ## 查看单个服务状态 (用法: make service-status SERVICE=服务名)
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-status SERVICE=服务名"; \
		echo "提示: 使用 make list 查看所有可用服务"; \
		exit 1; \
	fi
	@echo "$(BLUE)[INFO]$(NC) 查看服务状态: $(SERVICE)"
	@if [ "$(SERVICE)" = "clash" ]; then \
		if [ ! -f "$(CLASH_FILE)" ]; then \
			echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
			exit 1; \
		fi; \
		$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) ps $(SERVICE); \
	else \
		$(COMPOSE) -f $(COMPOSE_FILE) ps $(SERVICE); \
	fi

.PHONY: service-exec
service-exec: check-docker ## 进入服务容器 (用法: make service-exec SERVICE=服务名 [CMD=命令])
	@if [ -z "$(SERVICE)" ]; then \
		echo "$(RED)[ERROR]$(NC) 请指定服务名称"; \
		echo "用法: make service-exec SERVICE=服务名 [CMD=命令]"; \
		echo "提示: 使用 make list 查看所有可用服务"; \
		exit 1; \
	fi
	@if [ "$(SERVICE)" = "clash" ]; then \
		if [ ! -f "$(CLASH_FILE)" ]; then \
			echo "$(RED)[ERROR]$(NC) 未找到 $(CLASH_FILE) 文件"; \
			exit 1; \
		fi; \
		if [ -z "$(CMD)" ]; then \
			echo "$(BLUE)[INFO]$(NC) 进入服务容器: $(SERVICE)"; \
			$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) exec $(SERVICE) /bin/sh || \
			$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) exec $(SERVICE) /bin/bash; \
		else \
			echo "$(BLUE)[INFO]$(NC) 在服务 $(SERVICE) 中执行命令: $(CMD)"; \
			$(COMPOSE) -f $(COMPOSE_FILE) -f $(CLASH_FILE) exec $(SERVICE) $(CMD); \
		fi; \
	else \
		if [ -z "$(CMD)" ]; then \
			echo "$(BLUE)[INFO]$(NC) 进入服务容器: $(SERVICE)"; \
			$(COMPOSE) -f $(COMPOSE_FILE) exec $(SERVICE) /bin/sh || \
			$(COMPOSE) -f $(COMPOSE_FILE) exec $(SERVICE) /bin/bash; \
		else \
			echo "$(BLUE)[INFO]$(NC) 在服务 $(SERVICE) 中执行命令: $(CMD)"; \
			$(COMPOSE) -f $(COMPOSE_FILE) exec $(SERVICE) $(CMD); \
		fi; \
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
	@echo "  make service-start SERVICE=qbittorrent    # 启动单个服务"
	@echo "  make service-stop SERVICE=moviepilot      # 停止单个服务"
	@echo "  make service-restart SERVICE=navidrome    # 重启单个服务"
	@echo "  make service-pull SERVICE=jellyfin        # 拉取单个服务镜像"
	@echo "  make service-update SERVICE=qbittorrent   # 更新单个服务（拉取镜像+重启）"
	@echo "  make service-status SERVICE=mysql         # 查看单个服务状态"
	@echo "  make service-logs SERVICE=sqmusic_web     # 查看单个服务日志"
	@echo "  make service-exec SERVICE=mysql           # 进入服务容器"
	@echo "  make service-exec SERVICE=mysql CMD=bash  # 在容器中执行命令"
	@echo ""
	@echo "$(YELLOW)Clash 代理管理:$(NC)"
	@echo "  make clash-refresh                        # 刷新代理订阅"
	@echo "  make clash-nodes                          # 查看代理节点列表"
	@echo "  make clash-switch NODE=节点名             # 切换代理节点"
	@echo "  make clash-healthcheck                    # 触发节点健康检查"
	@echo "  make test-proxy                           # 测试代理连通性"
	@echo "  make test-proxy-detail                    # 详细代理测试"
	@echo ""

.PHONY: version
version: ## 显示版本信息
	@echo "NAS Docker Compose Makefile v1.2.0"
