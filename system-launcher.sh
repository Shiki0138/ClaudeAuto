#!/bin/bash

# 🚀 ClaudeAuto 統合起動システム
# 6段階システム + クイックセットアップ統合版

set -e

show_usage() {
    cat << 'EOF'
🚀 ClaudeAuto 統合起動システム

使用方法:
  ./system-launcher.sh [プロジェクト名] [オプション]

オプション:
  --full         6段階完全システム起動（推奨・デフォルト）
  --quick        クイックセットアップのみ
  --president    プレジデントのみ起動
  --team         Multiagentチームのみ起動  
  --errorfix     Fixチームのみ起動
  --help, -h     ヘルプ表示

使用例:
  ./system-launcher.sh myproject            # 6段階完全起動
  ./system-launcher.sh myproject --quick    # クイック起動
  ./system-launcher.sh myproject --team     # チームのみ起動

🎯 推奨: 初回は --full オプションで6段階システムを体験してください
EOF
}

# 共通設定関数
setup_project_env() {
    local project_name="$1"
    
    # ディレクトリ準備
    mkdir -p tmp development specifications logs scripts
    touch development/development_log.txt
    touch specifications/project_spec.txt
    
    # 環境変数ファイル作成
    cat > ".env_${project_name}" << EOF
export PROJECT_NAME="${project_name}"
export PRESIDENT_SESSION="${project_name}_president"
export MULTIAGENT_SESSION="${project_name}_multiagent"
export ERRORFIX_SESSION="${project_name}_errorfix"
EOF

    echo "✅ プロジェクト環境準備完了: $project_name"
}

# ログ記録関数
log_action() {
    local project_name="$1"
    local action="$2"
    local details="$3"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] [LAUNCHER] [$project_name] $action: $details" >> development/development_log.txt
}

# 6段階完全システム
launch_full_system() {
    local project_name="$1"
    
    echo "================================================"
    echo " 🚀 ClaudeAuto 6段階システム起動"
    echo "================================================"
    echo "プロジェクト: $project_name"
    echo ""

    # STEP 1: セットアップ
    echo "==============================================="
    echo " STEP 1: セットアップ（設定適用）"
    echo "==============================================="
    setup_project_env "$project_name"
    log_action "$project_name" "SETUP" "環境設定・ディレクトリ準備完了"
    echo ""

    # STEP 2: プレジデント起動案内
    echo "==============================================="
    echo " STEP 2: プレジデント起動（Claude Code）"
    echo "==============================================="
    echo "⚠️  別ターミナルでClaudeCodeを起動してください："
    echo "   ./start-president.sh $project_name"
    echo ""
    echo -n "プレジデント起動完了後、Enterを押してください..."
    read
    log_action "$project_name" "PRESIDENT" "起動確認完了"
    echo ""

    # STEP 3: Multiagentチーム起動案内
    echo "==============================================="
    echo " STEP 3: Multiagentチーム起動（Claude Code）"
    echo "==============================================="  
    echo "⚠️  別ターミナルでClaudeCodeを起動してください："
    echo "   ./start-team.sh $project_name"
    echo ""
    echo -n "Multiagentチーム起動完了後、Enterを押してください..."
    read
    log_action "$project_name" "MULTIAGENT" "チーム起動確認完了"
    echo ""

    # STEP 4: Fix チーム起動案内
    echo "==============================================="
    echo " STEP 4: Fixチーム起動（Claude + 手動）"
    echo "==============================================="
    echo "⚠️  以下を実行してください："
    echo "   1) 別ターミナルで: ./start-errorfix.sh $project_name"
    echo "   2) Claude起動後、ペイン0.1でGemini手動起動"
    echo "   3) ペイン0.0でCodex手動起動"
    echo ""
    echo -n "Fixチーム（Claude+Gemini+Codex）起動完了後、Enterを押してください..."
    read
    log_action "$project_name" "ERRORFIX" "Fix チーム起動確認完了"
    echo ""

    # STEP 5: 連携確認
    echo "==============================================="
    echo " STEP 5: 各チーム連携確認"
    echo "==============================================="
    echo "通信テストを実行します..."

    # 通信テスト
    echo "📡 Test 1: PRESIDENT → Boss1"
    ./agent-send.sh "$project_name" boss1 "システム起動確認テスト。応答してください。"
    sleep 3

    echo "📡 Test 2: Boss1 → Worker1"
    ./agent-send.sh "$project_name" worker1 "Worker1応答確認テスト"
    sleep 3

    echo "📡 Test 3: Error Fix チーム確認"
    ./agent-send.sh "$project_name" errorfix_claude "Error Fix チーム応答確認テスト"
    sleep 3

    echo "各チームからの応答を確認してください。"
    echo -n "すべて正常に応答している場合、Enterを押してください..."
    read
    log_action "$project_name" "COMMUNICATION" "通信テスト完了"
    echo ""

    # STEP 6: 仕様書変換と指示開始
    echo "==============================================="
    echo " STEP 6: 仕様書変換と作業指示"
    echo "==============================================="

    echo "📋 仕様書を変換します..."
    if [ -f "specifications/project_spec.txt" ]; then
        if [ -f "scripts/convert_spec.sh" ]; then
            ./scripts/convert_spec.sh
            echo "✅ 仕様書変換完了"
        else
            echo "⚠️  scripts/convert_spec.sh が見つかりません"
            echo "手動で specifications/project_spec.txt → project_spec.md に変換してください"
        fi
    else
        echo "⚠️  specifications/project_spec.txt が見つかりません"
        echo "仕様書を作成してください"
    fi
    echo ""

    echo "🎯 各チームに初期指示を送信します..."
    ./president-command.sh "$project_name" "6段階システム起動完了。プロジェクト開始指示を出してください。"
    
    log_action "$project_name" "FULL_SYSTEM" "6段階システム起動完了"
    echo ""

    # 完了報告
    echo "==============================================="
    echo " 🎉 6段階システム起動完了！"
    echo "==============================================="
    echo ""
    echo "📊 システム状況:"
    echo "  ✅ Step 1: セットアップ完了"
    echo "  ✅ Step 2: プレジデント起動完了"  
    echo "  ✅ Step 3: Multiagentチーム起動完了"
    echo "  ✅ Step 4: Fixチーム起動完了"
    echo "  ✅ Step 5: 連携確認完了"
    echo "  ✅ Step 6: 仕様書変換・指示開始完了"
    echo ""
    echo "🔧 操作コマンド:"
    echo "  - 指示送信: ./president-command.sh $project_name \"指示内容\""
    echo "  - 個別通信: ./agent-send.sh $project_name [エージェント名] \"メッセージ\""  
    echo "  - 状況確認: ./agent-send.sh $project_name --list"
    echo ""
    echo "🎯 すべてのシステムが稼働中です！"
}

# クイックセットアップ
launch_quick_setup() {
    local project_name="$1"
    
    echo "================================================"
    echo " ⚡ ClaudeAuto クイックセットアップ"
    echo "================================================"
    echo "プロジェクト: $project_name"
    echo ""
    echo "⚠️  推奨: 完全システムを使用してください"
    echo "   ./system-launcher.sh $project_name --full"
    echo ""
    
    setup_project_env "$project_name"
    log_action "$project_name" "QUICK" "クイックセットアップ完了"
    
    echo "✅ 基本セットアップ完了"
    echo ""
    echo "次のステップ："
    echo "1. ./start-president.sh $project_name"
    echo "2. ./start-team.sh $project_name"
    echo "3. ./start-errorfix.sh $project_name"
}

# 個別起動関数
launch_president() {
    local project_name="$1"
    echo "🎯 プレジデント起動中..."
    setup_project_env "$project_name"
    ./start-president.sh "$project_name"
}

launch_team() {
    local project_name="$1"
    echo "👥 Multiagentチーム起動中..."
    setup_project_env "$project_name"
    ./start-team.sh "$project_name"
}

launch_errorfix() {
    local project_name="$1"
    echo "🛠️ Fixチーム起動中..."
    setup_project_env "$project_name"
    ./start-errorfix.sh "$project_name"
}

# メイン処理
main() {
    # ヘルプ表示
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]] || [[ $# -eq 0 ]]; then
        show_usage
        exit 0
    fi

    local project_name="$1"
    local option="${2:---full}"

    # プロジェクト名検証
    if ! [[ "$project_name" =~ ^[a-zA-Z0-9_]+$ ]]; then
        echo "❌ エラー: プロジェクト名は英数字とアンダースコアのみ使用可能です"
        exit 1
    fi

    # オプション処理
    case "$option" in
        "--full")
            launch_full_system "$project_name"
            ;;
        "--quick")
            launch_quick_setup "$project_name"
            ;;
        "--president")
            launch_president "$project_name"
            ;;
        "--team")
            launch_team "$project_name"
            ;;
        "--errorfix")
            launch_errorfix "$project_name"
            ;;
        *)
            echo "❌ 無効なオプション: $option"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"