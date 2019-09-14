# lxd-gui-apps
A bash script preparing lxd and an already setup container to run gui apps seemlessly intergrating into the desktop environment.


Based on an article by Simos Xenitellis which can be found here:

https://blog.simos.info/how-to-run-graphics-accelerated-gui-apps-in-lxd-containers-on-your-ubuntu-desktop/

and (newer version)

https://blog.simos.info/how-to-easily-run-graphics-accelerated-gui-apps-in-lxd-containers-on-your-ubuntu-desktop/


## Prequisites:

- snap install of lxd on ubuntu (tested with 19.04/disco)
- lxd setup with `lxd init`
- a container running ubunu 19.04 -> `lxc launch ubuntu:19.04 ubuntu-1904-gui`


### Notes:
Contrary to the article the changes in this script to the /etc/subuid and /etc/subgid files depend on membership
of the user in the lxd group in /etc/group.
As tested, these changes are not needed anymore. Also group membership on desktop systems seems to be standard now.
This enables the user to use the lxc command without sudo for management purposes.


### Notable variables to set to your needs within the script:
- container_name

	- The name of the container to change the settings for.
	- Standard: ubuntu-1904-gui

- lxd_bridge
	- Set this to the name of the network bridge lxd/lxc uses for the container.
	`lxc network list` helps to find the right name.
	- Standard: lxdbr0


