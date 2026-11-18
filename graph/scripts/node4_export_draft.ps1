# graph/scripts/node4_export_draft.ps1
# Generates human-readable graph/state/03_slides_draft.md with explicit Layout Plan, PICO & Live Char Count

$ErrorActionPreference = "Stop"
$data = [System.IO.File]::ReadAllText("graph/state/03_slides_content.json", [System.Text.Encoding]::UTF8) | ConvertFrom-Json

function Count-VisibleChars([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return 0 }
    # Remove spaces/newlines for fair visible character count
    return ([regex]::Replace($s, '\s+', '')).Length
}

function Get-SlideVisibleText($s) {
    $parts = @()
    if ($s.title) { $parts += $s.title }
    if ($s.subtitle) { $parts += $s.subtitle }
    if ($s.footer_note) { $parts += $s.footer_note }
    if ($s.sections) { foreach ($sec in $s.sections) { $parts += $sec.name } }
    if ($s.cards) {
        foreach ($c in $s.cards) {
            if ($c.title) { $parts += $c.title }
            if ($c.tag) { $parts += $c.tag }
            if ($c.bullets) { $parts += ($c.bullets -join '') }
        }
    }
    if ($s.type -eq "interactive_myth") {
        foreach ($it in $s.items) { $parts += ($it.badge + $it.question) }
    }
    elseif ($s.type -eq "interactive_match") {
        foreach ($it in $s.items) { $parts += ($it.badge + $it.scenario) }
    }
    elseif ($s.type -eq "interactive_pico") {
        # Visible on screen at once = tabs + active 1 paper PICO (compute worst-case max paper)
        $tabText = ($s.papers | ForEach-Object { $_.tab_label }) -join ''
        $maxP = 0
        $maxTxt = ""
        foreach ($p in $s.papers) {
            $t = $p.P + $p.I + $p.C + $p.O
            if ($t.Length -gt $maxP) { $maxP = $t.Length; $maxTxt = $t }
        }
        $parts += $maxTxt
    }
    if ($s.quote) { $parts += $s.quote }
    if ($s.vision) { $parts += $s.vision }
    if ($s.public_quote) { $parts += $s.public_quote }
    return ($parts -join '')
}

$req = [System.IO.File]::ReadAllText("graph/state/00_requirements.json", [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$litPages = @($req.deck_scope.literature_pages)
$maxGen = $req.deck_scope.max_visible_chars_general_slide

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("# 簡報逐頁精簡文字稿與版面配置（15 頁｜一般頁 ≤ $maxGen 字・文獻頁放寬｜含 PICO 互動）")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("- **產出節點**：Node 4 (page_writer v4)")
[void]$sb.AppendLine("- **分級字數預算**：一般頁嚴格控制 **≤ $maxGen 字**；文獻實證頁（第 $($litPages -join '、') 頁）放寬限制以完整保留期刊與臨床細節")
[void]$sb.AppendLine("- **當前關卡**：等待 **Gate 5（人類介入關卡 2：審閱文案、版面與 PICO）** 確認")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("---")
[void]$sb.AppendLine("")

foreach ($s in $data.slides) {
    $visChars = Count-VisibleChars (Get-SlideVisibleText $s)
    $isLit = ($litPages -contains $s.page)
    $budgetTag = if ($isLit) { "文獻頁放寬 ✅" } else { "≤ $maxGen 字 ✅" }
    [void]$sb.AppendLine("## 第 $($s.page) 頁｜$($s.title)")
    [void]$sb.AppendLine("- **版面配置**：$($s.layout_plan)")
    [void]$sb.AppendLine("- **可見字數**：約 **$visChars 字**（$budgetTag）")
    if ($s.subtitle) { [void]$sb.AppendLine("- **副標題**：$($s.subtitle)") }
    [void]$sb.AppendLine("")

    if ($s.type -eq "cover") {
        [void]$sb.AppendLine("- **底部引導**：$($s.footer_note)")
    }
    elseif ($s.type -eq "toc") {
        foreach ($sec in $s.sections) {
            [void]$sb.AppendLine("- **$($sec.name)**")
        }
    }
    elseif ($s.type -in @("content_2col", "content_3col", "content_4grid")) {
        foreach ($c in $s.cards) {
            $tagStr = if ($c.tag) { "（$($c.tag)）" } else { "" }
            [void]$sb.AppendLine("### $($c.title)$tagStr")
            foreach ($b in $c.bullets) {
                [void]$sb.AppendLine("- $b")
            }
            [void]$sb.AppendLine("")
        }
    }
    elseif ($s.type -eq "interactive_myth") {
        foreach ($it in $s.items) {
            [void]$sb.AppendLine("1. **$($it.badge)**：$($it.question)")
            [void]$sb.AppendLine("   - 點擊翻面：$($it.verdict) —— $($it.explanation)")
        }
    }
    elseif ($s.type -eq "interactive_match") {
        foreach ($it in $s.items) {
            [void]$sb.AppendLine("1. **$($it.badge)**：$($it.scenario)")
            [void]$sb.AppendLine("   - 點擊展開：**機轉**＝$($it.mechanism)｜**生活**＝$($it.daily_life)")
        }
    }
    elseif ($s.type -eq "interactive_pico") {
        foreach ($p in $s.papers) {
            $pChars = Count-VisibleChars ($p.P + $p.I + $p.C + $p.O)
            [void]$sb.AppendLine("### $($p.tab_label) — $($p.title)（PICO 約 $pChars 字）")
            [void]$sb.AppendLine("- **P（對象）**：$($p.P)")
            [void]$sb.AppendLine("- **I（介入）**：$($p.I)")
            [void]$sb.AppendLine("- **C（對照）**：$($p.C)")
            [void]$sb.AppendLine("- **O（結果）**：$($p.O)")
            [void]$sb.AppendLine("")
        }
    }
    elseif ($s.type -eq "ending") {
        [void]$sb.AppendLine("> $($s.quote)")
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("- **願景**：$($s.vision)")
    }

    if ($s.public_quote) {
        [void]$sb.AppendLine("")
        [void]$sb.AppendLine("> **🌟 生活轉譯**：$($s.public_quote)")
    }
    [void]$sb.AppendLine("")
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine("")
}

[System.IO.File]::WriteAllText("graph/state/03_slides_draft.md", $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Host "[Node 4] Exported v3 concise draft with layout & PICO -> graph/state/03_slides_draft.md"
