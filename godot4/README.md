# SHINRIYO Remote for Godot 4 — Godot 4.7.2向け

Godot 4向けのサーバーアドオンと、新しいiPhone／Android／デスクトップクライアントです。標準GodotのGDScript APIで実装しているため、エンジン本体やC++ライブラリのビルドは不要です。Godot 4.7.2で動作確認済みです。他のGodot 4.xは未検証で、対応する最低バージョンは未確定です。

旧Godot 3版のネイティブモジュールを全機能移植したものではありません。基本的な遠隔操作を新しい通信方式で実装した開発版です。旧クライアント・旧APIとは互換性がありません。

## PC側のゲームに組み込む

サーバープラグインの正式名称は **SHINRIYO Remote Server for Godot 4** です。

1. このディレクトリの `addons/godot_remote` を、対象Godot 4プロジェクトの `addons/` にコピーします。
2. 「プロジェクト設定 → プラグイン」で **SHINRIYO Remote Server for Godot 4** を有効にします。
3. 必要に応じて「プロジェクト設定」の `godot_remote/server` を設定します。
4. ゲームを実行します。実行中のルートViewportを転送します。

| 設定 | 初期値 | 内容 |
| --- | --- | --- |
| enabled | true | サーバーを起動 |
| port | 22766 | TCP待受ポート |
| password | 空文字列 | クライアントと一致させる接続パスワード |
| fps | 20 | 転送頻度（1〜60） |
| quality | 0.65 | JPEG品質（0.1〜1.0） |
| scale | 0.5 | 転送画像の縮小率（0.1〜1.0） |

自動起動はデバッグビルドのみです。リリースエクスポートでは起動しません。プロジェクトを複数同時実行するときは、ポートを分けてください。サーバーは同時に1クライアントを受け付けます。

通信は暗号化されていません。パスワードも平文で送られるため、信頼できるローカルネットワークまたはUSBのADB転送で使用してください。

## スマホ／PCのクライアント

このディレクトリの `project.godot` をGodot 4.7.2で開いて実行します。**クライアント側でサーバープラグインを有効化する必要はありません。**

- iPhoneでは、同じネットワーク内のMacで実行中のゲームが一覧に表示されます。ゲームを選ぶと接続先が自動入力されるので、必要ならパスワードを入力してConnectを押します。
- Android／デスクトップ、または検出できない場合は、PCのIPアドレスとポートを手入力できます。
- 表示されたゲーム画面をタッチするとPC側へ入力されます。余白を除いた表示領域から座標を変換します。
- マウス・キーボードも送信できます。接続欄の編集中はキーを送りません。
- Androidでは加速度・重力・ジャイロ・磁力センサーを30Hzで送ります。実際の値の取得可否は端末に依存します。
- Disconnectで切断できます。切断・タイムアウト時は、押したままの入力とセンサー値をPC側で解除します。

### Android APK

`export_presets.cfg` にAndroidプリセットがあります。Godot 4.7.2のエクスポートテンプレート、Android SDK、JDKを設定した環境で、次のコマンドでデバッグAPKを生成します。

```sh
mkdir -p build
godot --headless --audio-driver Dummy --path . --export-debug Android build/GodotRemote4.apk
```

パッケージ名は `org.godotremote.client4` です。ARM64端末とx86_64エミュレーターを対象にしています。旧版アプリとは別パッケージです。ストア公開用の署名・リリース設定は含みません。

USB経由では次を実行し、クライアントの接続先を `127.0.0.1:22766` にします。

```sh
adb reverse tcp:22766 tcp:22766
```

## iPhone

`iOS` エクスポートプリセットを追加しています。Bundle IDは `com.shinriyo.godotremote4`、署名チームは `R8W4W3W2S5` です。iPhone用ARM64ビルド、既存の開発用プロファイルによるオフライン署名に対応します。

1. Mac側のGodotプロジェクトに上記サーバーアドオンを導入し、ゲームを実行します。
2. 同じWi-Fiに接続したiPhoneで **SHINRIYO Remote for Godot 4** を開きます。
3. ローカルネットワークへのアクセスを求められたら許可します。
4. 上部の一覧から実行中のゲームを選び、Connectを押します。IPアドレスとポートは自動入力されます。パスワードを設定した場合は入力してください。

自動検出には、今回の更新版アドオンをMac側にもコピーしてください。ゲーム実行中だけ、macOS標準のBonjourで `_godotremote._tcp` サービスを公開します。複数のゲームは別ポートにすると一覧から選べます。アプリは勝手に接続せず、選択後のConnectで接続します。

一覧が空の場合は、Mac側のゲーム実行・iPhoneのローカルネットワーク許可・同じLANへの接続を確認してください。ゲストWi-Fiなどで端末間通信やBonjourが遮断されている場合は検出できません。手入力も利用できます。自動検出は現時点で **Macサーバー → iPhoneクライアント** に対応しています。

iPhoneから接続する場合の `127.0.0.1` はiPhone自身を指すため、Macのアドレスを使用してください。初回の許可操作中にタイムアウトした場合は、Connectを押し直してください。許可を拒否した場合は、iPhoneの設定でこのアプリの「ローカルネットワーク」を有効にします。ADB転送はAndroid専用です。

接続すると設定欄を隠し、映像を縦横比を保って利用可能な画面いっぱいに表示します。右上のSettingsで設定欄を開き、Hideで閉じられます。横長のゲームはiPhoneを横向きにすると大きく表示できます。

縦・横画面のセーフエリアを考慮し、接続操作のタップ領域を確保しています。接続先アドレスとポートは端末に保存しますが、パスワードは保存しません。アプリをバックグラウンドにすると切断し、Mac側の入力が押されたまま残らないようにします。復帰時はConnectで再接続してください。

### 再ビルドと開発用インストール

MacにXcodeとGodot 4.7.2のiOSエクスポートテンプレートが必要です。

```sh
sh scripts/export_ios.sh
```

このスクリプトはXcodeプロジェクトへSwift製のBonjour検出ヘルパーを組み込み、署名なし実機用アプリを `build/` に生成します。**自動検出を含める場合は、このスクリプトでビルドしてください。Godotのエクスポートのみではネイティブヘルパーは入りません。**Appleへのプロビジョニング更新は行いません。

既存の対象端末入り開発用プロファイルと、Keychainにある有効な署名証明書を使う場合:

```sh
python3 scripts/sign_ios.py \
  --app build/ios-derived/Build/Products/Debug-iphoneos/GodotRemote4.app \
  --profile /path/to/existing.mobileprovision \
  --identity CERTIFICATE_SHA1 \
  --device IPHONE_UDID \
  --output build/ios-device

xcrun devicectl device install app --device IPHONE_UDID \
  build/ios-device/Payload/GodotRemote4.app
```

手動署名スクリプトは、所属チーム・Bundle ID・プロファイル有効期限・証明書・対象端末を照合します。既存プロファイルと証明書を使うだけで、新規登録・証明書発行は行いません。開発用IPAは `build/ios-device/GodotRemote4.ipa` です。プロファイルに含まれる端末専用で、App StoreやTestFlight向けではありません。開発用署名の有効期限が切れた場合は再署名が必要です。

## 確認用サーバー

`demo_server.tscn` を実行すると、タッチで円が移動するサーバー画面が起動します。別のクライアントから接続して、画面転送と入力を確認できます。

## 新しいAPI

プラグインを有効にしたゲームでは `GodotRemote` がサーバーのAutoloadです。

```gdscript
GodotRemote.client_connected.connect(func(): print("Connected"))
GodotRemote.user_data_received.connect(func(id, data): print(id, data))
GodotRemote.send_user_data("score", 100)
```

サーバーを手動生成する場合は `addons/godot_remote/server.gd` をNodeとして追加し、`start(port, bind_address)`／`stop()` を使用します。クライアントは `client.gd` の `connect_to_host(host, port, password)`、`disconnect_from_host()`、`send_input(event, display_rect)` を使用します。

送受信データはオブジェクト復元を無効にしたGodot 4のVariant形式です。JPEG転送は確認応答を待ってから次フレームを送信するため、低速な接続で古いフレームを積み続けません。

## 対応状況

| 機能 | 状態 |
| --- | --- |
| JPEG画面転送、画質・縮小率・FPS設定 | 実装、合成画像の送受信を検証 |
| タッチ・ドラッグ・マウス・キーボード | 実装、座標変換・入力送信を検証 |
| センサー転送 | 実装、合成値の受信とInput反映を検証 |
| カスタムデータ | 実装、送受信検証 |
| パスワード照合、切断解除、再接続 | 検証済み |
| Android APK | デバッグ書き出し・署名検証済み |
| iPhone 15 Pro MaxへのLAN接続・実画面転送・タッチ入力 | 2026-10-20に実機確認済み（Mac上のデモ） |
| 実機センサーの精度、Android実機、USB経由接続 | 未検証 |
| Bonjour自動検出 | Mac→iPhone用に実装。Mac上で公開・検出・停止後の削除を通信検証。iPhone 15 Pro Maxでもゲームの検出・選択を確認 |
| 旧UDP自動検出、H.264、ジョイパッド転送 | 未移植 |
| カスタム入力シーン転送、旧通知／統計UI、旧API互換 | 未移植 |
| iPhone用アプリ | ARM64ビルド・開発用署名・iPhone 15 Pro Maxへのインストールとデモの実操作を確認 |
| iPhone向けUI | 最大表示・設定切替・入力分離を含む24項目をヘッドレス検証。実機縦画面で長いゲーム名の表示・選択・接続を確認 |
| App Store／TestFlight公開 | 未設定 |

## ヘッドレス検証

```sh
godot --headless --audio-driver Dummy --path . --script res://tests/compile.gd
godot --headless --audio-driver Dummy --path . --script res://tests/integration.gd
godot --headless --audio-driver Dummy --path . --quit-after 3
python3 tests/plugin_lifecycle.py /path/to/godot
godot --headless --audio-driver Dummy --path . --script res://tests/mobile_ui.gd
godot --headless --audio-driver Dummy --path . --script res://tests/discovery.gd
python3 tests/bonjour_native.py /path/to/godot
```

通信テストはローカルホストの24766番ポートを使用します。ヘッドレス環境では画面キャプチャを行わず、合成画像をJPEGに変換して実際のTCP接続で送受信します。これによって画像転送の検証と、GPUによる画面キャプチャの実機検証を区別しています。

Bonjour検出テストはmacOSで実行し、TCP 24768とループバックUDP 22767を一時使用します。検出一覧のテストはUDP 24769を使用します。ネットワーク全体のポート走査は行いません。

### 実機確認（2026-10-20）

iPhone 15 Pro MaxとMac上のGodot 4.7.2デモで、Bonjour一覧からの選択、接続、480×300の実画面転送、実機のタップとドラッグがMacへ届き円の位置に反映されることを確認しました。XCTestの実操作と、サーバー側の入力記録、iPhone画面のスクリーンショットを照合しています。

検証中に見つかった、長いゲーム名による横はみ出しを修正しました。これはデモでの確認であり、各ゲーム固有の操作や長時間の通信安定性・性能を保証するものではありません。

## 名前・ライセンス

アプリ名は **SHINRIYO Remote for Godot 4** です。Godot Engineおよび元のGodot Remote作者の公式製品ではありません。独自のモニター＋スマートフォン図案を `remote_icon.svg` に用意しています。名称の商標調査・ストア上の使用可否確認は公開前に別途行います。

設定欄の **About / Licenses** から、元作者の著作権表記とMIT全文、実行中のGodotのライセンス、Godotが提供するサードパーティ著作権・ライセンス一覧をオフラインで閲覧できます。アドオンにも元のLICENSEを同梱しています。エンジン・プラグイン・素材を追加／変更した場合は配布物全体の条件を再確認してください。

ストア審査と事前テストの準備は [STORE_REVIEW.md](STORE_REVIEW.md) を参照してください。

## 配布・販売方針

ソースコードとMac側アドオンをMITライセンスで無料公開し、App Store版はビルド・署名不要でインストールできる買い切りの有料版として提供する方針です。購入による収益は、SHINRIYO Remote for Godot 4の開発・保守に役立てます。Godot Engine本体や元作者への寄付ではありません。

有料版はアプリの購入であり、寄付を募る仕組みではありません。無料のソース配布にも元作者の著作権表記とライセンスを保持します。

現在は販売準備中です。App Store版は未公開です。販売前に、配布する版に対応したソースとアドオンを取得できることを確認します。公開後に使用する紹介文は [STORE_DESCRIPTION.md](STORE_DESCRIPTION.md) に用意しています。
