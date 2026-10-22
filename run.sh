#!/usr/bin/env bash
# Lab experiments launcher: ./run.sh  (or ./run.sh 7)
# 1-10  -> creates the Python file for you to run
# 13-17 -> runs the setup/demo commands and writes a README with the remaining steps
# Runs the chosen experiment once and leaves the output on screen.
# Clear the terminal once at the start, before anything else runs
clear 2>/dev/null || printf '\033c'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Everything is created inside  ~/Desktop/practical  (never in system/root folders)
if [ "$(id -u)" -eq 0 ] && [ -n "${SUDO_USER:-}" ]; then
    HOME="$(getent passwd "$SUDO_USER" | cut -d: -f6)"
fi
DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null)"
if [ -z "$DESKTOP_DIR" ] || [ "$DESKTOP_DIR" = "$HOME" ]; then DESKTOP_DIR="$HOME/Desktop"; fi
PRAC="$DESKTOP_DIR/practical"
mkdir -p "$PRAC" && cd "$PRAC" || { echo "Cannot create $PRAC"; exit 1; }

# Real shell tracing: bash itself prints each command as it executes it
PS4='$ '

# ======================= Python experiments (1-10): generate the .py file =======================
exp1() {
    cat > "$PWD/exp1_euclidean.py" <<'PYEOF'
# Experiment 1: Implement Euclidean Algorithm
def gcd(a, b):
    while b != 0:
        a, b = b, a % b
    return a

# Input from the user
try:
    num1 = int(input("Enter first number: "))
    num2 = int(input("Enter second number: "))

    # Calculate GCD
    gcd_result = gcd(num1, num2)

    # Display output
    print(f"\nThe GCD of {num1} and {num2} is: {gcd_result}")

except ValueError:
    print("Please enter valid integers.")
PYEOF
    echo "Created exp1_euclidean.py in $PWD"
    echo "Run it with:  python3 exp1_euclidean.py"
}

exp2() {
    cat > "$PWD/exp2_brute_force.py" <<'PYEOF'
# Experiment 2: Implement Brute Force attack
import string
import itertools

def brute_force_password(target_password):
    # Characters to try: lowercase, uppercase, and digits
    chars = string.ascii_letters + string.digits
    attempts = 0

    # Try combinations of increasing lengths
    for length in range(1, 9):
        for guess in itertools.product(chars, repeat=length):
            attempts += 1
            guess_str = "".join(guess)

            # Print the current attempt
            print(f"Attempt {attempts}: {guess_str}")

            # Check if the guess matches the target password
            if guess_str == target_password:
                print(f"\nPassword found: '{guess_str}'")
                print(f"Total attempts: {attempts}")
                return

    print("\nPassword not found within length limit.")

# Input from the user
try:
    user_password = input("Enter a 3 digit password to crack: ")
    print("\n--- Starting Brute Force Attack ---")
    brute_force_password(user_password)

except Exception as e:
    print(f"An error occurred: {e}")
PYEOF
    echo "Created exp2_brute_force.py in $PWD"
    echo "Run it with:  python3 exp2_brute_force.py"
}

exp3() {
    cat > "$PWD/exp3_playfair.py" <<'PYEOF'
# Experiment 3: Implement Playfair cipher encryption technique
def prepare_key_matrix(key):
    # Prepare key string by removing duplicates and replacing J with I
    key = key.upper().replace("J", "I")
    seen = set()
    key_chars = []
    for char in key:
        if char.isalpha() and char not in seen:
            seen.add(char)
            key_chars.append(char)

    # Fill the remaining matrix with the rest of the alphabet
    alphabet = "ABCDEFGHIKLMNOPQRSTUVWXYZ"
    for char in alphabet:
        if char not in seen:
            seen.add(char)
            key_chars.append(char)

    # Create 5x5 matrix
    matrix = [key_chars[i:i+5] for i in range(0, 25, 5)]
    return matrix

def find_position(matrix, char):
    for r in range(5):
        for c in range(5):
            if matrix[r][c] == char:
                return r, c
    return None

def encrypt_playfair(plain_text, key):
    matrix = prepare_key_matrix(key)

    # Clean and prepare plaintext
    text = plain_text.upper().replace("J", "I")
    cleaned_text = ""
    for char in text:
        if char.isalpha():
            cleaned_text += char

    # Break into pairs (digraphs) and insert filler 'X' if necessary
    digraphs = []
    i = 0
    while i < len(cleaned_text):
        char1 = cleaned_text[i]
        if i + 1 < len(cleaned_text):
            char2 = cleaned_text[i+1]
            if char1 == char2:
                digraphs.append(char1 + "X")
                i += 1
            else:
                digraphs.append(char1 + char2)
                i += 2
        else:
            digraphs.append(char1 + "X")
            i += 1

    # Encrypt digraphs
    cipher_text = ""
    for pair in digraphs:
        r1, c1 = find_position(matrix, pair[0])
        r2, c2 = find_position(matrix, pair[1])

        if r1 == r2:  # Same row
            cipher_text += matrix[r1][(c1 + 1) % 5] + matrix[r2][(c2 + 1) % 5]
        elif c1 == c2:  # Same column
            cipher_text += matrix[(r1 + 1) % 5][c1] + matrix[(r2 + 1) % 5][c2]
        else:  # Rectangle swap
            cipher_text += matrix[r1][c2] + matrix[r2][c1]

    return cipher_text

# Input from the user
try:
    plaintext_input = input("Enter the plaintext to encrypt: ")
    key_input = input("Enter the secret key: ")

    cipher_result = encrypt_playfair(plaintext_input, key_input)

    print(f"\nEncrypted Ciphertext: {cipher_result}")

except Exception as e:
    print(f"An error occurred: {e}")
PYEOF
    echo "Created exp3_playfair.py in $PWD"
    echo "Run it with:  python3 exp3_playfair.py"
}

exp4() {
    cat > "$PWD/exp4_hill.py" <<'PYEOF'
# Experiment 4: Implement Hill cipher encryption technique
def encrypt_hill(plain_text, key_string):
    # Convert key string to a 2x2 matrix
    key_string = key_string.upper()
    key_matrix = [
        [ord(key_string[0]) - 65, ord(key_string[1]) - 65],
        [ord(key_string[2]) - 65, ord(key_string[3]) - 65]
    ]

    # Clean plaintext (uppercase, letters only)
    cleaned_text = "".join([char.upper() for char in plain_text if char.isalpha()])

    # Pad with 'X' if the length is odd
    if len(cleaned_text) % 2 != 0:
        cleaned_text += "X"

    cipher_text = ""

    # Process in blocks of 2 (2x1 vectors)
    for i in range(0, len(cleaned_text), 2):
        p1 = ord(cleaned_text[i]) - 65
        p2 = ord(cleaned_text[i+1]) - 65

        # Vector matrix multiplication: C = (K * P) mod 26
        c1 = (key_matrix[0][0] * p1 + key_matrix[0][1] * p2) % 26
        c2 = (key_matrix[1][0] * p1 + key_matrix[1][1] * p2) % 26

        cipher_text += chr(c1 + 65) + chr(c2 + 65)

    return cipher_text

# Input from the user
try:
    plaintext_input = input("Enter a plaintext (letters only): ")
    key_input = input("Enter a 4-letter secret key (e.g., HILL): ")

    if len(key_input) != 4 or not key_input.isalpha():
        print("Error: Key must be exactly 4 alphabetic characters long.")
    else:
        cipher_result = encrypt_hill(plaintext_input, key_input)
        print(f"\nEncrypted Ciphertext: {cipher_result}")

except Exception as e:
    print(f"An error occurred: {e}")
PYEOF
    echo "Created exp4_hill.py in $PWD"
    echo "Run it with:  python3 exp4_hill.py"
}

exp5() {
    cat > "$PWD/exp5_rail_fence.py" <<'PYEOF'
# Experiment 5: Implement a transposition cipher: Rail Fence Cipher
def encrypt_rail_fence(text, rails):
    # Create a 2D matrix filled with placeholders
    fence = [['\n' for _ in range(len(text))] for _ in range(rails)]

    # Determine the direction of movement
    direction_down = False
    row, col = 0, 0

    # Place characters in the matrix in a zig-zag pattern
    for i in range(len(text)):
        if (row == 0) or (row == rails - 1):
            direction_down = not direction_down

        fence[row][col] = text[i]
        col += 1

        row += 1 if direction_down else -1

    # Read the matrix row-by-row to construct ciphertext
    result = []
    for i in range(rails):
        for j in range(len(text)):
            if fence[i][j] != '\n':
                result.append(fence[i][j])

    return "".join(result)

# Input from the user
try:
    plaintext_input = input("Enter the plaintext: ")
    rails_input = int(input("Enter number of rails: "))

    if rails_input <= 1:
        print("Number of rails must be greater than 1.")
    else:
        cipher_result = encrypt_rail_fence(plaintext_input, rails_input)
        print(f"\nEncrypted Ciphertext: {cipher_result}")

except ValueError:
    print("Please enter a valid integer for rails.")
except Exception as e:
    print(f"An error occurred: {e}")
PYEOF
    echo "Created exp5_rail_fence.py in $PWD"
    echo "Run it with:  python3 exp5_rail_fence.py"
}

exp6() {
    cat > "$PWD/exp6_columnar_transposition.py" <<'PYEOF'
# Experiment 6: Transposition cipher: Encrypt using column-based rearrangement
import math

def encrypt_columnar_transposition(text, key):
    # Determine column order based on alphabetical order of key letters
    key_sorted = sorted(list(enumerate(key)), key=lambda x: x[1])

    num_cols = len(key)
    num_rows = math.ceil(len(text) / num_cols)

    # Pad text with underscores if length is not a multiple of column count
    padded_text = text.ljust(num_rows * num_cols, '_')

    # Fill the grid row by row
    grid = [padded_text[i:i + num_cols] for i in range(0, len(padded_text), num_cols)]

    # Read column by column based on sorted key order
    cipher_text = ""
    for col_index, _ in key_sorted:
        for row in grid:
            cipher_text += row[col_index]

    return cipher_text

# Input from the user
try:
    plaintext_input = input("Enter the plaintext: ")
    key_input = input("Enter the key : ")

    if not key_input:
        print("Key cannot be empty.")
    else:
        cipher_result = encrypt_columnar_transposition(plaintext_input, key_input)
        print(f"\nEncrypted Ciphertext: {cipher_result}")

except Exception as e:
    print(f"An error occurred: {e}")
PYEOF
    echo "Created exp6_columnar_transposition.py in $PWD"
    echo "Run it with:  python3 exp6_columnar_transposition.py"
}

exp7() {
    cat > "$PWD/exp7_rsa.py" <<'PYEOF'
# Experiment 7: Implement RSA Algorithm
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
        return None  # e and phi are not coprime
    if d_old < 0:
        d_old += phi
    return d_old

def generate_keypair(p, q):
    n = p * q
    phi = (p - 1) * (q - 1)

    # Choose e such that 1 < e < phi and gcd(e, phi) == 1
    e = 3
    while gcd(e, phi) != 1:
        e += 2

    # Calculate d
    d = mod_inverse(e, phi)

    return ((e, n), (d, n), phi)

def encrypt(public_key, plaintext):
    e, n = public_key
    # Encrypt each character using C = (M^e) mod n
    cipher = [pow(ord(char), e, n) for char in plaintext]
    return cipher

def decrypt(private_key, ciphertext):
    d, n = private_key
    # Decrypt each character using M = (C^d) mod n
    plain = [chr(pow(char, d, n)) for char in ciphertext]
    return ''.join(plain)

# Driver Program
if __name__ == "__main__":
    # Step 1: Select two prime numbers
    p = 61
    q = 53

    print(f"1. Prime Numbers Selected: p = {p}, q = {q}")

    # Step 2 & 3: Key generation
    public_key, private_key, phi = generate_keypair(p, q)
    n = public_key[1]

    print(f"2. Calculated Modulus (n) = {n}")
    print(f"3. Calculated Euler's Totient phi(n) = {phi}")
    print(f"4. Public Key (e, n): {public_key}")
    print(f"5. Private Key (d, n): {private_key}")

    # Message input
    message = "RSA"
    print(f"\nOriginal Message: {message}")

    # Step 4: Encryption
    encrypted_msg = encrypt(public_key, message)
    print(f"Encrypted Ciphertext: {encrypted_msg}")

    # Step 5: Decryption
    decrypted_msg = decrypt(private_key, encrypted_msg)
    print(f"Decrypted Message: {decrypted_msg}")
PYEOF
    echo "Created exp7_rsa.py in $PWD"
    echo "Run it with:  python3 exp7_rsa.py"
}

exp8() {
    cat > "$PWD/exp8_diffie_hellman.py" <<'PYEOF'
# Experiment 8: Implement Diffie-Hellman Key Exchange Algorithm

# Step 1: Publicly agreed prime number and primitive root
p = 23
g = 5

# Step 2: Private keys chosen by Alice and Bob
a = 6
b = 15

print(f"1. Public Prime Number (p): {p}")
print(f"2. Public Primitive Root (g): {g}")
print(f"3. Alice's Private Key (a): {a}")
print(f"4. Bob's Private Key (b): {b}")

# Step 3: Calculate public keys
A = pow(g, a, p)  # Alice's public key
B = pow(g, b, p)  # Bob's public key

print(f"5. Alice's Public Key (A): {A}")
print(f"6. Bob's Public Key (B): {B}")

# Step 4: Calculate the shared secret key
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

exp9() {
    cat > "$PWD/exp9_md5.py" <<'PYEOF'
# Experiment 9: Generate hash value for input data using MD5
import hashlib

# Input data
data = "Hello, World!"

# Generate MD5 hash
# 1. Encode string to bytes
# 2. Pass bytes to hashlib.md5()
# 3. Get the hexadecimal representation
md5_hash = hashlib.md5(data.encode("utf-8")).hexdigest()

print(f"MD5 Hash: {md5_hash}")
PYEOF
    echo "Created exp9_md5.py in $PWD"
    echo "Run it with:  python3 exp9_md5.py"
}

exp10() {
    cat > "$PWD/exp10_sha1.py" <<'PYEOF'
# Experiment 10: Generate hash value for input data using SHA-1
import hashlib

# Input data
data = "Hello, World!"

# Generate SHA-1 hash
sha1_hash = hashlib.sha1(data.encode("utf-8")).hexdigest()

print(f"SHA-1 Hash: {sha1_hash}")
PYEOF
    echo "Created exp10_sha1.py in $PWD"
    echo "Run it with:  python3 exp10_sha1.py"
}

# ============================ Exp 13: GPG ============================
exp13() {
    rm -rf "${PRAC:?}/gpg_lab"
    mkdir -p $PRAC/gpg_lab/student/.gnupg $PRAC/gpg_lab/recipient/.gnupg
    chmod 700 $PRAC/gpg_lab/student/.gnupg $PRAC/gpg_lab/recipient/.gnupg
    cd "$PRAC" || return

    if ! command -v gpg >/dev/null 2>&1; then
        sudo apt update
        sudo apt install gnupg -y
    fi

    GNUPGHOME=$PRAC/gpg_lab/student/.gnupg
    export GNUPGHOME=$PRAC/gpg_lab/student/.gnupg
    # safety: make sure gpg really uses the lab folder and not your own ~/.gnupg
    if [ "$(gpgconf --list-dirs homedir)" != "$PRAC/gpg_lab/student/.gnupg" ]; then
        echo "Error: gpg is not using the lab keyring - stopping so your own keys stay untouched."
        return 1
    fi
    set -x
    # ---------- sender: student ----------
    gpg --version
    GNUPGHOME=$PRAC/gpg_lab/student/.gnupg
    cd $PRAC/gpg_lab/student
    printf '%%no-protection\nKey-Type: RSA\nKey-Length: 3072\nKey-Usage: sign\nSubkey-Type: RSA\nSubkey-Length: 3072\nSubkey-Usage: encrypt\nName-Real: Student\nName-Email: student@example.com\nExpire-Date: 0\n%%commit\n' > student_key.params
    gpg --batch --generate-key student_key.params
    gpg --list-keys
    gpg --list-secret-keys
    gpg --armor --export student@example.com > student_public_key.asc
    cat student_public_key.asc

    # ---------- recipient ----------
    GNUPGHOME=$PRAC/gpg_lab/recipient/.gnupg
    cd $PRAC/gpg_lab/recipient
    printf '%%no-protection\nKey-Type: RSA\nKey-Length: 3072\nKey-Usage: sign\nSubkey-Type: RSA\nSubkey-Length: 3072\nSubkey-Usage: encrypt\nName-Real: Recipient\nName-Email: recipient@example.com\nExpire-Date: 0\n%%commit\n' > recipient_key.params
    gpg --batch --generate-key recipient_key.params
    gpg --armor --export recipient@example.com > recipient_public_key.asc
    cp recipient_public_key.asc $PRAC/gpg_lab/student/
    cp $PRAC/gpg_lab/student/student_public_key.asc .

    # ---------- student: import recipient key, write + encrypt email ----------
    GNUPGHOME=$PRAC/gpg_lab/student/.gnupg
    cd $PRAC/gpg_lab/student
    gpg --import recipient_public_key.asc
    gpg --list-keys
    printf 'Subject: Confidential Project Discussion\n\nDear Team,\n\nThis is a confidential message for our project discussion.\nThe contents of this message should only be accessible\nto the intended recipient.\n\nRegards,\nStudent\n' > email.txt
    cat email.txt
    gpg --armor --trust-model always --encrypt --recipient recipient@example.com email.txt
    ls
    cat email.txt.asc
    cp email.txt.asc $PRAC/gpg_lab/recipient/

    # ---------- recipient: decrypt ----------
    GNUPGHOME=$PRAC/gpg_lab/recipient/.gnupg
    cd $PRAC/gpg_lab/recipient
    gpg --decrypt email.txt.asc

    # ---------- student: sign ----------
    GNUPGHOME=$PRAC/gpg_lab/student/.gnupg
    cd $PRAC/gpg_lab/student
    printf 'Subject: Signed Message\n\nThis message is signed by Student to prove authenticity and integrity.\n' > signed_email.txt
    gpg --armor --detach-sign signed_email.txt
    ls
    cp signed_email.txt signed_email.txt.asc $PRAC/gpg_lab/recipient/

    # ---------- recipient: verify ----------
    GNUPGHOME=$PRAC/gpg_lab/recipient/.gnupg
    cd $PRAC/gpg_lab/recipient
    gpg --import student_public_key.asc
    gpg --verify signed_email.txt.asc signed_email.txt
    { set +x; } 2>/dev/null

    gpgconf --homedir $PRAC/gpg_lab/student/.gnupg   --kill gpg-agent 2>/dev/null
    gpgconf --homedir $PRAC/gpg_lab/recipient/.gnupg --kill gpg-agent 2>/dev/null
    unset GNUPGHOME
    cat > "$PRAC/README_exp13_GPG.md" <<'README_END'
# Exp 13 – GPG Email Security (Linux): remaining steps

`./run.sh` -> **13** already did the setup and a full demo run with two test users
(student = sender, recipient) under `~/Desktop/practical/gpg_lab`. Your real `~/.gnupg` was not touched.
The terminal output of that run is what you can screenshot (Sections 4–13 of your doc).

## What is left for you (manual run, for a record with your own passphrase)

Open **two terminals**. Terminal 1 = Student, Terminal 2 = Recipient.

```bash
# Terminal 1
mkdir -p ~/Desktop/practical/gpg_manual/student/.gnupg ~/Desktop/practical/gpg_manual/recipient && chmod 700 ~/Desktop/practical/gpg_manual/student/.gnupg
export GNUPGHOME=~/Desktop/practical/gpg_manual/student/.gnupg ; cd ~/Desktop/practical/gpg_manual/student
# Terminal 2
mkdir -p ~/Desktop/practical/gpg_manual/recipient/.gnupg && chmod 700 ~/Desktop/practical/gpg_manual/recipient/.gnupg
export GNUPGHOME=~/Desktop/practical/gpg_manual/recipient/.gnupg ; cd ~/Desktop/practical/gpg_manual/recipient
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
| 12 | T1 | `cp email.txt.asc ~/Desktop/practical/gpg_manual/recipient/` | |
| 13 | T2 | `gpg --decrypt email.txt.asc` (enter Recipient passphrase) | yes |
| 14 | T1 | `nano signed_email.txt`, then `gpg --armor --detach-sign signed_email.txt` | yes |
| 15 | T1 | `cp signed_email.txt signed_email.txt.asc ~/Desktop/practical/gpg_manual/recipient/` | |
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

# ======================== Exp 14: Personal Firewall ========================
exp14() {
    cd "$PRAC" || return
    echo "This lab flushes your current iptables rules and drops all unsolicited incoming traffic."
    echo "Your existing rules are saved first to $PRAC/iptables-backup.rules (restore steps: README_exp14_Firewall.md)."
    read -rp "Continue? [y/N] " ans
    case "$ans" in y|Y) ;; *) echo "Cancelled. Nothing was changed."; return ;; esac

    if ! command -v iptables >/dev/null 2>&1; then
        sudo apt update
        sudo apt install iptables -y
    fi

    set -x
    sudo iptables --version
    sudo iptables -L -n -v
    sudo iptables-save | tee $PRAC/iptables-backup.rules
    sudo iptables -F
    sudo iptables -X
    sudo iptables -P INPUT DROP
    sudo iptables -P FORWARD DROP
    sudo iptables -P OUTPUT ACCEPT
    sudo iptables -A INPUT -i lo -j ACCEPT
    sudo iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
    sudo iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
    sudo iptables -L -n -v --line-numbers
    sudo iptables -A INPUT -p tcp --dport 80 -j DROP
    sudo iptables -L INPUT -n -v --line-numbers
    sudo apt update
    echo 'iptables-persistent iptables-persistent/autosave_v4 boolean false' | sudo debconf-set-selections
    echo 'iptables-persistent iptables-persistent/autosave_v6 boolean false' | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt install iptables-persistent -y
    sudo netfilter-persistent save
    sudo netfilter-persistent status
    ip addr
    { set +x; } 2>/dev/null

    cat > "$PRAC/README_exp14_Firewall.md" <<'README_END'
# Exp 14 – Personal Firewall using iptables: remaining steps

`./run.sh` -> **14** (after you confirm with `y`) backed up your rules to `~/Desktop/practical/iptables-backup.rules`,
flushed them, set INPUT/FORWARD to DROP and OUTPUT to ACCEPT, added the loopback / established /
SSH (22) / ICMP-echo rules, blocked TCP port 80, listed the rules and saved them with
iptables-persistent. **The rules stay active** so you can test them.

## What is left for you

### 1. Find this machine's IP (also printed at the end of the run)
```bash
ip addr
```

### 2. Test from a second authorised machine (or a VM) – screenshot on the CLIENT
```bash
ping -c 4 <Linux-machine-IP>          # allowed (ICMP echo rule) -> replies
ssh <username>@<Linux-machine-IP>     # allowed (port 22 rule)
```
SSH only works if an SSH server runs on the firewalled machine:
`sudo apt install openssh-server -y && sudo systemctl start ssh`

Optional check that port 80 is blocked: `curl -m 5 http://<Linux-machine-IP>` (times out) or `nmap -p 22,80 <IP>` (80 shows *filtered*).

### 3. Show the rule counters again (screenshot)
```bash
sudo iptables -L -n -v --line-numbers
```
The packet counters rise after the ping/SSH tests.

### 4. Restore your original firewall when you are done (important)
```bash
sudo iptables-restore < ~/Desktop/practical/iptables-backup.rules
sudo iptables -L -n -v
sudo netfilter-persistent save        # also removes the lab rules from the saved (boot-time) config
```
If you can no longer reach something on this laptop, run the restore step above (or `sudo iptables -F` and `sudo iptables -P INPUT ACCEPT`).

## Notes
- All unsolicited incoming connections except SSH and ping are dropped while the lab rules are active; outgoing traffic and replies still work.
- Your doc's section numbering skips from 14 to 17 – add the sections you need (e.g. 15 Observation, 16 Result) yourself.
README_END
}

# ======================== Exp 15: Wireshark install + capture ========================
pick_iface() {
    IFACE="$(ip route show default 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="dev"){print $(i+1); exit}}')"
    [ -z "$IFACE" ] && IFACE="$(tshark -D 2>/dev/null | head -n1 | sed -E 's/^[0-9]+\. ([^ ]+).*/\1/')"
}

exp15() {
    mkdir -p $PRAC/wireshark_lab
    cd "$PRAC" || return

    set -x
    sudo apt update
    echo 'wireshark-common wireshark-common/install-setuid boolean true' | sudo debconf-set-selections
    sudo DEBIAN_FRONTEND=noninteractive apt install wireshark tshark curl -y
    sudo usermod -aG wireshark "$USER"
    wireshark --version
    ip -br addr
    { set +x; } 2>/dev/null

    pick_iface

    set -x
    sudo tshark -i "$IFACE" -a duration:15 -F pcapng -w - > $PRAC/wireshark_lab/exp15_capture.pcapng &
    sleep 3
    ping -c 4 8.8.8.8
    curl -sI http://example.com
    wait
    tshark -r $PRAC/wireshark_lab/exp15_capture.pcapng -Y "icmp" | head -n 8
    tshark -r $PRAC/wireshark_lab/exp15_capture.pcapng -Y "tcp" | head -n 8
    tshark -r $PRAC/wireshark_lab/exp15_capture.pcapng -Y "http" | head -n 8
    ls -l $PRAC/wireshark_lab
    { set +x; } 2>/dev/null

    cat > "$PRAC/README_exp15_Wireshark.md" <<'README_END'
# Exp 15 – Install Wireshark and capture ICMP, TCP, HTTP: remaining steps

`./run.sh` -> **15** installed Wireshark/tshark (answering "allow non-superusers to capture" with Yes),
added you to the `wireshark` group, and recorded `~/Desktop/practical/wireshark_lab/exp15_capture.pcapng`
(ping = ICMP, curl to http://example.com = TCP + HTTP). The terminal output shows the ICMP, TCP and HTTP packets.

## What is left for you (GUI + screenshots)

1. **Apply group change:** log out and log in again, or run `newgrp wireshark`.
2. **Launch Wireshark:** `wireshark`
3. **Start capture:** double-click your active interface (Wi-Fi/Ethernet) or click the blue shark-fin **Start** button. 📸
4. **Generate traffic** in a terminal:
   ```bash
   ping -c 4 8.8.8.8              # ICMP
   curl -sI http://example.com    # TCP + HTTP
   ```
5. **Stop capture** (red square) and use the filter bar, one screenshot each:
   - `icmp` – echo request / reply
   - `tcp` – handshake (SYN, SYN-ACK, ACK) and data
   - `http` – GET / response
6. Or open the pre-recorded file: `wireshark -r ~/Desktop/practical/wireshark_lab/exp15_capture.pcapng`
7. Add your screenshots and the conclusion to the record.

## Troubleshooting
- "No permission to capture": log out/in, or `sudo dpkg-reconfigure wireshark-common` (Yes) then `sudo usermod -aG wireshark $USER` and re-login.
- `http` shows nothing: use a plain `http://` URL; HTTPS traffic is encrypted and appears as TLS.
README_END
}

# ======================== Exp 16: Wireshark ========================
exp16() {
    mkdir -p $PRAC/wireshark_lab
    cd "$PRAC" || return

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
    sudo tshark -i "$IFACE" -a duration:20 -F pcapng -w - > $PRAC/wireshark_lab/full_capture.pcapng &
    sleep 3
    ping -c 4 8.8.8.8
    nslookup example.com
    nslookup wireshark.org
    curl -sI http://example.com
    curl -sI https://example.com
    wait

    # ---------- display filters ----------
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "dns" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "http" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "tcp" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "udp" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "icmp" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "ip.addr == $LOCALIP" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "ip.src == $LOCALIP" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "ip.dst == $LOCALIP" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "tcp.port == 443" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "dns && ip" | head -n 5
    tshark -r $PRAC/wireshark_lab/full_capture.pcapng -Y "tcp.flags.syn == 1" | head -n 5

    # ---------- capture filter ----------
    sudo tshark -i "$IFACE" -f "port 53" -a duration:8 -F pcapng -w - > $PRAC/wireshark_lab/dns_only_capture.pcapng &
    sleep 3
    nslookup example.com
    nslookup wireshark.org
    wait
    tshark -r $PRAC/wireshark_lab/dns_only_capture.pcapng | head -n 8
    ls -l $PRAC/wireshark_lab
    { set +x; } 2>/dev/null

    cat > "$PRAC/README_exp16_Wireshark.md" <<'README_END'
# Exp 16 – Wireshark Packet Filters: remaining steps

`./run.sh` -> **16** already installed Wireshark/tshark, recorded two sample captures
(`~/Desktop/practical/wireshark_lab/full_capture.pcapng` and `dns_only_capture.pcapng`) and ran the lab's
display filters from the terminal. **Log out and back in once** so the `wireshark` group
lets you capture live without sudo.

## What is left for you (GUI work + screenshots)

### 1. Open the capture (Section 5)
```bash
wireshark -r ~/Desktop/practical/wireshark_lab/full_capture.pcapng &
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
- No GUI: `tshark -r ~/Desktop/practical/wireshark_lab/full_capture.pcapng -Y dns`.
README_END
}

# ======================== Exp 17: Nmap ========================
exp17() {
    mkdir -p $PRAC/nmap_lab
    cd $PRAC/nmap_lab || return
    echo "Only scan machines you own or are authorised to test."
    read -rp "Target IP/host to scan [127.0.0.1]: " TARGET
    TARGET="${TARGET:-127.0.0.1}"
    read -rp "Subnet for the ping scan [Enter = just $TARGET]: " SUBNET
    SUBNET="${SUBNET:-$TARGET}"

    set -x
    sudo apt update
    sudo apt install nmap -y
    nmap --version
    nmap "$TARGET"
    nmap -sn "$SUBNET"
    sudo nmap -sS "$TARGET"
    nmap -sT "$TARGET"
    sudo nmap -sU "$TARGET"
    nmap -p 22,53,80,443 "$TARGET"
    nmap -sV "$TARGET"
    nmap -p- "$TARGET"
    nmap -T4 "$TARGET"
    nmap -oN scan-results.txt "$TARGET"
    ls -l scan-results.txt
    sudo nmap -O "$TARGET"
    nmap -sT -p 22,80,443 "$TARGET"
    sudo nmap -sU -p 53,123,161 "$TARGET"
    { set +x; } 2>/dev/null

    cat > "$PRAC/README_exp17_Nmap.md" <<'README_END'
# Exp 17 – Nmap Port Scanning and Host Discovery: remaining steps

`./run.sh` -> **17** asked for a target (default `127.0.0.1`, this machine), installed Nmap, and ran every
scan from your doc against it: basic, ping scan, SYN, connect, UDP, selected ports, service/version,
all TCP ports, timing, saved output, OS detection, and the TCP/UDP example. Output of `-oN` is in
`~/Desktop/practical/nmap_lab/scan-results.txt`.

> Only scan machines you own or have **explicit permission** to test (your own PC, a lab VM, your lab network).

## What is left for you
1. **Screenshots** of the terminal output for each scan type.
2. **Scan your lab target / network** (a VM or lab machine) so the record shows real hosts. Re-run `./run.sh 17` and type the target IP, and the subnet for the ping scan (e.g. `192.168.56.0/24`). Find your own subnet with `ip -br addr`.
3. **Interpret the results** (Section 8): note port, protocol, state, service.
   - *open* = an application is listening
   - *closed* = reachable but nothing listening
   - *filtered* = a firewall/network blocks the probe so Nmap cannot tell
4. **Compare** the TCP connect scan with the SYN scan and the UDP scan results in your report.
5. Write the Observation/Result and Conclusion using **your own output**.

## Notes
- `sudo nmap -sU` against a remote host can take many minutes (UDP probes are slow). Against `127.0.0.1` it finishes quickly.
- A fresh laptop often has **no** open ports on `127.0.0.1`; "all ports closed" is a valid result. To see open ports, scan a VM that runs SSH/HTTP (e.g. `sudo apt install openssh-server apache2` on the VM).
- `-O` and `-sS`/`-sU` need `sudo`; the script uses it where the doc does.
README_END
}

# ============================== Menu ==============================
choice="$1"
if [ -z "$choice" ]; then
    echo "Select experiment:"
    echo "   1  - Euclidean Algorithm"
    echo "   2  - Brute Force Attack"
    echo "   3  - Playfair Cipher"
    echo "   4  - Hill Cipher"
    echo "   5  - Rail Fence Cipher"
    echo "   6  - Transposition Cipher (columnar)"
    echo "   7  - RSA Algorithm"
    echo "   8  - Diffie-Hellman Algorithm"
    echo "   9  - MD5 Hash"
    echo "  10  - SHA-1 Hash"
    echo "  13  - GPG Tool (email security)"
    echo "  14  - Personal Firewall (iptables)"
    echo "  15  - Wireshark: install + capture ICMP/TCP/HTTP"
    echo "  16  - Wireshark Packet Filters"
    echo "  17  - Nmap Port Scanning"
    read -rp "Enter experiment number: " choice
    # wipe the menu and the typed number so only the experiment output remains
    clear 2>/dev/null || printf '\033c'
fi

case "$choice" in
    1|2|3|4|5|6|7|8|9|10|13|14|15|16|17) "exp$choice" ;;
    *) echo "Invalid experiment number: $choice" ;;
esac
