# 🎯 ClaudeAuto 6段階システム ワークフロー

## 📋 システム概要
ClaudeAutoは3つのチーム（プレジデント、multiagent、fixチーム）が連携して動作する自律開発システムです。

## 🚀 6段階起動手順

### STEP 1: セットアップ（設定適用）
**目的**: 全チームの環境設定・ディレクトリ準備

```bash
# 自動実行
./6step-system.sh [プロジェクト名]
```

**実行内容**:
- 必要ディレクトリ作成（tmp, development, specifications, logs）
- 環境変数ファイル（.env_[プロジェクト名]）作成
- 基本ファイル準備

### STEP 2: プレジデント起動（Claude Code）
**目的**: 統括管理者の起動

```bash
# 別ターミナルで実行
./start-president.sh [プロジェクト名]
```

**ウィンドウ名**: `[プロジェクト名]_president`

### STEP 3: Multiagentチーム起動（Claude Code）
**目的**: Boss1 + Worker1-5 の6体制チーム起動

```bash
# 別ターミナルで実行  
./start-team.sh [プロジェクト名]
```

**ウィンドウ名**: `[プロジェクト名]_multiagent`
- Boss1: ペイン 0.0
- Worker1: ペイン 0.1
- Worker2: ペイン 0.2
- Worker3: ペイン 0.3
- Worker4: ペイン 0.4
- Worker5: ペイン 0.5

### STEP 4: Fixチーム起動（Claude + 手動）
**目的**: エラー修正専門チームの起動

```bash
# 別ターミナルで実行
./start-errorfix.sh [プロジェクト名]
```

**ウィンドウ名**: `[プロジェクト名]_errorfix`
- Claude（リーダー）: ペイン 0.2 - 自動起動
- Gemini（CI/CD担当）: ペイン 0.1 - 手動起動
- Codex（コード解析担当）: ペイン 0.0 - 手動起動

### STEP 5: 各チーム連携確認
**目的**: 通信テスト・応答確認

**自動実行テスト**:
- Test 1: PRESIDENT → Boss1
- Test 2: Boss1 → Worker1  
- Test 3: Error Fixチーム確認

### STEP 6: 仕様書変換と作業指示
**目的**: 仕様書の準備と初期指示送信

**実行内容**:
- `specifications/project_spec.txt` → `project_spec.md` 変換
- プレジデントに初期指示送信

## 📡 通信システム

### 基本通信コマンド
```bash
# 個別通信
./agent-send.sh [プロジェクト名] [エージェント名] "メッセージ"

# プレジデントからの指示
./president-command.sh [プロジェクト名] "指示内容"
```

### 利用可能エージェント
- **president**: プロジェクト統括責任者
- **boss1**: チームリーダー
- **worker1-5**: 実行担当者
- **errorfix_claude**: エラー修正リーダー  
- **errorfix_gemini**: CI/CD担当
- **errorfix_codex**: コード解析担当

## 📊 システムフロー

### 通常開発フロー
```
PRESIDENT（統括管理）
    ↓ 指示
Boss1（チーム管理）
    ↓ 作業分配
Worker1-5（実装）
    ↓ 完了報告
Boss1（統合）
    ↓ 報告
PRESIDENT（確認）
```

### エラー対応フロー
```
PRESIDENT（エラー指示）
    ↓
Claude（Error Fixリーダー）
    ↓ 分析指示
Gemini（CI/CD） & Codex（コード解析）
    ↓ 分析結果
Claude（統合・解決策決定）
    ↓ 完了報告
PRESIDENT（確認）
```

## 🔧 重要な設定

### ウィンドウ名統一
- **プレジデント**: `[プロジェクト名]_president`
- **Multiagent**: `[プロジェクト名]_multiagent`
- **Fix**: `[プロジェクト名]_errorfix`

### 環境変数ファイル（.env_[プロジェクト名]）
```bash
export PROJECT_NAME="[プロジェクト名]"
export PRESIDENT_SESSION="[プロジェクト名]_president"
export MULTIAGENT_SESSION="[プロジェクト名]_multiagent"
export ERRORFIX_SESSION="[プロジェクト名]_errorfix"
```

## 🎯 使用例

```bash
# プロジェクト開始
./6step-system.sh myproject

# 指示送信
./president-command.sh myproject "新機能の実装を開始してください"

# 個別通信
./agent-send.sh myproject worker1 "進捗を確認してください"

# エラー修正
./agent-send.sh myproject errorfix_claude "ビルドエラーが発生しています"
```

## 📝 開発ルール・仕様書遵守

全エージェントは以下を必ず確認：
- `development/development_rules.md`（開発ルール）
- `specifications/project_spec.md`（プロジェクト仕様書）

## 🔄 自動化機能

- **自動再指示システム**: Boss1による継続的タスク配信
- **30分ごとの自動継続**: `auto-continue.sh`
- **開発ログ自動記録**: 全通信・作業ログ記録

## ⚠️ 注意事項

1. **必ず6段階順序で実行**
2. **各ステップ完了確認必須**
3. **手動起動部分の実行忘れ防止**
4. **通信テストでの応答確認**
5. **仕様書の事前準備**