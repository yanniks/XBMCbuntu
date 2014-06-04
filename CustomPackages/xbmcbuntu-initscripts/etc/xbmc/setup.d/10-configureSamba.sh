#!/bin/bash

# Copyright (C) 2005-2013 Team XBMC
# http://www.xbmc.org
#
# This Program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2, or (at your option)
# any later version.
#
# This Program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with XBMC; see the file COPYING. If not, write to
# the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.
# http://www.gnu.org/copyleft/gpl.html

xbmcUser=$1
xbmcParams=$2

# stop netatalk
service netatalk stop
rm -f /etc/netatalk/afpd.conf /etc/netatalk/afp_ldap.conf /etc/netatalk/AppleVolumes.default /etc/netatalk/atalkd.conf /etc/netatalk/papd.conf >/dev/null 2>&1
cat > /etc/netatalk/afpd.conf << EOF
- -tcp -ipaddr 10.0.0.5 -noddp -uamlist uams_dhx.so,uams_dhx2.so -nosavepassword
EOF
touch /etc/netatalk/afp_ldap.conf
cat > /etc/netatalk/AppleVolumes.default << EOF
:DEFAULT: options:upriv,usedots
/media/Volume/Files/Movies "Movies" allow:yannik cnidscheme:cdb
/media/Volume/Files/Musik "Music" allow:yannik cnidscheme:cdb
/home/yannik/repos "git" allow:yannik cnidscheme:cdb
"/home/yannik/TV Shows" "TV Shows" allow:yannik cnidscheme:cdb
/media/Volume/Files/Downloads "Downloads" allow:yannik cnidscheme:cdb
/media/Volume/Files "Medienplatte" allow:yannik cnidscheme:cdb
/media/Volume "Volume" allow:yannik cnidscheme:cdb
/media/Volume/Files/Bilder "Pictures" allow:yannik cnidscheme:cdb
/home/yannik/.xbmc "System" allow:yannik cnidscheme:cdb
/home/yannik/TimeMachine     "Yanniks_MBP" allow:yannik cnidscheme:dbd options:upriv,usedots,tm volsizelimit:1000000
EOF
touch /etc/netatalk/atalkd.conf
touch /etc/netatalk/papd.conf

# start netatalk
service netatalk start

update-rc.d smbd defaults

# stop Samba
service smbd stop

#
# setup smb config file
#
rm -f /etc/samba/smb.conf >/dev/null 2>&1
cat > /etc/samba/smb.conf << EOF

[global]
workgroup = WORKGROUP
server string = %h server (Samba, XBMC)
netbios name = XBMCbuntu
dns proxy = no
name resolve order = hosts wins bcast
guest account = $xbmcUser
load printers = no
show add printer wizard = no
log file = /var/log/samba/log.%m
max log size = 1000
syslog = 0
panic action = /usr/share/samba/panic-action %d
encrypt passwords = true
passdb backend = tdbsam
obey pam restrictions = yes
unix password sync = yes
passwd program = /usr/bin/passwd %u
passwd chat = *Enter\snew\s*\spassword:* %n\n *Retype\snew\s*\spassword:* %n\n *password\supdated\ssuccessfully* .
pam password change = yes
map to guest = bad user

[Movies]
path = /home/$xbmcUser/Movies
comment = Video's and Movies Folder
writeable = yes
browseable = yes
guest ok = yes

[Music]
path = /home/$xbmcUser/Music
comment = Music Folder
writeable = yes
browseable = yes
guest ok = yes

[TV Shows]
path = /home/$xbmcUser/TV Shows
comment = TV Shows Folder
writeable = yes
browseable = yes
guest ok = yes

[Downloads]
path = /home/$xbmcUser/Downloads
comment = Downloads Folder
writeable = yes
browseable = yes
guest ok = yes

[Pictures]
path = /home/$xbmcUser/Pictures
comment = Pictures
writeable = yes
browseable = yes
guest ok = yes

[System]
path = /home/$xbmcUser/.xbmc
comment = XBMC System Share
writeable = yes
browseable = yes
guest ok = yes
EOF

#
# start Samba
#

service smbd start

exit 0

