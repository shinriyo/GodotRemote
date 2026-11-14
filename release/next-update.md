# モバイル更新 4.0.1（2026-11-14）

- Google Play: 4.0.1 / versionCode 3 の製品版を審査送信済み。「審査中の変更」に表示。送信後の確認時点では事前クイックチェック中。公開は未確認。
- iOS: 4.0.1 / build 1 の署名・アーカイブ・App Store Connectへのアップロード成功。4.0.1の提出準備中レコードあり。ブラウザーログインが失効し、再認証待ちのため審査提出は未完了。
- 既存公開版: iOS 4.0.0 build 4 は Ready for Distribution、Android 4.0.0 code 2 は2026-10-20から公開済み。

## ソースの分離

- 今回の提出ソース: `codex/release-ui-4.0.1`、`ee6fe90`。公開版masterからUI改善を取り込み、TCP通信と既存無料アドオンの互換性を維持。
- `develop`のWebSocket変更は保持し、今回のストア版には含めない。音声転送も今回の対象外。
- 専用worktree: `godot4/build/release-ui-4.0.1`。
- 提出ソースはプッシュ済み。Apple提出後に対応PRを作成し、承認後にmasterへ統合する。未承認版をmasterへマージしない。

## 完了した検証と残り

- Android AABのmanifestで4.0.1 / code 3、min SDK 24、target/compile SDK 36を確認。署名検証成功。
- iOS IPAのmanifestで4.0.1 / build 1、bundle `com.shinriyo.godotremote4`、minimum iOS 15.0を確認。正式team `R8W4W3W2S5`で署名。
- Godot統合テスト・縦横UIテスト: failures 0。iPhone/iPadシミュレーターで新UIの実描画を確認。今回の新たな実機検証は未実施。
- 審査用ZIPのserver/link/input_codecは今回のTCPソースと一致。更新ZIP、英語審査手順、更新内容、新スクリーンショットを準備済み。
- Apple再ログイン後: ビルド処理結果確認、build 1選択、What's New・レビュー注記・ZIP・新画像を適用し、審査へ提出する。
- 成果物とハッシュの詳細は申請ブランチの `release/4.0.1-artifacts.json`。
