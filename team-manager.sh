#!/bin/bash

# 👥 ClaudeAuto チーム管理統合システム
# President/Multiagent/Errorfix チーム統合管理

set -e

show_usage() {
    cat << 'EOF'
👥 ClaudeAuto チーム管理システム

使用方法:
  ./team-manager.sh [プロジェクト名] [チーム] [アクション]

チーム:
  president    プレジデント統括チーム
  multiagent   Boss1 + Worker1-5 チーム  
  errorfix     Claude + Gemini + Codex 修正チーム
  all          全チーム（デフォルト）

アクション:
  start        チーム起動（デフォルト）
  stop         チーム停止
  restart      チーム再起動
  status       チーム状態確認
  connect      チームセッションに接続

使用例:
  ./team-manager.sh myproject                    # 全チーム起動
  ./team-manager.sh myproject multiagent start  # Multiagentチーム起動
  ./team-manager.sh myproject president status  # プレジデント状態確認
  ./team-manager.sh myproject errorfix connect  # Fixチームに接続

🎯 効率的なチーム管理で開発を加速させましょう
EOF
}

# ログ記録関数
log_team_action() {
    local project_name="$1"
    local team="$2"
    local action="$3"
    local status="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p development
    echo "[$timestamp] [TEAM_MANAGER] [$project_name] $team: $action - $status" >> development/development_log.txt
}

# 環境変数設定
setup_team_env() {
    local project_name="$1"
    
    if [ ! -f ".env_${project_name}" ]; then
        cat > ".env_${project_name}" << EOF
export PROJECT_NAME="${project_name}"
export PRESIDENT_SESSION="${project_name}_president"
export MULTIAGENT_SESSION="${project_name}_multiagent"
export ERRORFIX_SESSION="${project_name}_errorfix"
EOF
    fi
    
    source ".env_${project_name}"
}

# tmuxセッション存在確認
check_session() {
    local session_name="$1"
    tmux has-session -t "$session_name" 2>/dev/null
}

# プレジデントチーム管理
manage_president() {
    local project_name="$1"
    local action="$2"
    local session_name="${project_name}_president"
    
    case "$action" in
        "start")
            if check_session "$session_name"; then
                echo "⚠️  プレジデントセッションは既に存在します: $session_name"
                echo "接続しますか？ (y/N): "
                read connect_choice
                if [[ "$connect_choice" =~ ^[Yy]$ ]]; then
                    tmux attach-session -t "$session_name"
                fi
                return
            fi
            
            echo "🎯 プレジデントチーム起動中..."
            
            # 必要ディレクトリ作成
            mkdir -p tmp development specifications logs
            
            # セッション作成
            tmux new-session -d -s "$session_name" -x 120 -y 40
            
            # プレジデント設定
            tmux send-keys -t "$session_name" "echo '👑 PRESIDENT AI'" C-m
            tmux send-keys -t "$session_name" "echo '================'" C-m
            tmux send-keys -t "$session_name" "echo 'プロジェクト: $project_name'" C-m
            tmux send-keys -t "$session_name" "echo '役割: 統括責任者・品質管理・開発ルール監査'" C-m
            tmux send-keys -t "$session_name" "echo ''" C-m
            
            # Claude起動
            echo "🚀 PRESIDENT AI起動中..."
            tmux send-keys -t "$session_name" "claude --dangerously-skip-permissions" C-m
            sleep 2
            tmux send-keys -t "$session_name" "あなたはPRESIDENTです。指示書に従って統括管理してください。

重要事項：
- config/development_rules.md を必ず確認
- config/project_spec.md を必ず確認  
- 全ての指示の発信源として行動
- 品質管理監督の実施
- UX/UI変更時の確認・承認

プロジェクト名: $project_name
他チームからの報告を待機中です。" C-m
            
            log_team_action "$project_name" "PRESIDENT" "START" "起動完了"
            echo "✅ プレジデントチーム起動完了: $session_name"
            ;;
            
        "stop")
            if check_session "$session_name"; then
                tmux kill-session -t "$session_name"
                log_team_action "$project_name" "PRESIDENT" "STOP" "停止完了"
                echo "✅ プレジデントチーム停止完了: $session_name"
            else
                echo "⚠️  プレジデントセッションが見つかりません: $session_name"
            fi
            ;;
            
        "restart")
            manage_president "$project_name" "stop"
            sleep 2
            manage_president "$project_name" "start"
            ;;
            
        "status")
            if check_session "$session_name"; then
                echo "✅ プレジデントチーム稼働中: $session_name"
                tmux list-panes -t "$session_name" -F "#{pane_id} #{pane_current_command}" 2>/dev/null || echo "  詳細情報取得失敗"
            else
                echo "❌ プレジデントチーム停止中: $session_name"
            fi
            ;;
            
        "connect")
            if check_session "$session_name"; then
                echo "プレジデントセッションに接続中..."
                tmux attach-session -t "$session_name"
            else
                echo "❌ プレジデントセッションが存在しません"
                echo "起動しますか？ (y/N): "
                read start_choice
                if [[ "$start_choice" =~ ^[Yy]$ ]]; then
                    manage_president "$project_name" "start"
                fi
            fi
            ;;
    esac
}

# Multiagentチーム管理
manage_multiagent() {
    local project_name="$1"
    local action="$2"
    local session_name="${project_name}_multiagent"
    
    case "$action" in
        "start")
            if check_session "$session_name"; then
                echo "⚠️  Multiagentセッションは既に存在します: $session_name"
                echo "接続しますか？ (y/N): "
                read connect_choice
                if [[ "$connect_choice" =~ ^[Yy]$ ]]; then
                    tmux attach-session -t "$session_name"
                fi
                return
            fi
            
            echo "👥 Multiagentチーム起動中..."
            
            # 必要ディレクトリ作成
            mkdir -p tmp development specifications logs
            
            # セッション作成（6ペイン）
            tmux new-session -d -s "$session_name" -x 240 -y 80
            
            # ペイン分割: 2x3レイアウト
            tmux split-window -h -t "$session_name"
            tmux split-window -h -t "$session_name:0.1"
            tmux split-window -v -t "$session_name:0.0"
            tmux split-window -v -t "$session_name:0.2"
            tmux split-window -v -t "$session_name:0.4"
            tmux select-layout -t "$session_name" tiled
            
            # Boss設定（ペイン0）
            tmux send-keys -t "$session_name:0.0" "echo '🎯 BOSS1 AI'" C-m
            tmux send-keys -t "$session_name:0.0" "echo '================'" C-m
            tmux send-keys -t "$session_name:0.0" "echo 'プロジェクト: $project_name'" C-m
            tmux send-keys -t "$session_name:0.0" "echo '役割: チーム管理・品質監督・自動再指示'" C-m
            tmux send-keys -t "$session_name:0.0" "echo ''" C-m
            
            # Workers設定（ペイン1-5）
            for i in {1..5}; do
                tmux send-keys -t "$session_name:0.$i" "echo '👷 WORKER$i AI'" C-m
                tmux send-keys -t "$session_name:0.$i" "echo '================'" C-m
                tmux send-keys -t "$session_name:0.$i" "echo 'プロジェクト: $project_name'" C-m
                tmux send-keys -t "$session_name:0.$i" "echo '役割: 実装・開発・仕様書準拠作業'" C-m
                tmux send-keys -t "$session_name:0.$i" "echo ''" C-m
            done
            
            # AI起動
            echo "🚀 Multiagentチーム AI起動中..."
            
            # Boss起動
            tmux send-keys -t "$session_name:0.0" "claude --dangerously-skip-permissions" C-m
            sleep 2
            tmux send-keys -t "$session_name:0.0" "あなたはboss1です。指示書に従ってチーム管理してください。

重要事項：
- config/development_rules.md を必ず確認
- config/project_spec.md を必ず確認
- チーム全体の品質管理責任
- 自動再指示システムの実行

プロジェクト名: $project_name
PRESIDENTからの指示を待機中です。" C-m
            
            # Workers起動
            for i in {1..5}; do
                tmux send-keys -t "$session_name:0.$i" "claude --dangerously-skip-permissions" C-m
                sleep 1
                tmux send-keys -t "$session_name:0.$i" "あなたはworker$iです。指示書に従って作業してください。

重要事項：
- config/development_rules.md を必ず確認
- config/project_spec.md を必ず確認
- ユーザ第一主義で開発する
- 史上最強のシステムを作る意識を持つ
- 全作業を開発ログに記録する

プロジェクト名: $project_name
boss1からの指示を待機中です。" C-m
            done
            
            log_team_action "$project_name" "MULTIAGENT" "START" "Boss1+Worker1-5起動完了"
            echo "✅ Multiagentチーム起動完了: $session_name"
            ;;
            
        "stop")
            if check_session "$session_name"; then
                tmux kill-session -t "$session_name"
                log_team_action "$project_name" "MULTIAGENT" "STOP" "停止完了"
                echo "✅ Multiagentチーム停止完了: $session_name"
            else
                echo "⚠️  Multiagentセッションが見つかりません: $session_name"
            fi
            ;;
            
        "restart")
            manage_multiagent "$project_name" "stop"
            sleep 2
            manage_multiagent "$project_name" "start"
            ;;
            
        "status")
            if check_session "$session_name"; then
                echo "✅ Multiagentチーム稼働中: $session_name"
                echo "  Boss1: ペイン 0.0"
                echo "  Worker1-5: ペイン 0.1-0.5"
                tmux list-panes -t "$session_name" -F "#{pane_id} #{pane_current_command}" 2>/dev/null || echo "  詳細情報取得失敗"
            else
                echo "❌ Multiagentチーム停止中: $session_name"
            fi
            ;;
            
        "connect")
            if check_session "$session_name"; then
                echo "Multiagentセッションに接続中..."
                tmux attach-session -t "$session_name"
            else
                echo "❌ Multiagentセッションが存在しません"
                echo "起動しますか？ (y/N): "
                read start_choice
                if [[ "$start_choice" =~ ^[Yy]$ ]]; then
                    manage_multiagent "$project_name" "start"
                fi
            fi
            ;;
    esac
}

# Errorfix チーム管理
manage_errorfix() {
    local project_name="$1"
    local action="$2"
    local session_name="${project_name}_errorfix"
    
    case "$action" in
        "start")
            if check_session "$session_name"; then
                echo "⚠️  Errorfixセッションは既に存在します: $session_name"
                echo "接続しますか？ (y/N): "
                read connect_choice
                if [[ "$connect_choice" =~ ^[Yy]$ ]]; then
                    tmux attach-session -t "$session_name"
                fi
                return
            fi
            
            echo "🛠️ Errorfixチーム起動中..."
            
            # 必要ディレクトリ作成
            mkdir -p tmp development specifications logs
            
            # セッション作成（3ペイン）
            tmux new-session -d -s "$session_name" -x 180 -y 60
            
            # ペイン分割
            tmux split-window -h -t "$session_name"
            tmux split-window -h -t "$session_name:0.1"
            tmux select-layout -t "$session_name" even-horizontal
            
            # 各ペインの設定
            tmux send-keys -t "$session_name:0.0" "echo '⚡ CODEX AI (コード解析担当)'" C-m
            tmux send-keys -t "$session_name:0.0" "echo 'プロジェクト: $project_name'" C-m
            tmux send-keys -t "$session_name:0.0" "echo '⚠️  手動でCodexを起動してください'" C-m
            tmux send-keys -t "$session_name:0.0" "echo ''" C-m
            
            tmux send-keys -t "$session_name:0.1" "echo '🌟 GEMINI AI (CI/CD担当)'" C-m
            tmux send-keys -t "$session_name:0.1" "echo 'プロジェクト: $project_name'" C-m
            tmux send-keys -t "$session_name:0.1" "echo '⚠️  手動でGeminiを起動してください'" C-m
            tmux send-keys -t "$session_name:0.1" "echo ''" C-m
            
            tmux send-keys -t "$session_name:0.2" "echo '🔧 CLAUDE AI (修正リーダー)'" C-m
            tmux send-keys -t "$session_name:0.2" "echo 'プロジェクト: $project_name'" C-m
            tmux send-keys -t "$session_name:0.2" "echo '役割: エラー修正統括・分析指示・解決策決定'" C-m
            tmux send-keys -t "$session_name:0.2" "echo ''" C-m
            
            # Claude起動（リーダーのみ自動）
            echo "🚀 Claude (Error Fix リーダー) 起動中..."
            tmux send-keys -t "$session_name:0.2" "claude --dangerously-skip-permissions" C-m
            sleep 2
            tmux send-keys -t "$session_name:0.2" "あなたはError Fixチームのリーダー(Claude)です。

重要事項：
- config/development_rules.md を必ず確認
- config/project_spec.md を必ず確認
- Gemini(CI/CD)・Codex(コード解析)への分析指示
- エラー修正の統括管理
- 解決策の決定と実装指示

プロジェクト名: $project_name
チーム構成: Claude(リーダー) + Gemini(CI/CD) + Codex(コード解析)
PRESIDENTからのエラー修正指示を待機中です。" C-m
            
            log_team_action "$project_name" "ERRORFIX" "START" "Claude自動起動完了・Gemini/Codex手動起動待機"
            echo "✅ Errorfixチーム起動完了: $session_name"
            echo ""
            echo "⚠️  手動起動が必要："
            echo "  - ペイン 0.1: Gemini起動"
            echo "  - ペイン 0.0: Codex起動"
            ;;
            
        "stop")
            if check_session "$session_name"; then
                tmux kill-session -t "$session_name"
                log_team_action "$project_name" "ERRORFIX" "STOP" "停止完了"
                echo "✅ Errorfixチーム停止完了: $session_name"
            else
                echo "⚠️  Errorfixセッションが見つかりません: $session_name"
            fi
            ;;
            
        "restart")
            manage_errorfix "$project_name" "stop"
            sleep 2
            manage_errorfix "$project_name" "start"
            ;;
            
        "status")
            if check_session "$session_name"; then
                echo "✅ Errorfixチーム稼働中: $session_name"
                echo "  Codex: ペイン 0.0 (手動起動)"
                echo "  Gemini: ペイン 0.1 (手動起動)"
                echo "  Claude: ペイン 0.2 (自動起動)"
                tmux list-panes -t "$session_name" -F "#{pane_id} #{pane_current_command}" 2>/dev/null || echo "  詳細情報取得失敗"
            else
                echo "❌ Errorfixチーム停止中: $session_name"
            fi
            ;;
            
        "connect")
            if check_session "$session_name"; then
                echo "Errorfixセッションに接続中..."
                tmux attach-session -t "$session_name"
            else
                echo "❌ Errorfixセッションが存在しません"
                echo "起動しますか？ (y/N): "
                read start_choice
                if [[ "$start_choice" =~ ^[Yy]$ ]]; then
                    manage_errorfix "$project_name" "start"
                fi
            fi
            ;;
    esac
}

# 全チーム管理
manage_all_teams() {
    local project_name="$1"
    local action="$2"
    
    case "$action" in
        "start")
            echo "🚀 全チーム起動中..."
            manage_president "$project_name" "start"
            sleep 2
            manage_multiagent "$project_name" "start"
            echo "✅ プレジデント・マルチエージェントチーム起動完了"
            ;;
        "stop")
            echo "🛑 全チーム停止中..."
            manage_president "$project_name" "stop"
            manage_multiagent "$project_name" "stop"
            echo "✅ プレジデント・マルチエージェントチーム停止完了"
            ;;
        "restart")
            manage_all_teams "$project_name" "stop"
            sleep 3
            manage_all_teams "$project_name" "start"
            ;;
        "status")
            echo "📊 全チーム状態確認:"
            echo ""
            manage_president "$project_name" "status"
            manage_multiagent "$project_name" "status"
            ;;
    esac
}

# メイン処理
main() {
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]] || [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi

    local project_name="$1"
    local team="${2:-all}"
    local action="${3:-start}"

    # プロジェクト名検証
    if ! [[ "$project_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "❌ エラー: プロジェクト名は英数字とアンダースコアのみ使用可能です"
        exit 1
    fi

    # 環境設定
    setup_team_env "$project_name"

    # チーム・アクション実行
    case "$team" in
        "president")
            manage_president "$project_name" "$action"
            ;;
        "multiagent")
            manage_multiagent "$project_name" "$action"
            ;;
        "errorfix")
            manage_errorfix "$project_name" "$action"
            ;;
        "all")
            manage_all_teams "$project_name" "$action"
            ;;
        *)
            echo "❌ 無効なチーム: $team"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"