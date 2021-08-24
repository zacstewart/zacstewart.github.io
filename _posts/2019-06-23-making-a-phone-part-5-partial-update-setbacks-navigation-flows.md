---
layout: post
title: "Making a Phone Part 5: Partial Update Setbacks, Navigation Flows"
date: "2019-06-23 01:33:25"
excerpt: |
  I finally ordered a e-paper display capable of partial refresh. A 1.54" display made by Good Display and packaged with a PCB by a supplier called Waveshare. They also publish some drivers and demo code. I needed a higher-RAM microcontroller to handle partial updates, so I upgraded my Teensy LC to a Teensy 3.2.
tags:
  - hardware
  - phonium
---

> This and all my other [\#phonium][1] posts were originally published to [Scuttlebutt][2]. After running into some ssb-specific problems with identity continuity I've decided to republish them all on my own site at the originally-posted dates. They are in reality showing up on the internet for the first time in August of 2021. [original ssb link][3]

* [Part 1][4] background, motivations
* [Part 2][5] getting started, making calls
* [Part 3][6] answering calls, upgrading to a 32-bit microcontroller
* [Part 4][7] sending and receiving text messages

I finally ordered a e-paper display capable of partial refresh. A [1.54" display][8] made by Good Display and packaged with a PCB by a supplier called Waveshare. They also publish some drivers and demo code. I needed a higher-RAM microcontroller to handle partial updates, so I upgraded my Teensy LC to a [Teensy 3.2][9].

I wired up the new Teensy first. For the most part, it was a drop-in replacement because it has the same pin layout. My custom Makefile build did not continue to work, though. I burnt several hours late into the night trying to get it to work. I got past a lot of errors, but I’m not quite there. I spent enough time on it, though. I want to keep making progress on the phone itself; I can bikeshed later. For now, I’m back to building with the Arduino IDE.

I underestimated how hard replacing the display would be. I wired it all up, and then installed a library called [GxEPD][10] that supposedly supports this display. It inherits from the same `Adafruit_GFX` interface that my current `Adafruit_EPD` driver uses, so it was basically just replacing the constructor and changing some type signatures. Sadly, I uploaded the sketch and the display did nothing.

I figured I may have jumped the gun a little and should take a step back. I opened up an example sketch that comes with GxEPD and configured it for the pins I have it connected to. Still nothing. I took a step further back and grabbed the janky library and demo code that came from Waveshare. Even still, nothing. I put the Teensy LC I just replaced on another breadboard and wired the display up to it and uploaded the sketch. Nada. I got my old Uno-compatible board out from when I first started this project. Wired up, uploaded, noped.

At this point I don’t know what to think. Am I dumb, did I fry this display, or did they send me a defective one? As a software engineer, I’m used to being pretty damn sure that any bug I’m encountering is my fault. Well-trodden code like popular frameworks, or less till, operating systems, are exponentially less likely to have bugs than the code that I write, so usually it’s safe to assume that if I bang my head against the wall for long enough I’ll figure it out. Can I assume the same when it comes to hardware projects? I don’t have an intuition for this.

I filed a return with Amazon and have it packaged up to drop off at UPS next time I’m out. In the meantime, I’m feeling pretty beat up by e-paper. I decided to cop out and get a [SHARP Memory Display][11] from Adafruit. It purports to be the best of both worlds: lower power consumption with a fast refresh rate. It also bills great sunlight readability. It isn’t permanent like e-paper, but you only have to pulse the display with power once every second or so to persist the image. I also threw in a little 8 Ohm speaker and a tiny electret microphone. I’ll to and structure my code so that I can swap out the display later if I have a notion of going back to e-paper.

In the meantime, I can share a little of the UI design I’ve done. Individual screens are not “designed” by any stretch of the imagination. They really just display text and there’s no UI indicators for navigating from one screen to the next. I have 168x144px to work with and would love some minimalist aesthetic inspiration here. I’m not a very good designer and don’t really know where to start. I’m currently reading the Design of Everyday Things. **Seeking design advice.**

I mentioned the push, pop, replace navigation scheme I built before to transition between screens. Here’s a flow diagram showing how it works. It’s important to map out each transition, because it would be really bad to get the user into a dead end, or fail to have some data cleared out when it should be before a transition.

![Hand-drawn Phonium navigation flow diagram][image-1]

I’ve also been thinking about what the post-breadboard phase of this project would look like. I’d like to design a PCB and get a small batch of them printed. I’ve never designed a schematic from scratch, simple circuits when I was kid and my grandpa was teaching me some electronics basics. What are the merits to using something like EAGLE vs Kicad? How would would I even get started? Do I just find (or create) schematics for each component I’m currently using, copy and paste them into another project and then start wiring things together with copper traces?

Last thoughts for this update. I’ve been thinking about novel features to include that would make this phone delightful without being toxic and distracting. I want to avoid gimmicks, but try things that might be weird. One limitation I have right now is my 4x4 button keypad. I hate touchscreens, so I’m not interested in that. But, what about some kind of analog input? I’ve considered using an incremental rotary encoder (aka a nob you can turn) to navigate menus or scroll texts. That might not be great for one-handed use. Another thing I’ve considered is putting an array of capacitive touch sensors (like tiny copper pinheads) that you can swipe your finger over. I’ve also considered some novel sensors like air quality or temperature. Are there any controls or sensors you’d like in a phone?

Thanks for reading!

[1]:	/tags/phonium.html
[2]:	https://scuttlebutt.nz/
[3]:	https://viewer.scuttlebot.io/%252yRFJesmO40UnvhEn6yaONkT28fGHA6UD3mV160HXmE%3D.sha256#%252yRFJesmO40UnvhEn6yaONkT28fGHA6UD3mV160HXmE%3D.sha256
[4]:	{% post_url 2019-06-17-im-making-a-phone %}
[5]:	{% post_url 2019-06-17-making-a-phone-part-2-getting-started %}
[6]:	{% post_url 2019-06-18-making-a-phone-part-3-going-32-bit %}
[7]:	{% post_url 2019-06-18-making-a-phone-part-4-text-messages %}
[8]:	https://www.waveshare.com/1.54inch-e-paper-module.htm
[9]:	https://www.pjrc.com/teensy/teensy31.html
[10]:	https://github.com/ZinggJM/GxEPD
[11]:	https://www.adafruit.com/product/3502

[image-1]:	/images/making-a-phone-part-5-navigation-flow.jpg
