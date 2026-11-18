# graph/scripts/node5_build_slides.ps1
# Node 5: Deterministic Interactive Web Presentation Compiler
# Input:  graph/state/03_slides_content.json + assets/*.svg
# Output: slides.html

$ErrorActionPreference = "Stop"

$dataRaw = [System.IO.File]::ReadAllText("graph/state/03_slides_content.json", [System.Text.Encoding]::UTF8)
$data = $dataRaw | ConvertFrom-Json

function Esc([string]$s) {
    if ($null -eq $s) { return "" }
    return [System.Net.WebUtility]::HtmlEncode($s)
}

$slidesMarkup = New-Object System.Text.StringBuilder

foreach ($s in $data.slides) {
    $idx = $s.page
    $activeCls = if ($idx -eq 1) { " active" } else { "" }

    if ($s.type -eq "cover") {
        [void]$slidesMarkup.AppendLine("    <!-- SLIDE $idx : COVER -->")
        [void]$slidesMarkup.AppendLine("    <div class=`"slide cover-slide$activeCls`" data-index=`"$idx`">")
        [void]$slidesMarkup.AppendLine("      <div class=`"cover-animals-row`">")
        foreach ($a in $s.assets) {
            [void]$slidesMarkup.AppendLine("        <img src=`"$a`" width=`"92`" height=`"92`" alt=`"治療動物`" />")
        }
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <h1 class=`"cover-title`">$(Esc $s.title)</h1>")
        [void]$slidesMarkup.AppendLine("      <div class=`"cover-footer-note`">🐾 $(Esc $s.footer_note) &rarr;</div>")
        [void]$slidesMarkup.AppendLine("    </div>")
    }
    elseif ($s.type -eq "toc") {
        [void]$slidesMarkup.AppendLine("    <!-- SLIDE $idx : TOC -->")
        [void]$slidesMarkup.AppendLine("    <div class=`"slide$activeCls`" data-index=`"$idx`">")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-header`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"slide-title-wrap`">")
        [void]$slidesMarkup.AppendLine("          <h2 class=`"slide-title`" style=`"font-size: 2.15rem;`">$(Esc $s.title)</h2>")
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"導覽犬`" />")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-body toc-layout`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"toc-list`">")
        foreach ($sec in $s.sections) {
            [void]$slidesMarkup.AppendLine("          <button type=`"button`" class=`"toc-item`" onclick=`"goToSlide($($sec.jump_to))`">")
            [void]$slidesMarkup.AppendLine("            <span class=`"toc-text`">$(Esc $sec.name)</span>")
            [void]$slidesMarkup.AppendLine("            <span class=`"toc-arrow`">前往 &rarr;</span>")
            [void]$slidesMarkup.AppendLine("          </button>")
        }
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <div class=`"toc-visual`">")
        [void]$slidesMarkup.AppendLine("          <img src=`"assets/cute-dog-study.svg`" width=`"190`" height=`"190`" alt=`"研究小犬`" />")
        [void]$slidesMarkup.AppendLine("          <div style=`"color: #64748b; font-size: 0.98rem; margin-top: 0.6rem;`">點擊任一章節快速跳轉</div>")
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("    </div>")
    }
    elseif ($s.type -in @("content_2col", "content_3col", "content_4grid")) {
        $gridCls = switch ($s.type) {
            "content_2col"  { "grid-2" }
            "content_3col"  { "grid-3" }
            "content_4grid" { "grid-2" }
        }
        $denseCls = if ($idx -in @(10, 11)) { " lit-dense" } else { "" }

        [void]$slidesMarkup.AppendLine("    <!-- SLIDE $idx : $($s.type) -->")
        [void]$slidesMarkup.AppendLine("    <div class=`"slide$activeCls$denseCls`" data-index=`"$idx`">")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-header`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"slide-title-wrap`">")
        [void]$slidesMarkup.AppendLine("          <span class=`"slide-unit-badge`">$(Esc $s.unit)</span>")
        [void]$slidesMarkup.AppendLine("          <h2 class=`"slide-title`">$(Esc $s.title)</h2>")
        if (-not [string]::IsNullOrWhiteSpace($s.subtitle)) {
            [void]$slidesMarkup.AppendLine("          <p class=`"slide-subtitle`">$(Esc $s.subtitle)</p>")
        }
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"動物插圖`" />")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-body`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"$gridCls`" style=`"flex: 1; align-content: center;`">")
        foreach ($c in $s.cards) {
            $accentStyle = if ($c.accent) { " style=`"border-top: 5px solid $($c.accent);`"" } else { "" }
            $titleStyle  = if ($c.accent) { " style=`"color: $($c.accent);`"" } else { "" }
            [void]$slidesMarkup.AppendLine("          <div class=`"content-box`"$accentStyle>")
            [void]$slidesMarkup.AppendLine("            <div class=`"box-title`"$titleStyle>$(Esc $c.title)</div>")
            if (-not [string]::IsNullOrWhiteSpace($c.tag)) {
                [void]$slidesMarkup.AppendLine("            <div class=`"box-tag`">$(Esc $c.tag)</div>")
            }
            [void]$slidesMarkup.AppendLine("            <ul class=`"box-list`">")
            foreach ($b in $c.bullets) {
                [void]$slidesMarkup.AppendLine("              <li>$(Esc $b)</li>")
            }
            [void]$slidesMarkup.AppendLine("            </ul>")
            [void]$slidesMarkup.AppendLine("          </div>")
        }
        [void]$slidesMarkup.AppendLine("        </div>")
        if (-not [string]::IsNullOrWhiteSpace($s.public_quote)) {
            [void]$slidesMarkup.AppendLine("        <div class=`"public-quote-box`"><strong>🌟 生活轉譯</strong>：$(Esc $s.public_quote)</div>")
        }
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("    </div>")
    }
    elseif ($s.type -eq "interactive_myth") {
        [void]$slidesMarkup.AppendLine("    <!-- SLIDE $idx : INTERACTIVE MYTH -->")
        [void]$slidesMarkup.AppendLine("    <div class=`"slide$activeCls`" data-index=`"$idx`">")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-header`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"slide-title-wrap`">")
        [void]$slidesMarkup.AppendLine("          <span class=`"slide-unit-badge badge-interactive`">🎮 $(Esc $s.unit)</span>")
        [void]$slidesMarkup.AppendLine("          <h2 class=`"slide-title`">$(Esc $s.title)</h2>")
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"陪伴貓`" />")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-body`" style=`"justify-content: center;`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"grid-3`">")
        foreach ($it in $s.items) {
            [void]$slidesMarkup.AppendLine("          <div class=`"interactive-card`" id=`"$($it.id)`" onclick=`"toggleMythCard('$($it.id)')`">")
            [void]$slidesMarkup.AppendLine("            <div>")
            [void]$slidesMarkup.AppendLine("              <span class=`"quiz-q-badge`">$(Esc $it.badge)</span>")
            [void]$slidesMarkup.AppendLine("              <div class=`"quiz-question`">$(Esc $it.question)</div>")
            [void]$slidesMarkup.AppendLine("            </div>")
            [void]$slidesMarkup.AppendLine("            <button class=`"quiz-action-btn`" type=`"button`">點擊翻牌看解答 💡</button>")
            [void]$slidesMarkup.AppendLine("            <div class=`"quiz-answer-content`">")
            [void]$slidesMarkup.AppendLine("              <div style=`"font-weight: bold; color: #15803d; margin-bottom: 0.35rem;`">✅ $(Esc $it.verdict)</div>")
            [void]$slidesMarkup.AppendLine("              <div>$(Esc $it.explanation)</div>")
            [void]$slidesMarkup.AppendLine("            </div>")
            [void]$slidesMarkup.AppendLine("          </div>")
        }
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <div style=`"text-align: center; margin-top: 0.6rem;`">")
        [void]$slidesMarkup.AppendLine("          <button type=`"button`" class=`"btn-soft-action`" onclick=`"toggleAllCards('myth')`">一次展開／收合全部迷思解答</button>")
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("    </div>")
    }
    elseif ($s.type -eq "interactive_match") {
        [void]$slidesMarkup.AppendLine("    <!-- SLIDE $idx : INTERACTIVE MATCH -->")
        [void]$slidesMarkup.AppendLine("    <div class=`"slide$activeCls`" data-index=`"$idx`">")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-header`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"slide-title-wrap`">")
        [void]$slidesMarkup.AppendLine("          <span class=`"slide-unit-badge badge-interactive`">🎮 $(Esc $s.unit)</span>")
        [void]$slidesMarkup.AppendLine("          <h2 class=`"slide-title`">$(Esc $s.title)</h2>")
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"長耳兔`" />")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-body`" style=`"justify-content: center;`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"grid-2`">")
        foreach ($it in $s.items) {
            [void]$slidesMarkup.AppendLine("          <div class=`"interactive-card match-card`" id=`"$($it.id)`" onclick=`"toggleMatchCard('$($it.id)')`">")
            [void]$slidesMarkup.AppendLine("            <div style=`"display: flex; justify-content: space-between; align-items: center; gap: 0.8rem;`">")
            [void]$slidesMarkup.AppendLine("              <div>")
            [void]$slidesMarkup.AppendLine("                <span class=`"quiz-q-badge`">$(Esc $it.badge)</span>")
            [void]$slidesMarkup.AppendLine("                <div class=`"quiz-question`" style=`"margin-bottom: 0;`">$(Esc $it.scenario)</div>")
            [void]$slidesMarkup.AppendLine("              </div>")
            [void]$slidesMarkup.AppendLine("              <button class=`"quiz-action-btn`" style=`"flex-shrink: 0;`" type=`"button`">看配對 💡</button>")
            [void]$slidesMarkup.AppendLine("            </div>")
            [void]$slidesMarkup.AppendLine("            <div class=`"quiz-answer-content`">")
            [void]$slidesMarkup.AppendLine("              <div><strong>🧬 對應機轉</strong>：$(Esc $it.mechanism)</div>")
            [void]$slidesMarkup.AppendLine("              <div style=`"margin-top: 0.3rem;`"><strong>🏠 日常能力</strong>：$(Esc $it.daily_life)</div>")
            [void]$slidesMarkup.AppendLine("            </div>")
            [void]$slidesMarkup.AppendLine("          </div>")
        }
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <div style=`"text-align: center; margin-top: 0.4rem;`">")
        [void]$slidesMarkup.AppendLine("          <button type=`"button`" class=`"btn-soft-action`" onclick=`"toggleAllCards('match')`">一次展開／收合全部配對</button>")
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("    </div>")
    }
    elseif ($s.type -eq "interactive_pico") {
        [void]$slidesMarkup.AppendLine("    <!-- SLIDE $idx : INTERACTIVE PICO EXPLORER -->")
        [void]$slidesMarkup.AppendLine("    <div class=`"slide$activeCls`" data-index=`"$idx`">")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-header`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"slide-title-wrap`">")
        [void]$slidesMarkup.AppendLine("          <span class=`"slide-unit-badge badge-interactive`">🎮 $(Esc $s.unit)</span>")
        [void]$slidesMarkup.AppendLine("          <h2 class=`"slide-title`">$(Esc $s.title)</h2>")
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"研究博士犬`" />")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-body`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"pico-tabs`">")
        for ($pi = 0; $pi -lt $s.papers.Count; $pi++) {
            $p = $s.papers[$pi]
            $act = if ($pi -eq 0) { " active" } else { "" }
            [void]$slidesMarkup.AppendLine("          <button type=`"button`" class=`"pico-tab-btn$act`" data-color=`"$($p.color)`" onclick=`"switchPicoTab($pi)`">$(Esc $p.tab_label)</button>")
        }
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <div class=`"pico-panel`" id=`"picoDisplayPanel`"></div>")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("    </div>")
    }
    elseif ($s.type -eq "ending") {
        [void]$slidesMarkup.AppendLine("    <!-- SLIDE $idx : ENDING -->")
        [void]$slidesMarkup.AppendLine("    <div class=`"slide cover-slide$activeCls`" data-index=`"$idx`">")
        [void]$slidesMarkup.AppendLine("      <div class=`"cover-animals-row`">")
        foreach ($a in $s.assets) {
            [void]$slidesMarkup.AppendLine("        <img src=`"$a`" width=`"74`" height=`"74`" alt=`"治療動物`" />")
        }
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <h2 class=`"slide-title`" style=`"font-size: 2rem; color: #0d9488;`">$(Esc $s.title)</h2>")
        [void]$slidesMarkup.AppendLine("      <div class=`"ending-quote`">$(Esc $s.quote)</div>")
        [void]$slidesMarkup.AppendLine("      <p class=`"ending-vision`">$(Esc $s.vision)</p>")
        [void]$slidesMarkup.AppendLine("      <div style=`"display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap; margin-top: 0.4rem;`">")
        [void]$slidesMarkup.AppendLine("        <button type=`"button`" class=`"nav-btn`" onclick=`"goToSlide(1)`">🔄 重新播放簡報</button>")
        [void]$slidesMarkup.AppendLine("        <a href=`"index.html`" class=`"nav-btn`" style=`"background: #0d9488; color: #ffffff; text-decoration: none;`">📖 返回知識庫首頁查看完整論文</a>")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("    </div>")
    }
}

$picoSlide = $data.slides | Where-Object { $_.type -eq "interactive_pico" }
$picoJson = $picoSlide.papers | ConvertTo-Json -Depth 4 -Compress
$totalPages = $data.slides.Count
$allSlidesHtml = $slidesMarkup.ToString()

$html = @"
<!DOCTYPE html>
<html lang="zh-TW">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>$(Esc $data.deck_meta.title)</title>
  <style>
    *, *::before, *::after, html, body, h1, h2, h3, h4, p, span, div, a, button, li {
      font-family: "標楷體", "BiauKai", "DFKai-SB", "TW-Kai", "KaiTi", serif !important;
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    :root {
      --primary: #0d9488;
      --bg: #0f172a;
      --slide-bg: #ffffff;
      --text-main: #0f172a;
      --text-muted: #475569;
      --border: #e2e8f0;
    }

    body {
      background: radial-gradient(circle at 50% 15%, #334155 0%, #0f172a 100%);
      color: var(--text-main);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 0.9rem 1rem;
      overflow-x: hidden;
    }

    .top-toolbar {
      width: 100%;
      max-width: 1180px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.4rem 0.6rem;
      margin-bottom: 0.45rem;
      gap: 0.6rem;
      flex-wrap: wrap;
    }

    .top-toolbar-left, .top-toolbar-right {
      display: flex;
      align-items: center;
      gap: 0.65rem;
    }

    .btn-toolbar {
      background: rgba(255, 255, 255, 0.1);
      border: 1px solid rgba(255, 255, 255, 0.22);
      color: #f8fafc;
      padding: 0.35rem 0.85rem;
      border-radius: 8px;
      font-size: 0.92rem;
      cursor: pointer;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      transition: all 0.2s;
    }

    .btn-toolbar:hover {
      background: rgba(56, 189, 248, 0.2);
      border-color: #38bdf8;
      color: #7dd3fc;
    }

    .progress-bar-container {
      width: 100%;
      max-width: 1180px;
      height: 6px;
      background: rgba(255, 255, 255, 0.16);
      border-radius: 999px;
      overflow: hidden;
      margin-bottom: 0.75rem;
    }

    .progress-bar-fill {
      height: 100%;
      width: 6.67%;
      background: linear-gradient(90deg, #14b8a6 0%, #38bdf8 100%);
      transition: width 0.3s ease;
    }

    .presentation-viewport {
      width: 100%;
      max-width: 1180px;
      height: 685px;
      background: var(--slide-bg);
      border-radius: 24px;
      box-shadow: 0 24px 48px rgba(0, 0, 0, 0.35);
      position: relative;
      overflow: hidden;
    }

    .slide {
      position: absolute;
      inset: 0;
      padding: 2.3rem 2.9rem 1.9rem 2.9rem;
      opacity: 0;
      pointer-events: none;
      transform: translateX(28px);
      transition: opacity 0.32s ease, transform 0.32s ease;
      display: flex;
      flex-direction: column;
      overflow-y: auto;
    }

    .slide.active {
      opacity: 1;
      pointer-events: auto;
      transform: translateX(0);
      z-index: 2;
    }

    /* 頁首 */
    .slide-header {
      border-bottom: 2px solid #f1f5f9;
      padding-bottom: 0.75rem;
      margin-bottom: 1.15rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 1rem;
    }

    .slide-title-wrap {
      display: flex;
      flex-direction: column;
      gap: 0.32rem;
    }

    .slide-unit-badge {
      font-size: 0.88rem;
      font-weight: bold;
      color: #0f766e;
      background: #ccfbf1;
      padding: 0.2rem 0.65rem;
      border-radius: 6px;
      width: fit-content;
    }

    .badge-interactive {
      color: #0369a1;
      background: #e0f2fe;
    }

    .slide-title {
      font-size: 1.85rem;
      color: #0f172a;
      font-weight: bold;
      line-height: 1.3;
    }

    .slide-subtitle {
      font-size: 1rem;
      color: #64748b;
    }

    .slide-header-animal {
      width: 60px;
      height: 60px;
      flex-shrink: 0;
    }

    .slide-body {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 1.05rem;
    }

    /* 封面 & 結語 */
    .cover-slide {
      justify-content: center;
      align-items: center;
      text-align: center;
      gap: 1.7rem;
      background: linear-gradient(160deg, #ffffff 0%, #f0fdfa 100%);
    }

    .cover-animals-row {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 1.4rem;
      flex-wrap: wrap;
    }

    .cover-title {
      font-size: 2.55rem;
      color: #0f172a;
      font-weight: bold;
      line-height: 1.45;
      max-width: 900px;
    }

    .cover-footer-note {
      font-size: 1.08rem;
      color: #0f766e;
      background: #ccfbf1;
      padding: 0.55rem 1.5rem;
      border-radius: 999px;
      font-weight: bold;
    }

    .ending-quote {
      font-size: 1.55rem;
      font-weight: bold;
      color: #0f172a;
      max-width: 860px;
      line-height: 1.75;
      background: #fffbeb;
      border-left: 5px solid #f59e0b;
      padding: 1rem 1.5rem;
      border-radius: 0 14px 14px 0;
    }

    .ending-vision {
      font-size: 1.15rem;
      color: #475569;
      max-width: 780px;
      line-height: 1.7;
    }

    /* 極簡目錄頁 */
    .toc-layout {
      flex-direction: row !important;
      align-items: center;
      gap: 2.5rem;
      padding: 0.5rem 0;
    }

    .toc-list {
      flex: 1.4;
      display: flex;
      flex-direction: column;
      gap: 0.9rem;
    }

    .toc-item {
      background: #f8fafc;
      border: 1.8px solid #cbd5e1;
      border-radius: 14px;
      padding: 1rem 1.4rem;
      font-size: 1.32rem;
      font-weight: bold;
      color: #0f172a;
      display: flex;
      justify-content: space-between;
      align-items: center;
      cursor: pointer;
      transition: all 0.2s;
      text-align: left;
    }

    .toc-item:hover {
      background: #f0fdfa;
      border-color: #0d9488;
      color: #0f766e;
      transform: translateX(6px);
      box-shadow: 0 6px 16px rgba(13, 148, 136, 0.14);
    }

    .toc-arrow {
      font-size: 0.98rem;
      color: #0d9488;
    }

    .toc-visual {
      flex: 0.7;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
    }

    /* 網格與內容卡片 */
    .grid-2 {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1.25rem;
    }

    .grid-3 {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 1.1rem;
    }

    .content-box {
      background: #f8fafc;
      border: 1.5px solid #e2e8f0;
      border-radius: 16px;
      padding: 1.2rem 1.3rem;
      display: flex;
      flex-direction: column;
      gap: 0.55rem;
    }

    .box-title {
      font-size: 1.22rem;
      font-weight: bold;
      color: #0f172a;
    }

    .box-tag {
      font-size: 0.86rem;
      color: #64748b;
      font-weight: bold;
      margin-bottom: 0.15rem;
    }

    .box-list {
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 0.5rem;
      font-size: 1.05rem;
      color: #334155;
      line-height: 1.7;
    }

    .box-list li::before {
      content: "• ";
      color: #0d9488;
      font-weight: bold;
    }

    /* 文獻完整版微調（第 10、11 頁） */
    .lit-dense .content-box {
      padding: 0.95rem 1.05rem;
      gap: 0.4rem;
    }
    .lit-dense .box-title { font-size: 1.12rem; }
    .lit-dense .box-list { font-size: 0.93rem; line-height: 1.58; gap: 0.35rem; }
    .lit-dense .public-quote-box { font-size: 0.96rem; padding: 0.7rem 1.1rem; }

    .public-quote-box {
      background: #fffbeb;
      border-left: 5px solid #f59e0b;
      border-radius: 0 12px 12px 0;
      padding: 0.85rem 1.2rem;
      color: #78350f;
      font-size: 1.05rem;
      line-height: 1.65;
    }

    /* 互動翻牌與配對卡 (Slide 4 & Slide 9) */
    .interactive-card {
      background: #ffffff;
      border: 2px solid #cbd5e1;
      border-radius: 18px;
      padding: 1.25rem;
      cursor: pointer;
      transition: all 0.22s ease;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      gap: 0.8rem;
    }

    .interactive-card:hover {
      border-color: #0284c7;
      transform: translateY(-3px);
      box-shadow: 0 8px 20px rgba(2, 132, 199, 0.14);
    }

    .interactive-card.revealed {
      border-color: #0d9488;
      background: #f0fdf4;
    }

    .quiz-q-badge {
      background: #e0f2fe;
      color: #0369a1;
      padding: 0.2rem 0.65rem;
      border-radius: 6px;
      font-size: 0.88rem;
      font-weight: bold;
      display: inline-block;
      margin-bottom: 0.45rem;
    }

    .quiz-question {
      font-size: 1.16rem;
      font-weight: bold;
      color: #0f172a;
      line-height: 1.55;
    }

    .quiz-action-btn {
      background: #0284c7;
      color: #ffffff;
      border: none;
      padding: 0.5rem 0.9rem;
      border-radius: 8px;
      font-size: 0.95rem;
      font-weight: bold;
      cursor: pointer;
    }

    .interactive-card.revealed .quiz-action-btn {
      background: #16a34a;
    }

    .quiz-answer-content {
      display: none;
      padding-top: 0.75rem;
      border-top: 1.5px dashed #86efac;
      font-size: 1rem;
      color: #14532d;
      line-height: 1.65;
    }

    .interactive-card.revealed .quiz-answer-content {
      display: block;
    }

    .btn-soft-action {
      background: #f1f5f9;
      border: 1.5px solid #cbd5e1;
      color: #334155;
      padding: 0.45rem 1.2rem;
      border-radius: 999px;
      font-size: 0.94rem;
      font-weight: bold;
      cursor: pointer;
    }

    .btn-soft-action:hover {
      background: #e2e8f0;
      color: #0f172a;
    }

    /* PICO 互動展廳 (Slide 12) */
    .pico-tabs {
      display: grid;
      grid-template-columns: repeat(6, 1fr);
      gap: 0.5rem;
    }

    .pico-tab-btn {
      background: #f8fafc;
      border: 1.8px solid #cbd5e1;
      border-radius: 10px;
      padding: 0.6rem 0.35rem;
      font-size: 0.88rem;
      font-weight: bold;
      color: #475569;
      cursor: pointer;
      transition: all 0.2s;
    }

    .pico-tab-btn:hover {
      background: #e2e8f0;
      color: #0f172a;
    }

    .pico-tab-btn.active {
      color: #ffffff;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.16);
    }

    .pico-panel {
      flex: 1;
      background: #ffffff;
      border: 2px solid #0d9488;
      border-radius: 18px;
      padding: 1.25rem 1.4rem;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      gap: 0.9rem;
    }

    .pico-header-title {
      font-size: 1.32rem;
      font-weight: bold;
      color: #0f172a;
    }

    .pico-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 0.95rem;
      flex: 1;
    }

    .pico-cell {
      background: #f8fafc;
      border: 1.5px solid #e2e8f0;
      border-radius: 12px;
      padding: 0.9rem 1.05rem;
      display: flex;
      flex-direction: column;
      gap: 0.35rem;
    }

    .pico-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.4rem;
      font-size: 1rem;
      font-weight: bold;
    }

    .pico-letter {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 26px;
      height: 26px;
      border-radius: 6px;
      color: #ffffff;
      font-size: 0.95rem;
    }

    .pico-text {
      font-size: 1.02rem;
      color: #334155;
      line-height: 1.65;
    }

    /* 底部操作列 */
    .bottom-nav {
      width: 100%;
      max-width: 1180px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.65rem 0.6rem;
      margin-top: 0.45rem;
    }

    .nav-btn {
      background: #38bdf8;
      color: #0f172a;
      border: none;
      padding: 0.58rem 1.35rem;
      border-radius: 12px;
      font-size: 1.02rem;
      font-weight: bold;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 0.45rem;
      transition: all 0.2s;
    }

    .nav-btn:hover { background: #7dd3fc; transform: translateY(-1px); }
    .nav-btn:disabled { background: #475569; color: #94a3b8; cursor: not-allowed; transform: none; }

    .dots-indicator {
      display: flex;
      gap: 0.4rem;
      align-items: center;
      flex-wrap: wrap;
      justify-content: center;
    }

    .dot {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.28);
      cursor: pointer;
      transition: all 0.2s;
    }

    .dot.active {
      width: 26px;
      border-radius: 999px;
      background: #38bdf8;
    }

    @media (max-width: 960px) {
      .presentation-viewport { height: auto; min-height: 620px; }
      .slide { padding: 1.5rem; position: relative; display: none; }
      .slide.active { display: flex; }
      .grid-2, .grid-3, .pico-grid { grid-template-columns: 1fr; }
      .pico-tabs { grid-template-columns: repeat(3, 1fr); }
      .toc-layout { flex-direction: column !important; }
    }
  </style>
</head>
<body>

  <div class="top-toolbar">
    <div class="top-toolbar-left">
      <a href="index.html" class="btn-toolbar">🏠 返回知識庫</a>
      <button type="button" class="btn-toolbar" onclick="goToSlide(2)">📋 目錄</button>
      <span id="slideCounterText" style="color: #e2e8f0; font-weight: bold; font-size: 0.98rem;">第 1 / $totalPages 頁</span>
    </div>
    <div class="top-toolbar-right">
      <span style="color: #94a3b8; font-size: 0.88rem;">支援鍵盤 ← → 鍵翻頁</span>
      <button type="button" class="btn-toolbar" onclick="toggleFullScreen()">⛶ 全螢幕簡報</button>
    </div>
  </div>

  <div class="progress-bar-container">
    <div class="progress-bar-fill" id="progressBarFill"></div>
  </div>

  <main class="presentation-viewport">
$allSlidesHtml
  </main>

  <footer class="bottom-nav">
    <button type="button" class="nav-btn" id="prevBtn" onclick="prevSlide()">&larr; 上一頁</button>
    <div class="dots-indicator" id="dotsContainer"></div>
    <button type="button" class="nav-btn" id="nextBtn" onclick="nextSlide()">下一頁 &rarr;</button>
  </footer>

  <script>
    const totalSlides = $totalPages;
    let currentSlide = 1;
    const picoPapers = $picoJson;

    const dotsContainer = document.getElementById('dotsContainer');
    for (let i = 1; i <= totalSlides; i++) {
      const dot = document.createElement('div');
      dot.className = 'dot' + (i === 1 ? ' active' : '');
      dot.title = '前往第 ' + i + ' 頁';
      dot.onclick = () => goToSlide(i);
      dotsContainer.appendChild(dot);
    }

    function goToSlide(n) {
      if (n < 1 || n > totalSlides) return;
      currentSlide = n;
      document.querySelectorAll('.slide').forEach(el => {
        el.classList.toggle('active', parseInt(el.getAttribute('data-index')) === currentSlide);
      });
      document.getElementById('progressBarFill').style.width = ((currentSlide / totalSlides) * 100) + '%';
      document.getElementById('slideCounterText').textContent = '第 ' + currentSlide + ' / ' + totalSlides + ' 頁';
      document.getElementById('prevBtn').disabled = (currentSlide === 1);
      document.getElementById('nextBtn').disabled = (currentSlide === totalSlides);
      document.querySelectorAll('.dot').forEach((d, i) => d.classList.toggle('active', i + 1 === currentSlide));
    }

    function nextSlide() { if (currentSlide < totalSlides) goToSlide(currentSlide + 1); }
    function prevSlide() { if (currentSlide > 1) goToSlide(currentSlide - 1); }

    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' || e.key === 'PageDown' || e.key === ' ') {
        if (document.activeElement.tagName !== 'BUTTON') { e.preventDefault(); nextSlide(); }
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        prevSlide();
      } else if (e.key === 'Home') { goToSlide(1); }
      else if (e.key === 'End') { goToSlide(totalSlides); }
    });

    function toggleFullScreen() {
      if (!document.fullscreenElement) {
        if (document.documentElement.requestFullscreen) document.documentElement.requestFullscreen();
      } else {
        if (document.exitFullscreen) document.exitFullscreen();
      }
    }

    function toggleMythCard(id) {
      const el = document.getElementById(id);
      if (el) el.classList.toggle('revealed');
    }

    function toggleMatchCard(id) {
      const el = document.getElementById(id);
      if (el) el.classList.toggle('revealed');
    }

    function toggleAllCards(prefix) {
      const cards = Array.from(document.querySelectorAll('[id^="' + prefix + '"]'));
      const allOpen = cards.every(c => c.classList.contains('revealed'));
      cards.forEach(c => c.classList.toggle('revealed', !allOpen));
    }

    function switchPicoTab(index) {
      const paper = picoPapers[index];
      if (!paper) return;

      document.querySelectorAll('.pico-tab-btn').forEach((btn, idx) => {
        const isActive = (idx === index);
        btn.classList.toggle('active', isActive);
        if (isActive) {
          btn.style.background = paper.color;
          btn.style.borderColor = paper.color;
        } else {
          btn.style.background = '#f8fafc';
          btn.style.borderColor = '#cbd5e1';
        }
      });

      const panel = document.getElementById('picoDisplayPanel');
      panel.style.borderColor = paper.color;
      panel.innerHTML =
        '<div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.5rem;">' +
          '<div class="pico-header-title" style="color:' + paper.color + ';">' + paper.title + '</div>' +
          '<a href="index.html" target="_blank" style="font-size:0.92rem; color:' + paper.color + '; font-weight:bold; text-decoration:underline;">前往 Wiki 查閱全文 ↗</a>' +
        '</div>' +
        '<div class="pico-grid">' +
          '<div class="pico-cell"><div class="pico-badge"><span class="pico-letter" style="background:#0d9488;">P</span>研究對象 (Population)</div><div class="pico-text">' + paper.P + '</div></div>' +
          '<div class="pico-cell"><div class="pico-badge"><span class="pico-letter" style="background:#2563eb;">I</span>介入方式 (Intervention)</div><div class="pico-text">' + paper.I + '</div></div>' +
          '<div class="pico-cell"><div class="pico-badge"><span class="pico-letter" style="background:#d97706;">C</span>對照組 (Comparison)</div><div class="pico-text">' + paper.C + '</div></div>' +
          '<div class="pico-cell"><div class="pico-badge"><span class="pico-letter" style="background:#e11d48;">O</span>主要結果 (Outcome)</div><div class="pico-text">' + paper.O + '</div></div>' +
        '</div>';
    }

    switchPicoTab(0);
    goToSlide(1);
  </script>
</body>
</html>
"@

[System.IO.File]::WriteAllText("slides.html", $html, [System.Text.Encoding]::UTF8)
Write-Host "[Node 5] Compiled interactive 15-page Web Slide Deck -> slides.html"
