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
