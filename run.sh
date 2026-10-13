#!/usr/bin/env bash
# Lab experiments launcher: ./run.sh  (or ./run.sh 7)
# Runs the chosen experiment once and leaves the output on screen.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Real shell tracing: bash itself prints each command as it executes it
PS4='$ '

# ============================ Exp 7: RSA ============================
exp7() {
    cat > "$PWD/exp7_rsa.py" <<'PYEOF'
import math

def gcd(a, b):
    while b != 0:
        a, b = b, a % b
    return a

def mod_inverse(e, phi):
    """Finds d such that (d * e) % phi == 1 using extended Euclidean algorithm"""
    d_old, d_new = 0, 1
    r_old, r_new = phi, e
    while r_new != 0:
        quotient = r_old // r_new
        r_old, r_new = r_new, r_old - quotient * r_new
        d_old, d_new = d_new, d_old - quotient * d_new
    if r_old > 1:
        return None
    if d_old < 0:
        d_old += phi
    return d_old

def generate_keypair(p, q):
    n = p * q
    phi = (p - 1) * (q - 1)
    e = 3
    while gcd(e, phi) != 1:
        e += 2
    d = mod_inverse(e, phi)
    return ((e, n), (d, n), phi)

def encrypt(public_key, plaintext):
    e, n = public_key
    return [pow(ord(char), e, n) for char in plaintext]

def decrypt(private_key, ciphertext):
    d, n = private_key
    return "".join(chr(pow(c, d, n)) for c in ciphertext)

if __name__ == "__main__":
    p = 61
    q = 53
    print(f"1. Prime Numbers Selected: p = {p}, q = {q}")
    public_key, private_key, phi = generate_keypair(p, q)
    n = public_key[1]
    print(f"2. Calculated Modulus (n) = {n}")
    print(f"3. Calculated Euler's Totient phi(n) = {phi}")
    print(f"4. Public Key (e, n): {public_key}")
    print(f"5. Private Key (d, n): {private_key}")
    message = "RSA"
    print(f"\nOriginal Message: {message}")
    encrypted_msg = encrypt(public_key, message)
    print(f"Encrypted Ciphertext: {encrypted_msg}")
    decrypted_msg = decrypt(private_key, encrypted_msg)
    print(f"Decrypted Message: {decrypted_msg}")
PYEOF
    echo "Created exp7_rsa.py in $PWD"
    echo "Run it with:  python3 exp7_rsa.py"
}

# ======================= Exp 8: Diffie-Hellman =======================
exp8() {
    cat > "$PWD/exp8_diffie_hellman.py" <<'PYEOF'
p = 23
g = 5
a = 6
b = 15
print(f"1. Public Prime Number (p): {p}")
print(f"2. Public Primitive Root (g): {g}")
print(f"3. Alice's Private Key (a): {a}")
print(f"4. Bob's Private Key (b): {b}")
A = pow(g, a, p)
B = pow(g, b, p)
print(f"5. Alice's Public Key (A): {A}")
print(f"6. Bob's Public Key (B): {B}")
alice_shared_key = pow(B, a, p)
bob_shared_key = pow(A, b, p)
print(f"7. Alice's Shared Secret Key: {alice_shared_key}")
print(f"8. Bob's Shared Secret Key: {bob_shared_key}")
if alice_shared_key == bob_shared_key:
    print("Key Exchange Successful: Shared keys match.")
else:
    print("Key Exchange Failed: Shared keys do not match.")
PYEOF
    echo "Created exp8_diffie_hellman.py in $PWD"
    echo "Run it with:  python3 exp8_diffie_hellman.py"
}

# ============================ Exp 9: MD5 ============================
exp9() {
    cat > "$PWD/exp9_md5.py" <<'PYEOF'
import hashlib
data = "Hello, World!"
md5_hash = hashlib.md5(data.encode("utf-8")).hexdigest()
print(f"MD5 Hash: {md5_hash}")
PYEOF
    echo "Created exp9_md5.py in $PWD"
    echo "Run it with:  python3 exp9_md5.py"
}

# ============================ Exp 13: GPG ============================
exp13() {
    rm -rf ~/gpg_lab
    mkdir -p ~/gpg_lab/student/.gnupg ~/gpg_lab/recipient/.gnupg
    chmod 700 ~/gpg_lab/student/.gnupg ~/gpg_lab/recipient/.gnupg
    cd ~ || return

    if ! command -v gpg >/dev/null 2>&1; then
        sudo apt update
        sudo apt install gnupg -y
    fi

    GNUPGHOME=~/gpg_lab/student/.gnupg
    set -x
    # ---------- sender: student ----------
    gpg --version
    GNUPGHOME=~/gpg_lab/student/.gnupg
    cd ~/gpg_lab/student
    printf '%%no-protection\nKey-Type: RSA\nKey-Length: 3072\nKey-Usage: sign\nSubkey-Type: RSA\nSubkey-Length: 3072\nSubkey-Usage: encrypt\nName-Real: Student\nName-Email: student@example.com\nExpire-Date: 0\n%%commit\n' > student_key.params
    gpg --batch --generate-key student_key.params
    gpg --list-keys
    gpg --list-secret-keys
    gpg --armor --export student@example.com > student_public_key.asc
    cat student_public_key.asc

    # ---------- recipient ----------
    GNUPGHOME=~/gpg_lab/recipient/.gnupg
    cd ~/gpg_lab/recipient
    printf '%%no-protection\nKey-Type: RSA\nKey-Length: 3072\nKey-Usage: sign\nSubkey-Type: RSA\nSubkey-Length: 3072\nSubkey-Usage: encrypt\nName-Real: Recipient\nName-Email: recipient@example.com\nExpire-Date: 0\n%%commit\n' > recipient_key.params
    gpg --batch --generate-key recipient_key.params
    gpg --armor --export recipient@example.com > recipient_public_key.asc
    cp recipient_public_key.asc ~/gpg_lab/student/
    cp ~/gpg_lab/student/student_public_key.asc .

    # ---------- student: import recipient key, write + encrypt email ----------
    GNUPGHOME=~/gpg_lab/student/.gnupg
    cd ~/gpg_lab/student
    gpg --import recipient_public_key.asc
    gpg --list-keys
    printf 'Subject: Confidential Project Discussion\n\nDear Team,\n\nThis is a confidential message for our project discussion.\nThe contents of this message should only be accessible\nto the intended recipient.\n\nRegards,\nStudent\n' > email.txt
    cat email.txt
    gpg --armor --trust-model always --encrypt --recipient recipient@example.com email.txt
    ls
    cat email.txt.asc
    cp email.txt.asc ~/gpg_lab/recipient/

    # ---------- recipient: decrypt ----------
    GNUPGHOME=~/gpg_lab/recipient/.gnupg
    cd ~/gpg_lab/recipient
    gpg --decrypt email.txt.asc

    # ---------- student: sign ----------
    GNUPGHOME=~/gpg_lab/student/.gnupg
    cd ~/gpg_lab/student
    printf 'Subject: Signed Message\n\nThis message is signed by Student to prove authenticity and integrity.\n' > signed_email.txt
    gpg --armor --detach-sign signed_email.txt
    ls
    cp signed_email.txt signed_email.txt.asc ~/gpg_lab/recipient/

    # ---------- recipient: verify ----------
    GNUPGHOME=~/gpg_lab/recipient/.gnupg
    cd ~/gpg_lab/recipient
    gpg --import student_public_key.asc
    gpg --verify signed_email.txt.asc signed_email.txt
    { set +x; } 2>/dev/null

    gpgconf --homedir ~/gpg_lab/student/.gnupg   --kill gpg-agent 2>/dev/null
    gpgconf --homedir ~/gpg_lab/recipient/.gnupg --kill gpg-agent 2>/dev/null
    unset GNUPGHOME
    cat > "$SCRIPT_DIR/README_exp13_GPG.md" <<'README_END'
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
README_END
}

# ======================== Exp 16: Wireshark ========================
exp16() {
    mkdir -p ~/wireshark_lab
    cd ~ || return

    IFACE="$(ip route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')"
    LOCALIP="$(ip -4 addr show dev "$IFACE" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"

    set -x
    sudo apt update
    echo 'wireshark-common wireshark-common/install-setuid boolean true' | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt install wireshark tshark curl dnsutils -y
    sudo usermod -aG wireshark "$USER"
    wireshark --version
    ip -br addr
    { set +x; } 2>/dev/null

    # fall back to the first tshark interface if no default route was found
    if [ -z "$IFACE" ]; then
        IFACE="$(tshark -D 2>/dev/null | head -n1 | sed -E 's/^[0-9]+\. ([^ ]+).*/\1/')"
        LOCALIP="$(ip -4 addr show dev "$IFACE" 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 | head -n1)"
    fi
    [ -z "$LOCALIP" ] && LOCALIP="192.168.1.1"

    set -x
    # ---------- capture all traffic while generating some ----------
    sudo tshark -i "$IFACE" -a duration:20 -w ~/wireshark_lab/full_capture.pcapng &
    sleep 3
    ping -c 4 8.8.8.8
    nslookup example.com
    nslookup wireshark.org
    curl -sI http://example.com
    curl -sI https://example.com
    wait
    sudo chown "$USER":"$USER" ~/wireshark_lab/full_capture.pcapng

    # ---------- display filters ----------
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "dns" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "http" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "tcp" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "udp" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "icmp" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "ip.addr == $LOCALIP" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "ip.src == $LOCALIP" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "ip.dst == $LOCALIP" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "tcp.port == 443" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "dns && ip" | head -n 5
    tshark -r ~/wireshark_lab/full_capture.pcapng -Y "tcp.flags.syn == 1" | head -n 5

    # ---------- capture filter ----------
    sudo tshark -i "$IFACE" -f "port 53" -a duration:8 -w ~/wireshark_lab/dns_only_capture.pcapng &
    sleep 3
    nslookup example.com
    nslookup wireshark.org
    wait
    sudo chown "$USER":"$USER" ~/wireshark_lab/dns_only_capture.pcapng
    tshark -r ~/wireshark_lab/dns_only_capture.pcapng | head -n 8
    ls -l ~/wireshark_lab
    { set +x; } 2>/dev/null

    cat > "$SCRIPT_DIR/README_exp16_Wireshark.md" <<'README_END'
# Exp 16 – Wireshark Packet Filters: remaining steps

`./run.sh` -> **16** already installed Wireshark/tshark, recorded two sample captures
(`~/wireshark_lab/full_capture.pcapng` and `dns_only_capture.pcapng`) and ran the lab's
display filters from the terminal. **Log out and back in once** so the `wireshark` group
lets you capture live without sudo.

## What is left for you (GUI work + screenshots)

### 1. Open the capture (Section 5)
```bash
wireshark -r ~/wireshark_lab/full_capture.pcapng &
```
*(Live capture instead: run `wireshark`, double-click your interface, open a website, press the red Stop button.)*

### 2. Display filters (Section 6) – type in the filter bar, press Enter, clear between filters
| Filter | Shows |
|--------|-------|
| `dns` | DNS |
| `http` | plain HTTP (from `curl http://example.com`) |
| `tcp` / `udp` | TCP / UDP |
| `icmp` | ping |
| `ip.addr == <your IP>` | to or from your IP |
| `ip.src == <your IP>` / `ip.dst == <your IP>` | from / to your IP |
| `tcp.port == 443` | HTTPS |
| `dns && ip` | DNS and IPv4 |
| `tcp.flags.syn == 1` | TCP connection starts |

Your IP: `ip -4 addr`. Green filter bar = valid syntax, red = error. Take one screenshot per filter.

### 3. Capture filters (Section 7)
Set **before** capturing, in "Enter a capture filter" on the Wireshark start screen, then double-click the interface.
Try `host 8.8.8.8`, `port 53`, `tcp`, `net 192.168.1.0/24` (use your own network). Generate traffic (`nslookup example.com`), stop, screenshot.

### 4. Trace one packet (Sections 8–9)
1. Apply `dns`, click a packet.
2. Expand Frame, Ethernet II, Internet Protocol, UDP, Domain Name System in Packet Details; note addresses, ports, query name, Query vs Response.
3. Look at Packet Bytes (hex + ASCII).
4. Clear the filter. Repeat for `tcp` (flags) and `icmp`.

### 5. Report
Observation/Result: list the filters used and how the packet list narrowed; use your own screenshots/counts.

## Troubleshooting
- "No permission to capture": log out/in, or `sudo dpkg-reconfigure wireshark-common` (Yes) and `sudo usermod -aG wireshark $USER`.
- No interface: check `ip link`.
- `http` empty: most sites are HTTPS; use `curl http://example.com` or an `http://` site.
- No GUI: `tshark -r ~/wireshark_lab/full_capture.pcapng -Y dns`.
README_END
}

# ============================== Menu ==============================
choice="$1"
if [ -z "$choice" ]; then
    echo "Select experiment:"
    echo "  7  - RSA Algorithm"
    echo "  8  - Diffie-Hellman Algorithm"
    echo "  9  - MD5 Hash"
    echo "  13 - GPG Tool (email security)"
    echo "  16 - Wireshark Packet Filters"
    read -rp "Enter experiment number: " choice
fi

case "$choice" in
    7)  exp7  ;;
    8)  exp8  ;;
    9)  exp9  ;;
    13) exp13 ;;
    16) exp16 ;;
    *)  echo "Invalid experiment number: $choice" ;;
esac
