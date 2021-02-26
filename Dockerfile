FROM debian:buster-slim
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get dist-upgrade -y
RUN apt install -y \
    xinit xserver-xorg-video-dummy x11vnc \
    openbox ffmpeg obs-studio pulseaudio

ADD https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb /root/chrome.deb
RUN apt install -y /root/chrome.deb

WORKDIR /root
COPY xinitrc /root/.xinitrc
COPY xorg.conf /etc/X11/xorg.xdummy.conf
COPY system.pa /etc/pulse/system.pa
COPY openbox.menu.xml /etc/xdg/openbox/menu.xml
COPY google-chrome.desktop /usr/share/applications/google-chrome.desktop

COPY obs.global.ini /root/.config/obs-studio/global.ini
COPY obs.basic.ini /root/.config/obs-studio/basic/profiles/Untitled/basic.ini
COPY obs.scene.json /root/.config/obs-studio/basic/scenes/Untitled.json

ADD rec /bin/rec
RUN chmod +x /bin/rec

ENV DISPLAY :0
ENV QT_X11_NO_MITSHM 1
CMD dbus-run-session xinit -- :0 -nolisten tcp vt$XDG_VTNR -noreset +extension GLX +extension RANDR +extension RENDER +extension XFIXES -config /etc/X11/xorg.xdummy.conf

# Stuff you want:
# - google-chrome --no-sandbox --disable-gpu --disable-dev-shm-usage
# - obs or ffmpeg (see README for details)
