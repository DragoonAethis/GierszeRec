# GierszeRec

A tiny Docker container to record lectures and such on headless servers. Preferrably on Fridays, 8am.

Comes with minimal Openbox, Xdummy and all the stuff to run a persistent GUI session in a container,
along with OBS Studio, Chromium, ffmpeg, Mesa/llvmpipe, etc - so it's ready to record anything.


## How to use

First start requires some setup:

```bash
git clone https://github.com/DragoonAethis/GierszeRec.git && cd GierszeRec
docker build -t dragoonaethis/gierszerec:1.0 .
docker volume create rec

docker run --name gierszerec --publish 5900:5900 --mount source=rec,target=/rec dragoonaethis/gierszerec:1.0
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
