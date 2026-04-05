param(
    [string]$LubanClient = "./tools/luban/Luban.Client.dll",
    [string]$InputDataDir = "./data-authoring/excel",
    [string]$DefineFile = "./data-authoring/luban/defines/__root__.xml",
    [string]$OutputDataDir = "./three-kingdoms-simulator/data/generated/190"
)

$tables = "Scenario,Character,Faction,City"

Write-Host "Exporting Phase 1 smoke sample JSON via Luban..."
Write-Host "Input workbook dir: $InputDataDir"
Write-Host "Define file: $DefineFile"
Write-Host "Output data dir: $OutputDataDir"

$command = @(
    "dotnet", $LubanClient,
    "-j", "cfg",
    "--",
    "--define_file", $DefineFile,
    "--input_data_dir", $InputDataDir,
    "--output_data_dir", $OutputDataDir,
    "--output:tables", $tables,
    "--service", "all",
    "--gen_types", "data_json2"
)

Write-Host "Command:"
Write-Host ($command -join " ")
Write-Host ""
Write-Host "Expected outputs under three-kingdoms-simulator/data/generated/190:"
Write-Host "- scenario_190_smoke.json"
Write-Host "- characters.json"
Write-Host "- factions.json"
Write-Host "- cities.json"
Write-Host "- index.json"

if (Test-Path $LubanClient) {
    & $command[0] $command[1] $command[2] $command[3] $command[4] $command[5] $command[6] $command[7] $command[8] $command[9] $command[10] $command[11] $command[12] $command[13] $command[14] $command[15]
} else {
    Write-Warning "Luban client not found at $LubanClient. Install it, then rerun this script from repo root."
}
