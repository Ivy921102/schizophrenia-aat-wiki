# graph/validators/check_node1.ps1
# Code Validator 1: Validates 01_wiki_knowledge.json against 00_requirements.json

$ErrorActionPreference = "Stop"

$req = [System.IO.File]::ReadAllText("graph/state/00_requirements.json", [System.Text.Encoding]::UTF8) | ConvertFrom-Json
$kn  = [System.IO.File]::ReadAllText("graph/state/01_wiki_knowledge.json", [System.Text.Encoding]::UTF8) | ConvertFrom-Json

$errors = @()

# 1. Check all 6 required papers exist
$extractedIds = @($kn.sources | ForEach-Object { $_.id })
foreach ($paperId in $req.hard_constraints.required_papers) {
    if ($extractedIds -notcontains $paperId) {
        $errors += "Missing required paper: $paperId"
    }
}

# 2. Check all 4 negative symptoms exist
if ($kn.symptoms.Count -lt 4) { $errors += "Expected 4 negative symptoms, found $($kn.symptoms.Count)" }

# 3. Check all 3 mechanisms exist
if ($kn.mechanisms.Count -lt 3) { $errors += "Expected 3 mechanisms, found $($kn.mechanisms.Count)" }

# 4. Check public translation exists in every extracted source and mechanism
foreach ($s in $kn.sources) {
    if (-not $s.has_public_msg) { $errors += "Source $($s.id) missing public translation section" }
}
foreach ($m in $kn.mechanisms) {
    if (-not $m.has_public_msg) { $errors += "Mechanism $($m.id) missing public translation section" }
}

# 5. Check SVG assets exist
if ($kn.assets.Count -lt 5) { $errors += "Expected at least 5 Q-animal SVG assets, found $($kn.assets.Count)" }

$status = if ($errors.Count -eq 0) { "PASS" } else { "FAIL" }
$nextNode = if ($status -eq "PASS") { "Node 2: outline_planner" } else { "ROLLBACK -> Node 1: wiki_extractor" }

$report = [ordered]@{
    checked_at         = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
    validator          = "Code Validator 1 (check_node1.ps1)"
    status             = $status
    routing_decision   = $nextNode
    counts             = [ordered]@{
        sources       = $kn.sources.Count
        symptoms      = $kn.symptoms.Count
        mechanisms    = $kn.mechanisms.Count
        interventions = $kn.interventions.Count
        syntheses     = $kn.syntheses.Count
        svg_assets    = $kn.assets.Count
    }
    errors             = $errors
}

$reportJson = $report | ConvertTo-Json -Depth 5
[System.IO.File]::WriteAllText("graph/state/01_check_report.json", $reportJson, [System.Text.Encoding]::UTF8)
Write-Host "[Code Validator 1] Status: $status | Routing: $nextNode"
if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}
