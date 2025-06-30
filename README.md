# 🚀 ClaudeAuto 6段階システム

[![GitHub](https://img.shields.io/badge/GitHub-ClaudeAuto-blue?logo=github)](https://github.com/Shiki0138/ClaudeAuto)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-5.0-blue.svg)](CHANGELOG.md)

**6段階システム** | **完全ガイド付き** | **3チーム連携** | **史上最強開発**

---

## 🎯 システム概要

ClaudeAutoは、**プレジデント**、**Multiagent**、**Fix**の3チームが自律連携する史上最強の開発システムです。6段階の明確な手順で、誰でも簡単に最高レベルの開発環境を構築できます。

### ✨ 主な特徴

- 🎯 **6段階システム**: 明確で分かりやすい起動手順
- 👑 **プレジデント統括**: 全指示の一元管理
- 🏗️ **3チーム分散**: President/Multiagent/Fix独立動作
- 🔄 **完全連携**: ウィンドウ名統一による確実な通信
- 🛠️ **エラー自動修正**: 専門Fixチーム（Claude+Gemini+Codex）
- 📊 **開発ログ完備**: 全作業の詳細記録

---

## 🚀 6段階起動（推奨）

### 1回コマンド実行（推奨）
```bash
./system-launcher.sh [プロジェクト名]
```

### 統合システム利用
```bash
# 統合起動システム（推奨）
./system-launcher.sh myproject --full    # 6段階完全起動
./system-launcher.sh myproject --quick   # クイック起動

# チーム管理システム
./team-manager.sh myproject all start    # 全チーム起動
./team-manager.sh myproject president status  # プレジデント状態確認

# 通信システム
./communication-hub.sh myproject president "プロジェクト開始"  # 自然言語指示
./communication-hub.sh myproject boss1 "進捗確認"  # 直接通信
```

---

## 🏗️ システム構成

### プレジデント（統括管理）
```
[プロジェクト名]_president
```
- 全指示の発信源
- 品質管理監督  
- 開発ルール・仕様書管理

### Multiagentチーム（実装）
```
[プロジェクト名]_multiagent
├── Boss1 (0.0) - チームリーダー
├── Worker1 (0.1) - 実装担当A
├── Worker2 (0.2) - 実装担当B  
├── Worker3 (0.3) - 実装担当C
├── Worker4 (0.4) - 実装担当D
└── Worker5 (0.5) - 実装担当E
```

### Fixチーム（エラー修正）
```
[プロジェクト名]_errorfix
├── Codex (0.0) - コード解析担当（手動）
├── Gemini (0.1) - CI/CD担当（手動）
└── Claude (0.2) - 修正リーダー（自動）
```

---

## 📡 通信システム

### 統合通信システム
```bash
# 自然言語プレジデント指示（推奨）
./communication-hub.sh [プロジェクト名] president "指示内容"

# 個別エージェント通信
./communication-hub.sh [プロジェクト名] [エージェント名] "メッセージ"

# システム管理
./communication-hub.sh [プロジェクト名] --list    # エージェント一覧
./communication-hub.sh [プロジェクト名] --status  # 通信状況確認
./communication-hub.sh [プロジェクト名] --test    # 通信テスト実行
```

### 利用可能エージェント
- `president` - プロジェクト統括責任者
- `boss1` - チームリーダー
- `worker1-5` - 実行担当者
- `errorfix_claude` - エラー修正リーダー
- `errorfix_gemini` - CI/CD担当
- `errorfix_codex` - コード解析担当

---

## 🔄 開発フロー

### 通常開発
```
PRESIDENT（指示）
    ↓
Boss1（チーム管理）
    ↓
Worker1-5（実装）
    ↓
Boss1（統合）
    ↓
PRESIDENT（確認）
```

### エラー対応
```
PRESIDENT（エラー指示）
    ↓
Claude（Fix リーダー）
    ↓
Gemini & Codex（分析）
    ↓
Claude（解決策決定）
    ↓
PRESIDENT（完了確認）
```

---

## 📋 開発ルール・仕様書システム

### 必須確認ファイル
- `development/development_rules.md` - 開発ルール
- `specifications/project_spec.md` - プロジェクト仕様書

### 重要原則
- **ユーザ第一主義**での開発
- **史上最強システム**作りの意識
- **仕様書準拠**の徹底
- **開発ログ記録**の完備

---

## 🎮 実用例

### プロジェクト開始
```bash
# 統合システム起動（推奨）
./system-launcher.sh hotel_booking --full

# 自然言語で開発指示
./communication-hub.sh hotel_booking president "ホテル予約システムを開発してください"
```

### 進捗確認
```bash
./communication-hub.sh hotel_booking president "現在の進捗を確認してください"
```

### エラー対応
```bash
./communication-hub.sh hotel_booking president "エラー修正：ビルドエラーが発生しています"
```

### チーム管理
```bash
# 全チーム状態確認
./team-manager.sh hotel_booking all status

# 個別チーム再起動
./team-manager.sh hotel_booking multiagent restart
```

---

## 📁 主要ファイル

| ファイル | 説明 |
|---------|------|
| `system-launcher.sh` | 統合起動システム（推奨） |
| `team-manager.sh` | チーム管理統合システム |
| `communication-hub.sh` | 通信統合システム |
| `start-president.sh` | プレジデント個別起動 |
| `start-team.sh` | Multiagentチーム個別起動 |
| `start-errorfix.sh` | Fixチーム個別起動 |
| `SYSTEM_WORKFLOW.md` | 詳細ワークフロー |

---

## 🚨 注意事項

- **6段階の順序**を必ず守る
- **各ステップの完了確認**必須
- **手動起動部分**（Gemini/Codex）の実行忘れ防止
- **通信テスト**での応答確認
- **仕様書**の事前準備

---

## 🌟 今すぐ体験

```bash
git clone https://github.com/Shiki0138/ClaudeAuto.git
cd ClaudeAuto

# 統合システムで史上最強の開発環境を構築！
./system-launcher.sh myproject
```

**Welcome to the 6-Step Development Revolution! 🚀**