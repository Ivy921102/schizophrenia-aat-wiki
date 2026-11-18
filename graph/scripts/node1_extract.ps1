# graph/scripts/node1_extract.ps1
# Node 1: Wiki Knowledge Extractor
# Input:  wiki/sources/*.md, wiki/concepts/**/*.md, wiki/syntheses/*.md
# Output: graph/state/01_wiki_knowledge.json

$ErrorActionPreference = "Stop"

function Read-WikiEntry {
    param([string]$Path, [string]$Id)
    if (-not (Test-Path $Path)) {
        throw "Missing wiki source file: $Path"
    }
    $raw = [System.IO.File]::ReadAllText($Path, [System.Text.Encoding]::UTF8)
    $title = $Id
    if ($raw -match '(?m)^#\s+(.+)$') {
        $title = $Matches[1].Trim()
    }
    $publicSection = ""
    if ($raw -match '(?s)臨床實務與日常生活.*?\r?\n(.+)$') {
        $publicSection = $Matches[1].Trim()
    }
    return [ordered]@{
        id             = $Id
        source_path    = $Path.Replace("\", "/")
        title          = $title
        char_count     = $raw.Length
        has_public_msg = ($publicSection.Length -gt 0)
        public_excerpt = if ($publicSection.Length -gt 240) { $publicSection.Substring(0, 240) + "..." } else { $publicSection }
    }
}

$sourceIds = @(
    "2021-chen-dog-aat-taiwan-rct",
    "2026-peraile-huerta-aat-psychosis-meta",
    "2025-ozturk-equine-aat-rct",
    "2023-tyssedal-dog-assisted-review",
    "2019-hawkins-aat-schizophrenia-review",
    "2016-calvo-dog-aat-rehab-rct"
)

$symptomIds = @("avolition", "asociality", "blunted-affect", "anhedonia")
$mechanismIds = @("oxytocin", "cortisol-hpa", "social-scaffolding")
$interventionIds = @("canine-aat", "equine-aat")

$knowledge = [ordered]@{
    extracted_at  = (Get-Date -Format "yyyy-MM-ddTHH:mm:ssK")
    node          = "Node 1: wiki_extractor"
    sources       = @($sourceIds | ForEach-Object { Read-WikiEntry "wiki/sources/$_.md" $_ })
    symptoms      = @($symptomIds | ForEach-Object { Read-WikiEntry "wiki/concepts/symptoms/$_.md" $_ })
    mechanisms    = @($mechanismIds | ForEach-Object { Read-WikiEntry "wiki/concepts/mechanisms/$_.md" $_ })
    interventions = @($interventionIds | ForEach-Object { Read-WikiEntry "wiki/concepts/interventions/$_.md" $_ })
    syntheses     = @(Read-WikiEntry "wiki/syntheses/from-isolation-to-connection.md" "from-isolation-to-connection")
    assets        = @(Get-ChildItem -Path "assets" -Filter "*.svg" | ForEach-Object { "assets/$($_.Name)" })
}

$json = $knowledge | ConvertTo-Json -Depth 6
[System.IO.File]::WriteAllText("graph/state/01_wiki_knowledge.json", $json, [System.Text.Encoding]::UTF8)
Write-Host "[Node 1] Extracted wiki knowledge -> graph/state/01_wiki_knowledge.json"
