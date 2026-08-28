# 🌈 Hyperion Ambilight

A DIY Ambilight-style system that analyses a live HDMI video feed and reproduces the colours around the TV using 112 WS2812B addressable LEDs.

## Demo

![Hyperion Ambilight demo](../../assets/hyperion-sonic-demo.gif)

The demo uses the **Sonic the Hedgehog movie — baseball stadium scene**, showing the LED colours following the on-screen content.

## System architecture

```text
HDMI sources
     │
     ▼
HDMI switch
     │
     ▼
HDMI splitter ───────────────► TV
     │
     ▼
HDMI → capture path
     │
     ▼
Raspberry Pi
(Hyperion)
     │
     │ LAN / JSON
     ▼
NodeMCU
(WLED)
     │
     ▼
112 × WS2812B LEDs
```

## Wiring / signal flow

![Hyperion wiring diagram](../../assets/hyperion-wiring-diagram.png)

## Hardware

- Raspberry Pi 3B+
- HDMI switch
- HDMI splitter
- HDMI capture hardware
- NodeMCU
- 112 × WS2812B LEDs
- 5 V power supply

The Pi runs the video-processing side while the NodeMCU runs WLED and drives the LED strip.

## How it works

The HDMI switch lets multiple sources feed the system. The splitter sends one copy to the TV and another into the capture path. The Raspberry Pi receives the captured image and Hyperion calculates the colours required around the screen.

Hyperion then sends lighting data over the LAN to WLED, which drives the WS2812B strip.

This separation keeps video processing and LED timing/control on different devices:

**video capture → image processing → network → LED controller → pixels**

## Why I built it

I wanted to understand the complete signal chain rather than buying an off-the-shelf Ambilight system. It became a practical exercise in HDMI routing, video capture, Linux, networking, microcontrollers and addressable LEDs.

## Demo

The intended demo is a short recording using the **Sonic the Hedgehog movie — baseball stadium scene**, showing the LED colours following the on-screen action.

For GitHub, a short GIF is preferable for inline playback because README files don't provide reliable inline MP4/MOV playback.
