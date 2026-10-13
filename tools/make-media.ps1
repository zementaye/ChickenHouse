<#
.SYNOPSIS
  Turns one video clip into everything the Doro Bet site needs.

.DESCRIPTION
  Writes into the site's media folder:
    media\hero.mp4, media\hero.webm   silent loop (1080p max, no sound)
    media\hero-poster.jpg             still shown while the video loads
    media\img\still-1.jpg ... still-7.jpg   4:5 stills (skip with -SkipStills)

  The loop is made seamless: the last -Crossfade seconds are blended into the
  first ones, so the video does not jump when it restarts.

.EXAMPLE
  powershell -ExecutionPolicy Bypass -File .\tools\make-media.ps1 -InputFile "D:\Chrome_Downloads\clip.mp4" -Start 0 -Length 7 -SkipStills

.NOTES
  Needs ffmpeg and ffprobe on PATH. Install once with:  winget install Gyan.FFmpeg
  then close and reopen PowerShell.
  The clip must be at least Start + Length + Crossfade seconds long.
#>
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$InputFile,
    [double]$Start = 0,
    [double]$Length = 6,
    [double]$Crossfade = 1,
    [switch]$SkipStills
)

$ErrorActionPreference = 'Stop'
$inv = [System.Globalization.CultureInfo]::InvariantCulture

function Num([double]$x) { return $x.ToString('0.###', $inv) }

foreach ($tool in 'ffmpeg', 'ffprobe') {
    if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
        Write-Host "$tool was not found. Install it with:  winget install Gyan.FFmpeg" -ForegroundColor Red
        Write-Host "Then close PowerShell, open it again and re-run this script." -ForegroundColor Red
        exit 1
    }
}

if (-not (Test-Path -LiteralPath $InputFile)) {
    Write-Host "Cannot find the video: $InputFile" -ForegroundColor Red
    exit 1
}
$InputFile = (Resolve-Path -LiteralPath $InputFile).Path

if ($Length -lt 5 -or $Length -gt 8) {
    Write-Host "Note: a hero loop of 5-8 seconds works best (you asked for $Length)." -ForegroundColor Yellow
}

$durText = (& ffprobe -v error -show_entries format=duration -of csv=p=0 $InputFile | Select-Object -First 1).Trim()
$dur = [double]::Parse($durText, $inv)

# the crossfade needs extra footage after the loop; shrink it if the clip is too short
$room = $dur - $Start - $Length
if ($room -lt $Crossfade) { $Crossfade = [Math]::Max(0, $room) }
if ($Crossfade -lt 0.3) { $Crossfade = 0 }

# media folder sits next to the tools folder
$root = Split-Path -Parent $PSScriptRoot
$out  = Join-Path $root 'media'
$img  = Join-Path $out 'img'
New-Item -ItemType Directory -Force -Path $img | Out-Null

$ss = Num $Start
$L  = Num $Length

if ($Crossfade -gt 0) {
    $F  = Num $Crossfade
    $LF = Num ($Length + $Crossfade)
    $inT = $LF
    $fc = "[0:v]scale='min(1920,iw)':-2,fps=30,split=2[a][b];" +
          "[a]trim=0:$L,setpts=PTS-STARTPTS[A];" +
          "[b]trim=${L}:${LF},setpts=PTS-STARTPTS,format=yuva420p,fade=t=out:st=0:d=${F}:alpha=1[B];" +
          "[A][B]overlay=eof_action=pass,format=yuv420p"
    $filterArgs = @('-filter_complex', $fc)
    Write-Host "Seamless loop: $F s crossfade."
} else {
    $inT = $L
    $filterArgs = @('-vf', "scale='min(1920,iw)':-2,fps=30,format=yuv420p")
    Write-Host "Plain cut (no crossfade: clip too short or -Crossfade 0)."
}

function Run-Ffmpeg([string[]]$ffArgs) {
    & ffmpeg @ffArgs
    if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed (exit code $LASTEXITCODE)." }
}

# 1. Hero loop
Write-Host "1/3  Cutting hero.mp4 ..."
Run-Ffmpeg (@('-y', '-loglevel', 'error', '-ss', $ss, '-t', $inT, '-i', $InputFile) + $filterArgs +
            @('-an', '-c:v', 'libx264', '-crf', '26', '-preset', 'slow', '-movflags', '+faststart',
              (Join-Path $out 'hero.mp4')))

Write-Host "     Cutting hero.webm (slower) ..."
Run-Ffmpeg (@('-y', '-loglevel', 'error', '-ss', $ss, '-t', $inT, '-i', $InputFile) + $filterArgs +
            @('-an', '-c:v', 'libvpx-vp9', '-crf', '36', '-b:v', '0',
              (Join-Path $out 'hero.webm')))

# 2. Poster: a frame from the middle of the loop
Write-Host "2/3  Saving hero-poster.jpg ..."
$mid = Num ($Start + $Length / 2)
Run-Ffmpeg @('-y', '-loglevel', 'error', '-ss', $mid, '-i', $InputFile, '-frames:v', '1', '-q:v', '3',
             '-vf', "scale='min(1920,iw)':-2",
             (Join-Path $out 'hero-poster.jpg'))

# 3. Seven 4:5 stills spread across the whole clip
if ($SkipStills) {
    Write-Host "3/3  Skipping stills (-SkipStills)."
} else {
    Write-Host "3/3  Saving 7 stills ..."
    for ($i = 1; $i -le 7; $i++) {
        $at = Num ($dur * $i / 8)
        Run-Ffmpeg @('-y', '-loglevel', 'error', '-ss', $at, '-i', $InputFile, '-frames:v', '1', '-q:v', '3',
                     '-vf', "crop='min(iw,ih*4/5)':ih,scale=1000:-2",
                     (Join-Path $img "still-$i.jpg"))
    }
    Write-Host "Open media\img, pick the best stills and rename them to:"
    Write-Host "  classics.jpg  fried.jpg  grilled.jpg  wings.jpg  burger.jpg  sides.jpg  kitchen.jpg"
}

Write-Host ""
Write-Host "Done. Files are in $out" -ForegroundColor Green
