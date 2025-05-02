# PowerShell script to add namespace to flutter_local_notifications plugin

$packagePath = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev\flutter_local_notifications-13.0.0\android"
$filePath = "$packagePath\build.gradle"

# Check if the file exists
if (Test-Path $filePath) {
    Write-Host "Found the file at: $filePath"
    
    # Create a backup
    Copy-Item $filePath "$filePath.bak"
    Write-Host "Created backup at: $filePath.bak"
    
    # Read the file content
    $content = Get-Content $filePath -Raw
    
    # Check if android block exists
    if ($content -match "android\s*\{") {
        # Check if namespace already exists
        if ($content -match "namespace\s+") {
            Write-Host "Namespace already exists in the file."
        } else {
            # Add namespace to the android block
            $newContent = $content -replace "android\s*\{", "android {`n    namespace 'com.dexterous.flutterlocalnotifications'"
            
            # Write the modified content back to the file
            Set-Content -Path $filePath -Value $newContent
            
            Write-Host "Successfully added namespace to the file!"
        }
    } else {
        Write-Host "Could not find android block in the file."
    }
    
    Write-Host "Now run 'flutter clean' and then 'flutter build apk --release'"
} else {
    Write-Host "File not found at: $filePath"
    Write-Host "Please check if the flutter_local_notifications package is installed correctly."
}
