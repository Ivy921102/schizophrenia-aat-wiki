# graph/scripts/render_graph_png.ps1
# Renders a crisp, high-resolution, single continuous tall vertical dark-mode State Graph PNG
# Output: graph/slide_generation_graph.png

Add-Type -AssemblyName System.Drawing

$W = 1040
$H = 2660
$bmp = New-Object System.Drawing.Bitmap($W, $H)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

function HexColor([string]$hex, [int]$alpha = 255) {
    $c = [System.Drawing.ColorTranslator]::FromHtml($hex)
    return [System.Drawing.Color]::FromArgb($alpha, $c.R, $c.G, $c.B)
}

function Get-RoundedRectPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $r * 2
    $path.AddArc($x, $y, $d, $d, 180, 90)
    $path.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
    $path.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
    $path.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    return $path
}

function Draw-RoundRect([float]$x, [float]$y, [float]$w, [float]$h, [float]$r, [string]$fillHex, [string]$strokeHex, [float]$strokeW = 1.5, [int]$fillAlpha = 255) {
    $path = Get-RoundedRectPath $x $y $w $h $r
    $brush = New-Object System.Drawing.SolidBrush((HexColor $fillHex $fillAlpha))
    $g.FillPath($brush, $path)
    $brush.Dispose()
    if ($strokeHex) {
        $pen = New-Object System.Drawing.Pen((HexColor $strokeHex), $strokeW)
        $g.DrawPath($pen, $path)
        $pen.Dispose()
    }
    $path.Dispose()
}

function Draw-CenteredText([string]$text, [float]$cx, [float]$cy, [float]$size, [string]$colorHex, [bool]$bold = $false) {
    $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $font = New-Object System.Drawing.Font("Microsoft JhengHei", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush((HexColor $colorHex))
    $sf = New-Object System.Drawing.StringFormat
    $sf.Alignment = [System.Drawing.StringAlignment]::Center
    $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
    $g.DrawString($text, $font, $brush, $cx, $cy, $sf)
    $font.Dispose()
    $brush.Dispose()
    $sf.Dispose()
}

function Draw-LeftText([string]$text, [float]$x, [float]$y, [float]$size, [string]$colorHex, [bool]$bold = $false) {
    $style = if ($bold) { [System.Drawing.FontStyle]::Bold } else { [System.Drawing.FontStyle]::Regular }
    $font = New-Object System.Drawing.Font("Microsoft JhengHei", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
    $brush = New-Object System.Drawing.SolidBrush((HexColor $colorHex))
    $g.DrawString($text, $font, $brush, $x, $y)
    $font.Dispose()
    $brush.Dispose()
}

function Draw-Diamond([float]$cx, [float]$cy, [float]$rx, [float]$ry, [string]$fillHex, [string]$strokeHex, [float]$strokeW = 2.0) {
    $pts = @(
        (New-Object System.Drawing.PointF($cx, ($cy - $ry))),
        (New-Object System.Drawing.PointF(($cx + $rx), $cy)),
        (New-Object System.Drawing.PointF($cx, ($cy + $ry))),
        (New-Object System.Drawing.PointF(($cx - $rx), $cy))
    )
    $brush = New-Object System.Drawing.SolidBrush((HexColor $fillHex))
    $g.FillPolygon($brush, $pts)
    $brush.Dispose()
    $pen = New-Object System.Drawing.Pen((HexColor $strokeHex), $strokeW)
    $g.DrawPolygon($pen, $pts)
    $pen.Dispose()
}

function Draw-ArrowPath([float[][]]$points, [string]$colorHex = "#94a3b8", [float]$width = 2.0, [bool]$dashed = $false) {
    $pen = New-Object System.Drawing.Pen((HexColor $colorHex), $width)
    if ($dashed) {
        $pen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
    }
    $cap = New-Object System.Drawing.Drawing2D.AdjustableArrowCap(5, 6, $true)
    $pen.CustomEndCap = $cap
    $pts = New-Object System.Collections.Generic.List[System.Drawing.PointF]
    foreach ($p in $points) {
        $pts.Add((New-Object System.Drawing.PointF($p[0], $p[1])))
    }
    $g.DrawLines($pen, $pts.ToArray())
    $cap.Dispose()
    $pen.Dispose()
}

function Draw-EdgeBadge([string]$text, [float]$cx, [float]$cy, [float]$w, [string]$bgHex = "#18181b", [string]$borderHex = "#52525b", [string]$textHex = "#e2e8f0") {
    Draw-RoundRect ($cx - $w / 2) ($cy - 14) $w 28 6 $bgHex $borderHex 1.2
    Draw-CenteredText $text $cx $cy 13 $textHex $true
}

# Canvas Background (#18181b)
$g.Clear((HexColor "#18181b"))

$CX = 520

# Top Header
Draw-CenteredText "動物輔助治療 × 思覺失調症簡報生成 State Graph" $CX 44 27 "#f8fafc" $true
Draw-CenteredText "Shift-Left 品質左移工作流｜程式檢核 ＋ AI 審查 ＋ 人類介入 (HITL)｜精準錯誤退回" $CX 78 14.5 "#94a3b8" $false
$sepPen = New-Object System.Drawing.Pen((HexColor "#27272a"), 1.5)
$g.DrawLine($sepPen, 70, 102, 970, 102)
$sepPen.Dispose()

# ==================== STAGE 1 ====================
Draw-RoundRect 75 120 890 462 14 "#1f1f23" "#3f3f46" 1.4 220
Draw-RoundRect 75 120 890 36 10 "#27272a" "#3f3f46" 1.0 255
Draw-LeftText "第一階段：知識庫萃取與規格確立" 96 128 15 "#e2e8f0" $true

# Node 0 & Node 1
Draw-RoundRect 125 176 345 68 8 "#27272a" "#52525b" 1.4
Draw-CenteredText "Node 0：需求、美術風格與字級規格化" 297 198 15.5 "#f8fafc" $true
Draw-CenteredText "輸出：00_requirements.json（暖陽繪本風）" 297 223 12.5 "#a1a1aa" $false

Draw-RoundRect 580 176 320 68 8 "#27272a" "#52525b" 1.4
Draw-CenteredText "Node 1：Wiki 原始知識源" 740 198 16 "#f8fafc" $true
Draw-CenteredText "wiki/*.md（6 篇文獻＋症狀＋機轉）" 740 223 13 "#a1a1aa" $false

Draw-ArrowPath @(@(300,244), @(300,268), @(460,268), @(460,290)) "#94a3b8" 1.8
Draw-ArrowPath @(@(740,244), @(740,268), @(580,268), @(580,290)) "#94a3b8" 1.8

# Node 2
Draw-RoundRect 295 292 450 68 8 "#27272a" "#52525b" 1.4
Draw-CenteredText "Node 2：Wiki 知識萃取 (node1_extract.ps1)" $CX 315 16 "#f8fafc" $true
Draw-CenteredText "輸出：01_wiki_knowledge.json" $CX 340 13 "#a1a1aa" $false

Draw-ArrowPath @(@($CX,360), @($CX,390)) "#94a3b8" 1.8

# Gate 1 (Dark Slate Diamond)
Draw-Diamond $CX 474 195 82 "#27272a" "#71717a" 2.0
Draw-CenteredText "Gate 1：Wiki 程式檢驗" $CX 452 15.5 "#f8fafc" $true
Draw-CenteredText "JSON 合法？6 篇文獻與 3 機轉齊全？" $CX 476 13 "#d4d4d8" $false
Draw-CenteredText "輸出：01_check_report.json" $CX 498 12.5 "#a1a1aa" $false

# G1 Fail -> N2
Draw-ArrowPath @(@(325,474), @(150,474), @(150,326), @(293,326)) "#94a3b8" 1.8
Draw-EdgeBadge "未通過：重抽" 150 400 108 "#18181b" "#52525b" "#e2e8f0"

# G1 Pass -> Stage 2 N3
Draw-ArrowPath @(@($CX,556), @($CX,664)) "#34d399" 2.2
Draw-EdgeBadge "通過" $CX 600 64 "#064e3b" "#10b981" "#ecfdf5"

# ==================== STAGE 2 ====================
Draw-RoundRect 75 622 890 618 14 "#1f1f23" "#3f3f46" 1.4 220
Draw-RoundRect 75 622 890 36 10 "#27272a" "#3f3f46" 1.0 255
Draw-LeftText "第二階段：大綱規劃與人類確認 (Shift-Left 核心)" 96 630 15 "#e2e8f0" $true

# Node 3
Draw-RoundRect 265 666 510 70 8 "#27272a" "#52525b" 1.4
Draw-CenteredText "Node 3：15 頁大綱與 3 互動頁規劃 (含目錄)" $CX 689 16 "#f8fafc" $true
Draw-CenteredText "輸入：00 + 01 → 輸出：02_outline.md" $CX 714 13 "#a1a1aa" $false

Draw-ArrowPath @(@($CX,736), @($CX,768)) "#94a3b8" 1.8

# Gate 2 (Mint Green Diamond)
Draw-Diamond $CX 866 225 96 "#a7f3d0" "#10b981" 2.2
Draw-CenteredText "Gate 2：大綱合規檢驗 (程式＋AI)" $CX 832 15.5 "#064e3b" $true
Draw-CenteredText "1. AAT與機轉前置   2. 倫理置於文獻後" $CX 858 13 "#065f46" $false
Draw-CenteredText "3. 6 篇全列零統計   4. 極簡目錄＋3 互動" $CX 880 13 "#065f46" $false
Draw-CenteredText "輸出：02_outline_review.json" $CX 904 12.5 "#047857" $false

# G2 Fail -> N3
Draw-ArrowPath @(@(295,866), @(150,866), @(150,701), @(263,701)) "#94a3b8" 1.8
Draw-EdgeBadge "退回修改" 150 784 86 "#18181b" "#52525b" "#e2e8f0"

# G2 Pass -> G3
Draw-ArrowPath @(@($CX,962), @($CX,1022)) "#34d399" 2.2
Draw-EdgeBadge "通過" $CX 990 64 "#064e3b" "#10b981" "#ecfdf5"

# Gate 3 (Bright Amber/Orange Diamond - HITL 1)
Draw-Diamond $CX 1114 198 90 "#fbbf24" "#f59e0b" 2.2
Draw-CenteredText "Gate 3：人類介入關卡 1 (HITL)" $CX 1090 16 "#451a03" $true
Draw-CenteredText "由使用者審閱並確認 15 頁大綱" $CX 1116 13.5 "#78350f" $false
Draw-CenteredText "【強制暫停】" $CX 1141 15 "#451a03" $true

# G3 Feedback -> N3
Draw-ArrowPath @(@(718,1114), @(890,1114), @(890,701), @(777,701)) "#f59e0b" 2.0
Draw-EdgeBadge "依修改指示" 890 890 100 "#18181b" "#d97706" "#fde68a"

# G3 OK -> Stage 3 N4
Draw-ArrowPath @(@($CX,1204), @($CX,1322)) "#34d399" 2.2
Draw-EdgeBadge "確認大綱 OK" $CX 1254 114 "#064e3b" "#10b981" "#ecfdf5"

# ==================== STAGE 3 ====================
Draw-RoundRect 75 1280 890 628 14 "#1f1f23" "#3f3f46" 1.4 220
Draw-RoundRect 75 1280 890 36 10 "#27272a" "#3f3f46" 1.0 255
Draw-LeftText "第三階段：逐頁文案、版面規劃與字數品管" 96 1288 15 "#e2e8f0" $true

# Node 4
Draw-RoundRect 235 1324 570 72 8 "#27272a" "#52525b" 1.4
Draw-CenteredText "Node 4：逐頁精簡文案、版面配置與 PICO 編寫" $CX 1348 16 "#f8fafc" $true
Draw-CenteredText "輸出：03_slides_content.json（含版面規格）與 03_slides_draft.md" $CX 1373 12.5 "#a1a1aa" $false

Draw-ArrowPath @(@($CX,1396), @($CX,1424)) "#94a3b8" 1.8

# Gate 4 (Soft Coral Pink Diamond)
Draw-Diamond $CX 1526 254 104 "#fda4af" "#f43f5e" 2.2
Draw-CenteredText "Gate 4：逐頁雙重品管 (程式＋AI)" $CX 1482 15.5 "#4c0519" $true
Draw-CenteredText "1. 字數：一般頁 ≤ 150 字 (文獻頁放寬)" $CX 1507 13 "#881337" $true
Draw-CenteredText "2. 版面配置與 6 篇 PICO 欄位齊全" $CX 1529 13 "#881337" $false
Draw-CenteredText "3. Regex 禁統計符號、國旗與誇飾詞" $CX 1551 13 "#881337" $false
Draw-CenteredText "4. AI 查客觀語氣與轉譯 (04_audit)" $CX 1573 12 "#9f1239" $false

# G4 Fail -> N4
Draw-ArrowPath @(@(266,1526), @(145,1526), @(145,1360), @(233,1360)) "#94a3b8" 1.8
Draw-EdgeBadge "超字/規則未過" 145 1444 122 "#18181b" "#52525b" "#e2e8f0"

# G4 Missing Source -> Far-left dashed rollback to Node 2
Draw-ArrowPath @(@(335,1548), @(38,1548), @(38,312), @(293,312)) "#f59e0b" 1.8 $true
Draw-RoundRect 6 882 64 82 6 "#18181b" "#d97706" 1.4
Draw-CenteredText "缺原始" 38 902 12.5 "#fde68a" $true
Draw-CenteredText "素材" 38 922 12.5 "#fde68a" $true
Draw-CenteredText "退 N2" 38 943 12.5 "#fde68a" $true

# G4 Pass -> G5
Draw-ArrowPath @(@($CX,1626), @($CX,1686)) "#34d399" 2.2
Draw-EdgeBadge "品管通過" $CX 1654 88 "#064e3b" "#10b981" "#ecfdf5"

# Gate 5 (Bright Amber/Orange Diamond - HITL 2)
Draw-Diamond $CX 1778 208 90 "#fbbf24" "#f59e0b" 2.2
Draw-CenteredText "Gate 5：人類介入關卡 2 (HITL)" $CX 1754 16 "#451a03" $true
Draw-CenteredText "審閱逐頁精簡文案、版面配置與 PICO" $CX 1780 13 "#78350f" $false
Draw-CenteredText "【強制暫停】" $CX 1805 15 "#451a03" $true

# G5 Feedback -> N4
Draw-ArrowPath @(@(728,1778), @(890,1778), @(890,1360), @(807,1360)) "#f59e0b" 2.0
Draw-EdgeBadge "調整文案/版面" 890 1560 116 "#18181b" "#d97706" "#fde68a"

# G5 OK -> Stage 4 N5
Draw-ArrowPath @(@($CX,1868), @($CX,1988)) "#34d399" 2.2
Draw-EdgeBadge "核准逐頁稿 OK" $CX 1922 132 "#064e3b" "#10b981" "#ecfdf5"

# ==================== STAGE 4 ====================
Draw-RoundRect 75 1946 890 562 14 "#1f1f23" "#3f3f46" 1.4 220
Draw-RoundRect 75 1946 890 36 10 "#27272a" "#3f3f46" 1.0 255
Draw-LeftText "第四階段：互動網頁封裝與最終驗收" 96 1954 15 "#e2e8f0" $true

# Node 5
Draw-RoundRect 215 1990 610 70 8 "#27272a" "#52525b" 1.4
Draw-CenteredText "Node 5：暖陽繪本風互動網頁簡報 HTML 編譯" $CX 2013 16 "#f8fafc" $true
Draw-CenteredText "輸入：03 + assets/*.svg（大字級＋活潑插圖）→ 輸出：slides.html" $CX 2038 12.5 "#a1a1aa" $false

Draw-ArrowPath @(@($CX,2060), @($CX,2086)) "#94a3b8" 1.8

# Gate 6 (Dark Charcoal Diamond)
Draw-Diamond $CX 2178 242 92 "#27272a" "#71717a" 2.0
Draw-CenteredText "Gate 6：美術、字級與互動驗收" $CX 2144 15.5 "#f8fafc" $true
Draw-CenteredText "1. 標題 ≥ 50px、一般內文 ≥ 30px (文獻頁放大)" $CX 2168 12.5 "#d4d4d8" $false
Draw-CenteredText "2. 暖陽繪本風 / 標楷體 / PICO 作者(年份)" $CX 2190 12.5 "#d4d4d8" $false
Draw-CenteredText "輸出：05_build_check.json" $CX 2213 12 "#a1a1aa" $false

# G6 Fail -> N5
Draw-ArrowPath @(@(278,2178), @(145,2178), @(145,2025), @(213,2025)) "#94a3b8" 1.8
Draw-EdgeBadge "字級/版面未過" 145 2100 122 "#18181b" "#52525b" "#e2e8f0"

# G6 Pass -> N6
Draw-ArrowPath @(@($CX,2270), @($CX,2376)) "#34d399" 2.2
Draw-EdgeBadge "驗收通過" $CX 2322 88 "#064e3b" "#10b981" "#ecfdf5"

# Node 6 (Final Delivery)
Draw-RoundRect 245 2378 550 82 10 "#134e4a" "#14b8a6" 2.2
Draw-CenteredText "Node 6：最終交付與獨立網頁同步 GitHub" $CX 2407 17 "#f0fdfa" $true
Draw-CenteredText "獨立部署 slides.html 與 graph.html，保持 LLM Wiki 純淨" $CX 2436 13 "#99f6e4" $false

# ==================== FOOTER LEGEND & ESCALATION ====================
Draw-RoundRect 75 2530 890 104 10 "#27272a" "#3f3f46" 1.4

# Legend row
Draw-RoundRect 108 2548 16 16 3 "#a7f3d0" "#10b981" 1.2
Draw-LeftText "大綱自動審查" 132 2546 13.5 "#e2e8f0" $false

Draw-RoundRect 258 2548 16 16 3 "#fbbf24" "#f59e0b" 1.2
Draw-LeftText "人類介入關卡 (HITL)" 282 2546 13.5 "#e2e8f0" $false

Draw-RoundRect 452 2548 16 16 3 "#fda4af" "#f43f5e" 1.2
Draw-LeftText "逐頁雙重品管" 476 2546 13.5 "#e2e8f0" $false

Draw-RoundRect 604 2548 16 16 3 "#27272a" "#71717a" 1.2
Draw-LeftText "程式與瀏覽器驗收" 628 2546 13.5 "#e2e8f0" $false

$dashPen = New-Object System.Drawing.Pen((HexColor "#f59e0b"), 2.0)
$dashPen.DashStyle = [System.Drawing.Drawing2D.DashStyle]::Dash
$g.DrawLine($dashPen, 778, 2556, 814, 2556)
$dashPen.Dispose()
Draw-LeftText "跨階段退回" 822 2546 13.5 "#fde68a" $false

Draw-CenteredText "防死迴圈保護機制：任一自動檢核關卡 (Gate 1 / 2 / 4 / 6) 連續失敗超過 3 次，自動暫停並升級交由人工裁決" $CX 2604 13.5 "#fde68a" $true

# Save PNG to graph folder & artifacts folder
$outWorkspace = "graph/slide_generation_graph.png"
$outArtifact  = "C:\Users\x2206\.gemini\antigravity\brain\99e1a147-d08b-487d-852d-e7743305642a\slide_generation_graph.png"

$bmp.Save($outWorkspace, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Save($outArtifact, [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()

Write-Host "Successfully rendered PNG: $outWorkspace & $outArtifact"
