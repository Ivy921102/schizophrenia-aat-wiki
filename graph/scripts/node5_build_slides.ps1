# graph/scripts/node5_build_slides.ps1
# Node 5 (v2): Warm Storybook Healing Theme + Giant Typography (Title >= 50px, Body >= 30px) + Lively Large Animals + Author(Year) PICO
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
            [void]$slidesMarkup.AppendLine("        <div class=`"animal-medallion`"><img src=`"$a`" width=`"126`" height=`"126`" alt=`"治療動物`" /></div>")
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
        [void]$slidesMarkup.AppendLine("          <h2 class=`"slide-title`" style=`"font-size: 56px;`">$(Esc $s.title)</h2>")
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <div class=`"header-animal-badge`"><img src=`"assets/cute-paw.svg`" class=`"slide-header-animal`" alt=`"爪印`" /></div>")
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
        [void]$slidesMarkup.AppendLine("          <div class=`"toc-animal-frame`"><img src=`"assets/cute-dog-study.svg`" width=`"240`" height=`"240`" alt=`"研究小犬`" /></div>")
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
        [void]$slidesMarkup.AppendLine("        <div class=`"header-animal-badge`"><img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"動物插圖`" /></div>")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-body`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"$gridCls`" style=`"flex: 1; align-content: center;`">")
        foreach ($c in $s.cards) {
            $accentStyle = if ($c.accent) { " style=`"border-top: 7px solid $($c.accent);`"" } else { "" }
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
        [void]$slidesMarkup.AppendLine("        <div class=`"header-animal-badge`"><img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"陪伴貓`" /></div>")
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
            [void]$slidesMarkup.AppendLine("              <div style=`"font-weight: bold; color: #2F6F5E; margin-bottom: 0.3rem;`">✅ $(Esc $it.verdict)</div>")
            [void]$slidesMarkup.AppendLine("              <div>$(Esc $it.explanation)</div>")
            [void]$slidesMarkup.AppendLine("            </div>")
            [void]$slidesMarkup.AppendLine("          </div>")
        }
        [void]$slidesMarkup.AppendLine("        </div>")
        [void]$slidesMarkup.AppendLine("        <div style=`"text-align: center; margin-top: 0.5rem;`">")
        [void]$slidesMarkup.AppendLine("          <button type=`"button`" class=`"btn-soft-action`" onclick=`"toggleAllCards('myth')`">一次展開／收合全部解答</button>")
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
        [void]$slidesMarkup.AppendLine("        <div class=`"header-animal-badge`"><img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"長耳兔`" /></div>")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-body`" style=`"justify-content: center;`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"grid-2`">")
        foreach ($it in $s.items) {
            [void]$slidesMarkup.AppendLine("          <div class=`"interactive-card`" id=`"$($it.id)`" onclick=`"toggleMatchCard('$($it.id)')`">")
            [void]$slidesMarkup.AppendLine("            <div style=`"display: flex; justify-content: space-between; align-items: center; gap: 0.8rem;`">")
            [void]$slidesMarkup.AppendLine("              <div>")
            [void]$slidesMarkup.AppendLine("                <span class=`"quiz-q-badge`">$(Esc $it.badge)</span>")
            [void]$slidesMarkup.AppendLine("                <div class=`"quiz-question`">$(Esc $it.scenario)</div>")
            [void]$slidesMarkup.AppendLine("              </div>")
            [void]$slidesMarkup.AppendLine("              <button class=`"quiz-action-btn`" style=`"flex-shrink: 0;`" type=`"button`">看配對 💡</button>")
            [void]$slidesMarkup.AppendLine("            </div>")
            [void]$slidesMarkup.AppendLine("            <div class=`"quiz-answer-content`">")
            [void]$slidesMarkup.AppendLine("              <div><strong>🧬 機轉</strong>：$(Esc $it.mechanism)</div>")
            [void]$slidesMarkup.AppendLine("              <div style=`"margin-top: 0.25rem;`"><strong>🏠 生活</strong>：$(Esc $it.daily_life)</div>")
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
        [void]$slidesMarkup.AppendLine("        <div class=`"header-animal-badge`"><img src=`"$($s.header_asset)`" class=`"slide-header-animal`" alt=`"研究博士犬`" /></div>")
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <div class=`"slide-body`">")
        [void]$slidesMarkup.AppendLine("        <div class=`"pico-tabs`">")
        for ($pi = 0; $pi -lt $s.papers.Count; $pi++) {
            $paper = $s.papers[$pi]
            $act = if ($pi -eq 0) { " active" } else { "" }
            [void]$slidesMarkup.AppendLine("          <button type=`"button`" class=`"pico-tab-btn$act`" data-color=`"$($paper.color)`" onclick=`"switchPicoTab($pi)`">$(Esc $paper.tab_label)</button>")
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
            [void]$slidesMarkup.AppendLine("        <div class=`"animal-medallion`"><img src=`"$a`" width=`"108`" height=`"108`" alt=`"治療動物`" /></div>")
        }
        [void]$slidesMarkup.AppendLine("      </div>")
        [void]$slidesMarkup.AppendLine("      <h2 class=`"slide-title`" style=`"color: #2F6F5E;`">$(Esc $s.title)</h2>")
        [void]$slidesMarkup.AppendLine("      <div class=`"ending-quote`">$(Esc $s.quote)</div>")
        [void]$slidesMarkup.AppendLine("      <p class=`"ending-vision`">$(Esc $s.vision)</p>")
        [void]$slidesMarkup.AppendLine("      <div style=`"display: flex; gap: 1.2rem; justify-content: center; flex-wrap: wrap; margin-top: 0.4rem;`">")
        [void]$slidesMarkup.AppendLine("        <button type=`"button`" class=`"nav-btn`" onclick=`"goToSlide(1)`">🔄 重新播放簡報</button>")
        [void]$slidesMarkup.AppendLine("        <a href=`"index.html`" class=`"nav-btn`" style=`"background: #2F6F5E; color: #ffffff; text-decoration: none;`">📖 返回知識庫查看完整論文</a>")
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
    /* 英數採用 Times New Roman，中文回退至標楷體 */
    *, *::before, *::after, html, body, h1, h2, h3, h4, p, span, div, a, button, li {
      font-family: "Times New Roman", "標楷體", "BiauKai", "DFKai-SB", "TW-Kai", "KaiTi", serif !important;
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    :root {
      --oat-canvas: #FAF7F2;
      --cream-card: #FFFDF9;
      --sage-dark: #2F6F5E;
      --sage-mid: #4B8B77;
      --sage-soft: #E3F1EC;
      --apricot: #D97706;
      --apricot-soft: #FEF3C7;
      --apricot-border: #F59E0B;
      --ink-main: #2C241E;
      --ink-body: #3E352F;
      --ink-muted: #786B61;
      --warm-border: #E6DDD0;
    }

    body {
      background: linear-gradient(155deg, #EAE0D2 0%, #DFD2C0 100%);
      color: var(--ink-main);
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      padding: 0.75rem 1rem 1rem 1rem;
      overflow-x: hidden;
    }

    /* 頂部控制列 */
    .top-toolbar {
      width: 100%;
      max-width: 1500px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.35rem 0.5rem;
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
      background: rgba(255, 253, 249, 0.9);
      border: 1.5px solid #D5C8B7;
      color: #3E352F;
      padding: 0.4rem 0.95rem;
      border-radius: 999px;
      font-size: 20px;
      font-weight: bold;
      cursor: pointer;
      text-decoration: none;
      display: inline-flex;
      align-items: center;
      gap: 0.35rem;
      transition: all 0.2s;
      box-shadow: 0 2px 6px rgba(62, 53, 47, 0.08);
    }

    .btn-toolbar:hover {
      background: var(--sage-dark);
      border-color: var(--sage-dark);
      color: #ffffff;
    }

    .progress-bar-container {
      width: 100%;
      max-width: 1500px;
      height: 8px;
      background: rgba(120, 107, 97, 0.22);
      border-radius: 999px;
      overflow: hidden;
      margin-bottom: 0.7rem;
    }

    .progress-bar-fill {
      height: 100%;
      width: 6.67%;
      background: linear-gradient(90deg, #4B8B77 0%, #E08E45 100%);
      transition: width 0.3s ease;
    }

    /* 暖陽療癒繪本風主畫布 (大字級專屬寬敞比例) */
    .presentation-viewport {
      width: 100%;
      max-width: 1500px;
      min-height: 780px;
      background: var(--oat-canvas);
      background-image:
        radial-gradient(circle at 92% 10%, rgba(254, 243, 199, 0.75) 0%, transparent 32%),
        radial-gradient(circle at 6% 92%, rgba(227, 241, 236, 0.8) 0%, transparent 34%);
      border: 3px solid #E5DCCB;
      border-radius: 30px;
      box-shadow: 0 22px 48px rgba(74, 58, 43, 0.16);
      position: relative;
      overflow: hidden;
    }

    .slide {
      display: none;
      width: 100%;
      min-height: 780px;
      padding: 2.2rem 3rem 2rem 3rem;
      flex-direction: column;
      animation: fadeSlideIn 0.3s ease;
    }

    .slide.active {
      display: flex;
    }

    @keyframes fadeSlideIn {
      from { opacity: 0; transform: translateY(10px); }
      to   { opacity: 1; transform: translateY(0); }
    }

    /* 頁首：標題 >= 50px + 顯眼大萌寵徽章 */
    .slide-header {
      border-bottom: 2.5px dashed #DFD4C4;
      padding-bottom: 0.85rem;
      margin-bottom: 1.35rem;
      display: flex;
      justify-content: space-between;
      align-items: center;
      gap: 1.2rem;
    }

    .slide-title-wrap {
      display: flex;
      flex-direction: column;
      gap: 0.35rem;
    }

    .slide-unit-badge {
      font-size: 22px;
      font-weight: bold;
      color: var(--sage-dark);
      background: var(--sage-soft);
      border: 1.5px solid #B7DDD0;
      padding: 0.2rem 0.85rem;
      border-radius: 999px;
      width: fit-content;
    }

    .badge-interactive {
      color: #9A3412;
      background: #FFEDD5;
      border-color: #FDBA74;
    }

    /* 一般頁標題強制 >= 50px */
    .slide-title {
      font-size: 52px;
      color: var(--ink-main);
      font-weight: bold;
      line-height: 1.25;
      letter-spacing: 0.5px;
    }

    .slide-subtitle {
      font-size: 26px;
      color: var(--ink-muted);
      line-height: 1.4;
    }

    .header-animal-badge {
      background: #FFFDF9;
      border: 3px solid #F3DFC1;
      border-radius: 50%;
      padding: 10px;
      box-shadow: 0 6px 16px rgba(180, 83, 9, 0.12);
      flex-shrink: 0;
    }

    .slide-header-animal {
      width: 104px;
      height: 104px;
      display: block;
    }

    .slide-body {
      flex: 1;
      display: flex;
      flex-direction: column;
      gap: 1.25rem;
    }

    /* 封面 & 結語 */
    .cover-slide {
      justify-content: center;
      align-items: center;
      text-align: center;
      gap: 2rem;
    }

    .cover-animals-row {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 1.6rem;
      flex-wrap: wrap;
    }

    .animal-medallion {
      background: #FFFDF9;
      border: 3.5px solid #F3DFC1;
      border-radius: 50%;
      padding: 14px;
      box-shadow: 0 10px 22px rgba(146, 64, 14, 0.12);
      transition: transform 0.25s ease;
    }

    .animal-medallion:hover {
      transform: translateY(-6px) rotate(-3deg);
    }

    .cover-title {
      font-size: 62px;
      color: var(--ink-main);
      font-weight: bold;
      line-height: 1.38;
      max-width: 1180px;
    }

    .cover-footer-note {
      font-size: 30px;
      color: var(--sage-dark);
      background: var(--sage-soft);
      border: 2px solid #A7D7C5;
      padding: 0.65rem 2rem;
      border-radius: 999px;
      font-weight: bold;
    }

    .ending-quote {
      font-size: 36px;
      font-weight: bold;
      color: #5C2D0C;
      max-width: 1150px;
      line-height: 1.6;
      background: var(--apricot-soft);
      border-left: 8px solid var(--apricot-border);
      padding: 1.2rem 1.8rem;
      border-radius: 0 20px 20px 0;
    }

    .ending-vision {
      font-size: 31px;
      color: var(--ink-body);
      max-width: 1080px;
      line-height: 1.6;
    }

    /* 極簡目錄頁 */
    .toc-layout {
      flex-direction: row !important;
      align-items: center;
      gap: 2.5rem;
    }

    .toc-list {
      flex: 1.5;
      display: flex;
      flex-direction: column;
      gap: 1rem;
    }

    .toc-item {
      background: var(--cream-card);
      border: 2.5px solid var(--warm-border);
      border-radius: 18px;
      padding: 1.05rem 1.6rem;
      font-size: 34px;
      font-weight: bold;
      color: var(--ink-main);
      display: flex;
      justify-content: space-between;
      align-items: center;
      cursor: pointer;
      transition: all 0.22s;
      text-align: left;
      box-shadow: 0 4px 12px rgba(62, 53, 47, 0.05);
    }

    .toc-item:hover {
      background: var(--sage-soft);
      border-color: var(--sage-dark);
      color: var(--sage-dark);
      transform: translateX(8px);
    }

    .toc-arrow {
      font-size: 26px;
      color: var(--apricot);
    }

    .toc-visual {
      flex: 0.7;
      display: flex;
      justify-content: center;
      align-items: center;
    }

    .toc-animal-frame {
      background: #FFFDF9;
      border: 4px solid #F3DFC1;
      border-radius: 50%;
      padding: 26px;
      box-shadow: 0 12px 28px rgba(146, 64, 14, 0.14);
    }

    /* 網格與內容卡片 (一般內文 >= 30px) */
    .grid-2 {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1.4rem;
    }

    .grid-3 {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 1.25rem;
    }

    .content-box {
      background: var(--cream-card);
      border: 2px solid var(--warm-border);
      border-radius: 22px;
      padding: 1.45rem 1.6rem;
      display: flex;
      flex-direction: column;
      gap: 0.75rem;
      box-shadow: 0 6px 18px rgba(74, 58, 43, 0.06);
    }

    .box-title {
      font-size: 34px;
      font-weight: bold;
      color: var(--sage-dark);
      line-height: 1.3;
    }

    .box-tag {
      font-size: 22px;
      color: var(--ink-muted);
      font-weight: bold;
    }

    /* 一般頁正文 >= 30px */
    .box-list {
      list-style: none;
      display: flex;
      flex-direction: column;
      gap: 0.65rem;
      font-size: 31px;
      color: var(--ink-body);
      line-height: 1.55;
    }

    .box-list li::before {
      content: "• ";
      color: var(--apricot);
      font-weight: bold;
    }

    .public-quote-box {
      background: var(--apricot-soft);
      border-left: 7px solid var(--apricot-border);
      border-radius: 0 16px 16px 0;
      padding: 1rem 1.4rem;
      color: #6B3409;
      font-size: 30px;
      line-height: 1.5;
    }

    /* 文獻頁（第 10、11 頁）：免受 30px 強制下限，但依然盡量放大字體 */
    .lit-dense .slide-title { font-size: 50px; }
    .lit-dense .slide-subtitle { font-size: 24px; }
    .lit-dense .content-box { padding: 1.15rem 1.25rem; gap: 0.5rem; }
    .lit-dense .box-title { font-size: 29px; }
    .lit-dense .box-tag { font-size: 19px; }
    .lit-dense .box-list { font-size: 23px; line-height: 1.55; gap: 0.45rem; }
    .lit-dense .public-quote-box { font-size: 25px; padding: 0.85rem 1.25rem; }

    /* 互動翻牌與配對卡 (Slide 4 & Slide 9 — 大字 >= 30px) */
    .interactive-card {
      background: var(--cream-card);
      border: 2.5px solid #DCCEB9;
      border-radius: 22px;
      padding: 1.4rem 1.5rem;
      cursor: pointer;
      transition: all 0.22s ease;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      gap: 0.9rem;
      box-shadow: 0 6px 16px rgba(74, 58, 43, 0.06);
    }

    .interactive-card:hover {
      border-color: var(--apricot);
      transform: translateY(-4px);
      box-shadow: 0 10px 22px rgba(217, 119, 6, 0.16);
    }

    .interactive-card.revealed {
      border-color: var(--sage-dark);
      background: #F1F8F5;
    }

    .quiz-q-badge {
      background: #FFEDD5;
      color: #9A3412;
      padding: 0.2rem 0.75rem;
      border-radius: 999px;
      font-size: 22px;
      font-weight: bold;
      display: inline-block;
      margin-bottom: 0.5rem;
    }

    .quiz-question {
      font-size: 32px;
      font-weight: bold;
      color: var(--ink-main);
      line-height: 1.45;
    }

    .quiz-action-btn {
      background: var(--apricot);
      color: #ffffff;
      border: none;
      padding: 0.55rem 1.15rem;
      border-radius: 12px;
      font-size: 26px;
      font-weight: bold;
      cursor: pointer;
    }

    .interactive-card.revealed .quiz-action-btn {
      background: var(--sage-dark);
    }

    .quiz-answer-content {
      display: none;
      padding-top: 0.8rem;
      border-top: 2px dashed #99C9B8;
      font-size: 30px;
      color: #1F4E42;
      line-height: 1.5;
    }

    .interactive-card.revealed .quiz-answer-content {
      display: block;
    }

    .btn-soft-action {
      background: #EFE7DA;
      border: 2px solid #D6C7B2;
      color: #4A3E35;
      padding: 0.5rem 1.5rem;
      border-radius: 999px;
      font-size: 24px;
      font-weight: bold;
      cursor: pointer;
    }

    .btn-soft-action:hover {
      background: #E2D5C1;
      color: var(--ink-main);
    }

    /* PICO 互動展廳 (Slide 12：3x2 寬敞作者(年份)按鈕 ＋ 放大 PICO 四格) */
    .pico-tabs {
      display: grid;
      grid-template-columns: repeat(3, 1fr);
      gap: 0.7rem;
    }

    .pico-tab-btn {
      background: var(--cream-card);
      border: 2px solid #D8CBB8;
      border-radius: 14px;
      padding: 0.65rem 0.8rem;
      font-size: 24px;
      font-weight: bold;
      color: var(--ink-body);
      cursor: pointer;
      transition: all 0.2s;
    }

    .pico-tab-btn:hover {
      background: #F4EDE2;
      color: var(--ink-main);
    }

    .pico-tab-btn.active {
      color: #ffffff;
      box-shadow: 0 5px 14px rgba(44, 36, 30, 0.18);
    }

    .pico-panel {
      flex: 1;
      background: var(--cream-card);
      border: 3px solid var(--sage-dark);
      border-radius: 22px;
      padding: 1.35rem 1.6rem;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
      gap: 1rem;
    }

    .pico-header-title {
      font-size: 32px;
      font-weight: bold;
    }

    .pico-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 1rem;
      flex: 1;
    }

    .pico-cell {
      background: #FAF6EE;
      border: 2px solid #E6DDD0;
      border-radius: 16px;
      padding: 1rem 1.2rem;
      display: flex;
      flex-direction: column;
      gap: 0.45rem;
    }

    .pico-badge {
      display: inline-flex;
      align-items: center;
      gap: 0.5rem;
      font-size: 26px;
      font-weight: bold;
      color: var(--ink-main);
    }

    .pico-letter {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      width: 36px;
      height: 36px;
      border-radius: 10px;
      color: #ffffff;
      font-size: 24px;
    }

    .pico-text {
      font-size: 27px;
      color: var(--ink-body);
      line-height: 1.5;
    }

    /* 底部導覽列 */
    .bottom-nav {
      width: 100%;
      max-width: 1500px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 0.65rem 0.5rem;
      margin-top: 0.4rem;
    }

    .nav-btn {
      background: var(--sage-dark);
      color: #ffffff;
      border: none;
      padding: 0.6rem 1.6rem;
      border-radius: 999px;
      font-size: 24px;
      font-weight: bold;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 0.45rem;
      transition: all 0.2s;
      box-shadow: 0 5px 14px rgba(47, 111, 94, 0.25);
    }

    .nav-btn:hover { background: #235749; transform: translateY(-2px); }
    .nav-btn:disabled { background: #BEB3A4; color: #F5EFE6; cursor: not-allowed; transform: none; box-shadow: none; }

    .dots-indicator {
      display: flex;
      gap: 0.45rem;
      align-items: center;
      flex-wrap: wrap;
      justify-content: center;
    }

    .dot {
      width: 12px;
      height: 12px;
      border-radius: 50%;
      background: rgba(120, 107, 97, 0.35);
      cursor: pointer;
      transition: all 0.2s;
    }

    .dot.active {
      width: 30px;
      border-radius: 999px;
      background: var(--apricot);
    }

    @media (max-width: 1100px) {
      .slide { padding: 1.6rem; }
      .cover-title { font-size: 46px; }
      .slide-title { font-size: 38px; }
      .grid-2, .grid-3, .pico-grid, .pico-tabs { grid-template-columns: 1fr; }
      .toc-layout { flex-direction: column !important; }
    }
  </style>
</head>
<body>

  <div class="top-toolbar">
    <div class="top-toolbar-left">
      <a href="index.html" class="btn-toolbar">🏠 返回知識庫</a>
      <button type="button" class="btn-toolbar" onclick="goToSlide(2)">📋 目錄</button>
      <span id="slideCounterText" style="color: #3E352F; font-weight: bold; font-size: 22px;">第 1 / $totalPages 頁</span>
    </div>
    <div class="top-toolbar-right">
      <span style="color: #6B5E53; font-size: 19px;">支援鍵盤 ← → 鍵翻頁</span>
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

    function clearFocus() {
      if (document.activeElement && typeof document.activeElement.blur === 'function') {
        document.activeElement.blur();
      }
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
      clearFocus();
      window.scrollTo({ top: 0, behavior: 'smooth' });
    }

    function nextSlide() { if (currentSlide < totalSlides) goToSlide(currentSlide + 1); }
    function prevSlide() { if (currentSlide > 1) goToSlide(currentSlide - 1); }

    /* 全螢幕與任何點擊後，左右方向鍵與 PageUp/PageDown 永遠有效 */
    document.addEventListener('keydown', (e) => {
      if (e.key === 'ArrowRight' || e.key === 'PageDown') {
        e.preventDefault();
        nextSlide();
      } else if (e.key === 'ArrowLeft' || e.key === 'PageUp') {
        e.preventDefault();
        prevSlide();
      } else if (e.key === ' ') {
        if (!document.activeElement || document.activeElement.tagName !== 'BUTTON') {
          e.preventDefault();
          nextSlide();
        }
      } else if (e.key === 'Home') {
        e.preventDefault();
        goToSlide(1);
      } else if (e.key === 'End') {
        e.preventDefault();
        goToSlide(totalSlides);
      }
    });

    function toggleFullScreen() {
      clearFocus();
      if (!document.fullscreenElement) {
        const el = document.documentElement;
        if (el.requestFullscreen) {
          el.requestFullscreen().then(clearFocus).catch(() => {});
        }
      } else {
        if (document.exitFullscreen) {
          document.exitFullscreen().then(clearFocus).catch(() => {});
        }
      }
    }

    document.addEventListener('fullscreenchange', clearFocus);

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
          btn.style.background = '#FFFDF9';
          btn.style.borderColor = '#D8CBB8';
        }
      });

      const panel = document.getElementById('picoDisplayPanel');
      panel.style.borderColor = paper.color;
      panel.innerHTML =
        '<div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:0.5rem;">' +
          '<div class="pico-header-title" style="color:' + paper.color + ';">' + paper.title + '</div>' +
          '<a href="index.html" target="_blank" style="font-size:22px; color:' + paper.color + '; font-weight:bold; text-decoration:underline;">前往 Wiki 查閱全文 ↗</a>' +
        '</div>' +
        '<div class="pico-grid">' +
          '<div class="pico-cell"><div class="pico-badge"><span class="pico-letter" style="background:#2F6F5E;">P</span>研究對象 (Population)</div><div class="pico-text">' + paper.P + '</div></div>' +
          '<div class="pico-cell"><div class="pico-badge"><span class="pico-letter" style="background:#3B7A9E;">I</span>介入方式 (Intervention)</div><div class="pico-text">' + paper.I + '</div></div>' +
          '<div class="pico-cell"><div class="pico-badge"><span class="pico-letter" style="background:#D97706;">C</span>對照組 (Comparison)</div><div class="pico-text">' + paper.C + '</div></div>' +
          '<div class="pico-cell"><div class="pico-badge"><span class="pico-letter" style="background:#C95B6B;">O</span>主要結果 (Outcome)</div><div class="pico-text">' + paper.O + '</div></div>' +
        '</div>';
    }

    switchPicoTab(0);
    goToSlide(1);
  </script>
</body>
</html>
"@

[System.IO.File]::WriteAllText("slides.html", $html, [System.Text.Encoding]::UTF8)
Write-Host "[Node 5 v2] Compiled Warm Storybook Giant-Font 15-page Web Slide Deck -> slides.html"
