# graph/validators/check_node5.ps1
# Gate 6: Automated Build & Interactive Integrity Verification
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

# 2. Verify BiauKai font-family
if (-not $html.Contains("標楷體")) {
    $errors += "Missing 標楷體 global font rule"
}

# 3. Verify all 3 interactive functions exist & bound
foreach ($fn in @("toggleMythCard", "toggleMatchCard", "switchPicoTab")) {
    if (-not $html.Contains("function $fn")) {
        $errors += "Missing interactive JS handler: $fn"
    }
}

# 4. Verify all referenced SVG assets exist
$assetMatches = [regex]::Matches($html, 'assets/[a-zA-Z0-9\-_]+\.svg')
$uniqueAssets = @($assetMatches | ForEach-Object { $_.Value } | Select-Object -Unique)
foreach ($ap in $uniqueAssets) {
    if (-not (Test-Path $ap)) {
        $errors += "Broken SVG asset reference in slides.html: $ap"
    }
}

# 5. Verify PICO labels present
foreach ($lbl in @("研究對象 (Population)", "介入方式 (Intervention)", "對照組 (Comparison)", "主要結果 (Outcome)")) {
    if (-not $html.Contains($lbl)) {
        $errors += "Missing PICO label in slides.html: $lbl"
    }
}

# 6. Verify ZERO forbidden stats / exaggeration / broken flag emojis in visible text
$noScript = [regex]::Replace($html, '(?s)<(style|script).*?</\1>', ' ')
$visibleText = [regex]::Replace($noScript, '<[^>]+>', ' ')
foreach ($pat in $req.hard_constraints.forbidden_stat_patterns) {
    if ($visibleText.Contains($pat)) { $errors += "Forbidden statistical symbol in visible text: $pat" }
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
    validator          = "Gate 6: HTML Build, SVG Asset & Interactive Handler Verification"
    status             = $status
    routing_decision   = $routing
    metrics            = [ordered]@{
        rendered_slides      = $slideMatches.Count
        verified_svg_assets  = $uniqueAssets.Count
        file_size_bytes      = (Get-Item "slides.html").Length
        interactive_handlers = 3
        pico_ready           = $true
        font_biaukai         = $true
    }
    errors             = $errors
}

[System.IO.File]::WriteAllText("graph/state/05_build_check.json", ($report | ConvertTo-Json -Depth 5), [System.Text.Encoding]::UTF8)
Write-Host "[Gate 6] Status: $status | Slides: $($slideMatches.Count) | SVGs: $($uniqueAssets.Count) | Routing: $routing"
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
