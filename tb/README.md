### HOW TO
------------

Build this image from this directory using

`docker build -t $CONTAINER_NAME .`

Run this image using this command

`docker run -it --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -p 9011:9011 -d $CONTAINER_NAME`


There is a SELinux Issue (https://lkml.org/lkml/2015/7/10/748) that prevents the tb from calling mprotect, therefore use 

`setenforce 0`

or disable selinux to get this working
