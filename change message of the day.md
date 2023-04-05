1.
```bash
nano /etc/default/motd-new
```

in the file:
ENABLED=0 <br> **tip: change enable=1 to enable=0**

---
2. 
```bash
ll /etc/update-motd.d
sudo chmod -x /etc/update-motd.d/*
nano /etc/motd
```
and in motd file what ever you want to show, can write there.
