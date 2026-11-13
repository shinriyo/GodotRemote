# サポートページ

公開先: https://shinriyo-remote.netlify.app/
プライバシーポリシー: https://shinriyo-remote.netlify.app/privacy.html
Netlifyサイト名: shinriyo-remote
NetlifyサイトID: 27b7bf18-79cd-4658-87ba-2dff604e4a09

公開ディレクトリは `release/support_page`。HTML、CSS、アイコンだけを公開します。READMEやゲームソースをアップロードしないでください。リポジトリのGit連携は設定していません。

2026-10-20: デプロイ `6ad6f092ba835bd23c885bec` のready状態と、本番トップ・プライバシー・CSS・アイコンのHTTPS応答と内容を確認しました。ブラウザーでデスクトップ表示を確認済み。スマートフォン幅向けCSSあり、実機ブラウザーでの表示は未確認です。

App Store版4.0.0は2026-11-13に公開され、5言語の案内とストアへの導線を更新済みです。問い合わせ窓口は公開GitHub Issuesです。

## Godotアドオンの入手案内の方針

2026-10-20のユーザー指定：ゲーム側の無料アドオンはGodot Asset Storeに掲載する予定です。サイトの「無料アドオンをコピー」とGitHubからのコピー手順は、ストア公開までの暫定案内として扱います。申請状況は `godot4/ASSET_STORE.md` を参照してください。

ストア公開を確認したら、日本語HTML・各言語の翻訳データ・READMEの主な導入案内を、アセット掲載ページからの入手手順へ更新してください。GitHubからの手動コピーは補助的な方法として残します。掲載予定・審査中と、一般公開済みを区別してください。

## 言語

日本語・英語・中国語（簡体字）・韓国語・ベトナム語のサポートとプライバシーページを提供しています。ページ上部から言語を切り替えられます。言語の自動転送は行いません。

- 英語: https://shinriyo-remote.netlify.app/index-en.html
- 簡体字中国語: https://shinriyo-remote.netlify.app/index-zh-Hans.html
- 韓国語: https://shinriyo-remote.netlify.app/index-ko.html
- ベトナム語: https://shinriyo-remote.netlify.app/index-vi.html

翻訳元データは `release/translations.json`。リポジトリルートで `python3 release/generate_translations.py` を実行すると翻訳HTMLを生成し、日本語ページにも言語リンクを設定します。日本語本文はHTMLを直接編集します。生成スクリプトとJSONは公開ディレクトリ外に置いています。

2026-10-20: 多言語デプロイ `6ad71161b43ad71a776113e1` のready状態と全10ページのHTTPS応答、言語属性、ローカル参照と言語切り替えリンクを確認しました。翻訳のネイティブレビューは未実施です。

## 公式ストアバッジ

`app-store-badge`スキルに従い、5言語それぞれのApple・Google公式素材を `support_page/badges/` に同梱しました。取得元は `badge_sources.json` に記録しています。画像は改変していません。

`store_links.json` で画像の検証状態とリンク先の確定状態を別々に管理します。AppleのURLは確定済みでバッジからリンクしています。Google PlayはURL未確定のため画像のみ表示し、未配信の状態を別文言で表示しています。確定URL取得後に `url` と `store_url_status: confirmed` を設定し、`python3 release/add_store_badges.py` で反映してください。

2026-10-20: デプロイ `6ad711f15c73c352903e8602`。本番5言語の両バッジのロード・実表示・未リンク状態と、390px幅で横にはみ出さないことをブラウザーで確認しました。

2026-10-20: デプロイ `6ad71410b80e2cf988d3425c`。5言語のサポートページに接続パスワードの設定・解除手順とGodot Asset Storeの配布案内を追加しました。ready状態、本番全10ページの本文一致、ローカル参照先の存在を確認しました（Netlifyによるリンク整形あり）。

## 2026-10-28 Godot公開確認と次回Androidリリース

Godot Asset Storeで商品Public、4.0.0-dev Published（Unstable、Godot 4.7.2–4.7.2）を確認。Grampsのticket 1477返信は2026-10-28 04:37 JST。名称修正のみで、機能・版番号・対応範囲は変更していません。公式サイト5言語と導入READMEをストア入手案内へ更新しました。

- アドオン: https://store.godotengine.org/asset/shinriyo/shinriyo-remote-server/
- [ ] 次回Android版リリース時、`google-play-description.md` の入手リンクと導入手順をメイン掲載情報へ反映する。今回Play Consoleは変更しない。
- [ ] 掲載文と公式サイトのリンク、Godot対応範囲、プラグイン表示名を再照合し、保存・審査・公開を確認する。
- iPhoneクライアントの公開状態は別途確認する。Media Kobo,Inc. は対象外。

本番反映確認: 2026-10-28 19:27 JST。Netlify deploy `6ae1ce1e51e1a005c8ffd12d` はready、published_at `2026-10-28T10:27:43.981Z`。全22ファイルのHTTPS応答、5言語の配布リンク・公開版表示、既存画像/CSSの一致を確認。デスクトップと390px幅の表示確認済み。iOS/Google Playの公開表記とリンクは変更していません。

2026-11-13: デプロイ `6af6e42eed6bb76295ee3431`。5言語のApp Storeバッジを https://apps.apple.com/app/shinriyo-remote-for-godot-4/id6824852108 にリンクし、本文の未配信表記を更新。ready状態、本番10ページ・5バッジのHTTPS応答とリンクを確認。新規ブラウザー表示検証はアプリ内ブラウザー利用不可のため未実施。CSS・バッジ画像は変更していません。
