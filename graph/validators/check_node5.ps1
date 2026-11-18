# graph/validators/check_node5.ps1
# Gate 6 (v2): Theme + Typography (Title >= 50px, General Body >= 30px) + PICO Author(Year) + Interactive Verification
# Input:  slides.html, graph/state/00_requirements.json
# Output: graph/state/05_build_check.json

$ErrorActionPreference = "Stop"

$req  = [System.IO.File]::ReadAllText("graph/state/00_requirements.json", [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$html = [System.IO.File]::ReadAllText("slides.html", [System.Text.Encoding]::UTF8)

$errors = @()

# 1. Verify exactly 15 slides rendered
$slideMatches = [regex]::Matches($html, 'data-index="\d+"')
if ($slideMatches.Count -ne 15) {
    $errors += "Expected 15 rendered slides in slides.html, found $($slideMatches.Count)"
}

# 2. Verify Warm Storybook theme (#FAF7F2) & Times New Roman -> 標楷體 font stack
if (-not $html.Contains("#FAF7F2")) { $errors += "Missing Warm Storybook canvas color (#FAF7F2)" }
if (-not ($html -match 'font-family:\s*"Times New Roman",\s*"標楷體"')) {
    $errors += "Missing 'Times New Roman' before '標楷體' in font-family stack"
}

# 2b. Verify Fullscreen ArrowRight keyboard navigation is NOT blocked by focused buttons
if (-not $html.Contains("function clearFocus()") -or -not $html.Contains("fullscreenchange")) {
    $errors += "Missing fullscreen focus-blur safeguard (clearFocus / fullscreenchange)"
}
if ($html -match "ArrowRight.*?\r?\n\s*if\s*\(document\.activeElement\.tagName\s*!==\s*'BUTTON'\)") {
    $errors += "ArrowRight is still incorrectly blocked when a button has focus"
}

# 3. Verify Typography minimums: .slide-title >= 50px, .box-list >= 30px, .public-quote-box >= 30px
$titlePx = 0
if ($html -match '\.slide-title\s*\{[^}]*font-size:\s*(\d+)px') { $titlePx = [int]$Matches[1] }
if ($titlePx -lt $req.visual_and_typography.general_title_min_px) {
    $errors += "General .slide-title font-size ($titlePx px) < minimum $($req.visual_and_typography.general_title_min_px) px"
}

$bodyPx = 0
if ($html -match '\.box-list\s*\{[^}]*font-size:\s*(\d+)px') { $bodyPx = [int]$Matches[1] }
if ($bodyPx -lt $req.visual_and_typography.general_body_min_px) {
    $errors += "General .box-list font-size ($bodyPx px) < minimum $($req.visual_and_typography.general_body_min_px) px"
}

$quotePx = 0
if ($html -match '\.public-quote-box\s*\{[^}]*font-size:\s*(\d+)px') { $quotePx = [int]$Matches[1] }
if ($quotePx -lt $req.visual_and_typography.general_body_min_px) {
    $errors += "General .public-quote-box font-size ($quotePx px) < minimum $($req.visual_and_typography.general_body_min_px) px"
}

# 4. Verify all 6 PICO tab buttons use Author (Year) format
$expectedTabs = @(
    "Chen et al. (2021)",
    "Peraile-Huerta et al. (2026)",
    "Öztürk et al. (2025)",
    "Tyssedal et al. (2023)",
    "Hawkins et al. (2019)",
    "Calvo et al. (2016)"
)
foreach ($tb in $expectedTabs) {
    if (-not $html.Contains($tb)) {
        $errors += "Missing Author(Year) PICO tab label: $tb"
    }
}

# 5. Verify all 3 interactive JS handlers & PICO labels
foreach ($fn in @("toggleMythCard", "toggleMatchCard", "switchPicoTab")) {
    if (-not $html.Contains("function $fn")) { $errors += "Missing interactive JS handler: $fn" }
}
foreach ($lbl in @("研究對象 (Population)", "介入方式 (Intervention)", "對照組 (Comparison)", "主要結果 (Outcome)")) {
    if (-not $html.Contains($lbl)) { $errors += "Missing PICO label: $lbl" }
}

# 6. Verify SVG assets exist
$assetMatches = [regex]::Matches($html, 'assets/[a-zA-Z0-9\-_]+\.svg')
$uniqueAssets = @($assetMatches | ForEach-Object { $_.Value } | Select-Object -Unique)
foreach ($ap in $uniqueAssets) {
    if (-not (Test-Path $ap)) { $errors += "Broken SVG asset: $ap" }
}

# 7. Verify ZERO forbidden stats / exaggeration / broken flag emojis in visible text
$noScript = [regex]::Replace($html, '(?s)<(style|script).*?</\1>', ' ')
$visibleText = [regex]::Replace($noScript, '<[^>]+>', ' ')
foreach ($pat in $req.hard_constraints.forbidden_stat_patterns) {
    if ($visibleText.Contains($pat)) { $errors += "Forbidden stat symbol in visible text: $pat" }
}
foreach ($w in $req.hard_constraints.forbidden_exaggeration_words) {
    if ($visibleText.Contains($w)) { $errors += "Forbidden exaggeration word in visible text: $w" }
}
if (([regex]'[\uD83C][\uDDE6-\uDDFF]').IsMatch($html)) {
    $errors += "Found Windows-broken flag emoji in slides.html"
}

$status  = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
$routing = if ($status -eq "PASS") { "Node 6: Final Delivery & Sync GitHub" } else { "ROLLBACK -> Node 5: deck_builder" }

$report = [ordered]@{
    verified_at        = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
    revision           = "v2 (Warm Storybook + Title>=50px + Body>=30px + Author(Year) PICO)"
    validator          = "Gate 6: Theme, Typography, PICO Format & Interactive QA"
    status             = $status
    routing_decision   = $routing
    metrics            = [ordered]@{
        rendered_slides         = $slideMatches.Count
        art_theme               = "warm_storybook_healing (#FAF7F2)"
        general_title_px        = $titlePx
        general_body_px         = $bodyPx
        general_quote_px        = $quotePx
        pico_tabs_author_year   = $true
        verified_svg_assets     = $uniqueAssets.Count
        file_size_bytes         = (Get-Item "slides.html").Length
    }
    errors             = $errors
}

[System.IO.File]::WriteAllText("graph/state/05_build_check.json", ($report | ConvertTo-Json -Depth 5), [System.Text.Encoding]::UTF8)
Write-Host "[Gate 6 v2] Status: $status | Title: ${titlePx}px | Body: ${bodyPx}px | Quote: ${quotePx}px | Routing: $routing"
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
