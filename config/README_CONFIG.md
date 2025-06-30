# 📋 ClaudeAuto 設定ファイル

このフォルダには、ClaudeAutoシステムの設定ファイルが含まれています。

## 📁 ファイル構成

### 基本設定
- **CLAUDE.md** - エージェント用プロジェクト指示書
- **SYSTEM_WORKFLOW.md** - 6段階システムの詳細ワークフロー
- **development_rules.md** - 開発ルール（全エージェント必須遵守）
- **project_spec.md** - プロジェクト仕様書（Markdown版）
- **project_spec.txt** - プロジェクト仕様書（テキスト版）

### 指示書（instructions/）
- **president.md** - プレジデント指示書
- **boss.md** - Boss1指示書
- **worker.md** - Worker指示書

## 🔧 使用方法

### 仕様書の変換
```bash
# テキスト仕様書をMarkdownに変換
./scripts/convert_spec.sh
```

### 設定ファイルの更新
1. **project_spec.txt** にプロジェクト仕様を記載
2. `./scripts/convert_spec.sh` で変換
3. 各エージェントが **project_spec.md** を参照

## 📝 重要事項
- すべての設定ファイルはこのフォルダで一元管理
- 変更時は開発ログに記録
- UX/UI変更時はPRESIDENTの承認が必要