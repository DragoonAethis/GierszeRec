#!/bin/bash
pulseaudio --system --daemonize --disallow-exit
x11vnc -display :0 -forever -shared -nopw &
export XDG_SESSION_TYPE=x11
export GDK_BACKEND=x11
exec openbox
