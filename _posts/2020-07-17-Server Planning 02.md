---
title: Server - Network File Distribution
date: 2020-07-17 12:00:00 -0400
categories: [Computers, Server]
tags: [meta, linux, computer]
description: Setting up NFS on my server and Kodi on firestick
toc: false
comments: false
---

I am setting up NFS on the server, and Kodi on firestick.

This post will be the first step into a look on how I set up my server.
I meant to write this much later down the line actually,
I wanted to flesh out my OS design first.
But I have been really wanting to watch my movie library in the living room.
So instead of going through my OS workflow, I will dive into my NFS setup.
This also includes managing files on an Amazon Firestick as well;
as it is the machine I have on hand for HDMI output.

# Planning

What I have been trying to set up has been;

* Set up MariaDB server on my Server.
* Connect Kodi to use this server as the database (this is done)
* Set up NFS shares on the Server (this has been problematic)
* Add the NFS shares to Kodi; so that I can stream videos from my Server (Not here yet)
* Set this on my Firestick; so I have Kodi experience in my living room. (More or less done)

# Setting up MariaDB to use with the Server

So this step is pretty easy; I followed the [Archwiki](https://wiki.archlinux.org/index.php/Kodi#Install_and_set_up_the_MariaDB_server).

Installing MariaDB is as easy as running the following command as root.
```
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
mysql_secure_installation
```

Then to create a database for Kodi;
all that needs to be done is run the following in the mariadb console;
```
mysql -u root -p
   <<enter the mariadb root password assigned in the first step>>
MariaDB [(none)]> CREATE USER 'kodi' IDENTIFIED BY 'kodi';
MariaDB [(none)]> GRANT ALL ON *.* TO 'kodi';
MariaDB [(none)]> flush privileges;
MariaDB [(none)]> \q
```

Then to connect a Kodi instance to this database;
the file `userdata/advancedsettings.xml` needs to be dropped in the kodi folder.
```
<advancedsettings>
  <videodatabase>
    <type>mysql</type>
    <host>192.168.1.117</host>
    <port>3306</port>
    <user>kodi</user>
    <pass>kodi</pass>
  </videodatabase>

  <musicdatabase>
    <type>mysql</type>
    <host>192.168.1.117</host>
    <port>3306</port>
    <user>kodi</user>
    <pass>kodi</pass>
  </musicdatabase>

  <videolibrary>
    <importwatchedstate>true</importwatchedstate>
    <importresumepoint>true</importresumepoint>
  </videolibrary>
</advancedsettings>
```

For regular linux users, this directory is `~/.kodi`.
For the Firestick, the location is `/sdcard/Android/data/org.xbmc.kodi/files/.kodi/userdata/`
Do note that the server needs the followind service enabled in `firewalld`

* ***mysql*** **(3306 TCP)**: The port to connect to MariaDB.

To put this file in the Firestick; I used `adb` through network.
It's described [here](https://developer.amazon.com/docs/fire-tv/connecting-adb-to-device.html).

# NFS Problems

So I have been trying to setup NFS; but it seems harder than I thought.
At least for this usecase.

I started by reading the [ArchWiki](https://wiki.archlinux.org/index.php/NFS).
Which leads me into making the following entries to my `/etc/fstab`

```
/home/sbp/Music         /srv/nfs/media/Music-Home       none    defaults,rbind  0   0
/home/sbp/Videos        /srv/nfs/media/Videos-Home      none    defaults,rbind  0   0
/home/sbp/Pictures      /srv/nfs/media/Pictures-Home    none    defaults,rbind  0   0
/home/archive/Music     /srv/nfs/media/Music-Archive    none    defaults,rbind  0   0
/home/archive/Videos    /srv/nfs/media/Videos-Archive   none    defaults,rbind  0   0
/home/archive/Pictures  /srv/nfs/media/Videos-Archive   none    defaults,rbind  0   0
```

And created a file named `/etc/exports.d/server.exports`

```
# Home folder: Make available to edit to homestation and laptop
/srv/nfs/home sbp-homestation(rw,sync,crossmnt,insecure,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
/srv/nfs/home sbp-laptop(rw,sync,crossmnt,insecure,no_subtree_check,all_squash,anonuid=1000,anongid=1000)

# Media share; Allow all local connections to view files
/srv/nfs/media 192.168.1.0/24(ro,sync,crossmnt,insecure,no_subtree_check,all_squash,anonuid=1000,anongid=1000)
```

I opened the service through my firewall; which was the `nfs` (opens the `2049 TCP` port).
I did this both on my server, and my homestation.
(Idea was I also want to share some folders from the homestation.)

## Problem 1: No hostname resolution

I did `sudo exportfs -arv` on the server. And; 
```
exportfs: Failed to resolve sbp-homestation
exportfs: Failed to resolve sbp-homestation
exportfs: Failed to resolve sbp-laptop
exportfs: Failed to resolve sbp-laptop
```
Which baffled me on two terms

* Why would the hosts be tried for resolution?
Does the config need the computers to be available on export?
Seems like a ridiculous setup to me. Unfortunately, that is the case;
at least by specifying hostnames.
To make sure only my machines have read/write access to my home folder;
I will probably have to authenticate my machines, which will be Kerberos.
But anyways; that's something to think about later.
* Wait. You are trying to resolve sbp-homestation. Which is online right now.
WHY WOULD YOU FAIL TO DO SO? Unless . . .

Now, this is an issue I never came accross before.
I dreaded issuing `ping sbp-homestation`. The result;
```
ping: sbp-homestation: Name or service not known
```

WHAT?

I did a double-down. I did `ping sbp-server` from my homestation.

Nada.

What is going on? I used termux on my phone, and logged in with my laptop too.
Here is what I surmised.

* `sbp-server` is not resolvable by any other computer in my home network.
* My other devices (`sbp-homestation`, `sbp-laptop`, `sbp-phone`) can resolve eachother.
* `/etc/nsswitch.conf` is identical in all devices. (Sans the Android)
* Everyone can resolve each other using `avahi`.
Issuing `ping sbp-<cmp>.local` does work;
```
ping sbp-homestation.local
PING sbp-homestation.local(sbp-homestation.local (fe80::b3f:42e9:b87c:bc8a%wifi-server)) 56 data bytes
64 bytes from sbp-homestation.local (fe80::b3f:42e9:b87c:bc8a%wifi-server): icmp_seq=1 ttl=64 time=242 ms
^C
--- sbp-homestation.local ping statistics ---
2 packets transmitted, 1 received, 50% packet loss, time 1002ms
rtt min/avg/max/mdev = 242.212/242.212/242.212/0.000 ms
```
However; avahi is working through IPv6.

Immediately, this is not terrible.
I don't really need hostname resolution right now.
I don't mind using IPv6; and I don't mind an extra `.local` suffix.
Kodi NFS does not use hostname resolution anyway; it needs static IPv4 IP.

I know for a fact that every computer I use has the same network configuration files.
I use `git` with `etckeeper` to keep everything in sync.
Which lead me to the fact that the only difference between the devices was the following in `/etc/dhcpcd.conf`
```
# Configure static ip for server ethernet port
interface wifi-server
arping 192.168.1.0
arping 192.168.1.1

interface ethernet-server
arping 192.168.1.0
arping 192.168.1.1

profile 192.168.1.0
static ip_address=192.168.1.113
static routers=192.168.1.0
static domain_name_servers=192.168.1.0

profile 192.168.1.1
static ip_address=192.168.1.117
static routers=192.168.1.1
static domain_name_servers=192.168.1.0
```

The breakdown of what's happening here is;
I rename my network interfaces using udev,
so that I can write configuration that is machine agnostic.
(But can configure stuff differently in the case when I want to.)
I wanted to set a static IP address for my server only.
So I set things up following [this page](https://www.raspberrypi.org/forums/viewtopic.php?t=140252)
However; I realized that blindly I configured in the wrong DNS address.
(The lines with `static domain_name_servers`)
Removing those lines, and restarting `dhcpcd` and `unbound` fixed one part of this issue.
I can resolve `sbp-server` to the IPv4 address that is fine.
I still cannot resolve any other computer (`sbp-homestation`) from the server.

Immediate lesson is, honestly, ***DON'T COPY PASTE, TRY TO UNDERSTAND EACH LINE***.
No matter how good you think you are; you should never ever do this.

## Problem 2: Firewall

(I will mention that I have been trying to find the appropriate settings for two months.)
Anyways; things are configured, and I have done the following;

* No firewalls on either of the computers. (firewalld is disabled)
* Issuing `showmount -e sbp-server` displays the following
```
/srv/nfs/media 192.168.1.0/24
/srv/nfs/sbp   192.168.1.0/24
/srv/nfs       192.168.1.0/24
```
So we know that `nfs3` is working. (Showmount is nfs3 only)
This is important; because although it is not documented anywhere;
Kodi can only use `nfs3` and not `nfs4`.
Apparently; Kodi uses `libnfs`, which should have support for `nfs4`
but it is not implemented in Kodi 18.
* Running the following works successfully;
```
mount sbp-server:/srv/nfs/media         /mnt # IPv4, using nfs3
mount sbp-server.local:/srv/nfs/media   /mnt # IPv6, using nfs3
mount sbp-server:/media                 /mnt # IPv4, using nfs4
mount sbp-server.local:/media           /mnt # IPv6, using nfs4
```
* When I open Kodi from my laptop and want to add sources;
I can see and navigate to my server in the NFS menu.

At this stage; from my experiments;
enabling firewall in any of the computers breaks Kodi showing in the menu.
I keep my server on the **internal** zone;
by putting both `wifi-server` and `ethernet-server` to the internal zone.

I needed to enable services to my `internal` zone, so that NFS works.
Borrowing from [this link](https://unix.stackexchange.com/questions/243756/nfs-servers-and-firewalld),
it seems that for NFS to work with Kodi, `mountd`, `nfs`, and `rpc-bind` need to be open.

These are the services and ports I have opened on the server for Kodi;

* ***mountd*** **(20048 TCP/UDP)**: This allows `showmount`.
(Apparently in other distros; mountd is not specified in `/etc/services`;
hence this port is random. It must be set to a static port,
and that port should be opened in the firewall)
* ***mysql*** **(3306 TCP)**: This is for MariaDB server access.
* ***nfs*** **(2049 TCP)**: This is the main port that should be opened.
* ***rpc-bind:*** **(111 UDP/TCP)**: This allows use of `rpcinfo` I believe.

And through enabling these services on the server,
I am able to see my mount points and browse using Kodi.

There is a firewall problem on the client end.
It must be because when I enable the firewall on the client end,
I can't see the server in the NFS listing (in Kodi) anymore.
This is odd; because a client firewall should not block access to a server.

There is probably a port I can open on the client to get the entry back.
But manual entry works fine; and I will use it as such.
Not to mention; it's doable in the Firestick,
and the homestation can still play the files.

# Getting the Firestick working

I already sideloaded Kodi on my firestick some time ago.
When the Arch packages move on to version 19,
I will put in the sideloader here as well.

# End remarks

All set up; and everything is working!
I think I got my media under my own control for the time being.
Feel free to reach out for any questions.
