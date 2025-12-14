[CmdletBinding()]
param(
    [string]$ConfigPad = ".\config.json",

    [ValidateSet("Demo","Run")]
    [string]$Modus = "Demo",
# Hoeveel pomodoro-werkblokken
    [int]$AantalPomodoros = 4,

    [switch]$GeenPopup
)

# -----------------------------
# Config lezen
# -----------------------------
function Lees-Config {
    param([string]$Pad)

# Controle voor bestand
    if (-not (Test-Path $Pad -PathType Leaf)) {
        throw "Configbestand niet gevonden: $Pad"
    }
#Conversie van JSON naar object
    return Get-Content $Pad -Raw | ConvertFrom-Json
}

# -----------------------------
# Logging
# -----------------------------
function Schrijf-Log {
    param(
        [string]$Bestand,
        [string]$Bericht
    )

    $regel = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - $Bericht"
    Add-Content -Path $Bestand -Value $regel
    Write-Host $regel
}

# -----------------------------
# Popup tonen (Windows)
# -----------------------------
function Toon-Popup {
    param(
        [string]$Titel,
        [string]$Tekst
    )

    if ($GeenPopup) { return }

    try {
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        [System.Windows.Forms.MessageBox]::Show($Tekst, $Titel) | Out-Null
    }
    catch {
        Write-Host "[MELDING] $Tekst"
    }
}

# -----------------------------
# Tijd omzetten
# -----------------------------
function Minuten-Naar-Seconden {
    param([int]$Minuten)

    if ($Modus -eq "Demo") {
        return 3   # demo = 3 seconden
    }

    return $Minuten * 60
}

# -----------------------------
# Aftelklok
# -----------------------------
function Aftellen {
    param(
        [string]$Label,
        [int]$Seconden
    )

    for ($i = $Seconden; $i -gt 0; $i--) {
        $m = [math]::Floor($i / 60)
        $s = $i % 60
          # `r overschrijft dezelfde regel, -NoNewline voorkomt nieuwe lijn
        Write-Host -NoNewline "`r$Label - resterend $("{0:00}:{1:00}" -f $m,$s)   "
        Start-Sleep -Seconds 1
    }
    Write-Host ""
}

# -----------------------------
# Werkblok
# -----------------------------
function Start-Werkblok {
    param(
        [int]$Nummer,
        [int]$Minuten,
        [string]$Log
    )

    Schrijf-Log $Log "Start werkblok $Nummer ($Minuten minuten)"
    Aftellen -Label "FOCUS $Nummer" -Seconden (Minuten-Naar-Seconden $Minuten)
    Schrijf-Log $Log "Einde werkblok $Nummer"

    Toon-Popup -Titel "Pomodoro" -Tekst "Werkblok $Nummer afgerond. Tijd voor pauze."
}

# -----------------------------
# Pauzeblok
# -----------------------------
function Start-Pauze {
    param(
        [string]$Type,
        [int]$Minuten,
        [string]$Log
    )

    Schrijf-Log $Log "Start $Type pauze ($Minuten minuten)"
    Toon-Popup -Titel "Pomodoro" -Tekst "$Type pauze gestart."
    Aftellen -Label "$Type PAUZE" -Seconden (Minuten-Naar-Seconden $Minuten)
    Schrijf-Log $Log "Einde $Type pauze"

    Toon-Popup -Titel "Pomodoro" -Tekst "Pauze voorbij. Terug focussen."
}

# -----------------------------
# Hoofdprogramma
# -----------------------------
Clear-Host
$config = Lees-Config -Pad $ConfigPad
$logPad = Join-Path (Get-Location) $config.logBestand

Write-Host "================================="
Write-Host " $($config.titel)"
Write-Host " Modus: $Modus"
Write-Host " Pomodoro's: $AantalPomodoros"
Write-Host "================================="
Write-Host ""

Schrijf-Log $logPad "Pomodoro sessie gestart"

for ($i = 1; $i -le $AantalPomodoros; $i++) {

    Start-Werkblok -Nummer $i -Minuten $config.werkMinuten -Log $logPad

    if (($i % $config.langePauzeNa) -eq 0) {
        Start-Pauze -Type "LANGE" -Minuten $config.langePauzeMinuten -Log $logPad
    }
    # i=1 → 1%4=1 → korte pauze
    # i=2 → 2%4=2 → korte pauze
    # i=3 → 3%4=3 → korte pauze
    # i=4 → 4%4=0 → lange pauze
    else {
        Start-Pauze -Type "KORTE" -Minuten $config.kortePauzeMinuten -Log $logPad
    }
}

Schrijf-Log $logPad "Pomodoro sessie beëindigd"
Toon-Popup -Titel "Pomodoro" -Tekst "Studie sessie voltooid!"
