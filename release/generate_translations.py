"""Build localized support pages. Run from the repository root."""
from pathlib import Path
from html import escape
import json, re
root = Path(__file__).parent / 'support_page'
data = json.loads((Path(__file__).parent / 'translations.json').read_text())
languages = [('ja','日本語'),('en','English'),('zh-Hans','简体中文'),('ko','한국어'),('vi','Tiếng Việt')]
def filename(lang, privacy=False):
    return ('privacy' if privacy else 'index') + ('' if lang == 'ja' else '-' + lang) + '.html'
def switcher(lang, privacy=False):
    links = ' · '.join(f'<a href="{filename(code, privacy)}" lang="{code}" hreflang="{code}"'+(' aria-current="page"' if code == lang else '')+f'>{name}</a>' for code,name in languages)
    return '<nav class="languages" aria-label="Language">'+links+'</nav>'
def alternates(privacy=False):
    return ''.join(f'<link rel="alternate" hreflang="{code}" href="{filename(code, privacy)}">' for code,_ in languages)
for privacy in (False, True):
    p = root / filename('ja', privacy)
    text = p.read_text()
    text = re.sub(r'<nav class="languages".*?</nav>', '', text)
    text = re.sub(r'<link rel="alternate"[^>]+>', '', text)
    text = text.replace('</header>', switcher('ja', privacy)+'</header>')
    text = text.replace('</head>', alternates(privacy)+'</head>')
    p.write_text(text)
for lang, t in data.items():
    for privacy in (False, True):
        title = t['privacy_title'] if privacy else t['support_title']
        if privacy:
            content = '<h1>'+escape(title)+'</h1><p class="note">'+escape(t['updated'])+'</p>'
            content += ''.join('<section><h2>'+escape(h)+'</h2>'+body+'</section>' for h,body in t['privacy'])
        else:
            content = '<section><div class="eyebrow">REMOTE PLAYTESTING</div><h1>'+escape(t['hero'])+'</h1><p class="lead">'+escape(t['intro'])+'</p><p>'+escape(t['status'])+'</p></section>'
            content += '<div class="card"><h2>'+escape(t['required_title'])+'</h2><p>'+escape(t['required'])+'</p></div>'
            content += '<section id="setup"><h2>'+escape(t['setup'])+'</h2><div class="grid">'
            for i,(h,body) in enumerate(t['steps'],1):
                content += f'<article class="card"><span class="step">0{i}</span><h3>{escape(h)}</h3>{body}</article>'
            content += '</div><pre aria-label="Folder layout">Your game/\n├── project.godot\n└── addons/\n    └── godot_remote/\n        ├── plugin.cfg\n        ├── autoload.gd\n        ├── server.gd\n        └── …</pre><p>'+t['install_note']+'</p></section>'
            content += '<section><h2>'+escape(t['controls_title'])+'</h2><p>'+t['controls']+'</p></section>'
            content += '<section><h2>'+escape(t['faq_title'])+'</h2>'+''.join('<details><summary>'+escape(q)+'</summary><p>'+a+'</p></details>' for q,a in t['faq'])+'</section>'
            content += '<section><h2>'+escape(t['funding_title'])+'</h2><p>'+escape(t['funding'])+'</p></section>'
            content += '<section class="card"><h2>'+escape(t['contact_title'])+'</h2><a class="button" href="https://github.com/shinriyo/GodotRemote/issues">'+escape(t['contact_button'])+'</a><p>'+escape(t['contact'])+'</p><p class="note">'+escape(t['contact_warning'])+'</p></section>'
        html = f'''<!doctype html><html lang="{lang}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><meta name="description" content="{escape(t['intro'],quote=True)}"><title>{escape(title)} | SHINRIYO Remote</title><link rel="icon" href="icon.svg" type="image/svg+xml"><link rel="stylesheet" href="style.css">{alternates(privacy)}</head><body><header><div class="brand"><img src="icon.svg" alt="" width="72" height="72"><div><strong>SHINRIYO Remote for Godot 4</strong><div class="note">{escape(t['tagline'])}</div></div></div><nav aria-label="Navigation"><a href="{filename(lang)}">{escape(t['support_title'])}</a><a href="{filename(lang,True)}">{escape(t['privacy_title'])}</a></nav>{switcher(lang,privacy)}</header><main>{content}</main><footer>© 2026 SHINRIYO · {escape(t['independent'])}<br>Original Godot Remote: DmitriySalnikov / MIT License<br><a href="https://github.com/shinriyo/GodotRemote/tree/develop">{escape(t['source'])}</a> · <a href="https://godotengine.org/license">Godot license</a></footer></body></html>'''
        (root / filename(lang, privacy)).write_text(html)
print('Built 5-language navigation and 8 translated pages.')
import runpy
runpy.run_path(str(Path(__file__).parent / 'add_store_badges.py'), run_name='__main__')
