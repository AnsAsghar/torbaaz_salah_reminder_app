# PowerShell script to find and comment out ALL instances of bigLargeIcon

$packagePath = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\flutter_local_notifications-14.1.5\android\src\main\java\com\dexterous\flutterlocalnotifications"
$filePath = "$packagePath\FlutterLocalNotificationsPlugin.java"

# Check if the file exists
if (Test-Path $filePath) {
    Write-Host "Found the file at: $filePath"
    
    # Create a backup
    Copy-Item $filePath "$filePath.bak"
    Write-Host "Created backup at: $filePath.bak"
    
    # Read the file content
    $content = Get-Content $filePath -Raw
    
    # Count occurrences of the problematic pattern
    $pattern = "bigPictureStyle\.bigLargeIcon\("
    $matches = [regex]::Matches($content, $pattern)
    $count = $matches.Count
    
    Write-Host "Found $count occurrences of bigLargeIcon method calls"
    
    # Replace all occurrences with commented out versions
    $newContent = $content -replace "bigPictureStyle\.bigLargeIcon\(([^)]+)\);", "// bigPictureStyle.bigLargeIcon(`$1); // Commented out to fix build error"
    
    # Write the modified content back to the file
    Set-Content -Path $filePath -Value $newContent
    
    Write-Host "Successfully commented out ALL bigLargeIcon method calls!"
    Write-Host "Now run 'flutter clean' and then 'flutter build apk --release'"
} else {
    Write-Host "File not found at: $filePath"
    Write-Host "Please check if the flutter_local_notifications package is installed correctly."
}
