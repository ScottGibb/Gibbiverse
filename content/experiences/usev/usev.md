---
tags:
- MCU
- CANBUS
- Arduino
date: 2019-07-01
title: University of Strathclyde Eco Vehicle
featured_image: /images/experiences/university_of_strathclyde.png
draft: false
---

One of the earliest properly multidisciplinary engineering teams I was part of was the University of Strathclyde Eco Vehicle ([USEV](https://www.usev.co.uk/)). In short: a large group of slightly sleep-deprived students attempting to design, build, wire, debug, break, and then re‑debug a small-scale electric vehicle for the [Shell Eco‑Marathon](https://www.shellecomarathon.com/).

![usev car](/images/experiences/usev/usev_track_day.jpeg)

**It was chaotic, technical, occasionally stressful — and genuinely one of the most fun engineering experiences I’ve had.**

---

## The Team

USEV was big. At its peak, it had 100+ students from multiple year groups and disciplines, all trying to pull in the same direction (with varying degrees of success depending on deadlines).

Teams included:

- Mechanical – chassis, suspension, aerodynamics
- Powertrain – motor control, propulsion, electronics
- Telemetry – logging data and displaying it to the driver
- Battery – energy storage, monitoring, and efficiency
- Marketing – sponsorship, social media, and outreach

I was part of the Powertrain team under [Scott Lawson](https://www.linkedin.com/in/scott-lawson-ee-eng/), where I worked mainly on how all the electronics talked to each other. What I loved most was collaborating with other embedded engineers to design the CAN bus system that glued the entire car together.

---

## My Role: CAN Bus Engineer (and Occasional Firefighter)

My main responsibility was building a reliable communication network between all the microcontrollers in the car. These nodes handled things like:

- Motor control
- Throttle and braking inputs
- Battery monitoring
- Sensors and telemetry

Early on, I designed a self-healing CAN network with basic state monitoring and fault detection. This made the system far more tolerant of loose connectors, flaky nodes, and the general abuse that student-built vehicles tend to endure.

As we added more and more telemetry (temperatures, voltages, performance data), the network scaled without compromising safety — which felt like a small miracle at the time.

![CAN Network Breadboard](/images/experiences/usev/can_network_breadboard.jpg)

### Standardising the Chaos

By 2019, my focus shifted to two main goals:

 1. Cleaning up and standardising the CAN protocol
 2. Designing a CAN Gateway Controller

The protocol work involved:

- Defining message layouts (painfully, byte by byte - wish I knew what protobuf was back then)
- Writing things down properly so future teams wouldn’t hate us
- Improving the API so new nodes could be added without rewriting everything

This was less glamorous than motor control, but hugely important for keeping the project alive year after year.

---

## The CAN Gateway (a Very Fun Rabbit Hole)

Eventually, a single CAN bus just wasn’t enough.

High-priority safety messages were sharing bandwidth with telemetry spam, so we split the system into two networks:

- Primary CAN – fast, safety-critical messages
- Secondary CAN – telemetry, monitoring, and “nice to have” data

To connect them, we designed a Gateway Controller.

What it did

- Bridged two CAN networks
- Isolated critical traffic from telemetry noise
- Forwarded only the messages that actually needed to cross buses

What it ran on

- STM32F407VG (chosen specifically for dual CAN support)
- Custom firmware to manage routing and filtering

Sadly, due to time and competing priorities, the gateway never made it into full production — but designing it was an excellent lesson in system-level thinking.

### Heartbeats, Safety, and Letting the Car Coast

One of my favourite concepts we implemented was the CAN heartbeat.

Certain nodes periodically broadcast a “still alive” message. The most critical was between the Body Controller and the Motor Controller.

If the motor controller missed too many heartbeats, it would:

Shut down and let the car coast.

No sudden braking. No surprises. Just the safest possible failure mode.

Simple idea — massive safety improvement.

### Primary vs Secondary Networks

Primary CAN (Safety First)

Handled things like:

- Throttle (12‑bit)
- Brake input (12‑bit)
- Temperatures and  Motor Controllercritical flags

Nodes:

- Body Controller
- Motor Controller
- Gateway Controller

Secondary CAN (All the Nerdy Data)

Used for:

- Speed
- Temperatures
- Voltages
- Battery efficiency data

Nodes:

- Telemetry Module
- Sensor Controller
- Battery Management System
- Gateway Controller

### The Motor Controller (Not My Board, But Very Cool)

The Motor Controller was the most critical board in the vehicle:

- STM32F103C8T6 (Blue Pill)
- Custom H-bridge
- Brushed DC motor control
- Lots of sensors
- CAN-connected to the rest of the car
It was designed in Eagle and written in C using System Workbench. Watching it behave correctly for the first time was deeply satisfying. Hats off to [Scott Lawson](https://www.linkedin.com/in/scott-lawson-ee-eng/) for the mentoring and designing this bit of kit.

![Motor Controller](/images/experiences/usev/usev_motor_controller.jpeg)

---

## Becoming a Driver

In November 2019, I was selected as one of the USEV drivers.

That meant:

- Driving during test days
- Giving feedback on drivability
- Finding bugs that only appear when you’re actually in the car

Although COVID stopped the Shell Eco‑Marathon itself, I did get plenty of track time — which gave me a much better appreciation for how software decisions affect real‑world behaviour.

## Final Thoughts

USEV was messy, ambitious, and incredibly educational.

It taught me:

- How large engineering teams actually function
- Why documentation matters
- How to think about safety in embedded systems
- That CAN bus will survive almost anything

Most importantly, it made engineering fun — and that’s something I’ve tried to carry forward into everything I’ve worked on since.

{{< image-carousel images="[{ \"src\": \"/images/experiences/usev/usev_track_day.jpeg\", \"alt\": \"USEV Track Day\"  }, { \"src\": \"/images/experiences/usev/usev_motor_controller.jpeg\", \"alt\": \"motor controller\"  }, { \"src\": \"/images/experiences/usev/usev_on_the_track.jpeg\", \"alt\": \"One The Track\"  }, { \"src\": \"/images/experiences/usev/usev_track_day_debug.jpeg\", \"alt\": \"Track Debug\"  },  { \"src\": \"/images/experiences/usev/usev_team_photo.jpeg\", \"alt\": \"Team Photo\"  }]">}}
