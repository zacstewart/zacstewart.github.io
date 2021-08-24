---
layout: post
title: "Making a Phone Part 3: Going 32-bit"
date: "2019-06-18 02:30:25"
excerpt: |
  Naturally, the next function is answering incoming calls. One way to do that (aka the wrong way) is to poll the cellular module to ask it what its call status is. The microcontroller communicates with the FONA via a serial interface, so doing that every tick of the `loop` function (16 Mhz) is very chatty.
image: /images/making-a-phone-part-3-going-32-bit.jpg
tags:
  - hardware
  - phonium
---

> This and all my other [\#phonium][1] posts were originally published to [Scuttlebutt][2]. After running into some ssb-specific problems with identity continuity I've decided to republish them all on my own site at the originally-posted dates. They are in reality showing up on the internet for the first time in August of 2021. [original ssb link][3]

* [Part 1][4] background, motivations
* [Part 2][5] getting started, making calls

![A Teensy microcontroller][image-1]

Naturally, the next function is answering incoming calls. One way to do that (aka the wrong way) is to poll the cellular module to ask it what its call status is. The microcontroller communicates with the FONA via a serial interface, so doing that every tick of the `loop` function (16 Mhz) is very chatty. I suspect it would kill a battery very quickly. The right way is to handle a hardware interrupt from the FONA. Sadly, 20/20 pins are currently occupied and the I’d need to connect to the cell module’s RI (ringer interrupt) pin for that. I screwed around with the RESET pins again with no luck.

I had initially thought that I’d prototype with the Uno and then switch to an Arduino Nano when I wanted to scale things down. Now I was looking for something that could support more peripherals. I found the [Teensy][6] family of microcontrollers and was enthused. The Teensy LC looked like a winner. It’s smaller than the Uno, has 8 KB of RAM, 27 GPIO pins, and a 48 Mhz clock speed. It didn’t hurt that it has more ROM too, because I was a little worried that my code was going to get cramped in the space of 32 KB.

The Teensy arrived, and I soldered some headers to it and wired it up. The EPD wouldn’t power up. I could see from Serial output that button presses were being registering. I started poking around with my multimeter, and confirmed that no power was getting to the EPD. I tried giving it some power view the vout from the Uno that was now completely disconnected. For a few moments the display came to life and showed the graphics test I had uploaded to the Teensy. Then everything stopped. The Teensy quit responding to button presses, quit logging to Serial. It stopped restarting up uploading new code. I fried it with my tampering.

Undeterred, I ordered another one. While I waited for it to arrive, I rewired everything to the Uno. I disconnected the BUSY pin from the EPD to use the GPIO pin that it occupied. This makes the EPD update even slower, because instead of waiting just until the display reports that it’s done drawing, the driver waits a long, static amount of time. But, now I had a pin for the FONA’s ringer interrupt. Stealing this pin from the EPD worked and I was able to answer incoming calls, but I knew this was a temporary solution.

When my new Teensy arrived, I soldered and wired it all up again, and this time I was more cautious in exploring the lack of power to the EPD. I made the discovery that the power rail on my long breadboard does not expend the length of the entire board. It’s split in half. Facepalm. Moving the power lines up past the midpoint of the board fixed that.

Next I started getting the FONA to work with the Teensy. On the Uno, it was communicating via SoftwareSerial. The Teensy has several hardware serial channels so I connected it to what I thought were the right pins for Serial1. On boot, everything would power up, but the microcontroller would send an AT command repeatedly and never hear anything back from the cell module. I putzed around trying to figure out what was wrong with it for days. I read a bunch of misleading information about the FONA not supporting hardware serial and tried to go back to SoftwareSerial. I read misleading information about the Teensy not supporting RX via SoftwareSerial.

I racked my brains, multimeter tested everything, and then in a moment of glorious stupidity tried swapping the wires on the RX and TX pins. I had connected the Teensy’s 0 (RX) and 1 (TX) to the FONA’s RX and TX (RX\<-\>RX, TX\<-\>TX, see the problem?). Now those AT commands were answered, and after a few more moments of stupidity before I realized I didn’t have the uFL antenna connected, everything was working. It this point, it’s a bona fide phone that can do incoming and outgoing calls.

I also invested a little tooling work into getting off of the Arduino IDE. I found some Makefile examples for building and uploading to the Teensy. Initially, it was building an enormous binary, but I figured out how to make it prune out unused symbols in the linking phase and it trimmed it down significantly.

[1]:	/tags/phonium.html
[2]:	https://scuttlebutt.nz/
[3]:	https://viewer.scuttlebot.io/%25oSboStN4v114mBik1nXWMRG3cUPxJs9UnyTAZpJvaBw%3D.sha256
[4]:	{% post_url 2019-06-17-im-making-a-phone %}
[5]:	{% post_url 2019-06-17-making-a-phone-part-2-getting-started %}
[6]:	https://www.pjrc.com/teensy/

[image-1]:	/images/making-a-phone-part-3-going-32-bit.jpg
