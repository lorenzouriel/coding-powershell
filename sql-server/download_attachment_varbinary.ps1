# --------------------------------------------
# Script: download_attachment_varbinary.ps1
# Usage : powershell.exe -ExecutionPolicy Bypass -File "download_attachment.ps1" 10737
# --------------------------------------------

# --- RECEBE O NÚMERO DA RN COMO ARGUMENTO ---
$relatedNumber = $args[0]

if (-not $relatedNumber) {
    Write-Host "Erro: Nenhuma RN informada. Encerrando script."
    exit 1
}

# --- CONFIGURAÇÕES ---
$server = ".\SQLEXPRESS"
$database = "database"
$rootFolder = "C:\Anexos"
# $user = "DOMAIN\user"
# $password = "password"

# --- CONEXÃO COM SQL SERVER ---
Add-Type -AssemblyName System.Data
$connectionString = "Server=$server;Database=$database;Integrated Security=True;Encrypt=False;"
$connection = New-Object System.Data.SqlClient.SqlConnection $connectionString
$connection.Open()

# --- QUERY PARA PEGAR ANEXOS ---
$query = @"
SELECT 
    s.[related_number],
    a.[type],
    a.[description],
    a.[attachment],
    a.[extension]
FROM [number] s
JOIN [attachment] a ON (s.[id] = a.[number])
WHERE s.[related_number] = $relatedNumber
"@

# --- EXECUTA QUERY ---
$command = $connection.CreateCommand()
$command.CommandText = $query
$reader = $command.ExecuteReader()

# --- CRIA PASTA PARA A RN---
$osFolder = Join-Path $rootFolder "OS $relatedNumber"
if (!(Test-Path -Path $osFolder)) {
    New-Item -ItemType Directory -Path $osFolder | Out-Null
    Write-Host "Criada pasta: $osFolder"
}

# --- FAZ O DOWNLOAD DOS ANEXOS ---
while ($reader.Read()) {
    $description = $reader["description"]
    $extension = $reader["extension"]
    $fileData = $reader["attachment"]

    # Adiciona o ponto à extensão se não existir
    if (-not [string]::IsNullOrEmpty($extension) -and -not $extension.StartsWith('.')) {
        $extension = '.' + $extension
    }

    # Caso a extensão esteja vazia, opcionalmente defina um padrão, ex:
    if ([string]::IsNullOrEmpty($extension)) {
        $extension = ".dat"
    }

    $safeName = ($description -replace '[\\\/:*?"<>|]', '_')
    $fileName = "$safeName$extension"
    $filePath = Join-Path $osFolder $fileName

    [System.IO.File]::WriteAllBytes($filePath, $fileData)
    Write-Host "Salvo: $filePath"
}

# --- FECHA CONEXÃO ---
$reader.Close()
$connection.Close()

Write-Host "Download concluído para RN $relatedNumber"