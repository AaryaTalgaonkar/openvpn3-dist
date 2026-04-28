$drivers = pnputil /enum-drivers

$matches = $drivers | Select-String "Published Name|Provider Name"

$current = $null

foreach ($line in $matches) {
    if ($line -match "Published Name:\s+(oem\d+\.inf)") {
        $current = $matches[1]
    }
    if ($line -match "Provider Name:\s+TAP-Windows Provider V9") {
        if ($current) {
            pnputil /delete-driver $current /uninstall /force
        }
    }
}
