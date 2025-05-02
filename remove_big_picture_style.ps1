# PowerShell script to remove the bigPictureStyle completely

$packagePath = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\flutter_local_notifications-14.1.5\android\src\main\java\com\dexterous\flutterlocalnotifications"
$filePath = "$packagePath\FlutterLocalNotificationsPlugin.java"

# Check if the file exists
if (Test-Path $filePath) {
    Write-Host "Found the file at: $filePath"
    
    # Create a backup
    Copy-Item $filePath "$filePath.bak"
    Write-Host "Created backup at: $filePath.bak"
    
    # Read the file content line by line
    $lines = Get-Content $filePath
    
    # Create a new array to store modified lines
    $newLines = @()
    
    # Flag to track if we're in the bigPictureStyle section
    $skipBigPictureSection = $false
    
    foreach ($line in $lines) {
        # Check if this is the start of the bigPictureStyle section
        if ($line -match "if \(largeIcon == null\) \{") {
            $skipBigPictureSection = $true
        }
        
        # If we're not in the section to skip, add the line
        if (-not $skipBigPictureSection) {
            $newLines += $line
        }
        
        # Check if this is the end of the bigPictureStyle section
        if ($skipBigPictureSection -and $line -match "\}") {
            $skipBigPictureSection = $false
        }
    }
    
    # Write the modified content back to the file
    Set-Content -Path $filePath -Value $newLines
    
    Write-Host "Successfully removed the bigPictureStyle section!"
    Write-Host "Now run 'flutter clean' and then 'flutter build apk --release'"
} else {
    Write-Host "File not found at: $filePath"
    Write-Host "Please check if the flutter_local_notifications package is installed correctly."
}
