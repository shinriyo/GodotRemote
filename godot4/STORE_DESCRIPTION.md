# ストア説明の下書き

以下は公開前に作成した説明文です。iOS 4.0.0は2026-11-13に日本App Storeで公開確認済みです。現在の状態と検証範囲は[リリースノート](releases/2026-11-13.md)を参照してください。

## 紹介文

SHINRIYO Remote for Godot 4は、Macで実行中のGodotゲームをiPhoneで表示・操作できる、開発者向けの非公式リモートテストツールです。

同じネットワーク上のゲームを検出し、映像を表示してタッチ操作をMacへ送信します。ゲームはMac上で動作するため、ゲーム自体をiPhoneへ書き出さずに操作を試せます。iOS向けに書き出したゲームの性能や動作を検証する代わりにはなりません。

利用には、Mac、Godot、無料のMac側アドオン、MacとiPhoneが通信できる同一ネットワークが必要です。Godot 4.7.2で動作確認済みです。他のGodot 4.xは未検証です。

【はじめて使うとき】
1. 無料アドオンの `godot4/addons/godot_remote` を、操作したいゲームの `addons/` フォルダへコピーします。
2. Godotの「プロジェクト設定 → プラグイン」で「Godot Remote 4」を有効にし、ゲームを実行します。
3. 同じLANのiPhoneで本アプリを開き、ローカルネットワークへのアクセスを許可します。
4. 一覧でゲームを選び、Connectを押します。

iPhoneアプリのインストールだけでは接続できません。アドオンは操作したいゲームのプロジェクトごとに導入してください。詳しい図解と接続できない場合の確認方法はサポートページをご覧ください。

ソースコードとMac側アドオンはMITライセンスで無料公開しています。App Store版は、自分でビルド・署名せずに利用できる買い切りの有料版です。購入による収益は、このアプリの開発・保守に役立てます。

本アプリはSHINRIYOによる独立した製品です。Godot Engineおよび元のGodot Remote作者の公式製品ではなく、購入代金はそれらへの寄付ではありません。元のGodot Remote作者DmitriySalnikovのクレジットと各種ライセンスは、アプリ内の「About / Licenses」で確認できます。

## App Store Connectに設定するURL

- サポートURL: https://shinriyo-remote.netlify.app/
- プライバシーポリシーURL: https://shinriyo-remote.netlify.app/privacy.html
