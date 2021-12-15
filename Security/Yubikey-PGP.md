# Yubikey PGP config
Follow [these instructions](https://github.com/drduh/YubiKey-Guide).

Download simple installer from [GnuPG site](https://gnupg.org/download/index.html), because Gpg4win does not work without admin privileges.
## Changing of Yubikey
```bash
gpg-connect-agent "scd serialno" "learn --force" /bye
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