# モバイル更新 4.0.1（2026-11-14）

- Google Play: 4.0.1 / versionCode 3 の製品版を審査送信済み。「審査中の変更」に表示。事前クイックチェック完了後の「現在審査中」を確認。公開は未確認。
- iOS: 4.0.1 / build 1 を2026-11-14 23:17頃 JSTに審査提出済み。「1 Item Submitted」「Waiting for Review」を確認。新UIのiPhone・iPad画像各1枚、審査用ZIP、審査手順を反映済み。承認後は自動公開。公開は未確認。
- 既存公開版: iOS 4.0.0 build 4 は Ready for Distribution、Android 4.0.0 code 2 は2026-10-20から公開済み。

## ソースの分離

- 今回の提出ソース: `codex/release-ui-4.0.1`、`ee6fe90`。公開版masterからUI改善を取り込み、TCP通信と既存無料アドオンの互換性を維持。
- `develop`のWebSocket変更は保持し、今回のストア版には含めない。音声転送も今回の対象外。
- 専用worktree: `godot4/build/release-ui-4.0.1`。
- 提出ソースと提出記録はプッシュ済み。Draft PR #2: https://github.com/shinriyo/GodotRemote/pull/2 （codex/release-ui-4.0.1 → master）。Apple承認後に統合する。未承認版をmasterへマージしない。

## 完了した検証と残り

- Android AABのmanifestで4.0.1 / code 3、min SDK 24、target/compile SDK 36を確認。署名検証成功。
- iOS IPAのmanifestで4.0.1 / build 1、bundle `com.shinriyo.godotremote4`、minimum iOS 15.0を確認。正式team `R8W4W3W2S5`で署名。
- Godot統合テスト・縦横UIテスト: failures 0。iPhone/iPadシミュレーターで新UIの実描画を確認。今回の新たな実機検証は未実施。
- 審査用ZIPのserver/link/input_codecは今回のTCPソースと一致。更新ZIP、英語審査手順、更新内容、新スクリーンショットを準備済み。
- 残り: 両ストアの審査結果を待つ。Apple承認後に申請版PRをmasterへ統合する。
- 成果物とハッシュの詳細は申請ブランチの `release/4.0.1-artifacts.json`。
