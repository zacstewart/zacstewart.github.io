---
layout: post
title: Establish Your Encrypted Channels Now
---

The purpose of this post isn't to bemoan the expanding surveillance state,
warn of impending civil liberty revocation, or even to make you feel paranoid.
I only want to talk sensibly about a few tools that we should all be comfortable
using and know when we should use them.

There may come a time in your life wherein you will need a private, encrypted
channel to communicate with someone, whether it's your loved ones, your employer,
a reporter, your lawyer, whatever. At some point, you may urgently need to do so.
Even more importantly, there may come a time when someone needs to contact you
privately.

When said time arrives, it may be difficult to establish that channel in a
timely manner. You don't want to be groping in the dark for a way to send that
damning report of an impending disaster at a nuclear plant to a watchdog group,
or flipping a coin over whether to trust the authenticity of the key signing
those rebel dispatches, or hell, sending some racy, career destroying photos by
email in the clear.

If the top man at the CIA having his private communications breached isn't
enough motivation to take good look at your own privacy, then nothing I can say
is. So, put away your tinfoil hats and lets go!

## Off-the-Record Instant Messaging

[OTR][1] is probably the easiest one and there is absolutely _no_ reason you
shouldn't be able to do this one now–right now. As soon as you finish this
section, go do it.

It's as easy as installing [Adium][2] (or [Pidgin][3] if you're not on a Mac),
signing into your preferred messaging service (Google chat, AIM, etc…), going
to the Advanced preference pane, Encryption, and then generate a private key.
Have your partner do the same.

Initiate an encrypted OTR chat with them, accept and verify their key (provided
that you're sure it's them). And next time you need to converse privately,
"Initiate Encrypted OTR chat." Messages will be passed as encrypted blobs in
the clear. If you want to see one, sign in with another client while in an OTR
session and look at the messages coming from your partner.

## GPG Encrypted Email

Your email is not private. At all. There's not even a paper envelope
surrounding it to shield it from prying eyes, making "mail" a misnomer. For now
on, think of it as an epostcard. Anyone who happened to handle your message in
between you and your intended recipient has potentially read it.

[GPG][4] is an open source implementation of the OpenPGP standard, and many
mail clients provide built-in support or add-ons for it.

On OS X, you can install it with [Homebrew][5] (`brew install gpg`). Every flavor of
Linux I've ever used provides GPG. It should be available via your package manager.
Windows users should look into [Gpg4win][6].

To create your key, run `gpg --gen-key`. You will be guided through a series of
questions. In order for someone to send you an encrypted message, they need your
public key. To get that, run `gpg --armor --output pubkey.txt --export 'Your
Name'`.

Publish this thing as broadly as possible so that anyone who ends up
needing it doesn't have to go hunting for it. For instance, I keep [my key][7]
in a public gist. You can also publish it to a central keyserver: `gpg
--send-keys 'Your Name' --keyserver hkp://subkeys.pgp.net`.

GPG can be used to accomplish a lot more than just email encryption, though.
You can use it to encrypt any data, and since it can be used like any other UNIX
utility, you can incorporate it into larger, more complex workflows with a little
shell fu. Check out this [more detailed guide][8] by Paul Heinlein.

## Private Browsing

I don't recommend that you–nor do I myself–use Tor or a VPN on a constant
basis, but these should be two tools that you have at your disposal and are
comfortable using. Depending on your circumstances, you should evaluate which
is the best solution for you.

If you are abroad in a country where it's safe to assume you are snooped on,
it's sensible to be running a VPN back home. You can even [run one on a
Raspberry Pi][9]. In addition to a secure tunnel back to your home internet
connection, a VPN gives you the added benefit of having LAN access to your
devices at home.

Paid VPN services can be very useful, but should not be considered a way to
perpetrate crimes without a paper trail. Providers are typically businesses who
will comply with investigators to the full extent of the law. However, if you
choose a VPN provider from a jurisdiction where your activities are _not_
illegal, they should have no reason to reveal your identity. Jurisdiction
arbitrage is part of the game here.

[Tor][10] is an anonymity tool. Not only does it let you browse the internet as a
nameless, shady drifter, but it gives you access to a darknet–a shadowy place
not accessible from the normal internet. You're on your own here; explore at
your own peril. The downside to Tor is that it's very slow.

## Donate to the EFF

These tools are all bandaids for a bigger problem we have: the corrosion of
civil liberties. They are priceless, but we need to put up more than a technical
defense. Skip a few lattes and make a generous donation to [an organization
that's fighting for your rights][11].

[1]: http://www.cypherpunks.ca/otr/ "Off-the-Record Messaging"
[2]: http://adium.im "Adium"
[3]: http://www.pidgin.im "Pidgin"
[4]: http://www.gnupg.org
[5]: http://mxcl.github.com/homebrew/
[6]: http://gpg4win.org
[7]: https://gist.github.com/zacstewart/4190041
[8]: http://www.madboa.com/geek/gpg-quickstart/
[9]: http://lifehacker.com/5978098/turn-a-raspberry-pi-into-a-personal-vpn-for-secure-browsing-anywhere-you-go
[10]: https://www.torproject.org
[11]: https://www.eff.org
