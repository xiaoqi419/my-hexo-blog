#!/bin/bash
# ----------------------------------------------------------
# 🚀 Hexo 自动部署脚本（优化版）
# 作者: JASON
# 更新时间: 2025-10-22
# ----------------------------------------------------------

set -Eeuo pipefail

# ==============================
# 配置区域
# ==============================
BLOG_DIR="/opt/hexo-blog"
WEB_DIR="/opt/1panel/www/sites/blog.ojason.top/index"
LOG_FILE="/var/log/hexo-deploy.log"
BRANCH="master" # 可修改为 main

# ==============================
# 辅助函数
# ==============================

# 彩色输出
COLOR_INFO="\033[1;34m"
COLOR_SUCCESS="\033[1;32m"
COLOR_ERROR="\033[1;31m"
COLOR_RESET="\033[0m"

log() {
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${COLOR_INFO}$1${COLOR_RESET}" | tee -a "$LOG_FILE"
}

success() {
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${COLOR_SUCCESS}$1${COLOR_RESET}" | tee -a "$LOG_FILE"
}

error_exit() {
  echo -e "[$(date '+%Y-%m-%d %H:%M:%S')] ${COLOR_ERROR}❌ $1${COLOR_RESET}" | tee -a "$LOG_FILE"
  exit 1
}

# 捕获脚本错误
trap 'error_exit "脚本执行出错，请检查上方日志。"' ERR

# ==============================
# 主逻辑
# ==============================

log "🔍 检查依赖环境..."
for cmd in git hexo rsync; do
  command -v $cmd >/dev/null 2>&1 || error_exit "未找到命令: $cmd，请先安装。"
done

cd "$BLOG_DIR" || error_exit "无法进入目录：$BLOG_DIR"

log "🧹 重置本地仓库状态..."
git fetch origin "$BRANCH" --quiet
git reset --hard "origin/$BRANCH" --quiet
git clean -fd --quiet

log "🔨 生成静态文件..."
hexo clean --silent
hexo generate --silent

log "📤 同步到 Web 目录..."
rsync -a --delete public/ "$WEB_DIR"/
chown -R root:root "$WEB_DIR"

success "✅ 部署成功！博客已更新于：$WEB_DIR"
