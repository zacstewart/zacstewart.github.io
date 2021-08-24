---
layout: post
title: "Making a Phone Part 6: SHARP Memory Display"
date: "2019-07-04 16:59:18"
excerpt: |
  I’m frustrated by my struggles to get an e-paper display that can do partial screen updates, so I’ve decided to give another technology a shot. I ordered a SHARP Memory Display from Adafruit. I also threw in a small mic and a speaker because I was going to need those anyway, sooner or later.
image: /images/making-a-phone-part-5-navigation-flow.jpg
tags:
  - hardware
  - phonium
---

> This and all my other [\#phonium][1] posts were originally published to [Scuttlebutt][2]. After running into some ssb-specific problems with identity continuity I've decided to republish them all on my own site at the originally-posted dates. They are in reality showing up on the internet for the first time in August of 2021. [original ssb link][3]

* [Part 1][4] background, motivations
* [Part 2][5] getting started, making calls
* [Part 3][6] answering calls, upgrading to a 32-bit microcontroller
* [Part 4][7] sending and receiving text messages
* [Part 5][8] EPD partial update, menu navigation flow

I’m frustrated by my struggles to get an e-paper display that can do partial screen updates, so I’ve decided to give another technology a shot. I ordered a [SHARP Memory Display][9] from Adafruit. I also threw in a small mic and a speaker because I was going to need those anyway, sooner or later.

They arrived last weekend and I’ve had a little time this week to hook up the mem display and try it out. I had to solder header pins to it, as per usual and then figure out the wiring. It’s a write-only SPI device, so actually a little simpler to wire up than the EPD, and used fewer ports. However, lacking it’s own onboard memory buffer, it has to utilize the microcontroller’s memory. Good thing I upgraded to the more powerful Teensy 3.2.

![Prototype Phonium cell phone with new SHARP Memory Display beside repurposed EPD display and Teensy microcontroller][image-1]

After wiring it up I uploaded a demo sketch to try it out. I was impressed with the refresh rate it demonstrates. You could actually perform animations with this thing, or build games or whatever. The only complaints I have are that it has really poor viewing angles and it’s pretty low contrast. The whole surface looks metallic and reflective, which makes it very hard to read in low light. Because of that, I think I’ll eventually come back to e-paper, but I really just want to make some progress on the thing without worrying about the display for now.

Side note: what do you do with a disused Teensy LC and a slow-to-refresh e-paper display? I made a little magic 8-ball. I was thinking of loading it up with a bunch of [oblique strategies][10] or aphorisms or something so that every time you push a button you get a random one.

I replaced all the EPD code in the Phonium source with the mem display library. They share a similar interface since they both inherit from Adafruit GFX, but there were some slight changes. The OOP programmer in me wants to create my own display object to insulate the rest of the code from this mess should I change again, but the embedded device programmer in me says that would waste a few bytes of ROM and CPU cycles.

It has indeed made entering text messages much more enjoyable. I’ve begun work on an interface to navigate and read text messages. So far, I just have a list of “previews” (the first 9 chars of each message on the SIM). I’m going to tap out a least effort way to navigate up and down that list and then read one of them.

After that, I really need to start thinking about UI design. So far, everything is text-based with no real navigation or interaction signifiers. I’m not really sure how to go about sketching out screen UIs. Should I use pencil and paper, or just pixel art with an image editor? So much to figure out, but until next time, thanks for reading!

[1]:	/tags/phonium.html
[2]:	https://scuttlebutt.nz/
[3]:	https://viewer.scuttlebot.io/%251%2F57eTqD1nXYbhYUogciGenBAaip9TyhCFxV2YhNHcc%3D.sha256#%251%2F57eTqD1nXYbhYUogciGenBAaip9TyhCFxV2YhNHcc%3D.sha256
[4]:	{% post_url 2019-06-17-im-making-a-phone %}
[5]:	{% post_url 2019-06-17-making-a-phone-part-2-getting-started %}
[6]:	{% post_url 2019-06-18-making-a-phone-part-3-going-32-bit %}
[7]:	{% post_url 2019-06-18-making-a-phone-part-4-text-messages %}
[8]:	{% post_url 2019-06-23-making-a-phone-part-5-partial-update-setbacks-navigation-flows %}
[9]:	https://www.adafruit.com/product/3502
[10]:	https://en.wikipedia.org/wiki/Oblique_Strategies

[image-1]:	/images/making-a-phone-part-6-sharp-memory-display.jpg
