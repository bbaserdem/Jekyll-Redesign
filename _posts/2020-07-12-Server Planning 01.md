---
title: Server - Planning
date: 2020-07-12 12:00:00 -0400
categories: [Computers, Server]
tags: [linux, computer]
description: Planning my home server setup
toc: false
comments: false
---

I want to setup a home server.

# Why a home server?

I have been fascinated by the idea that servers can just run things in the background.
Certain things are useful when they are not wasting too many resources
and are running full time!
All my home computers are laptops so far, and I do enjoy not running them 24/7
for some of the tasks I have.

Even if you are not a tech savvy person, you can benefit from having a home server.
You can free up space on your computer by keeping your files within your network,
expeccially when you don't need to access them often.
You can also use your own computers as a cloud service.
Which frees you from hosting your data in someone else's computers,
which is a privacy risk.

Digital privacy is a strange discussion with my friends.
Among my circles, it comes down to the fact that people prefer convenience;
and the main argument is; *"I have nothing to hide."*
This actually does not work well in practice,
as I notice all my friends do actually hide stuff.
(Mostly their recreational drug use habits.)
While nefarious parties do abuse the privacy tools to fight law enforcement,
this is not an excuse to subject ourselves to surveilance.
We have a lot to lose if we become targets of active surveilance.
The state can always choose to marginalize you, even when you are not in wrong.
A good example is my government during 1980's;
when people would be flagged and taken by the secret police for promoting
various ideologies. (Ranging from communism to just western sympathy.)
While such opinions were legal to hold; the powers in place did not want them discussed.
And stifled their voices.
With current technological tools and massive surveilance,
these things would be far easier to do when you don't keep your digital life private.

Anyways, I don't want to derail this post too much.
[There is some reading here; I'm sure you can google more if you are interested.](https://teachprivacy.com/10-reasons-privacy-matters/)
My point here is that I am willing to sacrifice some convenience for a good deal of privacy.
And usually it's a good return of investment for a little effort.
I learn about how computers work in the meantime and that's fun on it's own regard.
I realize that 100% privacy is impossible.

One of these sacrifices is I try to self host whenever I can.
Specifically; this refers to me moving away from Dropbox to using Syncthing
and my own storage devices to have *cloud like* storage environment.
I trade the annual payment to Dropbox (along with their atrocious support)
with one time payments for storage space.

# Systems I will be currently setting up; as a part of the Server series.

* **Virtual machine deployment**: This ties in to the next few items.
Essentially, I want a few virtual machines running 24/7.
And I want to access these machines and maintain them from any of my computers.
But these VM's would be on the server; as to have them open 24/7.
* **Seedbox**: I use torrents. If I'm doing pirated ones, I do it
either to fetch digital versions of media I bought back home (and have no access to)
or to get some media for which I cannot obtain a high-quality digital hard copy otherwise.
I don't condone piracy unless it's the only option remaining.
While streaming services are used; I don't enjoy streaming being dependent on
what the content creator is enabling you to view.
I rather build my own digital library myself.
Anyways, what I do is I want to host a VM dedicated to running a VPN,
and a torrent server; which can be accessed through machines in my network.
* **VPN client**: To reach my computer at my laboratory; I have to use a VPN.
I am not comfortable using that VPN 24/7.
Hence I would like to have a VM dedicated to connecting to my lab VPN,
and I can use this VM to connect to the servers and workstation I have using SSH.
* **Network Storage Device**: I have media folders;
and basically I want to make them accessible throughout my network.
* **MariaDB**: I want to use Kodi to stream my media through multiple devices.
This step has been very easy; but allows me to almost have my own Netflix.

# Systems that I will be setting up; but not as a part of the Server series

While these services will be set up on my server;
they will also be set up accross all my computers as well.

* **Cloud service with Syncthing**: This will not be a part of the server setup.
Since it is almost trivial to set up.
I use [Syncthing](https://syncthing.net/) to sync my big files accross my computers.
In this usecase; as many backups as possible are better.
* **Firewall**: I think firewall is a thing everybody should have;
as it teaches about networking and a demo on how everything is so superbly convoluted
when it comes to networking.

# Future stuff that I would be interested in setting up, but not planning on doing this anytime soon

* **VPN server**: so that I can ssh into my server from my lab;
to check on my service.s
* Replace Google Calendar, Contacts and Notes with a CalDAV and CardDAV server.
* Set up my own git server for my projects.
* Host some services I have on the server to the internet, to be able to connect to my services.

# Hardware

After my CompuLab Fitlet2 died (I do NOT suggest this device for US customers,
shipping cost makes it a very poor choice) trying to set it up;
I decided to get a [Intel NUC NUC7i3DNHE](https://www.amazon.com/gp/product/B078TGV39W).
It is not fanless; but since it's compact it can be moved to the living room.
The pros over Fitlet2 are;

* Integrated wireless with bluetooth; so no wasted expansion slots to have wireless.
(I don't have access to my landlord's router; so I will be operating full wireless.)
* Cheaper price (300$ for an Intel i3 CPU device; pretty good bang for buck.)
The CPU is not Atom, hence is not horrible and you can put BSD on it.
* Supports both M.2 and SATA drives at the same time.
(Fitlet2 is a choose 2: M.2, Wifi, SATA)
* Has a VESA compatible mount; so you can plop it in the back of a screen and
have your own iMac-like workflow. (But why would you do this?)

Cons are

* Slightly larger; and does not have similar cool mount options.
* Not fanless
* Requires slightly more power
* Does not have a dedicated UPS like the one you can get from CompuLab.
* The CompuLab UPS does not work (UPS: 12V, NUC: 19V) so not power-outage safe.
* The NVME interface does not seem to be PCIE; so the NVME drive appears on
a SATA interface (`/dev/sda` instead of `/dev/nvme0n1`)
I am not sure if this translates to read/write being limited to SATA interface,
but honestly I don't need crazy read/write speed here.

Overall; I think it was a smart decision.
With the peripherals; 

* NUC: 300$
* 1TB NVME drive: 180$
* 8+8 GB DDR4 RAM 65$
* 4TB 2.5" SSD 450$

it came to around 1k$ in expenses.
If I dialed down to only the SSD and went with the fitlet2;
my expenses would be around the same.

* Fitlet2 of my specification 400$
* 4TB 2.5" SSD 450$
* Expansion in FACET card 30$
* Shipping 50$

(With about lower expendible storage; since around 1TB would not go to my media library)
I would also have to expand into a NAS earlier than I will; since I don't have that extra TB.
Also the reason why I definitely want the 4TB SSD; and not just 1TB of storage.

This is to show the planning that goes into the server setup.
Definitely not the most optimal; but this works for me.

# TL;DR:

I'm setting up a server; I paid 1k$ in hardware and in the process of setting it up.
Watch out for new posts about how I, through trial and error,
set this *"leave it in a corner and forget about it server"* up.
