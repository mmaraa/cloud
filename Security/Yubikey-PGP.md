# Yubikey PGP config
Follow [these instructions](https://github.com/drduh/YubiKey-Guide).

Download simple installer from [GnuPG site](https://gnupg.org/download/index.html), because Gpg4win does not work without admin privileges.

Download also [Yubikey smartcard minidriver](https://www.yubico.com/support/download/smart-card-drivers-tools/).

Import public key to target computer.
## Changing of Yubikey
```bash
gpg-connect-agent.exe "16844970" "learn --force" /bye
```
## Turn on touch requirements
```powershell
.\ykman.exe openpgp keys set-touch aut on
.\ykman.exe openpgp keys set-touch enc on
.\ykman.exe openpgp keys set-touch sig on
```

## Key management
```bash
# List keys
gpg --list-keys

# List secret keys
gpg --list-secret-keys

# Cleanup secret key
gpg --delete-secret-key "User Name"

# Cleanup key
gpg --delete-key "User Name"

# Import key
gpg --import mykeyfile.gpg
```

## Configure git for PGP-keys
```bash
#Path to executable
git config --global gpg.program 'C:\Program Files (x86)\gnupg\bin\gpg.exe' 

#Set Key ID that you are using
git config --global user.signingkey 'KEYID'

#Set auto sign on
git config commit.gpgsign true

```
## SSH Authentication
```bash
#List available public keys
gpg --list-public-keys

#Export SSH public key
gpg --export-ssh-key <PublicKeyID>

#If not working restart gpg-connect-agent
gpg-connect-agent killagent /bye
gpg-connect-agent /bye

```