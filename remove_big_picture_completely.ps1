# PowerShell script to completely remove BigPictureStyle implementation

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
    
    # Variables to track if we're in the BigPictureStyle section
    $inBigPictureStyleMethod = $false
    $braceCount = 0
    
    foreach ($line in $lines) {
        # Check if this is the start of the BigPictureStyle method
        if ($line -match "private Notification\.BigPictureStyle handleBigPictureStyle") {
            $inBigPictureStyleMethod = $true
            $braceCount = 0
            
            # Add a stub method instead
            $newLines += "  private Notification.BigPictureStyle handleBigPictureStyle("
            $newLines += "      Notification.Builder builder, Map<String, Object> styleDictionary) {"
            $newLines += "    // Method implementation removed to fix build error"
            $newLines += "    return new Notification.BigPictureStyle(builder);"
            $newLines += "  }"
            
            continue
        }
        
        # If we're in the BigPictureStyle method, count braces to know when it ends
        if ($inBigPictureStyleMethod) {
            if ($line -match "{") {
                $braceCount++
            }
            if ($line -match "}") {
                $braceCount--
                if ($braceCount <= 0) {
                    $inBigPictureStyleMethod = $false
                }
            }
            # Skip all lines in the method
            continue
        }
        
        # For all other lines, add them as is
        $newLines += $line
    }
    
    # Write the modified content back to the file
    Set-Content -Path $filePath -Value $newLines
    
    Write-Host "Successfully replaced the BigPictureStyle implementation with a stub!"
    Write-Host "Now run 'flutter clean' and then 'flutter build apk --release'"
} else {
    Write-Host "File not found at: $filePath"
    Write-Host "Please check if the flutter_local_notifications package is installed correctly."
}
