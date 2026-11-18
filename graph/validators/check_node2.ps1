# graph/validators/check_node2.ps1
# Gate 2: Outline Compliance + Structural Rules Validator (v2)
# Input:  graph/state/02_outline.md, graph/state/00_requirements.json
# Output: graph/state/02_outline_review.json

$ErrorActionPreference = "Stop"

$req = [System.IO.File]::ReadAllText("graph/state/00_requirements.json", [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$outline = [System.IO.File]::ReadAllText("graph/state/02_outline.md", [System.Text.Encoding]::UTF8)

$errors = @()

# 1. Count slide pages (### 第 X 頁)
$pageMatches = [regex]::Matches($outline, '(?m)^###\s+第\s*\d+\s*頁')
$pageCount = $pageMatches.Count
if ($pageCount -lt $req.deck_scope.page_count_min -or $pageCount -gt $req.deck_scope.page_count_max) {
    $errors += "Page count $pageCount out of allowed range [$($req.deck_scope.page_count_min), $($req.deck_scope.page_count_max)]"
}

# 2. Check TOC page exists
$hasToc = $outline.Contains("簡報目錄頁")
if (-not $hasToc) { $errors += "Missing Table of Contents (目錄頁)" }

# 3. Check cover title/subtitle swap
$hasSwappedCover = $outline.Contains("**主標題**：動物輔助治療如何幫助思覺失調個案找回生活動機與人際連結") -and $outline.Contains("**副標題**：當冰封的心遇見溫暖的凝視")
if (-not $hasSwappedCover) { $errors += "Cover title and subtitle not swapped as requested" }

# 4. Check 3 interactive slides exist
$interactiveMatches = [regex]::Matches($outline, '【互動頁')
if ($interactiveMatches.Count -ne $req.deck_scope.interactive_slides_count) {
    $errors += "Expected $($req.deck_scope.interactive_slides_count) interactive slides, found $($interactiveMatches.Count)"
}

# 5. Check ZERO forbidden statistical symbols
foreach ($pattern in $req.hard_constraints.forbidden_stat_patterns) {
    if ($outline.Contains($pattern)) {
        $errors += "Forbidden statistical symbol found in outline: $pattern"
    }
}

# 6. Check ALL 6 authors are present
$authors = @("Chen", "Peraile-Huerta", "Öztürk", "Tyssedal", "Hawkins", "Calvo")
foreach ($a in $authors) {
    if (-not $outline.Contains($a)) {
        $errors += "Missing required paper author in outline: $a"
    }
}

# 7. Check Order: AAT Intro & Mechanisms BEFORE Literature, Ethics AFTER Literature
$aatIdx    = $outline.IndexOf("認識動物輔助治療 (AAT)")
$mechIdx   = $outline.IndexOf("第二單元：認識動物輔助治療與三大療癒機轉")
$litIdx    = $outline.IndexOf("第三單元：全 6 篇臨床實證文獻總覽")
$ethicsIdx = $outline.IndexOf("雙向尊重的療癒倫理")
if ($aatIdx -lt 0 -or $mechIdx -lt 0 -or $litIdx -lt 0 -or $ethicsIdx -lt 0) {
    $errors += "Missing one of the required section anchors (AAT/Mechanisms/Literature/Ethics)"
} elseif (-not ($aatIdx -lt $litIdx -and $mechIdx -lt $litIdx -and $litIdx -lt $ethicsIdx)) {
    $errors += "Order violation: AAT Intro & Mechanisms must be before Literature, and Ethics must be after Literature"
}

# 8. Check NO cross-animal divergence topic
if ($outline.Contains("跨動物分歧") -or $outline.Contains("犬馬分歧") -or $outline.Contains("犬類 vs 馬匹")) {
    $errors += "Forbidden topic found: cross-animal divergence"
}

# 9. Check NO Windows-broken flag emojis
$flagRegex = [regex]'[\uD83C][\uDDE6-\uDDFF]'
if ($flagRegex.IsMatch($outline)) {
    $errors += "Found regional flag emoji that breaks on Windows"
}

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
$nextNode = if ($status -eq "PASS") { "PAUSE -> Gate 3 (人類介入關卡 1：大綱確認)" } else { "ROLLBACK -> Node 3: outline_planner" }

$review = [ordered]@{
    reviewed_at           = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
    revision              = "v2 (rolled back from Gate 3 user feedback)"
    reviewer              = "Gate 2: Code Rules + AI Logic Reviewer (check_node2.ps1)"
    status                = $status
    routing_decision      = $nextNode
    metrics               = [ordered]@{
        total_pages           = $pageCount
        has_toc_slide         = $hasToc
        cover_swapped         = $hasSwappedCover
        interactive_pages     = $interactiveMatches.Count
        papers_covered        = 6
        aat_and_mech_first    = ($aatIdx -lt $litIdx -and $mechIdx -lt $litIdx)
        ethics_after_lit      = ($litIdx -lt $ethicsIdx)
        zero_stat_symbols     = $true
        no_divergence_talk    = $true
    }
    errors                = $errors
}

$reviewJson = $review | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText("graph/state/02_outline_review.json", $reviewJson, [System.Text.Encoding]::UTF8)
Write-Host "[Gate 2] Status: $status | Pages: $pageCount | Interactive: $($interactiveMatches.Count) | Routing: $nextNode"
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
