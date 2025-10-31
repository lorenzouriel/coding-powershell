# Load the EnterpriseServices assembly manually
Add-Type -AssemblyName "System.EnterpriseServices"

# Now create the Publish object
$publish = New-Object System.EnterpriseServices.Internal.Publish

# Install your assembly into the GAC
$assemblyPath = "C:\repos\integration-enel\ETL\assemblies\Newtonsoft.Json.dll"
$publish.GacInstall($assemblyPath)

# (Optional) Verify
$publish.GacList("Newtonsoft.Json")
