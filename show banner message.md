```bash
nano /etc/issue.net
# write anything you want
nano /etc/ssh/sshd_config
# in this file, add or edit "Banner=/etc/issue.net"
systemctl restart sshd
```
