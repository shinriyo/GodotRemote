"""Add official, localized badges; activate links only after URL confirmation."""
from pathlib import Path
from html import escape
import json,re
base=Path(__file__).parent
root=base/'support_page'
stores=json.loads((base/'store_links.json').read_text())
labels={
'ja':('アプリのダウンロード','App Storeからダウンロード','Google Playで手に入れよう','App Store：配信準備中','Google Play：未配信・公開URL未確定'),
'en':('Download the app','Download on the App Store','Get it on Google Play','App Store: preparing for release','Google Play: not released; store URL unavailable'),
'zh-Hans':('下载应用','在 App Store 下载','在 Google Play 上获取','App Store：准备发布中','Google Play：尚未发布，商店链接未确定'),
'ko':('앱 다운로드','App Store에서 다운로드','Google Play에서 다운로드','App Store: 출시 준비 중','Google Play: 미출시, 스토어 URL 미정'),
'vi':('Tải ứng dụng','Tải về trên App Store','Tải trên Google Play','App Store: đang chuẩn bị phát hành','Google Play: chưa phát hành, chưa có URL cửa hàng')}
for lang,t in labels.items():
 p=root/('index'+('' if lang=='ja' else '-'+lang)+'.html');text=p.read_text()
 text=re.sub(r'<!-- STORE_BADGES -->.*?<!-- /STORE_BADGES -->','',text,flags=re.S)
 html='<!-- STORE_BADGES --><section class="downloads" aria-label="'+escape(t[0])+'"><h2>'+escape(t[0])+'</h2><div class="store-badges">'
 for i,(store,ext) in enumerate([('apple','svg'),('google','png')]):
  config=stores[store];url=config['url']
  img=f'<img class="badge-{store}" src="badges/{store}-{lang}.{ext}" alt="{escape(t[i+1])}">'
  if url:
   assert config['store_url_status']=='confirmed'
   assert url.startswith('https://apps.apple.com/' if store=='apple' else 'https://play.google.com/store/apps/details?')
   badge='<a href="'+escape(url,quote=True)+'">'+img+'</a>';status=''
  else:
   badge='<span class="store-unavailable" aria-disabled="true">'+img+'</span>';status='<p class="note">'+escape(t[i+3])+'</p>'
  html+='<div class="store-entry">'+badge+status+'</div>'
 html+='</div></section><!-- /STORE_BADGES -->'
 text=text.replace('</section>','</section>'+html,1);p.write_text(text)
print('Added verified official badges to all 5 support pages.')
