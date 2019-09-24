#! /bin/bash
#
#
#    Copyright (C) 2019  Dominik Steinberger
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
#


container_name=ubuntu-1904-gui

# use "lxc network list" manually to find the managed interface
lxd_bridge=lxdbr0


lxd_network_address=$(lxc network show $lxd_bridge | grep ipv4.address | awk '{print $2}')
x_display="${DISPLAY##*:}"

# install apps in container
lxc exec $container_name -- sudo --login --user ubuntu sudo apt update
lxc exec $container_name -- sudo --login --user ubuntu  sudo apt upgrade
lxc exec $container_name -- sudo --login --user ubuntu sudo apt install x11-apps mesa-utils alsa-utils firefox libcanberra-gtk3-module mplayer

# The command appends a new entry in both the /etc/subuid and /etc/subgid subordinate UID/GID files. It allows the LXD service (runs as root) to remap our user’s ID ($UID, from the host) as requested.
# not needed when user is in group lxd to manage lxc/lxd
if ! grep  "lxd.*$USER" /etc/group 
then
	echo "root:$UID:1" | sudo tee -a /etc/subuid /etc/subgid
fi

# for the container - to be able to use X
lxc config set $container_name raw.idmap "both $UID 1000"

# then restart the container
lxc restart $container_name

# get access to unix socket for X
lxc config device add $container_name X"$x_display" disk path=/tmp/.X11-unix/X"$x_display" source=/tmp/.X11-unix/X"$x_display"
lxc config device add $container_name Xauthority disk path=/home/ubuntu/.Xauthority source="${XAUTHORITY}"

# for graphics access (not neede for intel cards- but works also ;) ) - "hostgpu" is just a name, any name would be ok
lxc config device add $container_name hostgpu gpu
lxc config device set $container_name hostgpu uid 1000
lxc config device set $container_name hostgpu gid 1000

# for sound via pulseaudio via network on host
sudo sed -i.backup_"$(date -Iseconds)" 's/^#load-module module-native-protocol-tcp/load-module module-native-protocol-tcp/g' /etc/pulse/default.pa

# set network access
sudo cp  /etc/pulse/system.pa /etc/pulse/system.pa_backup_"$(date -Iseconds)"
echo "load-module module-native-protocol-tcp auth-ip-acl=$lxd_network_address" | sudo tee -a /etc/pulse/system.pa 

# push helper script on container
lxc file push ./gui-guest-helper.sh $container_name/tmp/

# execute script in the container:
lxc exec $container_name -- sudo --login --user ubuntu bash /tmp/gui-guest-helper.sh

# give access to the pulse cookie to be able to auth to pulse
lxc config device add $container_name PACookie disk path=/home/ubuntu/.config/pulse/cookie source=/home/"$USER"/.config/pulse/cookie

# then restart the container
lxc restart $container_name 

echo -E "Time to run 'lxc exec $container_name -- sudo --login --user ubuntu firefox'"
cat << 'EOF'
Consider this command for a deskop shortcut:
# if lxc info $container_name | grep -q "Status: Running"; then lxc exec $container_name -- sudo --login --user ubuntu firefox; else lxc start $container_name && lxc exec $container_name -- sudo --login --user ubuntu firefox && lxc stop $container_name; fi
(starts $container_name if needed and stops it after browsing or starts firefox without stopping after usage, when container is already running)

Or for private browsing link if container is used for this purpose only: make a snapshot- browse - restore system from made snapshot - then delete the snapshot again:
# lxc snapshot $container_name temporary_snapshot && lxc start $container_name && lxc exec $container_name -- sudo --login --user ubuntu firefox && lxc stop $container_name && lxc restore $container_name/temporary_snapshot  && lxc delete $container_name/temporary_snapshot"

Mind the '#' at the beginning! They are to prevent accidantly pasting on the CLI.
EOF



# former more difficult commands using 'lxc list'
# if [ $(lxc list | grep $container_name |awk -F'|' '{ print $3 }') = RUNNING ]; then lxc exec $container_name -- sudo --login --user ubuntu firefox; else lxc start $container_name && lxc exec $container_name -- sudo --login --user ubuntu firefox && lxc stop $container_name; fi

# former more difficult commands without snapshot name
# lxc snapshot $container_name && if [ "$(lxc list | grep $container_name |awk -F'|' '{ print $7 }')" -gt 0 ]; then snap=$(lxc list | grep $container_name | awk -F'|' '{ print $7 }') snap=$((snap-1)); else snap=0; fi && lxc start $container_name && lxc exec $container_name -- sudo --login --user ubuntu firefox && lxc stop $container_name && lxc restore $container_name snap$snap && lxc delete $container_name/snap$((snap-1))"
