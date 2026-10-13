# Exp 13 – GPG Email Security (Linux): remaining steps

`./run.sh` -> **13** already did the setup and a full demo run with two test users
(student = sender, recipient) under `~/gpg_lab`. Your real `~/.gnupg` was not touched.
The terminal output of that run is what you can screenshot (Sections 4–13 of your doc).

## What is left for you (manual run, for a record with your own passphrase)

Open **two terminals**. Terminal 1 = Student, Terminal 2 = Recipient.

```bash
# Terminal 1
mkdir -p ~/gpg_manual/student/.gnupg ~/gpg_manual/recipient && chmod 700 ~/gpg_manual/student/.gnupg
export GNUPGHOME=~/gpg_manual/student/.gnupg ; cd ~/gpg_manual/student
# Terminal 2
mkdir -p ~/gpg_manual/recipient/.gnupg && chmod 700 ~/gpg_manual/recipient/.gnupg
export GNUPGHOME=~/gpg_manual/recipient/.gnupg ; cd ~/gpg_manual/recipient
```

| # | Where | Command | Screenshot |
|---|-------|---------|-----------|
| 1 | both | `gpg --version` | yes |
| 2 | T1 | `gpg --full-generate-key` -> **1** (RSA and RSA), **3072**, validity **0**, Name `Student`, Email `student@example.com`, `O`, set passphrase | yes |
| 3 | T2 | same, Name `Recipient`, Email `recipient@example.com` | yes |
| 4 | T1 | `gpg --list-keys` and `gpg --list-secret-keys` | yes |
| 5 | T1 | `gpg --armor --export student@example.com > student_public_key.asc` then `cat student_public_key.asc` | yes |
| 6 | T2 | `gpg --armor --export recipient@example.com > recipient_public_key.asc` | |
| 7 | any | copy each `.asc` into the other folder with `cp` | |
| 8 | T1 | `gpg --import recipient_public_key.asc` then `gpg --list-keys` | yes |
| 9 | T1 | `nano email.txt` (paste sample email below; Ctrl+O, Enter, Ctrl+X) | yes |
| 10 | T1 | `gpg --armor --encrypt --recipient recipient@example.com email.txt` (if asked "Use this key anyway?" type `y`) | yes |
| 11 | T1 | `ls` and `cat email.txt.asc` | yes |
| 12 | T1 | `cp email.txt.asc ~/gpg_manual/recipient/` | |
| 13 | T2 | `gpg --decrypt email.txt.asc` (enter Recipient passphrase) | yes |
| 14 | T1 | `nano signed_email.txt`, then `gpg --armor --detach-sign signed_email.txt` | yes |
| 15 | T1 | `cp signed_email.txt signed_email.txt.asc ~/gpg_manual/recipient/` | |
| 16 | T2 | `gpg --import student_public_key.asc` | |
| 17 | T2 | `gpg --verify signed_email.txt.asc signed_email.txt` -> **Good signature** | yes |
| 18 | T2 | *(bonus)* `echo hacked >> signed_email.txt` and verify again -> **BAD signature** | yes |

Sample email for step 9:
```
Subject: Confidential Project Discussion

Dear Team,

This is a confidential message for our project discussion.
The contents of this message should only be accessible
to the intended recipient.

Regards,
Student
```

## Quick fixes
- "Use this key anyway?" is normal for a new imported key: answer `y`, or add `--trust-model always`.
- No passphrase prompt over SSH: `export GPG_TTY=$(tty)`.
- "unsafe permissions on homedir": `chmod 700 $GNUPGHOME`.
- `Good signature ... [unknown]` is expected (key not certified); mention it in the report.
- Key IDs and timestamps differ from the doc's sample output: use your own.
