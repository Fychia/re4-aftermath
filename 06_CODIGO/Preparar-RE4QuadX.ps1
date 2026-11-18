# RE4 Aftermath - diagnostic and safe extraction workspace for RE4 UHD / QuadX.
# Does NOT modify Steam files, alter QuadX config, or guess SMD mappings.
[CmdletBinding()]
param(
    [string]$GameRoot = 'F:\Steam\steamapps\common\Resident Evil 4',
    [string]$ProjectRoot = 'F:\RE4_MOD_PROJECT',
    [ValidatePattern('^r[0-9a-fA-F]{3}$')][string]$Room = 'r101',
    [string]$LfsExe = 'F:\Tools\re4-research_build-1.2a\re4lfs.exe',
    [string]$DatUdasExe = '',
    [switch]$SkipExtraction
)
$ErrorActionPreference = 'Stop'
$report = New-Object System.Collections.Generic.List[string]
function Log([string]$message) {
    Write-Host $message
    [void]$report.Add($message)
}
function Find-Tool([string]$name) {
    $toolsRoot = 'F:\Tools'
    if (-not (Test-Path -LiteralPath $toolsRoot)) { return $null }
    $all = @(Get-ChildItem -LiteralPath $toolsRoot -Filter '*.exe' -File -Recurse -ErrorAction SilentlyContinue)
    return ($all | Where-Object { $_.Name -match $name } | Select-Object -First 1 -ExpandProperty FullName)
}
function Unpack-Lfs([string]$source, [string]$target) {
    if (Test-Path -LiteralPath $target) {
        Log "[OK] Descompactado ja existe: $target"
        return
    }
    if ($SkipExtraction) { Log "[PENDENTE] Extracao desativada: $source"; return }
    Log "[LFS] Extraindo $source"
    & $LfsExe $source
    if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $target)) {
        throw "re4lfs nao gerou a saida esperada: $target (exit code $LASTEXITCODE)"
    }
    Log "[OK] $target"
}
function Unpack-Container([string]$file, [string]$index, [string]$folder) {
    if (Test-Path -LiteralPath $index) {
        if (@(Get-ChildItem -LiteralPath $folder -File -ErrorAction SilentlyContinue).Count -gt 0) {
            Log "[OK] Container ja extraido: $file"
            return
        }
    }
    if ($SkipExtraction) { Log "[PENDENTE] Extracao desativada: $file"; return }
    if (-not $DatUdasExe) { Log "[PENDENTE] Ferramenta DAT/UDAS nao encontrada para $file"; return }
    Log "[DAT/UDAS] Extraindo $file (a ferramenta pode abrir console proprio)."
    # These community tools may ask for input. Keep interactive so errors are visible.
    $proc = Start-Process -FilePath $DatUdasExe -ArgumentList ('"' + $file + '"') -PassThru -Wait
    if ($proc.ExitCode -ne 0) { Log "[AVISO] DAT/UDAS retornou codigo $($proc.ExitCode): $file" }
    if (Test-Path -LiteralPath $index) { Log "[OK] Indice criado: $index" }
    else { Log "[AVISO] Nao localizei indice: $index" }
}
try {
    $gameBIO4 = Join-Path $GameRoot 'BIO4'
    $stage = Join-Path $gameBIO4 'St1'
    if (-not (Test-Path -LiteralPath $stage)) { throw "Pasta da Steam inexistente: $stage" }
    if (-not (Test-Path -LiteralPath $LfsExe)) { throw "re4lfs.exe nao encontrado: $LfsExe" }
    $base = Join-Path $ProjectRoot ('02_MAPAS\' + $Room)
    $sourceCopy = Join-Path $base 'originais'
    $working = Join-Path $base 'extracao_separada'
    $reportFolder = Join-Path $ProjectRoot '07_TESTES\logs'
    foreach ($dir in @($base,$sourceCopy,$working,$reportFolder)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
    Log "=== RE4 QuadX | Diagnostico e preparacao | $Room ==="
    Log "Jogo: $GameRoot"
    Log "Projeto: $ProjectRoot"
    if (-not $DatUdasExe) { $DatUdasExe = Find-Tool 'DATUDAS.*\.exe$' }
    if ($DatUdasExe -and (Test-Path -LiteralPath $DatUdasExe)) { Log "DAT/UDAS: $DatUdasExe" }
    else { $DatUdasExe = ''; Log '[AVISO] Ferramenta DAT/UDAS nao identificada automaticamente.' }
    $archiveNames = @($Room + '.udas.lfs', $Room + '.udas')
    $matched = @(Get-ChildItem -LiteralPath $stage -File -ErrorAction SilentlyContinue | Where-Object {
        $_.Name -match ('^' + [regex]::Escape($Room) + '(_[0-9a-fA-F]{2})?\.(udas|dat)(\.lfs)?$')
    })
    if ($matched.Count -eq 0) { Log "[AVISO] Nenhum UDAS/DAT do $Room na pasta $stage" }
    foreach ($source in $matched) {
        $copyPath = Join-Path $sourceCopy $source.Name
        if (-not (Test-Path -LiteralPath $copyPath)) {
            Copy-Item -LiteralPath $source.FullName -Destination $copyPath
            Log "[BACKUP] $copyPath"
        }
        $workPath = Join-Path $working $source.Name
        if (-not (Test-Path -LiteralPath $workPath)) { Copy-Item -LiteralPath $source.FullName -Destination $workPath }
    }
    $compressed = @(Get-ChildItem -LiteralPath $working -Filter '*.lfs' -File -ErrorAction SilentlyContinue)
    foreach ($file in $compressed) {
        $output = $file.FullName.Substring(0,$file.FullName.Length - 4)
        Unpack-Lfs $file.FullName $output
    }
    $containers = @(Get-ChildItem -LiteralPath $working -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in @('.udas','.dat') })
    foreach ($file in $containers) {
        $folder = Join-Path $working $file.BaseName
        $index = Join-Path $working ($file.BaseName + '.idxj')
        Unpack-Container $file.FullName $index $folder
    }
    # Also inspect pre-existing user workspace (from previous manual extractions).
    $preExtracted = Join-Path $base $Room
    $smds = @()
    foreach ($dir in @($working,$preExtracted)) {
        if (Test-Path -LiteralPath $dir) {
            $smds += @(Get-ChildItem -LiteralPath $dir -Recurse -File -Filter '*.SMD' -ErrorAction SilentlyContinue)
        }
    }
    Log "[INFO] Arquivos SMD encontrados nas copias de trabalho: $($smds.Count)"
    foreach ($smd in ($smds | Select-Object -First 30)) { Log ('  ' + $smd.FullName) }
    $expected = Join-Path (Join-Path $stage $Room) '0000.SMD'
    if (Test-Path -LiteralPath $expected) {
        Log "[OK] Arquivo de geometria esperado pelo QuadX existe: $expected"
    } else {
        Log "[PENDENTE] QuadX ainda procura: $expected"
        Log '[IMPORTANTE] Os SMD do UDAS nao devem ser renomeados automaticamente para 0000.SMD.'
        Log '[IMPORTANTE] A geometria que QuadX procura pode vir de recursos DAT ou ImagePack; confirmar origem antes de instalar.'
    }
    $quadRoom = Join-Path $stage $Room
    Log "[INFO] Diretorio de leitura QuadX: $quadRoom"
    if (Test-Path -LiteralPath $quadRoom) {
        foreach ($item in @(Get-ChildItem -LiteralPath $quadRoom -File -ErrorAction SilentlyContinue | Select-Object -First 30)) { Log ('  ' + $item.Name) }
    }
    Log '[SEGURANCA] Nenhum arquivo da Steam foi alterado.'
    $stamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $reportFile = Join-Path $reportFolder ("quadx-$Room-$stamp.txt")
    $report | Out-File -LiteralPath $reportFile -Encoding UTF8
    Write-Host "`nRelatorio: $reportFile" -ForegroundColor Cyan
    if (-not (Test-Path -LiteralPath $expected)) {
        Write-Host 'RESULTADO: extraidos/diagnosticados os recursos possiveis; falta confirmar o layout exato do 0000.SMD do QuadX.' -ForegroundColor Yellow
    } else {
        Write-Host 'RESULTADO: arquivo 0000.SMD presente; tente abrir o cenario e confira novos erros.' -ForegroundColor Green
    }
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
