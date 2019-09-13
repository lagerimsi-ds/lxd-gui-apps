#! /bin/bash

echo "export PULSE_SERVER=tcp:'$(ip route show 0/0 | awk '{print $3}')'"| tee -a /home/"$USER"/.profile
mkdir -p /home/"$USER"/.config/pulse
echo "export PULSE_COOKIE=/home/$USER/.config/pulse/cookie" | tee -a /home/"$USER"/.profile
