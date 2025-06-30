#!/bin/bash

# 📡 ClaudeAuto 通信統合システム
# President指示 + Agent間通信 統合ハブ

set -e

show_usage() {
    cat << 'EOF'
📡 ClaudeAuto 通信統合システム

使用方法:
  ./communication-hub.sh [プロジェクト名] [対象] [メッセージ]
  ./communication-hub.sh [プロジェクト名] [オプション]

自然言語指示（プレジデント向け）:
  ./communication-hub.sh myproject president "プロジェクトを開始してください"
  ./communication-hub.sh myproject president "進捗を確認してください"
  ./communication-hub.sh myproject president "エラー修正：ビルドエラーが発生"

個別エージェント通信:
  ./communication-hub.sh myproject boss1 "Hello World 作業開始"
  ./communication-hub.sh myproject worker1 "進捗を確認してください"
  ./communication-hub.sh myproject errorfix_claude "緊急エラー対応"

オプション:
  --list         利用可能エージェント一覧
  --status       通信状況確認
  --test         通信テスト実行
  --help, -h     ヘルプ表示

利用可能エージェント:
  president       - プロジェクト統括責任者（自然言語解析対応）
  boss1           - チームリーダー
  worker1-5       - 実行担当者
  errorfix_claude - エラー修正リーダー
  errorfix_gemini - CI/CD担当
  errorfix_codex  - コード解析担当

🎯 自然言語でもダイレクト通信でも、すべての通信を統合管理
EOF
}

# ログ記録関数
log_communication() {
    local project_name="$1"
    local target="$2"
    local message="$3"
    local method="$4"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs development
    echo "[$timestamp] [COMM_HUB] [$project_name] $target ($method): \"$message\"" >> logs/communication_log.txt
    echo "[$timestamp] [COMMUNICATION] [$project_name] $target: \"$message\"" >> development/development_log.txt
}

# 環境変数設定
setup_comm_env() {
    local project_name="$1"
    
    if [ ! -f ".env_${project_name}" ]; then
        echo "❌ エラー: プロジェクト環境が見つかりません"
        echo "先にシステムを起動してください: ./system-launcher.sh $project_name"
        exit 1
    fi
    
    source ".env_${project_name}"
}

# エージェントターゲット取得
get_agent_target() {
    local project_name="$1"
    local agent="$2"
    
    case "$agent" in
        "president") echo "${project_name}_president" ;;
        "boss1") echo "${project_name}_multiagent:0.0" ;;
        "worker1") echo "${project_name}_multiagent:0.1" ;;
        "worker2") echo "${project_name}_multiagent:0.2" ;;
        "worker3") echo "${project_name}_multiagent:0.3" ;;
        "worker4") echo "${project_name}_multiagent:0.4" ;;
        "worker5") echo "${project_name}_multiagent:0.5" ;;
        "errorfix_claude") echo "${project_name}_errorfix:0.2" ;;
        "errorfix_gemini") echo "${project_name}_errorfix:0.1" ;;
        "errorfix_codex") echo "${project_name}_errorfix:0.0" ;;
        *) echo "" ;;
    esac
}

# ターゲット存在確認
check_target() {
    local target="$1"
    local session_name="${target%%:*}"
    
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        echo "❌ セッション '$session_name' が見つかりません"
        echo "先にチームを起動してください: ./team-manager.sh [プロジェクト名] [チーム] start"
        return 1
    fi
    
    return 0
}

# 自然言語解析・プレジデント指示システム
send_president_command() {
    local project_name="$1"
    local message="$2"
    
    echo "🎯 プレジデントに指示を送信中..."
    echo "指示内容: $message"
    echo ""
    
    # 自然言語解析
    local command_type=""
    local target_team=""
    
    # キーワード解析
    if echo "$message" | grep -iE "(開始|スタート|始め)" >/dev/null; then
        command_type="PROJECT_START"
        target_team="multiagent"
    elif echo "$message" | grep -iE "(進捗|状況|確認)" >/dev/null; then
        command_type="PROGRESS_CHECK"
        target_team="multiagent"
    elif echo "$message" | grep -iE "(エラー|修正|バグ|問題)" >/dev/null; then
        command_type="ERROR_FIX"
        target_team="errorfix"
    elif echo "$message" | grep -iE "(品質|チェック|レビュー)" >/dev/null; then
        command_type="QUALITY_CHECK"
        target_team="multiagent"
    elif echo "$message" | grep -iE "(デプロイ|リリース|本番)" >/dev/null; then
        command_type="DEPLOY"
        target_team="multiagent"
    else
        command_type="GENERAL"
        target_team="multiagent"
    fi
    
    echo "🔍 指示分析結果:"
    echo "  - 指示タイプ: $command_type"
    echo "  - 対象チーム: $target_team"
    echo ""
    
    # プレジデントへの送信
    local president_target="${project_name}_president"
    
    if ! check_target "$president_target"; then
        return 1
    fi
    
    # プレジデント用メッセージ作成
    local president_message="指示を受信しました: \"$message\"

分析結果:
- 指示タイプ: $command_type
- 推奨対象: $target_team チーム

この指示に基づいて適切なチームに作業指示を出してください。"
    
    # 送信実行
    send_direct_message "$president_target" "$president_message"
    
    log_communication "$project_name" "president" "$message" "NATURAL_LANGUAGE"
    
    echo "✅ プレジデントへの指示送信完了"
    echo ""
    echo "🔄 推奨フォローアップ:"
    case "$command_type" in
        "PROJECT_START")
            echo "  - Boss1への作業指示配信を確認"
            echo "  - Worker1-5の作業開始状況を監視"
            ;;
        "ERROR_FIX")
            echo "  - Error Fixチームの起動確認"
            echo "  - エラー分析結果の報告待機"
            ;;
        "PROGRESS_CHECK")
            echo "  - 各チームからの進捗報告確認"
            echo "  - 作業ログの詳細確認"
            ;;
        *)
            echo "  - 対象チームの応答確認"
            echo "  - 作業進行状況の監視"
            ;;
    esac
}

# ダイレクトメッセージ送信
send_direct_message() {
    local target="$1"
    local message="$2"
    
    echo "📤 送信中: $target ← '$message'"
    
    # Claude Codeのプロンプトを一度クリア
    tmux send-keys -t "$target" C-c
    sleep 0.3
    
    # メッセージ送信
    tmux send-keys -t "$target" "$message"
    sleep 0.1
    
    # エンター押下
    tmux send-keys -t "$target" C-m
    sleep 0.5
    
    echo "✅ 送信完了"
}

# エージェント間通信
send_agent_message() {
    local project_name="$1"
    local agent_name="$2"
    local message="$3"
    
    # エージェントターゲット取得
    local target
    target=$(get_agent_target "$project_name" "$agent_name")
    
    if [[ -z "$target" ]]; then
        echo "❌ エラー: 不明なエージェント '$agent_name'"
        echo "利用可能エージェント: ./communication-hub.sh $project_name --list"
        return 1
    fi
    
    # ターゲット確認
    if ! check_target "$target"; then
        return 1
    fi
    
    # メッセージ送信
    send_direct_message "$target" "$message"
    
    log_communication "$project_name" "$agent_name" "$message" "DIRECT"
    
    echo "✅ 送信完了: [$project_name] $agent_name に '$message'"
}

# エージェント一覧表示
show_agents() {
    local project_name="$1"
    echo "📋 利用可能なエージェント (プロジェクト: $project_name):"
    echo "==========================================="
    echo "  president       → ${project_name}_president:0        (プロジェクト統括責任者)"
    echo "  boss1           → ${project_name}_multiagent:0.0     (チームリーダー)"
    echo "  worker1         → ${project_name}_multiagent:0.1     (実行担当者A)"
    echo "  worker2         → ${project_name}_multiagent:0.2     (実行担当者B)" 
    echo "  worker3         → ${project_name}_multiagent:0.3     (実行担当者C)"
    echo "  worker4         → ${project_name}_multiagent:0.4     (実行担当者D)"
    echo "  worker5         → ${project_name}_multiagent:0.5     (実行担当者E)"
    echo "  errorfix_claude → ${project_name}_errorfix:0.2       (エラー修正リーダー)"
    echo "  errorfix_gemini → ${project_name}_errorfix:0.1       (CI/CD担当)"
    echo "  errorfix_codex  → ${project_name}_errorfix:0.0       (コード解析担当)"
    echo ""
    echo "🎯 自然言語指示: ./communication-hub.sh $project_name president \"指示内容\""
    echo "📡 直接通信: ./communication-hub.sh $project_name [エージェント名] \"メッセージ\""
}

# 通信状況確認
check_status() {
    local project_name="$1"
    
    echo "📊 通信状況確認 (プロジェクト: $project_name):"
    echo "==========================================="
    
    local agents=("president" "boss1" "worker1" "worker2" "worker3" "worker4" "worker5" "errorfix_claude" "errorfix_gemini" "errorfix_codex")
    
    for agent in "${agents[@]}"; do
        local target=$(get_agent_target "$project_name" "$agent")
        local session_name="${target%%:*}"
        
        if tmux has-session -t "$session_name" 2>/dev/null; then
            echo "  ✅ $agent: 稼働中 ($target)"
        else
            echo "  ❌ $agent: 停止中 ($target)"
        fi
    done
    
    echo ""
    echo "📁 通信ログ:"
    if [ -f "logs/communication_log.txt" ]; then
        echo "  最新通信: $(tail -1 logs/communication_log.txt 2>/dev/null || echo '通信履歴なし')"
    else
        echo "  通信ログファイル未作成"
    fi
}

# 通信テスト
run_communication_test() {
    local project_name="$1"
    
    echo "🧪 通信テスト実行中..."
    echo "=================================="
    
    # President テスト
    echo "📡 Test 1: President 通信テスト"
    if send_agent_message "$project_name" "president" "通信テスト: President応答確認"; then
        echo "✅ President通信: 正常"
    else
        echo "❌ President通信: 失敗"
    fi
    sleep 2
    
    # Boss1 テスト
    echo "📡 Test 2: Boss1 通信テスト"
    if send_agent_message "$project_name" "boss1" "通信テスト: Boss1応答確認"; then
        echo "✅ Boss1通信: 正常"
    else
        echo "❌ Boss1通信: 失敗"
    fi
    sleep 2
    
    # Worker1 テスト
    echo "📡 Test 3: Worker1 通信テスト"
    if send_agent_message "$project_name" "worker1" "通信テスト: Worker1応答確認"; then
        echo "✅ Worker1通信: 正常"
    else
        echo "❌ Worker1通信: 失敗"
    fi
    sleep 2
    
    # ErrorFix テスト
    echo "📡 Test 4: ErrorFix 通信テスト"
    if send_agent_message "$project_name" "errorfix_claude" "通信テスト: Error Fix応答確認"; then
        echo "✅ ErrorFix通信: 正常"
    else
        echo "❌ ErrorFix通信: 失敗"
    fi
    
    echo ""
    echo "🎯 通信テスト完了"
    echo "各エージェントからの応答を確認してください。"
}

# メイン処理
main() {
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]] || [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi

    local project_name="$1"
    
    # プロジェクト名検証
    if ! [[ "$project_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "❌ エラー: プロジェクト名は英数字とアンダースコアのみ使用可能です"
        exit 1
    fi
    
    # 環境設定
    setup_comm_env "$project_name"
    
    # オプション処理
    case "$2" in
        "--list")
            show_agents "$project_name"
            exit 0
            ;;
        "--status")
            check_status "$project_name"
            exit 0
            ;;
        "--test")
            run_communication_test "$project_name"
            exit 0
            ;;
    esac
    
    if [[ $# -lt 3 ]]; then
        echo "❌ エラー: メッセージが指定されていません"
        show_usage
        exit 1
    fi
    
    local target="$2"
    local message="$3"
    
    # 通信実行
    if [[ "$target" == "president" ]]; then
        # 自然言語プレジデント指示
        send_president_command "$project_name" "$message"
    else
        # ダイレクトエージェント通信
        send_agent_message "$project_name" "$target" "$message"
    fi
}

main "$@"