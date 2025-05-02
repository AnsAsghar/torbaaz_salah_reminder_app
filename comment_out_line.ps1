# PowerShell script to comment out the problematic bigLargeIcon line

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
    
    foreach ($line in $lines) {
        # Check if this is the problematic line
        if ($line -match "bigPictureStyle\.bigLargeIcon\(null\);") {
            # Comment out the line
            $newLines += "      // $line  // Commented out to avoid ambiguous reference error"
        } else {
            $newLines += $line
        }
    }
    
    # Write the modified content back to the file
    Set-Content -Path $filePath -Value $newLines
    
    Write-Host "Successfully commented out the problematic line!"
    Write-Host "Now run 'flutter clean' and then 'flutter build apk --release'"
} else {
    Write-Host "File not found at: $filePath"
    Write-Host "Please check if the flutter_local_notifications package is installed correctly."
}
