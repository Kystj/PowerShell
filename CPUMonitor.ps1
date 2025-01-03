# Set your threshold
$threshold = 50
$logFile = "C:\Logs\Reports\CpuPerformanceReport.txt"  # Specify where to save the log file

# Get current CPU usage
$cpuUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples.CookedValue

# Log the current CPU usage and time
$logMessage = "$(Get-Date): CPU usage is at $cpuUsage%"
Add-Content -Path $logFile -Value $logMessage

# Check if CPU usage exceeds threshold
if ($cpuUsage -ge $threshold) {
    # Alert by log
    $alertMessage = "$(Get-Date): ALERT! CPU usage is at $cpuUsage%, which is above the threshold."
    Add-Content -Path $logFile -Value $alertMessage
    
    # Optional: Trigger a sound (beep)
    [console]::beep(1000, 500)  # Beep sound
    
    # Optionally, you can also use a balloon notification here
    # $balloon = New-Object -ComObject WScript.Shell
    # $balloon.Popup($alertMessage, 0, "CPU Alert", 0x30)

    # THIS SHOULD RETIRVE USAGE INFO IF ABOVE TRHRESHOLD

} else {
    # Log normal CPU usage state
    Add-Content -Path $logFile -Value "$(Get-Date): CPU usage is within acceptable range."
}

# Exit once the task is done
Exit
