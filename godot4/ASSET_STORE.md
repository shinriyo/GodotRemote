# Godot Asset Store配布準備

2026-10-20に申請済み。管理画面で **Asset Status: Pending** を確認。審査待ちで、一般公開はまだ。無料のサーバーアドオンとして配布する。iPhoneクライアントが別途必要で、App Store版は販売準備中であることを掲載説明に明記する。

2026-10-20確認時点の公式案内では、Godot 4.7向けには新しいGodot Asset Storeを使用する。旧Asset Libraryは非推奨。

## 配布前に揃えるもの

- ZIPの直下を `addons/godot_remote/` にする。現リポジトリを丸ごとZIPにすると旧版との混同が起きるため、Godot 4版のアドオンだけを梱包する。
- プラグインフォルダ内のREADMEとLICENSEを含める。現在同梱済み。
- 英語の名前・説明、独自アイコン、導入・接続のスクリーンショット、ソースURL、版番号と変更履歴。
- 検証したGodotバージョンを登録する。4.7.2以外は未検証。
- AI利用の申告欄に、Codexによるコード・文書作成支援と実施した検証を正確に記載する。
- 空のゲームプロジェクトへZIPから導入し、有効化・待受・接続・無効化を確認してから提出する。
- 公開時のクライアント入手先と無料でビルドする手順を確認する。

候補名: SHINRIYO Remote Server for Godot 4

英語説明案:

> Stream your running Godot game to the SHINRIYO Remote client for remote playtesting. This free MIT-licensed server addon supports JPEG video and touch/mouse/keyboard input, with Bonjour discovery for Mac-to-iPhone connections. A compatible client is required; the App Store client is not yet released. Client source and build instructions are available in the linked repository. Tested with Godot 4.7.2. Independent software, not an official Godot Engine product.

公式資料:
- https://godotengine.org/article/introducing-the-godot-asset-store/
- https://docs.godotengine.org/en/stable/community/asset_store/submitting_to_asset_store.html

## 提出結果

- アセット: https://store.godotengine.org/asset/shinriyo/shinriyo-remote-server/
- バージョン: `4.0.0-dev`（プレビュー、version ID `7480`）
- 対応登録: Godot `4.7.2` のみ
- 英語説明・MIT・GDScriptタグ・AI利用申告・16:9サムネイル登録済み
- 配布ZIPからのプラグイン起動検証と統合テスト27項目が成功
- 提出内容の記録: `release/asset-store-submission.md`
