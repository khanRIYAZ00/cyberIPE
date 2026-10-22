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
