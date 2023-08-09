# Create Work folders
mkdir  %HOMEDRIVE%%HOMEPATH%\git

winget upgrade --all

# Basics
winget install --id=AgileBits.1Password -e
winget install --id=SlackTechnologies.Slack -e
winget install --id=Spotify.Spotify -e
winget install --id=9N1F85V9T8BN -e --accept-package-agreements #Windowds 365

# Data
winget install --id=Microsoft.AzureDataStudio -e
winget install --id=Microsoft.PowerBI -e

# Dev
winget install --id=Git.Git -e --accept-package-agreements --accept-source-agreements 
winget install --id=Microsoft.VisualStudioCode -e  
winget install --id=Microsoft.PowerShell -e  
winget install --id=JanDeDobbeleer.OhMyPosh -e  
winget install --id=Microsoft.Bicep -e
winget install --id=Postman.Postman -e
winget install --id=Amazon.AWSCLI -e

# If physical
winget install --id=Elgato.StreamDeck -e  
winget install --id=Elgato.ControlCenter -e 

# If private
winget install --id=9NKSQGP7F2NH -e  #WhatsApp
winget install --id=OpenWhisperSystems.Signal