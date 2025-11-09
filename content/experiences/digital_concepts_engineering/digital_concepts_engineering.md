---
tags:
- MCU
- Robotics
- Python
- C/C++
date: 2022-07-04
title: Digital Concepts Engineering
draft: false
---

{{< figure src="/images/SG_logo.png" title="Illustration from Victor Hugo et son temps (1881)" >}}

Represented Babcock on secondment with DCE to support rapid prototyping of embedded devices and increase stakeholder engagement.
- Field tested multiple unmanned wheeled, tracked and legged vehicles.
- Delivered a future-proof low-latency universal robot controller architecture which was used for past and ongoing projects.
- Liaison between Babcock and DCE, strengthening their ongoing partnership.

# Summary

Digital Concepts Engineering was a Defence company that I worked at whilst I left the [[University of Strathclyde]]. I joined this company during the [[Babcock Electrical Engineering Graduate Scheme]] instead of doing further rotations. I was there for about 6 months and worked on developing a [[Universal Robot Controller]] for all of their #Robotics platforms.

I spent six months on secondment at Digital Concepts Engineering. It was a compact, hands-on crash course in making robots work where it matters: outside the lab, in muddy fields, and on borrowed vehicles.

The central thread of my time there was a universal robot controller we designed — a low-latency, pragmatic architecture intended to be the default brain for several platforms. We weren't chasing academic elegance; we were chasing something that would survive noisy radios, dodgy connectors and the unpredictable physics of real terrain.

Days at DCE followed a pattern that kept you honest. One morning I'd be sketching control loops on paper; by afternoon I'd be bolting sensors onto a platform and tuning parameters while a colleague drove it across a car park. Field testing was where decisions met consequences: a good algorithm in the simulator sometimes fell apart at the first GPS outage or under a dripping raincloud.

We tested wheeled, tracked and legged platforms. I still remember the Ghost Robotics dog test — four UWB modules on a tag gave the robot a rough idea of where to go, and for a minute it looked like the tag and robot had coordinated choreography. It was a small, satisfying proof that our integration work could make complex systems behave predictably.

The Ford Ranger project was another highlight. Someone handed us a road vehicle and asked us to make it semi-autonomous enough for safe demonstrations. Bridging mechanical actuators, safety checks, and our control stack taught me the sharp edge of interfacing: assumptions that are harmless in simulation can be dangerous on tarmac.

We also prototyped medical and sensing devices — a clamp-on hospital bed follower, and a COVID proximity sensor that used UWB and simple haptic alerts. These projects were smaller in scale but stretched the same muscles: hardware reliability, user-centred behaviour, and rapid iteration.

Much of the role involved translation: turning stakeholder requirements into pragmatic engineering tasks and coordinating with small suppliers. That relationship work — ensuring a part arrived on time, or that a supplier understood the tolerance we really needed — was as crucial as the electronics and code.

I spent a lot of time on tooling too. I wrote a compact Python control app that became the glue for demos and tests: replay scenarios, inject failure modes, and automate data collection. It saved us time and prevented a surprising number of avoidable mistakes.

Highlights

- Designed and delivered a universal low-latency robot controller used across multiple platforms.
- Field-tested wheeled, tracked and legged robots, including UWB-enabled follow systems.
- Retrofitted a Ford Ranger for semi-autonomous demos (actuators, safety integration, control stack).
- Prototyped medical and COVID-sensing devices; built a Python control app for testing and demos.

Those six months were intense, pragmatic and enormously instructive — the kind of engineering that teaches you to make good decisions under pressure.

- Field-tested wheeled, tracked and legged robots, including UWB-enabled follow systems.
- Retrofitted a Ford Ranger for semi-autonomous demos (actuators, safety integration, Marionette stack).
- Prototyped medical and COVID-sensing devices; built a Python control app for testing and demos.

Those six months were intense, pragmatic and enormously instructive — the kind of engineering that teaches you to make good decisions under pressure.
