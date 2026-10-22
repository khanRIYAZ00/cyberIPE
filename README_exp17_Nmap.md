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
