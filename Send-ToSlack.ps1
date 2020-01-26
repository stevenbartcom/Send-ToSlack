# =======================================================
# NAME: Send-ToSlack.ps1
# AUTHOR: Steven BART, StevenBart.com
# DATE: 25/01/2020
#
# VERSION 3.2
# COMMENTS_FR: Ce script permet d'envoyer des messages dans Slack, par exemple à la fin d'une séquence de tâche.
# COMMENTS_EN: This script allows you to send messages in Slack, for example at the end of a task sequence.
#
# USAGE: PowerShell.exe -ExecutionPolicy Bypass -File .\Send-ToSlack.ps1 -Status (0|1)
# =======================================================


# Paramètre -Status pour le script / Parameter -Status for the script
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Status
)

# URI du Webhook Slack / URI of the Slack Webhook
$uri = 'https://hooks.slack.com/...'

# Logo du message / Logo for the message  - Format PNG / GIF / JPEG
$logo = 'https://...'

# Pied du message / Footer of the message
$footer = 'StevenBart.com - Send-ToSlack'
$footerIcon = 'https://...'

# Lecture de variables de la TS / Reading TS variables
# Décommenter pour utiliser, toutes les variables disponibles ici sont disponible: https://docs.microsoft.com/fr-fr/configmgr/osd/understand/task-sequence-variables
# Uncommented to use, all the variables available here are available : https://docs.microsoft.com/en-us/configmgr/osd/understand/task-sequence-variables
#
# $SCCM_ENV = New-Object -COMObject Microsoft.SMS.TSEnvironment
# $SMSTSCurrentActionName = $SCCM_ENV.Value("_SMSTSCurrentActionName") # Récupération de l'action problèmatique
# $SMSTSLastActionRetCode = $SCCM_ENV.Value("_SMSTSLastActionRetCode") # Récupération du code d'erreur

# Récupération via WMI, Registre ou Powershell
$DateTime = Get-Date -Format g # Date et heure
$Manufacturer = (Get-WmiObject -Class Win32_BIOS).Manufacturer # Fabricant de l'ordinateur / Computer Manufacturer
$Model = (Get-WmiObject -Class Win32_ComputerSystem).Model # Modèle de l'ordinateur/ Computer Model
[string]$SerialNumber = (Get-WmiObject win32_bios).SerialNumber # N° de série de l'ordinateur / Serial Number
$ComputerName = (Get-WmiObject -Class Win32_ComputerSystem).Name # Nom du PC de l'ordinateur / Computer Name
$IP= (Get-WmiObject win32_Networkadapterconfiguration | Where-Object{ $_.ipaddress -notlike $null }).IPaddress | Select-Object -First 1 # Adresse IP
$WinBuild = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").ReleaseId # Windows Build

# Envois du message sur Slack / Send the message on Slack
function Send-ToSlack {
  Invoke-RestMethod -uri $uri -Method Post -body $body -ContentType "application/json; charset=utf-8"
}

# $Status = 1 -> Installation réussie / Successful installation
# Création du JSON / JSON Creation
if ($Status -eq "1") {
  $body = ConvertTo-Json -Depth 4 @{
    text = "Installation reussie / Successful installation"
      attachments = @(
        @{
          color = 'good'
          footer = $footer
          footer_icon = $footerIcon
          fields = @(
            @{
              title  = 'Termine a / Finished at'
              value = $DateTime
              short = 'true'
            },
            @{
              title  = 'Windows Build'
              value = $WinBuild
              short = 'true'
            },
            @{
              title  = 'Ordinateur / Computer'
              value = "$Manufacturer $Model  ($SerialNumber)"
              short = 'true'
            }
          )
        }
      )
    }
  Send-ToSlack # Envois à Slack / Send to Slack
} # Fin IF / End IF

# $Status = 0 -> Installation échouée / Failed installation
# Création du JSON / JSON Creation
if ($Status -eq "0") {
  $body = ConvertTo-Json -Depth 4 @{
    text = "Erreur Installation / Failed installation"
      attachments = @(
        @{
          color = 'danger'
          footer = $footer
          footer_icon = $footerIcon
          fields = @(
            @{
              title  = 'Erreur a / Failed at'
              value = $DateTime
              short = 'true'
            },
            @{
              title  = 'Ordinateur / Computer'
              value = "$Manufacturer $Model  ($SerialNumber)"
              short = 'true'
            },
            @{
              title  = 'IP'
              value = $IP
              short = 'true'
            }
          )
        }
      )
    }
  Send-ToSlack # Envois à Slack / Send to Slack
} # Fin IF / End IF

