# Run as Administrator
# NOTE: 
# To run you may need to run this first
# > Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Write-Output "Scanning for services starting with 'HP'..."

# Try-catch each service query to avoid PermissionDenied errors
$allServices = @()
try {
    $allServices = Get-Service -ErrorAction Stop
} catch {
    Write-Warning "Some services could not be queried: $_"
}

# Filter services that start with "HP" (either Name or DisplayName)
$hpServices = $allServices | Where-Object {
    $_.Name -like "HP*" -or $_.DisplayName -like "HP*"
}

foreach ($service in $hpServices) {
    Write-Output "`nProcessing: $($service.Name) - $($service.DisplayName)"

    try {
        Stop-Service -Name $service.Name -Force -ErrorAction Stop
        Write-Output "  ✔ Stopped"
    } catch {
        Write-Warning "  ✘ Could not stop $($service.Name): $_"
    }

    try {
        Set-Service -Name $service.Name -StartupType Disabled -ErrorAction Stop
        Write-Output "  ✔ Disabled"
    } catch {
        Write-Warning "  ✘ Could not disable $($service.Name): $_"
    }
}

# Optional: Remove HP-related installed programs
# Comment this block out if you don't want to uninstall anything
# Write-Output "`nSearching for installed HP programs..."

# try {
#     $hpPrograms = Get-WmiObject -Class Win32_Product -ErrorAction Stop | Where-Object {
#         $_.Name -like "HP*" -or $_.Name -like "*Hewlett-Packard*"
#     }

#     foreach ($program in $hpPrograms) {
#         Write-Output "Uninstalling: $($program.Name)"
#         try {
#             $program.Uninstall() | Out-Null
#             Write-Output "  ✔ Uninstalled"
#         } catch {
#             Write-Warning "  ✘ Could not uninstall $($program.Name): $_"
#         }
#     }
# } catch {
#     Write-Warning "Could not retrieve HP programs: $_"
# }

# Write-Output "`n✅ Done. You may want to reboot the system."
