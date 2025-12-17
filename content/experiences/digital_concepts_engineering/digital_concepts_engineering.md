---
tags:
- MCU
- Robotics
- Python
- C/C++
date: 2022-07-04
title: Digital Concepts Engineering
draft: false
featured_image: '/images/experiences/dce/dce_x_series_logo.png'
---

During my time as an Electrical Graduate, I was seconded to a small but highly innovative startup called [Digital Concepts Engineering (DCE)](https://dconcepts.co.uk/). Their business model focused on retrofitting existing military and commercial vehicles converting them into unmanned or fully autonomous platforms. They operated across a diverse range of sectors, including Defence, Healthcare, Nuclear, and Agriculture, making it a fascinating environment to work in.

Shown below is their [**X Series platform**](https://dconcepts.co.uk/products/x-series/), one of the tracked robotic vehicles I had the opportunity to work with. It is a modular, ruggedised platform capable of supporting a wide range of sensors, payloads, and mission-specific equipment.

![DCE X-Series](/images/experiences/dce/dce_x_series_logo.png)

## The Task

My primary responsibility at DCE was the development of a **Universal Robot Controller**, designed to interface with the company’s wide range of robotic and vehicular platforms. These included:

- **HX60** – A heavy-duty, battle-hardened military logistics truck  
- **Ford Range Rover** – A modified commercial Range Rover platform  
- **X2–X4 series** – DCE’s own fleet of tracked unmanned ground vehicles  

The prototype I developed was a **multi-microcontroller system** built around the STM32 series, chosen for its performance and real-time capabilities. The architecture featured:

- A **primary microcontroller** responsible for low-latency IP communication with the target vehicle via long-range IP radios. It also handled critical user inputs such as joysticks, buttons, and real-time control loops.
- A **secondary microcontroller** driving a touchscreen LCD, providing an interactive UI for configuration, status monitoring, and telemetry.  

This separation of responsibilities offered improved safety, reliability, and maintainability—ensuring that high-priority, real-time control tasks were isolated from user-interface processing.

## Italy and Other Field Deployments

I also had the opportunity to travel to **Italy** to support one of DCE’s customers, assisting with trial deployments and field testing of the unmanned systems. This was an incredible hands-on experience and offered great insight into real-world robotic operations.

Beyond that, I attended several defence technology conferences and field demonstrations, giving me exposure to the latest advancements in autonomous systems, robotics, and military innovation.

{{< carousel
  "/images/experiences/dce/dce_logo.png|Digital Concepts Engineering"
  "/images/experiences/dce/dce_x_series_logo.png| X Series Vehicles"
  "/images/experiences/dce/ghost_robotics.jpeg|Ghost Robotics Quadruped"
  "/images/experiences/dce/hx60.jpeg|DCE HX60 Vehicle"
  "/images/experiences/dce/x_series_garage.png|X Series Vehicle Garage"
>}}
