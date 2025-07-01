#!/bin/bash

# 🤖 ClaudeAuto 自動応答システム
# チーム間の自動連携・返信機能

set -e

# ログ記録関数
log_auto_response() {
    local project_name="$1"
    local from="$2"
    local to="$3"
    local action="$4"
    local message="$5"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    mkdir -p logs
    echo "[$timestamp] [AUTO_RESPONSE] [$project_name] $from -> $to: $action - $message" >> logs/auto_response_log.txt
}

# プレジデント→ボス自動返信機能
setup_president_to_boss_auto() {
    local project_name="$1"
    local president_session="${project_name}_president"
    local boss_target="${project_name}_multiagent:0.0"
    
    cat > "tmp/president_boss_auto_${project_name}.sh" << 'EOF'
#!/bin/bash
PROJECT_NAME="__PROJECT_NAME__"
BOSS_TARGET="__BOSS_TARGET__"

# プレジデントからの指示を監視して自動的にボスに転送
monitor_president_instructions() {
    echo "🤖 プレジデント→ボス自動転送システム起動"
    
    while true; do
        # プレジデントの出力を監視
        if tmux capture-pane -t "${PROJECT_NAME}_president" -p | tail -5 | grep -E "(指示:|タスク:|作業:|開始:|実行:)" > /dev/null; then
            # 指示内容を抽出
            local instruction=$(tmux capture-pane -t "${PROJECT_NAME}_president" -p | tail -10 | grep -A 5 -E "(指示:|タスク:|作業:|開始:|実行:)")
            
            if [ -n "$instruction" ]; then
                # ボスに自動転送
                tmux send-keys -t "$BOSS_TARGET" "プレジデントからの指示を受信しました:
$instruction

自動的に作業を開始します。" C-m
                
                # ログ記録
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] プレジデント→ボス自動転送: $instruction" >> logs/auto_response_log.txt
                
                # 5秒待機してから次の監視
                sleep 5
            fi
        fi
        sleep 2
    done
}

monitor_president_instructions
EOF
    
    # プレースホルダーを置換
    sed -i "" "s/__PROJECT_NAME__/$project_name/g" "tmp/president_boss_auto_${project_name}.sh"
    sed -i "" "s/__BOSS_TARGET__/$boss_target/g" "tmp/president_boss_auto_${project_name}.sh"
    chmod +x "tmp/president_boss_auto_${project_name}.sh"
    
    log_auto_response "$project_name" "PRESIDENT" "BOSS" "AUTO_SETUP" "自動転送システム準備完了"
}

# ボス→ワーカー自動実行機能
setup_boss_to_workers_auto() {
    local project_name="$1"
    local boss_session="${project_name}_multiagent:0.0"
    
    cat > "tmp/boss_workers_auto_${project_name}.sh" << 'EOF'
#!/bin/bash
PROJECT_NAME="__PROJECT_NAME__"
BOSS_SESSION="__BOSS_SESSION__"

# ボスからの指示を監視して自動的にワーカーに配分
monitor_boss_instructions() {
    echo "🤖 ボス→ワーカー自動配分システム起動"
    
    while true; do
        # ボスの出力を監視
        if tmux capture-pane -t "$BOSS_SESSION" -p | tail -5 | grep -E "(作業指示:|タスク配分:|実装:|開発:)" > /dev/null; then
            # 指示内容を抽出
            local task=$(tmux capture-pane -t "$BOSS_SESSION" -p | tail -10 | grep -A 5 -E "(作業指示:|タスク配分:|実装:|開発:)")
            
            if [ -n "$task" ]; then
                # タスクを自動的にワーカーに配分
                for i in {1..5}; do
                    local worker_target="${PROJECT_NAME}_multiagent:0.$i"
                    
                    # ワーカーごとに異なるタスクを割り当て
                    case $i in
                        1) task_type="フロントエンド実装" ;;
                        2) task_type="バックエンド実装" ;;
                        3) task_type="データベース設計" ;;
                        4) task_type="テスト実装" ;;
                        5) task_type="ドキュメント作成" ;;
                    esac
                    
                    tmux send-keys -t "$worker_target" "ボスからのタスク割り当て:
担当: $task_type
詳細: $task

自動的に作業を開始します。
進捗は自動的にボスに報告されます。" C-m
                    
                    sleep 1
                done
                
                # ログ記録
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] ボス→ワーカー自動配分: $task" >> logs/auto_response_log.txt
                
                # 10秒待機してから次の監視
                sleep 10
            fi
        fi
        sleep 3
    done
}

monitor_boss_instructions
EOF
    
    # プレースホルダーを置換
    sed -i "" "s/__PROJECT_NAME__/$project_name/g" "tmp/boss_workers_auto_${project_name}.sh"
    sed -i "" "s/__BOSS_SESSION__/$boss_session/g" "tmp/boss_workers_auto_${project_name}.sh"
    chmod +x "tmp/boss_workers_auto_${project_name}.sh"
    
    log_auto_response "$project_name" "BOSS" "WORKERS" "AUTO_SETUP" "自動配分システム準備完了"
}

# ワーカー→ボス作業完了自動返信
setup_workers_to_boss_auto() {
    local project_name="$1"
    
    cat > "tmp/workers_boss_auto_${project_name}.sh" << 'EOF'
#!/bin/bash
PROJECT_NAME="__PROJECT_NAME__"
BOSS_TARGET="${PROJECT_NAME}_multiagent:0.0"

# ワーカーの作業完了を監視して自動的にボスに報告
monitor_workers_completion() {
    echo "🤖 ワーカー→ボス自動報告システム起動"
    
    while true; do
        for i in {1..5}; do
            local worker_session="${PROJECT_NAME}_multiagent:0.$i"
            
            # ワーカーの出力を監視
            if tmux capture-pane -t "$worker_session" -p | tail -5 | grep -E "(完了|完成|終了|成功|実装済み)" > /dev/null; then
                # 完了報告を抽出
                local completion=$(tmux capture-pane -t "$worker_session" -p | tail -10 | grep -B 2 -A 2 -E "(完了|完成|終了|成功|実装済み)")
                
                if [ -n "$completion" ]; then
                    # ボスに自動報告
                    tmux send-keys -t "$BOSS_TARGET" "Worker$i からの作業完了報告:
$completion

次のタスクの指示をお待ちしています。" C-m
                    
                    # ログ記録
                    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Worker$i→ボス自動報告: 作業完了" >> logs/auto_response_log.txt
                fi
            fi
        done
        sleep 5
    done
}

monitor_workers_completion
EOF
    
    # プレースホルダーを置換
    sed -i "" "s/__PROJECT_NAME__/$project_name/g" "tmp/workers_boss_auto_${project_name}.sh"
    chmod +x "tmp/workers_boss_auto_${project_name}.sh"
    
    log_auto_response "$project_name" "WORKERS" "BOSS" "AUTO_SETUP" "自動報告システム準備完了"
}

# ボス→プレジデント統合報告
setup_boss_to_president_auto() {
    local project_name="$1"
    local boss_session="${project_name}_multiagent:0.0"
    local president_target="${project_name}_president"
    
    cat > "tmp/boss_president_auto_${project_name}.sh" << 'EOF'
#!/bin/bash
PROJECT_NAME="__PROJECT_NAME__"
BOSS_SESSION="__BOSS_SESSION__"
PRESIDENT_TARGET="__PRESIDENT_TARGET__"

# ボスの統合報告を監視してプレジデントに自動報告
monitor_boss_reports() {
    echo "🤖 ボス→プレジデント自動報告システム起動"
    
    while true; do
        # ボスの出力を監視（全ワーカーの完了確認）
        if tmux capture-pane -t "$BOSS_SESSION" -p | tail -20 | grep -E "(全.*完了|タスク.*完了|作業.*終了)" > /dev/null; then
            # 統合報告を生成
            local report=$(tmux capture-pane -t "$BOSS_SESSION" -p | tail -30 | grep -B 5 -A 5 -E "(全.*完了|タスク.*完了|作業.*終了)")
            
            if [ -n "$report" ]; then
                # プレジデントに自動報告
                tmux send-keys -t "$PRESIDENT_TARGET" "ボスからの作業完了報告:

$report

指示されたタスクが完了しました。
次の指示をお待ちしています。" C-m
                
                # ログ記録
                echo "[$(date '+%Y-%m-%d %H:%M:%S')] ボス→プレジデント自動報告: タスク完了" >> logs/auto_response_log.txt
                
                # 10秒待機してから次の監視
                sleep 10
            fi
        fi
        sleep 5
    done
}

monitor_boss_reports
EOF
    
    # プレースホルダーを置換
    sed -i "" "s/__PROJECT_NAME__/$project_name/g" "tmp/boss_president_auto_${project_name}.sh"
    sed -i "" "s/__BOSS_SESSION__/$boss_session/g" "tmp/boss_president_auto_${project_name}.sh"
    sed -i "" "s/__PRESIDENT_TARGET__/$president_target/g" "tmp/boss_president_auto_${project_name}.sh"
    chmod +x "tmp/boss_president_auto_${project_name}.sh"
    
    log_auto_response "$project_name" "BOSS" "PRESIDENT" "AUTO_SETUP" "自動報告システム準備完了"
}

# 自動応答システム起動
start_auto_response_system() {
    local project_name="$1"
    
    echo "🚀 自動応答システム起動中..."
    
    # 各自動応答スクリプトを準備
    setup_president_to_boss_auto "$project_name"
    setup_boss_to_workers_auto "$project_name"
    setup_workers_to_boss_auto "$project_name"
    setup_boss_to_president_auto "$project_name"
    
    # バックグラウンドで各監視プロセスを起動
    echo "📡 監視プロセス起動中..."
    
    # プレジデント→ボス監視
    nohup bash "tmp/president_boss_auto_${project_name}.sh" > "logs/president_boss_auto_${project_name}.log" 2>&1 &
    echo $! > "tmp/president_boss_auto_${project_name}.pid"
    
    # ボス→ワーカー監視
    nohup bash "tmp/boss_workers_auto_${project_name}.sh" > "logs/boss_workers_auto_${project_name}.log" 2>&1 &
    echo $! > "tmp/boss_workers_auto_${project_name}.pid"
    
    # ワーカー→ボス監視
    nohup bash "tmp/workers_boss_auto_${project_name}.sh" > "logs/workers_boss_auto_${project_name}.log" 2>&1 &
    echo $! > "tmp/workers_boss_auto_${project_name}.pid"
    
    # ボス→プレジデント監視
    nohup bash "tmp/boss_president_auto_${project_name}.sh" > "logs/boss_president_auto_${project_name}.log" 2>&1 &
    echo $! > "tmp/boss_president_auto_${project_name}.pid"
    
    echo "✅ 自動応答システム起動完了"
    echo ""
    echo "📊 起動した監視プロセス:"
    echo "  - プレジデント→ボス自動転送"
    echo "  - ボス→ワーカー自動配分"
    echo "  - ワーカー→ボス自動報告"
    echo "  - ボス→プレジデント自動報告"
    echo ""
    echo "🎯 すべての通信が自動化されました！"
}

# 自動応答システム停止
stop_auto_response_system() {
    local project_name="$1"
    
    echo "🛑 自動応答システム停止中..."
    
    # 各監視プロセスを停止
    for pid_file in tmp/*_auto_${project_name}.pid; do
        if [ -f "$pid_file" ]; then
            pid=$(cat "$pid_file")
            if kill -0 "$pid" 2>/dev/null; then
                kill "$pid"
                echo "停止: PID $pid"
            fi
            rm "$pid_file"
        fi
    done
    
    echo "✅ 自動応答システム停止完了"
}

# メイン処理
main() {
    if [[ $# -lt 2 ]]; then
        echo "使用方法: $0 [プロジェクト名] [start|stop]"
        exit 1
    fi
    
    local project_name="$1"
    local action="$2"
    
    case "$action" in
        "start")
            start_auto_response_system "$project_name"
            ;;
        "stop")
            stop_auto_response_system "$project_name"
            ;;
        *)
            echo "❌ 無効なアクション: $action"
            echo "使用可能: start, stop"
            exit 1
            ;;
    esac
}

main "$@"