# PowerShell script to downgrade flutter_local_notifications package

# Check if pubspec.yaml exists
if (Test-Path "pubspec.yaml") {
    Write-Host "Found pubspec.yaml"
    
    # Create a backup
    Copy-Item "pubspec.yaml" "pubspec.yaml.bak"
    Write-Host "Created backup at: pubspec.yaml.bak"
    
    # Read the file content line by line
    $lines = Get-Content "pubspec.yaml"
    
    # Create a new array to store modified lines
    $newLines = @()
    
    foreach ($line in $lines) {
        # Check if this is the flutter_local_notifications dependency line
        if ($line -match "flutter_local_notifications:") {
            # Replace with downgraded version
            $newLines += "  flutter_local_notifications: ^13.0.0  # Downgraded to avoid bigLargeIcon ambiguity"
        } else {
            $newLines += $line
        }
    }
    
    # Write the modified content back to the file
    Set-Content -Path "pubspec.yaml" -Value $newLines
    
    Write-Host "Successfully downgraded flutter_local_notifications package to version 13.0.0!"
    Write-Host "Now run 'flutter pub get' and then 'flutter build apk --release'"
} else {
    Write-Host "pubspec.yaml not found in the current directory!"
    Write-Host "Please run this script from your Flutter project root directory."
}
