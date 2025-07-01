#!/bin/bash

# 🚀 ClaudeAuto 本番デプロイスクリプト
# Chrome環境対応・エラー防止機能付き

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# デプロイ設定
DEPLOY_ENV="${1:-production}"
CONFIG_FILE="deployment-config.yaml"
BACKUP_DIR="backups/$(date +%Y%m%d_%H%M%S)"

# ログ関数
log() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# 前提条件チェック
check_prerequisites() {
    log "前提条件をチェック中..."
    
    # Node.js チェック
    if ! command -v node &> /dev/null; then
        error "Node.js がインストールされていません"
        return 1
    fi
    
    # Docker チェック（本番環境の場合）
    if [[ "$DEPLOY_ENV" == "production" ]] && ! command -v docker &> /dev/null; then
        error "Docker がインストールされていません"
        return 1
    fi
    
    # 設定ファイルチェック
    if [[ ! -f "$CONFIG_FILE" ]]; then
        error "設定ファイル $CONFIG_FILE が見つかりません"
        return 1
    fi
    
    success "前提条件チェック完了"
}

# バックアップ作成
create_backup() {
    log "バックアップを作成中..."
    
    mkdir -p "$BACKUP_DIR"
    
    # 重要ファイルのバックアップ
    cp -r config "$BACKUP_DIR/" 2>/dev/null || true
    cp -r scripts "$BACKUP_DIR/" 2>/dev/null || true
    cp *.sh "$BACKUP_DIR/" 2>/dev/null || true
    
    # バックアップ情報記録
    cat > "$BACKUP_DIR/backup_info.txt" << EOF
Backup Date: $(date)
Environment: $DEPLOY_ENV
User: $(whoami)
EOF
    
    success "バックアップ作成完了: $BACKUP_DIR"
}

# 依存関係インストール
install_dependencies() {
    log "依存関係をインストール中..."
    
    # package.json が存在する場合
    if [[ -f "package.json" ]]; then
        npm ci --production
    fi
    
    # Python requirements が存在する場合
    if [[ -f "requirements.txt" ]]; then
        pip install -r requirements.txt
    fi
    
    success "依存関係インストール完了"
}

# ビルド実行
build_application() {
    log "アプリケーションをビルド中..."
    
    # TypeScript/JavaScript ビルド
    if [[ -f "tsconfig.json" ]] || [[ -f "webpack.config.js" ]]; then
        npm run build
    fi
    
    # Docker イメージビルド（本番環境）
    if [[ "$DEPLOY_ENV" == "production" ]] && [[ -f "Dockerfile" ]]; then
        docker build -t claude-auto:latest .
    fi
    
    success "ビルド完了"
}

# テスト実行
run_tests() {
    log "テストを実行中..."
    
    # ユニットテスト
    if [[ -f "package.json" ]] && grep -q "\"test\"" package.json; then
        npm test || {
            error "テストが失敗しました"
            return 1
        }
    fi
    
    # Lint チェック
    if [[ -f "package.json" ]] && grep -q "\"lint\"" package.json; then
        npm run lint || {
            warning "Lint エラーが検出されました"
        }
    fi
    
    success "テスト完了"
}

# システムヘルスチェック
health_check() {
    local service=$1
    local max_attempts=30
    local attempt=1
    
    log "ヘルスチェック実行中: $service"
    
    while [[ $attempt -le $max_attempts ]]; do
        if curl -f -s "http://localhost:3000/health/$service" > /dev/null; then
            success "$service ヘルスチェック成功"
            return 0
        fi
        
        log "待機中... ($attempt/$max_attempts)"
        sleep 2
        ((attempt++))
    done
    
    error "$service ヘルスチェック失敗"
    return 1
}

# デプロイ実行
deploy() {
    log "デプロイを開始します (環境: $DEPLOY_ENV)"
    
    case "$DEPLOY_ENV" in
        "development")
            log "開発環境にデプロイ中..."
            # 開発サーバー起動
            npm run dev &
            DEV_PID=$!
            echo $DEV_PID > .dev.pid
            success "開発サーバー起動 (PID: $DEV_PID)"
            ;;
            
        "staging")
            log "ステージング環境にデプロイ中..."
            # PM2 を使用してプロセス管理
            pm2 delete claude-auto-staging 2>/dev/null || true
            pm2 start ecosystem.config.js --env staging
            pm2 save
            success "ステージング環境デプロイ完了"
            ;;
            
        "production")
            log "本番環境にデプロイ中..."
            
            # Blue-Green デプロイメント
            if docker ps | grep -q "claude-auto-blue"; then
                CURRENT="blue"
                NEW="green"
            else
                CURRENT="green"
                NEW="blue"
            fi
            
            log "新しいコンテナを起動中 ($NEW)..."
            docker run -d \
                --name "claude-auto-$NEW" \
                -p 3001:3000 \
                --env-file .env.production \
                claude-auto:latest
            
            # ヘルスチェック
            sleep 5
            if health_check "multiagent"; then
                log "トラフィックを切り替え中..."
                # ロードバランサー設定更新（実際の環境に応じて調整）
                # nginx -s reload
                
                # 古いコンテナを停止
                if [[ -n "$CURRENT" ]]; then
                    docker stop "claude-auto-$CURRENT" || true
                    docker rm "claude-auto-$CURRENT" || true
                fi
                
                success "本番環境デプロイ完了"
            else
                error "ヘルスチェック失敗、ロールバック中..."
                docker stop "claude-auto-$NEW" || true
                docker rm "claude-auto-$NEW" || true
                return 1
            fi
            ;;
            
        *)
            error "不明な環境: $DEPLOY_ENV"
            return 1
            ;;
    esac
}

# デプロイ後の処理
post_deploy() {
    log "デプロイ後の処理を実行中..."
    
    # キャッシュクリア
    if [[ "$DEPLOY_ENV" == "production" ]]; then
        # CDN キャッシュクリア（必要に応じて）
        log "CDN キャッシュをクリア中..."
    fi
    
    # 通知送信
    if command -v slack-cli &> /dev/null; then
        slack-cli send "ClaudeAuto: $DEPLOY_ENV 環境へのデプロイが完了しました 🚀" || true
    fi
    
    # デプロイログ記録
    cat >> deployment_history.log << EOF
$(date '+%Y-%m-%d %H:%M:%S') - Environment: $DEPLOY_ENV - Status: SUCCESS - User: $(whoami)
EOF
    
    success "デプロイ後の処理完了"
}

# メイン処理
main() {
    echo "================================================"
    echo " 🚀 ClaudeAuto デプロイメントツール"
    echo "================================================"
    echo "環境: $DEPLOY_ENV"
    echo ""
    
    # トラップ設定（エラー時のクリーンアップ）
    trap 'error "デプロイ中にエラーが発生しました"; exit 1' ERR
    
    # デプロイステップ実行
    check_prerequisites || exit 1
    create_backup
    install_dependencies
    build_application
    run_tests || exit 1
    deploy || exit 1
    post_deploy
    
    echo ""
    echo "================================================"
    echo " 🎉 デプロイ完了！"
    echo "================================================"
    echo "環境: $DEPLOY_ENV"
    echo "時刻: $(date)"
    echo ""
    
    # デプロイ情報表示
    case "$DEPLOY_ENV" in
        "development")
            echo "開発サーバー: http://localhost:3000"
            echo "停止: npm run stop"
            ;;
        "staging")
            echo "ステージング: https://staging.claude-auto.com"
            echo "ログ確認: pm2 logs claude-auto-staging"
            ;;
        "production")
            echo "本番環境: https://claude-auto.com"
            echo "ステータス: docker ps | grep claude-auto"
            ;;
    esac
}

# 実行
main