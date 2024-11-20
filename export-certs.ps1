# Output directory where certificates will be saved
$outputDir = "C:\ExportedCerts" # Update this path if needed

# Create the output directory if it does not exist
if (-not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Force -Path $outputDir
}

# Get all the certificate store locations: LocalMachine and CurrentUser
$locations = @("Cert:\LocalMachine", "Cert:\CurrentUser")

foreach ($location in $locations) {
    # Get all the stores under each location
    $stores = Get-ChildItem -Path $location

    foreach ($store in $stores) {
        # Get the store name and generate a list of certificates
        $storeName = $store.PSChildName
        $certificates = Get-ChildItem -Path "$location\$storeName"

        foreach ($cert in $certificates) {
            try {
                # Create a filename based on the store and certificate thumbprint
                $certThumbprint = $cert.Thumbprint
                $certSubject = $cert.Subject -replace '[^a-zA-Z0-9]', '_'
                $outputFileName = "${storeName}_${certThumbprint}.der"
                $outputFilePath = Join-Path -Path $outputDir -ChildPath $outputFileName

                # Export the certificate as a DER encoded file
                Write-Output "Exporting certificate from store '$storeName': Thumbprint '$certThumbprint'"
                [System.IO.File]::WriteAllBytes($outputFilePath, $cert.RawData)

                Write-Output "Successfully saved certificate to '$outputFilePath'"
            }
            catch {
                Write-Warning "Failed to export certificate '$certThumbprint' from store '$storeName'. Error: $_"
            }
        }
    }
}

Write-Output "Certificate export completed."
