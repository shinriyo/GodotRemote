# 次回のモバイル更新申請

## 確認状況（2026-11-14）

- App Store Connect: iOS 4.0.0 は Ready for Distribution。
- 現在の開発ブランチ: develop、確認時点のHEADは4f9023e。
- 次回版は未申請。バージョン番号・ビルド番号はアップロード履歴との照合後に決める。
- Google Playの現在の公開・審査状態は今回未確認。

## 次回の中心となる変更

- 接続先・ポート・パスワードのラベルと配置を整理。
- 接続・切断のアイコン、パスワード表示切替、貼り付け操作を改善。
- 接続ボタンを広くし、Aboutを下部の控えめなボタンへ移動。
- ポート入力を1〜65535に対応。
- 音声転送は次々回の予定であり、この更新には含めない。

## 申請前に解消する項目

- developにはTCPからWebSocketへの通信変更も含まれる。既存4.0.0用アドオンとの互換性を維持するか、対応アドオンを同時配布して更新手順を明記する必要がある。UIだけの変更として申請しない。
- HTTPS URLではポート入力欄が接続に使われないことを画面上で明確にする。
- iPhone・iPad・Androidで新UI、接続、映像、入力、切断・再接続を確認し、掲載画像を更新。
- 公開URL経由のWebSocketハンドシェイク成功は、映像・入力までの確認とは区別する。
- 審査用デモZIPを申請する通信方式に合わせて更新し、手順を再検証。
- 新しい申請ビルドをソースコミットと紐付けて記録する。

## What's New 下書き（UI変更分）

Improved the connection screen with clearer field labels, easier paste and password controls, and a more prominent Connect button. Moved app information and licenses to a compact About button. Expanded port entry to support values from 1 to 65535.

通信方式の扱いが確定したら、この説明にも反映する。
