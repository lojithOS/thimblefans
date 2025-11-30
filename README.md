artix linux s6 fan service for lian li infinity, written in C, tailored to my system but easily adaptable.

Requires amd cpu and for you to run `modprobe k10temp`. That'll populate `/sys/class/hwmon/hwmon1/temp1_input` which the service will read every 6 seconds to get a cpu temperature number, then it'll tell the fans to run at a certain speed.

Ideally the install script would move the fan_speed_control binary somewhere more sensible, and reference that location in `s6-fan_speed_control/run`, cause right now it just points to my github page. But I am tired, so you can do it.

mint? sudo apt install -y linux-image-6.8.0-87-generic linux-headers-6.8.0-87-generic
