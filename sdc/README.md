### HOW TO
------------

Build this image from this directory using

`docker build -t $CONTAINER_NAME .`

Run this image using this command

`docker run -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 7072:7072 -d $CONTAINER_NAME`
