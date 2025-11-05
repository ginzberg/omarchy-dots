#!/usr/bin/env bash
# unezquake-handler — robust qw:// and qtv:// launcher

cd /home/rallen/nquake || exit 1

# Always use x11 for best performance under Wayland
export SDL_VIDEODRIVER=x11

# Launch unezquake with gamemoderun
exec gamemoderun ./unezquake-linux-x86_64 -no-triple-gl-buffer +qwurl "$1"
