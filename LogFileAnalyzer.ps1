# Function to display the menu options
function Show-Menu {
    Write-Host "=================== LOG FILE ANALYZER ===================" -ForegroundColor Cyan
    Write-Host "Options:"
    Write-Host "1. Specify the Log File Path"
    Write-Host "2. Filter by Date Range"
    Write-Host "3. Filter by Severity: [ERROR | WARNING]"
    Write-Host "4. Filter by Keyword"
    Write-Host "5. Export Results: [CSV or JSON]"
    Write-Host "6. Exit"
    Write-Host "========================================================"
}

# Function to process and filter the logs
function Get-LogFileContent {
    param (
        [string]$FilePath,
        [datetime]$StartDate,
        [datetime]$EndDate,
        [string]$Severity,
        [string]$Keyword
    )

    # Validate file path
    if ([string]::IsNullOrEmpty($FilePath)) {
        Write-Host "Error: No file path provided." -ForegroundColor Red
        return $null
    }

    # Remove quotes and trim spaces in the file path
    $FilePath = $FilePath.Trim('"', ' ')

    # Check if file exists
    Write-Host "Validating the file path: $FilePath" -ForegroundColor Cyan
    if (-Not (Test-Path $FilePath)) {
        Write-Host "Error: File path does not exist or is not accessible." -ForegroundColor Red
        return $null
    }

    # Reading the file content
    Write-Host "Reading and parsing the log file..." -ForegroundColor Green
    $Logs = Get-Content $FilePath

    # Store filtered logs in an array
    $FilteredLogs = @()

    foreach ($Line in $Logs) {
        if ($Line -match '^(?<Date>\d{4}-\d{2}-\d{2}) (?<Time>\d{2}:\d{2}:\d{2}) \[(?<Severity>\w+)\] (?<Message>.+)$') {
            $LogDate = [datetime]::ParseExact($matches.Date, "yyyy-MM-dd", $null)
            $LogSeverity = $matches.Severity
            $LogMessage = $matches.Message

            # Apply filtering
            if ($StartDate -and ($LogDate -lt $StartDate)) { continue }
            if ($EndDate -and ($LogDate -gt $EndDate)) { continue }
            if ($Severity -and ($LogSeverity -notlike $Severity)) { continue }
            if ($Keyword -and ($LogMessage -notmatch $Keyword)) { continue }

            # Add valid log entry to filtered logs
            $FilteredLogs += [PSCustomObject]@{
                Date     = $matches.Date
                Time     = $matches.Time
                Severity = $matches.Severity
                Message  = $matches.Message
            }
        }
    }

    Write-Host "`nFiltering complete. Logs matching criteria: $($FilteredLogs.Count)" -ForegroundColor Cyan
    return $FilteredLogs
}

# Main loop to keep showing the menu until the user exits
$Logs = @()
do {
    Write-Host "`nWelcome to the Log File Analyzer!" -ForegroundColor Cyan
    # Initial Menu Display
    Show-Menu

    # Process user choice
    $Choice = Read-Host "Enter your choice (1-6)"

    switch ($Choice) {
        1 {
            # Log file input section
            $LogFile = Read-Host "Please enter the full path to the log file"

            if (![string]::IsNullOrEmpty($LogFile)) {
                Write-Host "File path provided: $LogFile" -ForegroundColor Yellow

                # Process the log file
                $Logs = Get-LogFileContent -FilePath $LogFile
                
                if ($Logs) {
                    Write-Host "Log file parsed successfully." -ForegroundColor Green
                }
            } else {
                Write-Host "You must provide a valid file path." -ForegroundColor Red
            }
        }

        2 {
            # Filter logs by date range
            Write-Host "Filter by Date Range"
            $Start = Read-Host "Enter start date (YYYY-MM-DD)"
            $End = Read-Host "Enter end date (YYYY-MM-DD)"
            $StartDate = [datetime]::ParseExact($Start, "yyyy-MM-dd", $null)
            $EndDate = [datetime]::ParseExact($End, "yyyy-MM-dd", $null)
            Write-Host "Filtering between $Start and $End..."
        }

        3 {
            # Filter logs by severity
            Write-Host "Filter by Severity"
            $Severity = Read-Host "Enter severity level (ERROR, WARNING)"
            Write-Host "Filtering by severity: $Severity"
        }

        4 {
            # Filter logs by keyword
            Write-Host "Filter by Keyword"
            $Keyword = Read-Host "Enter a keyword to search"
            Write-Host "Filtering by keyword: $Keyword"
        }

        5 {
            # Export filtered results to CSV or JSON
            Write-Host "Exporting Results"
            $ExportFormat = Read-Host "Enter export format (CSV/JSON)"
            if ($ExportFormat -eq 'CSV') {
                $Logs | Export-Csv "filteredLogs.csv" -NoTypeInformation
                Write-Host "Logs exported to filteredLogs.csv" -ForegroundColor Green
            } elseif ($ExportFormat -eq 'JSON') {
                $Logs | ConvertTo-Json | Set-Content "filteredLogs.json"
                Write-Host "Logs exported to filteredLogs.json" -ForegroundColor Green
            } else {
                Write-Host "Invalid format selected. Please choose either CSV or JSON." -ForegroundColor Red
            }
        }

        6 {
            # Exit program
            Write-Host "Exiting the Log File Analyzer. Goodbye!" -ForegroundColor Green
            break
        }

        default {
            Write-Host "Invalid choice. Please select a valid option." -ForegroundColor Red
        }
    }

} while ($Choice -ne 6)
