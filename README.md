# lxd-gui-apps
A bash script preparing lxd and its container for running gui apps seemlessly intergrating into the desktop environment.


Based on an article by Simos Xenitellis which can be found here:
https://blog.simos.info/how-to-run-graphics-accelerated-gui-apps-in-lxd-containers-on-your-ubuntu-desktop/


prequisites:

- snap install of lxd on ubuntu (tested with 19.04/disco)
- lxd setup with 'lxd init' and 
- a container running ubunu 19.04 -> 'lxc launch ubuntu:19.04 ubuntu-1904-gui'


Notes:
Cotrary to the article the changes in this script to the /etc/subuid and /etc/subgid files depend on membership
of the user in the lxd group in /etc/group.

As tested, these changes are not needed anymore. Also group membership on desktop systems seems to be standard now.
This enables the user to launch the lxd command without sudo.

The name of the container that has to be changed has to be set in the variable on top of the script.

