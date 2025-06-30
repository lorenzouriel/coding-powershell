# Caminho para a pasta que contém os assemblies
$assemblyDir = "C:\Users\assemblies"

# Caminho para o gacutil.exe (exemplo: caso ele esteja na pasta do Visual Studio)
$gacutilPath = "C:\Program Files (x86)\Microsoft SDKs\Windows\v10.0A\bin\NETFX 4.8 Tools"

# Adicionar o caminho do gacutil ao PATH
$env:PATH += ";$gacutilPath"

# Iterar por cada arquivo .dll na pasta
Get-ChildItem -Path $assemblyDir -Filter *.dll | ForEach-Object {
    $assemblyPath = $_.FullName
    Write-Host "Registrando $assemblyPath no GAC..."
    
    # Executar gacutil
    $gacutilResult = & gacutil.exe -i $assemblyPath
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Sucesso: $assemblyPath registrado no GAC."
    } else {
        Write-Host "Erro: Falha ao registrar $assemblyPath no GAC."
    }
}