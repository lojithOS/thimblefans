# Wtf is this?

artix linux s6 fan service for lian li infinity, written in C, tailored to my system but easily adaptable.

Requires amd cpu and for you to run `modprobe k10temp`. That'll populate `/sys/class/hwmon/hwmon1/temp1_input` which the service will read every 6 seconds to get a cpu temperature number, then it'll tell the fans to run at a certain s

# Installation

## Artix

Put binary in /bin/ then throw `fan_speed_control &` in `.xinitrc`.
Alternatively you could put it in the shell script, like:

    if status is-login
      fan_speed_control
    end

Though be aware that's untested.

## Cachyos

Incredibly easy, just download it, extract it, put the binary in /bin/ or whereever you want, then load up `Startup Applications` application, and add the binary. You'll still need to run `modprobe k10temp`.

## Mint

Update your kernel to 6.0+
Your motherboard uses zen 4 which the linux 4v is unfamiliar with.
Be warned though that updating the kernel to 6.0 will break your network manager, so be prepared to deal with that.
You'll still need to run `modprobe k10temp` afterwards.
