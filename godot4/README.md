# Godot Remote for Godot 4.7.2

Godot 4向けのサーバーアドオンと、新しいAndroid／デスクトップクライアントです。標準GodotのGDScript APIで実装しているため、エンジン本体やC++ライブラリのビルドは不要です。Godot 4.7.2で検証しています。

旧Godot 3版のネイティブモジュールを全機能移植したものではありません。基本的な遠隔操作を新しい通信方式で実装した開発版です。旧クライアント・旧APIとは互換性がありません。

## PC側のゲームに組み込む

1. このディレクトリの `addons/godot_remote` を、対象Godot 4プロジェクトの `addons/` にコピーします。
2. 「プロジェクト設定 → プラグイン」で **Godot Remote 4** を有効にします。
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

- 同じWi-FiのPCのIPアドレス、ポート、設定したパスワードを入力し、Connectを押します。
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
| Wi-Fi実機接続、実画面キャプチャ、実機センサー、USB経由接続 | 実機／実描画確認が必要 |
| UDP自動検出、H.264、ジョイパッド転送 | 未移植 |
| カスタム入力シーン転送、旧通知／統計UI、旧API互換 | 未移植 |
| iOSパッケージ、ストア公開 | 未設定 |

## ヘッドレス検証

```sh
godot --headless --audio-driver Dummy --path . --script res://tests/compile.gd
godot --headless --audio-driver Dummy --path . --script res://tests/integration.gd
godot --headless --audio-driver Dummy --path . --quit-after 3
python3 tests/plugin_lifecycle.py /path/to/godot
```

通信テストはローカルホストの24766番ポートを使用します。ヘッドレス環境では画面キャプチャを行わず、合成画像をJPEGに変換して実際のTCP接続で送受信します。これによって画像転送の検証と、GPUによる画面キャプチャの実機検証を区別しています。
