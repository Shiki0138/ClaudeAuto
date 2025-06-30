#!/bin/bash

# 🎯 6段階システム起動スクリプト
# ユーザフレンドリーで明確な手順実行

echo "================================================"
echo " 🚀 ClaudeAuto 6段階システム起動"
echo "================================================"

PROJECT_NAME="$1"
if [ -z "$PROJECT_NAME" ]; then
    echo "プロジェクト名を入力してください:"
    read PROJECT_NAME
    if [ -z "$PROJECT_NAME" ]; then
        echo "❌ エラー: プロジェクト名が必要です"
        exit 1
    fi
fi

echo "🎯 プロジェクト: $PROJECT_NAME"
echo ""

# ステップ1: セットアップ
echo "==============================================="
echo " STEP 1: セットアップ（設定適用）"
echo "==============================================="
echo "必要情報と設定をすべてのチームに適用します..."
sleep 2

# ディレクトリ・ファイル準備
mkdir -p tmp development specifications logs
touch development/development_log.txt
touch specifications/project_spec.txt

# 環境変数設定
cat > ".env_${PROJECT_NAME}" << EOF
export PROJECT_NAME="${PROJECT_NAME}"
export PRESIDENT_SESSION="${PROJECT_NAME}_president"
export MULTIAGENT_SESSION="${PROJECT_NAME}_multiagent"  
export ERRORFIX_SESSION="${PROJECT_NAME}_errorfix"
EOF

echo "✅ Step 1完了: 環境設定・ディレクトリ準備完了"
echo ""

# ステップ2: プレジデント起動
echo "==============================================="
echo " STEP 2: プレジデント起動（Claude Code）"
echo "==============================================="
echo "プレジデントセッションを起動します..."
echo ""
echo "⚠️  別ターミナルでClaudeCodeを起動してください："
echo "   ./start-president.sh $PROJECT_NAME"
echo ""
echo -n "プレジデント起動完了後、Enterを押してください..."
read

echo "✅ Step 2完了: プレジデント起動確認"
echo ""

# ステップ3: Multiagentチーム起動
echo "==============================================="
echo " STEP 3: Multiagentチーム起動（Claude Code）"
echo "==============================================="  
echo "Boss1 + Worker1-5 チームを起動します..."
echo ""
echo "⚠️  別ターミナルでClaudeCodeを起動してください："
echo "   ./start-team.sh $PROJECT_NAME"
echo ""
echo -n "Multiagentチーム起動完了後、Enterを押してください..."
read

echo "✅ Step 3完了: Multiagentチーム起動確認"
echo ""

# ステップ4: Fix チーム起動
echo "==============================================="
echo " STEP 4: Fixチーム起動（Claude + 手動）"
echo "==============================================="
echo "エラー修正チームを起動します..."
echo ""
echo "⚠️  以下を実行してください："
echo "   1) 別ターミナルで: ./start-errorfix.sh $PROJECT_NAME"
echo "   2) Claude起動後、ペイン0.1でGemini手動起動"
echo "   3) ペイン0.0でCodex手動起動"
echo ""
echo -n "Fixチーム（Claude+Gemini+Codex）起動完了後、Enterを押してください..."
read

echo "✅ Step 4完了: Fixチーム起動確認"
echo ""

# ステップ5: 各チーム連携確認
echo "==============================================="
echo " STEP 5: 各チーム連携確認"
echo "==============================================="
echo "各チーム間の通信テストを実行します..."

# プレジデント→Boss1テスト
echo "📡 Test 1: PRESIDENT → Boss1"
./agent-send.sh "$PROJECT_NAME" boss1 "システム起動確認テスト。応答してください。"
sleep 3

# Boss1→Worker1テスト  
echo "📡 Test 2: Boss1 → Worker1"
./agent-send.sh "$PROJECT_NAME" worker1 "Worker1応答確認テスト"
sleep 3

# Error Fixチームテスト
echo "📡 Test 3: Error Fix チーム確認"
./agent-send.sh "$PROJECT_NAME" errorfix_claude "Error Fix チーム応答確認テスト"
sleep 3

echo "✅ Step 5完了: 通信テスト実行"
echo ""
echo "各チームからの応答を確認してください。"
echo -n "すべて正常に応答している場合、Enterを押してください..."
read

# ステップ6: 仕様書変換と指示開始
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

# プレジデントに開始指示
./president-command.sh "$PROJECT_NAME" "6段階システム起動完了。プロジェクト開始指示を出してください。"

echo ""
echo "✅ Step 6完了: 仕様書変換・初期指示送信完了"
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
echo "  - 指示送信: ./president-command.sh $PROJECT_NAME \"指示内容\""
echo "  - 個別通信: ./agent-send.sh $PROJECT_NAME [エージェント名] \"メッセージ\""  
echo "  - 状況確認: ./agent-send.sh $PROJECT_NAME --list"
echo ""
echo "🎯 すべてのシステムが稼働中です！"
echo "プレジデントから指示を開始してください。"

# 開発ログ記録
echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SYSTEM] [$PROJECT_NAME] 
6段階システム起動完了
- プレジデント起動: ${PROJECT_NAME}_president
- Multiagentチーム起動: ${PROJECT_NAME}_multiagent (Boss1 + Worker1-5)
- Fixチーム起動: ${PROJECT_NAME}_errorfix (Claude + Gemini + Codex)
全システム稼働準備完了" >> development/development_log.txt