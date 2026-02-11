#!/bin/bash

# NAS Docker Compose 管理脚本
# 用于管理 Docker Compose 服务的启动、停止、重启等操作

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置文件
COMPOSE_FILE="docker-compose.yaml"
CLASH_FILE="docker-compose.clash.yaml"

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示帮助信息
show_help() {
    cat << EOF
${GREEN}NAS Docker Compose 管理脚本${NC}

${YELLOW}用法:${NC}
    ./manage.sh [命令] [选项]

${YELLOW}命令:${NC}
    ${GREEN}start${NC}           启动所有服务（不包括 Clash）
    ${GREEN}start-all${NC}       启动所有服务（包括 Clash）
    ${GREEN}start-clash${NC}     仅启动 Clash 服务
    ${GREEN}stop${NC}            停止所有服务
    ${GREEN}stop-clash${NC}      仅停止 Clash 服务
    ${GREEN}restart${NC}         重启所有服务（不包括 Clash）
    ${GREEN}restart-all${NC}     重启所有服务（包括 Clash）
    ${GREEN}restart-clash${NC}   仅重启 Clash 服务
    ${GREEN}status${NC}          查看所有服务状态
    ${GREEN}logs${NC}            查看所有服务日志
    ${GREEN}logs-clash${NC}      查看 Clash 服务日志
    ${GREEN}pull${NC}            拉取最新镜像
    ${GREEN}update${NC}          更新并重启服务
    ${GREEN}clean${NC}           清理未使用的容器、镜像和卷
    ${GREEN}backup${NC}          备份服务配置和数据
    ${GREEN}service${NC}         管理单个服务

${YELLOW}服务管理示例:${NC}
    ./manage.sh service start qbittorrent     # 启动 qbittorrent
    ./manage.sh service stop moviepilot       # 停止 moviepilot
    ./manage.sh service restart navidrome     # 重启 navidrome
    ./manage.sh service logs sqmusic_web      # 查看 sqmusic_web 日志

${YELLOW}其他选项:${NC}
    ${GREEN}-h, --help${NC}      显示此帮助信息
    ${GREEN}-v, --version${NC}   显示版本信息

${YELLOW}示例:${NC}
    ./manage.sh start              # 启动所有服务（不包括 Clash）
    ./manage.sh start-all          # 启动所有服务（包括 Clash）
    ./manage.sh stop               # 停止所有服务
    ./manage.sh restart-clash      # 重启 Clash
    ./manage.sh logs               # 查看所有服务日志
    ./manage.sh service logs mysql # 查看 MySQL 日志

EOF
}

# 检查 Docker 和 Docker Compose 是否安装
check_requirements() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker 未安装，请先安装 Docker"
        exit 1
    fi

    if ! docker compose version &> /dev/null; then
        print_error "Docker Compose 未安装或版本过低，请升级到 Docker Compose V2"
        exit 1
    fi
}

# 启动服务（不包括 Clash）
start_services() {
    print_info "启动所有服务（不包括 Clash）..."
    docker compose -f "$COMPOSE_FILE" up -d
    print_success "服务启动完成"
}

# 启动所有服务（包括 Clash）
start_all_services() {
    print_info "启动所有服务（包括 Clash）..."
    if [ -f "$CLASH_FILE" ]; then
        docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" up -d
        print_success "所有服务启动完成"
    else
        print_warning "未找到 $CLASH_FILE，仅启动普通服务"
        start_services
    fi
}

# 仅启动 Clash
start_clash() {
    if [ ! -f "$CLASH_FILE" ]; then
        print_error "未找到 $CLASH_FILE 文件"
        exit 1
    fi
    print_info "启动 Clash 服务..."
    docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" up -d clash
    print_success "Clash 服务启动完成"
}

# 停止所有服务
stop_services() {
    print_info "停止所有服务..."
    if [ -f "$CLASH_FILE" ]; then
        docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" down
    else
        docker compose -f "$COMPOSE_FILE" down
    fi
    print_success "所有服务已停止"
}

# 仅停止 Clash
stop_clash() {
    if [ ! -f "$CLASH_FILE" ]; then
        print_error "未找到 $CLASH_FILE 文件"
        exit 1
    fi
    print_info "停止 Clash 服务..."
    docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" stop clash
    print_success "Clash 服务已停止"
}

# 重启服务（不包括 Clash）
restart_services() {
    print_info "重启所有服务（不包括 Clash）..."
    docker compose -f "$COMPOSE_FILE" restart
    print_success "服务重启完成"
}

# 重启所有服务（包括 Clash）
restart_all_services() {
    print_info "重启所有服务（包括 Clash）..."
    if [ -f "$CLASH_FILE" ]; then
        docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" restart
        print_success "所有服务重启完成"
    else
        print_warning "未找到 $CLASH_FILE，仅重启普通服务"
        restart_services
    fi
}

# 仅重启 Clash
restart_clash() {
    if [ ! -f "$CLASH_FILE" ]; then
        print_error "未找到 $CLASH_FILE 文件"
        exit 1
    fi
    print_info "重启 Clash 服务..."
    docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" restart clash
    print_success "Clash 服务重启完成"
}

# 查看服务状态
show_status() {
    print_info "查看服务状态..."
    if [ -f "$CLASH_FILE" ]; then
        docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" ps
    else
        docker compose -f "$COMPOSE_FILE" ps
    fi
}

# 查看日志
show_logs() {
    print_info "查看服务日志（Ctrl+C 退出）..."
    if [ -f "$CLASH_FILE" ]; then
        docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" logs -f
    else
        docker compose -f "$COMPOSE_FILE" logs -f
    fi
}

# 查看 Clash 日志
show_clash_logs() {
    if [ ! -f "$CLASH_FILE" ]; then
        print_error "未找到 $CLASH_FILE 文件"
        exit 1
    fi
    print_info "查看 Clash 日志（Ctrl+C 退出）..."
    docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" logs -f clash
}

# 拉取最新镜像
pull_images() {
    print_info "拉取最新镜像..."
    docker compose -f "$COMPOSE_FILE" pull
    if [ -f "$CLASH_FILE" ]; then
        docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" pull clash
    fi
    print_success "镜像拉取完成"
}

# 更新并重启服务
update_services() {
    print_info "更新服务..."
    pull_images
    print_info "重启服务以应用更新..."
    if [ -f "$CLASH_FILE" ]; then
        docker compose -f "$COMPOSE_FILE" -f "$CLASH_FILE" up -d
    else
        docker compose -f "$COMPOSE_FILE" up -d
    fi
    print_success "服务更新完成"
}

# 清理未使用的资源
clean_resources() {
    print_warning "此操作将清理未使用的容器、镜像、网络和卷"
    read -p "确认继续？(y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_info "清理未使用的资源..."
        docker system prune -a --volumes -f
        print_success "清理完成"
    else
        print_info "已取消清理操作"
    fi
}

# 备份服务配置和数据
backup_services() {
    BACKUP_DIR="backups"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="${BACKUP_DIR}/nas_backup_${TIMESTAMP}.tar.gz"
    
    print_info "开始备份服务配置和数据..."
    mkdir -p "$BACKUP_DIR"
    
    tar -czf "$BACKUP_FILE" \
        --exclude='services/*/cache' \
        --exclude='services/*/logs' \
        --exclude='services/*/temp' \
        services/ .env 2>/dev/null || true
    
    if [ -f "$BACKUP_FILE" ]; then
        print_success "备份完成: $BACKUP_FILE"
        print_info "备份大小: $(du -h "$BACKUP_FILE" | cut -f1)"
    else
        print_error "备份失败"
        exit 1
    fi
}

# 管理单个服务
manage_service() {
    local action=$1
    local service=$2
    
    if [ -z "$service" ]; then
        print_error "请指定服务名称"
        echo "用法: ./manage.sh service [start|stop|restart|logs] <服务名>"
        exit 1
    fi
    
    case $action in
        start)
            print_info "启动服务: $service"
            docker compose -f "$COMPOSE_FILE" up -d "$service"
            print_success "服务 $service 启动完成"
            ;;
        stop)
            print_info "停止服务: $service"
            docker compose -f "$COMPOSE_FILE" stop "$service"
            print_success "服务 $service 已停止"
            ;;
        restart)
            print_info "重启服务: $service"
            docker compose -f "$COMPOSE_FILE" restart "$service"
            print_success "服务 $service 重启完成"
            ;;
        logs)
            print_info "查看服务日志: $service（Ctrl+C 退出）"
            docker compose -f "$COMPOSE_FILE" logs -f "$service"
            ;;
        *)
            print_error "未知操作: $action"
            echo "支持的操作: start, stop, restart, logs"
            exit 1
            ;;
    esac
}

# 主函数
main() {
    check_requirements
    
    case "${1:-}" in
        start)
            start_services
            ;;
        start-all)
            start_all_services
            ;;
        start-clash)
            start_clash
            ;;
        stop)
            stop_services
            ;;
        stop-clash)
            stop_clash
            ;;
        restart)
            restart_services
            ;;
        restart-all)
            restart_all_services
            ;;
        restart-clash)
            restart_clash
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs
            ;;
        logs-clash)
            show_clash_logs
            ;;
        pull)
            pull_images
            ;;
        update)
            update_services
            ;;
        clean)
            clean_resources
            ;;
        backup)
            backup_services
            ;;
        service)
            manage_service "${2:-}" "${3:-}"
            ;;
        -h|--help|help)
            show_help
            ;;
        -v|--version)
            echo "NAS Docker Compose 管理脚本 v1.0.0"
            ;;
        "")
            print_error "请指定命令"
            echo "使用 './manage.sh --help' 查看帮助信息"
            exit 1
            ;;
        *)
            print_error "未知命令: $1"
            echo "使用 './manage.sh --help' 查看帮助信息"
            exit 1
            ;;
    esac
}

# 运行主函数
main "$@"
