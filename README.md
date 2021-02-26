# GierszeRec

A tiny Docker container to record lectures and such on headless servers. Preferrably on Fridays, 8am.

Comes with minimal Openbox, Xdummy and all the stuff to run a persistent GUI session in a container,
along with OBS Studio, Chromium, ffmpeg, Mesa/llvmpipe, etc - so it's ready to record anything.


## How to use

First start requires some setup:

```bash
docker pull dragoonaethis/gierszerec
docker volume create rec

docker run --name gierszerec --publish 5900:5900 --mount source=rec,target=/rec --detach dragoonaethis/gierszerec
```

If you'd rather build the image from scratch instead of pulling (swap the tag in `docker run`):

```bash
git clone https://github.com/DragoonAethis/GierszeRec.git && cd GierszeRec
docker build -t dragoonaethis/gierszerec:tag .
```

**Confirm OBS can record audio by opening the Desktop Audio -> Cog -> Properties page.** If there's
a "default" device selected, it should be good to go, but you can also try playing some audio in the
browser and confirm the volume meter shows activity.

Then just connect over VNC to :5900 and set up your recording session. Right-click anywhere to open
the system menu - the first 3 options should be enough. If you leave the VNC session, OBS will keep
recording (if you've started it, of course).

You might want to publish the VNC port to something like `127.0.0.1:5900:5900`, so that only local
machine users can connect to that (if you don't have a firewall, anyone will be able to connect to
the container with no authentication). With the localhost publish, you can set up a SSH tunnel in
your VNC client (like Remmina) to the host running that container and connect to the local port.

To pull recorded videos from the container:

- Find where the `rec` volume is mounted: `docker volume inspect rec`
- Copy/move your stuff from the `mountpoint` directory.

To stop the container, right-click anywhere in VNC -> Exit.

To start the container again, `docker restart gierszerec` - **make sure OBS can record audio**, for
some reason PulseAudio dies every now and then. If that happens, recreate the container:

- `docker kill gierszerec`
- `docker rm gierszerec`,
- `docker run ...` command from the first start section.


## Record with ffmpeg

If you don't have a machine powerful enough to handle OBS (for example, if running on a shared host)
then you'll have to use ffmpeg (1080p, 30FPS, grabs the entire screen and PulseAudio default output,
encodes on a CPU with the `ultrafast` preset):

```bash
ffmpeg -video_size 1920x1080 -framerate 30 \
    -f x11grab -i :0.0 \
    -f pulse -ac 2 -i default \
    -c:v h264 -preset ultrafast \
    "/rec/$(date +'%Y-%m-%e %X').mkv"
```

This script is also shipped as [`rec`](rec) in the Docker image, so you can just start xterm -> rec
and off you go.


## Hetzner helper

If you're using Hetzner to host your stuff:

- [Configure `hcloud` for a new project.](https://github.com/hetznercloud/cli#getting-started)
- Use the `gierszerec up|down|vnc|pull` script in this repo to:
  - `up`: Create a new server, configure Docker and start the container described above.
  - `vnc`: Connect via VNC to the server using Remmina and a SSH tunnel.
  - `pull`: Download the contents of the `rec` Docker volume to a new local directory.
  - `down`: Destroy that server.

It's a fast way to quickly set up a new recorder, pull all recorded files, then tear it down. The
default `CPX21` image costs 0.014EUR/h, so it's pretty cheap. Note that it assumes `hcloud` is
already configured with the context you want to use - it manages a server called `GierszeRec` in it.
