#!/sbin/openrc-run
# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

NAME="dhclient"

depend()
{
	need localmount
	keyword -vserver -lxc
}

start()
{
    ebegin "Starting dhclient networking"
    for DEVICE in /sys/class/net/* ; do
        ip link set ${DEVICE##*/} up
        [ ${DEVICE##*/} != lo ] && dhclient ${DEVICE##*/}
    done
    return 0
}

stop()
{
	return 0
}

# vim:ts=4

