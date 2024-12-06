param(
    [Parameter(Mandatory=$true)]
    [string]$InputFile,

    [Parameter(Mandatory=$false)]
    [string]$OutputFile = "thm-rooms-list.md"
)

# Validate input parameters
try {
    # Validate input file exists and is readable
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

# Initialize variables
$counter = 0
$urls = @()

try {
    # Read file content
    $content = Get-Content $InputFile -ErrorAction Stop

    # Extract URLs using regex
    $urls = $content | Select-String -Pattern '\[.*?\]\((.*?)\)' -AllMatches | 
        ForEach-Object { 
            $_.Matches 
        } | 
        ForEach-Object { 
            $_.Groups[1].Value 
        } | 
        Where-Object { $_ -match '^https?://(?:www\.)?tryhackme\.com/\S+' } | 
        Sort-Object -Unique

    # Check if any URLs were found
    if ($urls.Count -eq 0) {
        Write-Warning "No TryHackMe URLs found in the input file."
        exit 0
    }

    # Add numbering to the extracted links
    $numberedUrls = $urls | ForEach-Object { 
        $counter++
        "$counter. $_"
    }

    # Output numbered URLs to file
    $numberedUrls | Out-File -FilePath $OutputFile -Encoding UTF8 -ErrorAction Stop

    # Display results
    Write-Host "Extracted unique links have been saved to $OutputFile"
    Write-Host "`nExtracted Links:"
    $numberedUrls
}
catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
}