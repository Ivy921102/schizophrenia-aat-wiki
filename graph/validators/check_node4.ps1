# graph/validators/check_node4.ps1
# Gate 4 (v3): Per-Slide <=150 Chars + Layout Plan + PICO + Objective Tone + Regex Rules

$ErrorActionPreference = "Stop"

$req   = [System.IO.File]::ReadAllText("graph/state/00_requirements.json", [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$rawJ  = [System.IO.File]::ReadAllText("graph/state/03_slides_content.json", [System.Text.Encoding]::UTF8)
$draft = [System.IO.File]::ReadAllText("graph/state/03_slides_draft.md", [System.Text.Encoding]::UTF8)
$data  = $rawJ | ConvertFrom-Json

$errors = @()
$maxAllowed = $req.deck_scope.max_visible_chars_general_slide
$litPages   = @($req.deck_scope.literature_pages)
$charStats = [ordered]@{}

function Count-VisibleChars([string]$s) {
    if ([string]::IsNullOrWhiteSpace($s)) { return 0 }
    return ([regex]::Replace($s, '\s+', '')).Length
}

# 1. Page count
$pageCount = $data.slides.Count
if ($pageCount -lt $req.deck_scope.page_count_min -or $pageCount -gt $req.deck_scope.page_count_max) {
    $errors += "Slide count $pageCount out of range"
}

# 2. Cover no-subtitle & Minimalist TOC check (Page 1 & Page 2)
$cover = $data.slides[0]
if (-not [string]::IsNullOrEmpty($cover.subtitle)) {
    $errors += "Page 1 cover must NOT have a subtitle"
}
$toc = $data.slides[1]
if ($toc.type -ne "toc" -or $toc.title -ne "目錄" -or -not [string]::IsNullOrEmpty($toc.subtitle)) {
    $errors += "Page 2 TOC must have title '目錄' and empty subtitle"
}

# 3. Check Social Scaffolding removed from Page 8
$p8 = $data.slides[7]
$p8Raw = $p8 | ConvertTo-Json -Depth 4
if ($p8Raw.Contains("社交鷹架") -or $p8Raw.Contains("Social Scaffolding")) {
    $errors += "Page 8 still contains Social Scaffolding intro (must be removed)"
}

# 4. Check Layout Plan & Per-Slide Char Budget (<= 150 chars)
foreach ($s in $data.slides) {
    if ([string]::IsNullOrWhiteSpace($s.layout_plan)) {
        $errors += "Slide $($s.page) missing layout_plan"
    }
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
        $maxTxt = ""
        foreach ($p in $s.papers) {
            $t = $p.P + $p.I + $p.C + $p.O
            if ($t.Length -gt $maxTxt.Length) { $maxTxt = $t }
        }
        $parts += $maxTxt
    }
    if ($s.quote) { $parts += $s.quote }
    if ($s.vision) { $parts += $s.vision }
    if ($s.public_quote) { $parts += $s.public_quote }

    $cnt = Count-VisibleChars ($parts -join '')
    $isLit = ($litPages -contains $s.page)
    $charStats["page_$($s.page)"] = if ($isLit) { "$cnt (literature_exempt)" } else { "$cnt" }
    if (-not $isLit -and $cnt -gt $maxAllowed) {
        $errors += "General Slide $($s.page) exceeds char budget: $cnt > $maxAllowed"
    }
}

# 5. PICO structure check on Slide 12 (all 6 papers must have non-empty P, I, C, O)
$picoSlide = $data.slides | Where-Object { $_.type -eq "interactive_pico" }
if (-not $picoSlide -or $picoSlide.papers.Count -ne 6) {
    $errors += "Slide 12 must be interactive_pico with 6 papers"
} else {
    foreach ($p in $picoSlide.papers) {
        if ([string]::IsNullOrWhiteSpace($p.P) -or [string]::IsNullOrWhiteSpace($p.I) -or [string]::IsNullOrWhiteSpace($p.C) -or [string]::IsNullOrWhiteSpace($p.O)) {
            $errors += "Paper $($p.id) missing P/I/C/O field"
        }
    }
}

# 6. Forbidden stat symbols, exaggeration words, cross-animal divergence, broken flag emojis
foreach ($pat in $req.hard_constraints.forbidden_stat_patterns) {
    if ($rawJ.Contains($pat)) { $errors += "Forbidden statistical symbol: $pat" }
}
foreach ($w in $req.hard_constraints.forbidden_exaggeration_words) {
    if ($rawJ.Contains($w)) { $errors += "Forbidden non-objective exaggeration word: $w" }
}
foreach ($term in @("跨動物分歧", "犬馬分歧", "犬類 vs 馬匹")) {
    if ($rawJ.Contains($term)) { $errors += "Forbidden cross-animal divergence term: $term" }
}
if (([regex]'[\uD83C][\uDDE6-\uDDFF]').IsMatch($rawJ)) {
    $errors += "Windows-broken flag emoji detected"
}

# 7. Verify all 6 authors & SVG assets exist
foreach ($a in @("Chen", "Peraile-Huerta", "Öztürk", "Tyssedal", "Hawkins", "Calvo")) {
    if (-not $rawJ.Contains($a)) { $errors += "Missing author: $a" }
}
$allAssets = @()
foreach ($s in $data.slides) {
    if ($s.header_asset) { $allAssets += $s.header_asset }
    if ($s.assets) { $allAssets += $s.assets }
}
foreach ($ap in ($allAssets | Select-Object -Unique)) {
    if (-not (Test-Path $ap)) { $errors += "Missing SVG asset: $ap" }
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
$routing = if ($status -eq "PASS") { "PAUSE -> Gate 5 (人類介入關卡 2：審閱精簡文案、版面配置與 PICO)" } else { "ROLLBACK -> Node 4: page_writer" }

$audit = [ordered]@{
    audited_at         = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
    revision           = "v3 (per-slide <=150 chars, layout_plan, PICO, objective tone)"
    auditor            = "Gate 4: Code Char-Budget + PICO + Regex + Tone QA"
    status             = $status
    routing_decision   = $routing
    max_chars_allowed  = $maxAllowed
    per_slide_chars    = $charStats
    errors             = $errors
}

[System.IO.File]::WriteAllText("graph/state/04_audit_report.json", ($audit | ConvertTo-Json -Depth 5), [System.Text.Encoding]::UTF8)
Write-Host "[Gate 4 v3] Status: $status | Max allowed: $maxAllowed chars | Routing: $routing"
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
