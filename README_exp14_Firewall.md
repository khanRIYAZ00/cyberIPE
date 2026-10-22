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
