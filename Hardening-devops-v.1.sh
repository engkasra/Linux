#!/bin/bash
#############$#############$#############$#############$#############$#############$#############$#############$#############$#############$#############$#############$#############
#AUTHOR: DevOps
#DATE: 04/9/2023
#NOTES: INTERACTIVE MODE, MAKE SURE THE NETWORK CONNECTIVITY IS WORKING TO THE LOCAL REPOSITORIES
#############$#############$#############$#############$#############$#############$#############$#############$#############$#############$#############$#############$#############

#--------------------------------------------------------------------

#UPDATING REPOS
if ! apt-get update; then
    echo "Cannot update repos, Please make sure you've configured proper repositories!" >&2
    exit 1
fi
#checks if the system's package repositories can be updated, and if not, it will print an error message and exit with an error code of 1.
#This script is commonly used in shell scripts that require a specific package or tool to be installed on the system, to ensure that the package repositories are up-to-date before attempting to install the package or tool.

#--------------------------------------------------------------------

#DISABLING NOT USING FILESYSTEMS AND KERNEL MODULES
echo -e "Disabling modules . . . "
##ADD OR REMOVE MODULES FROM THE BELOW LINE
for i in hfs hfsplus cramfs freevxfs jffs2 squashfs udf vfat usb-storage 
do
  result=`lsmod | grep $i`
    if [ ${result} != "" ];
    then
      echo -e "$i is loaded!"
      rmmod $i
      if [ $? -eq 0 ];
      then
        echo -e "Disabled"
      fi;
    else
      echo -e "$i is not loaded!"
    fi
done
#This is a shell script that loops through a list of kernel modules specified in the for loop and checks if each module is currently loaded into the kernel by using the lsmod command and grep to search for the module name.
#If the module is found to be loaded, the script unloads the module using the rmmod command, and if the unloading is successful (i.e., returns an exit code of 0), it prints a message indicating that the module has been disabled.
#If the module is not found to be loaded, the script prints a message indicating that the module is not loaded.
#This script can be used to manage kernel modules and unload unnecessary modules to free up system resources.

#--------------------------------------------------------------------

#SECURE BOOT SETTINGS
##SET PERMISSION OF 400 ON /BOOT/GRUB/GRUB.CFG AND SETTING THE PROPER OWNERSHIP
chown root:root /boot/grub/grub.cfg
chmod 400 /boot/grub/grub.cfg

##CHECK WHETHER PASSWORD IS ALREADY SET
ifPass=`cat /etc/grub.d/40_custom | grep "set superusers"`
ifUnres=`cat /etc/grub.d/10_linux | grep "unrestricted"`
##SET PASSWORD FOR GRUB MENU
if [[ ${ifPass} = "" ]] && [[ ${ifUnres} = "" ]]; then
        echo -e "set superusers=\"root\"\npassword_pbkdf2 root grub.pbkdf2.sha512.10000.C95A7B0FE923D1D69ADE4A224943B8541F86DD0B7F0999BC848D605AD2373942A8792F3457474E42FF69E581F97B6C65B11245886B34F4028BB7710DB310EC15.1E8C896492BCB59EB27EC7A8B816BAFD2FF60E344F87BF6B6474C9583727AB27F7F02A3785A64312C789F127877D0148184F7822B1AD51249E136BBC7EFA7E41 " >> /etc/grub.d/40_custom
        sed -i 's/.*\(CLASS="--class gnu.*\)"/\1 --unrestricted"/' /etc/grub.d/10_linux
        grub-mkconfig -o /boot/grub/grub.cfg
        echo -e "grub password has been set!"
        grubEC=0
else

        echo -e "grub password detected!"
        grubEC=1

fi;

#--------------------------------------------------------------------

#CUSTOMIZING MOTD MESSAGES
echo -e "Disabling message of the day . . . "
sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
chmod 644 /etc/default/motd-news
chmod -x /etc/update-motd.d/*
#This script is used to customize the messages displayed when a user logs into the system.
#The first section of the script disables the "message of the day" (MOTD) news, which is a daily news bulletin that is displayed to users when they log in

echo -e "Changing local login terminal message . . . "
echo "Please login to continue . . ." > /etc/issue
chmod 644 /etc/issue

echo -e "Changing remote login terminal message . . . "
echo "Please login to continue . . ." > /etc/issue.net
chmod 644 /etc/issue.net
#The second section of the script changes the message that is displayed when a user logs into the local terminal. 
#The file permissions for /etc/issue are also set to 644.

#--------------------------------------------------------------------

#NETWORK PARAMETERS
echo -e "Configuring network parameters..."
kernel_params=(
    "net.ipv4.ip_forward=0"
#The net.ipv4.ip_forward parameter is a network parameter that determines whether or not the kernel will forward packets between network interfaces. 
    "net.ipv4.conf.all.send_redirects=0"
#This parameter controls whether the system will accept ICMP redirect messages from other hosts and route packets accordingly. Setting this to 0 disables this feature.
    "net.ipv4.conf.default.send_redirects=0"
#Similar to net.ipv4.conf.all.send_redirects, but applies only to the default network interface.
    "net.ipv4.conf.all.accept_redirects=0"
#This parameter controls whether the system will accept ICMP redirect messages from other hosts and modify its routing table accordingly. 
    "net.ipv4.conf.default.accept_redirects=0"
#Similar to net.ipv4.conf.all.accept_redirects, but applies only to the default network interface.
    "net.ipv6.conf.all.accept_ra=0"
#This parameter controls whether the system will accept Router Advertisement messages from other hosts and configure its own IPv6 address and routing accordingly. 
    "net.ipv6.conf.default.accept_ra=0"
#Similar to net.ipv6.conf.all.accept_ra, but applies only to the default network interface.
    "net.ipv4.tcp_syncookies=1"
#This parameter controls whether the system will use TCP SYN cookies to protect against SYN flood attacks.
    "net.ipv4.conf.all.log_martians=1"
#This parameter controls whether the system will log packets with impossible addresses (called "martians").
    "net.ipv4.conf.default.log_martians=1"
#Similar to net.ipv4.conf.all.log_martians, but applies only to the default network interface.
)

##Add the parameters to sysctl.conf if they're not already present
for param in "${kernel_params[@]}"; do
    if ! grep -q "^$param$" /etc/sysctl.conf; then
        echo "$param" >> /etc/sysctl.conf
    fi
done

##Apply the new settings immediately
sysctl -p

#This script configures some network parameters in a Linux system by modifying the sysctl.conf file and applying the new settings immediately.

#--------------------------------------------------------------------

#SECURING SSH CONFIG AND CERT FILES

##SET PERMISSIONS ON CERTIFICATES
echo -e "Securing sshd config and certificate files..."
chown root:root /etc/ssh/sshd_config
chmod 600 /etc/ssh/sshd_config
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chown root:root {} \;
find /etc/ssh -xdev -type f -name 'ssh_host_*_key' -exec chmod 0600 {} \;
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chmod 0644 {} \;
find /etc/ssh -xdev -type f -name 'ssh_host_*_key.pub' -exec chown root:root {} \;

##CONFIGURE SSHD_CONF FILE
echo "#THIS PART IS ADDED FOR THE HARDENING BY ASA INFRA DEPT"

sed -i 's/.*\(Protocol*\).*//' /etc/ssh/sshd_config
echo "Protocol 2" >> /etc/ssh/sshd_config

sed -i 's/.*\(MaxAuthTries*\).*//' /etc/ssh/sshd_config
echo "MaxAuthTries 4" >> /etc/ssh/sshd_config

sed -i 's/.*\(IgnoreRhosts*\).*//' /etc/ssh/sshd_config
echo "IgnoreRhosts yes" >> /etc/ssh/sshd_config

sed -i 's/.*\(HostbasedAuthentication*\).*//' /etc/ssh/sshd_config
echo "HostbasedAuthentication no" >> /etc/ssh/sshd_config

sed -i 's/.*\(PermitRootLogin*\).*//' /etc/ssh/sshd_config
echo "PermitRootLogin no" >> /etc/ssh/sshd_config

sed -i 's/.*\(PermitEmptyPasswords*\).*//' /etc/ssh/sshd_config
echo "PermitEmptyPasswords no" >> /etc/ssh/sshd_config

sed -i 's/.*\(PermitUserEnvironment*\).*//' /etc/ssh/sshd_config
echo "PermitUserEnvironment no" >> /etc/ssh/sshd_config
sed -i 's/.*\(PermitUserEnvironment*\).*//' /etc/ssh/sshd_config
echo "PermitUserEnvironment no" >> /etc/ssh/sshd_config

sed -i 's/.*\(ClientAliveInterval*\).*//' /etc/ssh/sshd_config
echo "ClientAliveInterval 300" >> /etc/ssh/sshd_config

sed -i 's/.*\(ClientAliveCountMax*\).*//' /etc/ssh/sshd_config
echo "ClientAliveCountMax 0" >> /etc/ssh/sshd_config

sed -i 's/.*\(LoginGraceTime*\).*//' /etc/ssh/sshd_config
echo "LoginGraceTime 60" >> /etc/ssh/sshd_config

sed -i 's/.*\(AllowTcpForwarding*\).*//' /etc/ssh/sshd_config
echo "AllowTcpForwarding no" >> /etc/ssh/sshd_config

sed -i 's/.*\(MaxSessions*\).*//' /etc/ssh/sshd_config
echo "MaxSessions 4" >> /etc/ssh/sshd_config

##RESTART THE SERVICE
echo -e "Restarting sshd..."
systemctl restart sshd

#--------------------------------------------------------------------

#ENABLING PAM.D PASSWORD COMPLEXITY
##Check if libpam_pwquality is installed
if ! dpkg -s libpam-pwquality >/dev/null 2>&1; then
    # If it's not installed, install it
    apt-get install -y libpam-pwquality
fi

##Check if password complexity is already configured
if ! grep -q 'minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1' /etc/pam.d/common-password; then
##If it's not configured, add the complexity options
    sed -i '/^password.*pam_pwquality\.so/s/$/ minlen=14 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1/' /etc/pam.d/common-password
fi

#This script enables password complexity requirements on the system by configuring the PAM (Pluggable Authentication Modules) subsystem.