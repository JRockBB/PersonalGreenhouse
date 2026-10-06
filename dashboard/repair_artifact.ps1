$ErrorActionPreference = 'Stop'
$artifact = 'C:\Users\jmurp\.julia\artifacts\e52e2e20e817dea175c440c5f2946ff60e59df9f'
$url = 'https://github.com/JuliaBinaryWrappers/MUMPS_seq_jll.jl/releases/download/MUMPS_seq-v500.900.0+0/MUMPS_seq.v500.900.0.x86_64-w64-mingw32-libgfortran5.tar.gz'
$archive = Join-Path $env:TEMP 'mumps_seq_500900.tar.gz'
Write-Host 'Downloading MUMPS artifact...'
Invoke-WebRequest -Uri $url -OutFile $archive -UseBasicParsing
Write-Host 'Replacing incomplete artifact...'
if (Test-Path $artifact) { Remove-Item -LiteralPath $artifact -Recurse -Force }
New-Item -ItemType Directory -Path $artifact | Out-Null
& tar.exe -xzf $archive -C $artifact
if ($LASTEXITCODE -ne 0) { throw "tar failed with exit code $LASTEXITCODE" }
Remove-Item $archive -Force
$required = Join-Path $artifact 'bin\libcmumps.dll'
if (-not (Test-Path $required)) { throw "Expected DLL was not extracted: $required" }
Write-Host "Artifact restored: $required"
