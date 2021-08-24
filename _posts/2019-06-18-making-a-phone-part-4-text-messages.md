---
layout: post
title: "Making a Phone Part 4: Text Messages"
date: "2019-06-18 02:35:00"
excerpt: |
  Sending texts is the next goalpost. The backend of this was pretty easy thanks to the Adafruit FONA library. The hard part was building a frontend for 9-key text entry. After a couple of after-work code sessions I got something complete enough to allow for lower-case text entry including spaces and punctuation.
tags:
  - hardware
  - phonium
---

> This and all my other [\#phonium][1] posts were originally published to [Scuttlebutt][2]. After running into some ssb-specific problems with identity continuity I've decided to republish them all on my own site at the originally-posted dates. They are in reality showing up on the internet for the first time in August of 2021. [original ssb link][3]

* [Part 1][4] background, motivations
* [Part 2][5] getting started, making calls
* [Part 3][6] answering calls, upgrading to a 32-bit microcontroller

<video alt="Composing a text message" controls="undefined">
  <source src="/images/making-a-phone-part-4-text-messages.webm">
</video>

Sending texts is the next goalpost. The backend of this was pretty easy thanks to the Adafruit FONA library. The hard part was building a frontend for 9-key text entry. After a couple of after-work code sessions I got something complete enough to allow for lower-case text entry including spaces and punctuation. The UX, however, remains horrible. Like I mentioned before, the EPD refreshes the whole screen (multiple times actually) every time you update it. That second-or-so of lag time every time you press a button is excruciating. Especially since you can’t just click-click-click and wait for the screen to update. Subsequent presses of the button do nothing until the display is finished updating. That means I had to make the move-onto-the-key-character timeout really long. 3 seconds. You know, if you want to enter “hi” on 9-key phone, you have to hit 4, wait, 4? Well, that wait has to be long enough to accommodate the screen refresh.

This sent me back to the drawing board about the EPD. I really want to use e-paper because of the extremely low power draw, but if I can’t do fast partial updates, then the phone is almost unusable. Adafruit sells a SHARP memory display which supposedly has pretty low power draw. Unfortunately, it has no on-board memory like the EPD module I’m using, so the entire display buffer has to fit in the microcontroller’s memory. The Teensy LC isn’t enough. I looked more and found a similar sized EPD sold by Waveshare that supports partial update. It, too, needs a higher-RAM microcontroller though. I decided I’d upgrade to a Teensy 3.2 and get the Waveshare EPD. Now, my last concern is that these displays are susceptible to burn-in because they’re not really designed for rapid updates. We’ll see how it does. If I have to, I’m okay with switching to the SHARP display. I ordered these parts on Saturday and they arrive yesterday.

While I waited, I worked on incoming text messages. This has two large chunks: a navigation menu screen for viewing a list of messages, and a detail screen for reading a message. The most daunting piece I see ahead is making a scrollable view for reading long messages. I’ve gotten it to do the minimum of printing how many messages there are, and then displaying the first one. A friend sent me the first SMS my phone has ever received. It thought something was wrong, data was corrupted, or encoded weirdly, or something, but after a little searching around, I learned that D83EDDA1 is the unicode hexadecimal for 🦡 and that the FONA does not handle emoji gracefully. Normally it gives you plain text (ASCII?) but if you include one emoji, suddenly the whole message is UTF-16 hex represented.

Well, that wraps up this episode. I’d love to dive into any details that you find interesting. If you want to see my source code, it’s on [GitHub][7]. I’ll write more updates as I make progress. Next up, I’ll be replacing the Teensy LC with the 3.2 and switching out the EPDs. Then I’ll try getting partial updates to work.

[1]:	/tags/phonium.html
[2]:	https://scuttlebutt.nz/
[3]:	https://viewer.scuttlebot.io/%256nvB0gMJTj%2BXS%2BiINJcPMmwpDQEIKdZ2316SjdCgeig%3D.sha256#%256nvB0gMJTj%2BXS%2BiINJcPMmwpDQEIKdZ2316SjdCgeig%3D.sha256
[4]:	{% post_url 2019-06-17-im-making-a-phone %}
[5]:	{% post_url 2019-06-17-making-a-phone-part-2-getting-started %}
[6]:	{% post_url 2019-06-18-making-a-phone-part-3-going-32-bit %}
[7]:	https://github.com/zacstewart/phonium "Phonium git repository"
