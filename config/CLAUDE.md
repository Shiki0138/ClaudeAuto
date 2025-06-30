# ClaudeAuto 6段階システム

## 🚀 プロジェクト起動（推奨）
```bash
# 統合システム（推奨）
./system-launcher.sh [プロジェクト名]
```

## 📋 6段階起動手順

### STEP 1: セットアップ（設定適用）
- 環境設定・ディレクトリ準備
- 全チーム対応設定

### STEP 2: プレジデント起動（Claude Code）
```bash
./team-manager.sh [プロジェクト名] president start
```

### STEP 3: Multiagentチーム起動（Claude Code）
```bash
./team-manager.sh [プロジェクト名] multiagent start
```

### STEP 4: Fixチーム起動（Claude + 手動）
```bash
./team-manager.sh [プロジェクト名] errorfix start
# + Gemini/Codex手動起動
```

### STEP 5: 各チーム連携確認
- 通信テスト自動実行
- 応答確認

### STEP 6: 仕様書変換と指示開始
- txt→md変換
- 初期指示送信

## エージェント構成
- **PRESIDENT** (`[プロジェクト名]_president`): 統括責任者
- **boss1** (`[プロジェクト名]_multiagent:0.0`): チームリーダー
- **worker1-5** (`[プロジェクト名]_multiagent:0.1-5`): 実行担当
- **errorfix_claude** (`[プロジェクト名]_errorfix:0.2`): エラー修正リーダー
- **errorfix_gemini** (`[プロジェクト名]_errorfix:0.1`): CI/CD担当  
- **errorfix_codex** (`[プロジェクト名]_errorfix:0.0`): コード解析担当

## 📋 開発ルール・仕様書システム
**全エージェント必須遵守**: 
- `config/development_rules.md` (開発ルール)
- `config/project_spec.md` (プロジェクト仕様書)

**重要事項**:
- **ユーザ第一主義での開発**
- **史上最強システム作りの意識**
- **仕様書準拠の徹底**
- **UX/UI変更時のPRESIDENT確認**
- **定期的なGitHubデプロイ**
- **開発ログ記録の徹底**

## あなたの役割
- **PRESIDENT**: @config/instructions/president.md (開発ルール・仕様書管理監査)
- **boss1**: @config/instructions/boss.md (チーム品質監督・仕様書確認)
- **worker1,2,3,4,5**: @config/instructions/worker.md (ルール・仕様書遵守実行)

## メッセージ送信（プロジェクト名必須）
```bash
./communication-hub.sh [プロジェクト名] [相手] "[メッセージ]"
```

## 📊 開発ログ・仕様書システム
- **通信ログ**: 自動記録（communication-hub.sh使用時）
- **作業ログ**: 各エージェントが手動記録
- **ログファイル**: `development/development_log.txt`
- **仕様書配置**: `config/project_spec.txt`
- **仕様書変換後**: `config/project_spec.md`
- **変換コマンド**: `./scripts/convert_spec.sh`

## 拡張フロー
### 基本フロー
PRESIDENT (ルール・仕様書管理) → boss1 (品質・仕様確認) → workers(1-5) (仕様書準拠実行) → boss1 → PRESIDENT

### worker間通信フロー
worker1 ⇄ worker2 ⇄ worker3 ⇄ worker4 ⇄ worker5 (全て開発ログ記録・仕様書準拠)

### 自動再指示サイクル
boss1 → 完了報告受信 → 自動的に新サイクル開始 → workers(1-5) (品質・仕様書準拠維持)

## 🔧 競合対策
- **プロジェクト名によるセッション分離**
- **複数プロジェクト同時実行可能**  
- **環境変数ファイル**: `.env_[プロジェクト名]`

## 🎯 品質基準
- **史上最強・史上最高クラスのシステム開発**
- **Claude Codeの技術最大限活用**
- **ユーザビリティ最優先**
- **継続的改善と学習** 