---
layout: post
title: Control a StorkAir/Zehnder WHR 930 ventilation unit using mqtt
category: domotica
comments: true
tags:
    - whr930
    - wtw
---

Our house is equipped with a WHR 930 ventilation system, in Dutch a ‘warmte terugwin systeem (wtw)’ and since we have the ‘basic’ version, we have to control it using switch in the bathroom. There is a RF module available for the WHR 930, but that’s a pretty expensive option and i could not figure out how open it was. Since i want to control it from Home Assistant, it must be open or should have some sort of API.

![]({{ site.baseurl }}/assets/whr930.jpg)

Searching the internet for possibilities i learned that the WHR 930 has a serial interface on it’s mainboard and that the protocol is [fully reverse engineered!](http://www.see-solutions.de/sonstiges/Protokollbeschreibung_ComfoAir.pdf) The picture below is one of the mainboard, the red arrow points at the serial interface (RJ45)

![]({{ site.baseurl }}/assets/whr930_board.png)

I modified a UTP cable to get the right pin layout for a Serial<>USB converter and attached it to a Raspberry Pi and wrote some python code to interface with the WHR 930 via the serial connection. The code reads the various temperature values and fan status and publishes the results on a mqtt topic. The python code subscribes to a specific mqtt topic (house/2/attic/wtw/set_ventilation_level) for messages (0, 1, 2 or 3) to set the ventilation level. Level 0 stops the ventilation, i did not even know that the WHR 930 could do that 🙂

For now i am happy, but the serial protocol description shows that there is much more possible. Maybe i will look into that later, but do not hesitate to contact me (see my Github page for contact info) if you found out nice additions!

For integration with Home Assistant, see the [README](https://github.com/Mosibi/whr_930) file on my Github channel.

![]({{ site.baseurl }}/assets/whr930_homeassistant_2.png)
