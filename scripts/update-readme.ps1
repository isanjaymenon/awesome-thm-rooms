# Script to update markdown file with categorized tables

param(
    [Parameter(Mandatory=$false)]
    [string]$InputFile = "./thm-rooms.md",
    
    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "./README.md"
)

# Validate input parameters
try {
    # Check input file exists
    if (-not (Test-Path $InputFile)) {
        throw "Input file not found: $InputFile"
    }

    # Validate output file path is writable
    $outputDir = Split-Path $OutputFile -Parent
    if ($outputDir -and (-not (Test-Path $outputDir))) {
        throw "Output directory does not exist: $outputDir"
    }
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}

# More robust regex for parsing markdown links
$linkRegex = '^(\d+)\.\s*\[(.+?)\]\((.+?)\)(?:\s*-\s*(.+))?$'

# Initialize variables
$tables = @()
$currentSection = ""
$counter = 0

try {
    # Read the content of the markdown file
    $content = Get-Content -Path $InputFile -ErrorAction Stop

    # Process the file line by line
    foreach ($line in $content) {
        $line = $line.Trim()  # Trim leading/trailing spaces from the current line

        # Preserve H1 and H2 headers
        if ($line -match "^#+\s" -and $line -notmatch "###") {
            $tables += $line
            continue
        }

        # Process H3 headers (###)
        if ($line -match "^###") {
            # Start a new section for H3 headers with tables
            $currentSection = $line.Trim()  # Trim header
            $tables += "`n$currentSection"
            $tables += "| S.No | Room Name | Description |"
            $tables += "|-------|-----------|-------------|"
            $counter = 0
            continue
        }

        # Process the numbered list under each section with more robust regex
        if ($line -match $linkRegex) {
            $counter++
            $roomNumber = $matches[1]
            $roomName = $matches[2].Trim()
            $roomLink = $matches[3].Trim()
            $description = if ($matches[4]) { $matches[4].Trim() } else { "" }
            
            $tables += "| $counter | [$roomName]($roomLink) | $description |"
            continue
        }

        # Add any non-header, non-list text directly
        if ($line) {
            $tables += $line
        }
    }

    # Write the tables to the output file
    Set-Content -Path $OutputFile -Value ($tables -join "`n") -ErrorAction Stop

    Write-Output "Readme updated and saved to $OutputFile"
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}