#!/sbin/openrc-run

description="load modules udv"

name="udv"
command="/bin/udv"
command_args=""
pidfile="/run/udv.pid"
command_background=true

depend() {
      need net
}

