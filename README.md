# Automatisering-van-een-taak-Pomodoro-HusnuCimen
Scripting &amp; Automation Taak 
# Pomodoro Studie Timer (PowerShell)

Dit PowerShell-script automatiseert de Pomodoro-studiemethode.

## Functionaliteiten
- Automatische werk- en pauzeblokken
- Korte pauzes na elke pomodoro
- Lange pauze na een instelbaar aantal pomodoro’s
- Console countdown
- Pop-up meldingen
- Logging naar bestand
- Externe configuratie via JSON

## Bestanden
- `Pomodoro.ps1` – hoofdscript
- `config.json` – configuratiebestand
- `pomodoro.log` – logbestand (automatisch aangemaakt)

## Gebruik

### Demo-modus (snelle demonstratie)
```powershell
.\Pomodoro.ps1 -Modus Demo -AantalPomodoros 4

