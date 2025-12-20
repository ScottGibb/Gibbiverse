---
tags:
- MCU
- Robotics
- Python
- C/C++
- Java
- PCB
- JLCPCB
date: 2020-06-08
title: Building an Autonomous Robot
featured_image: /images/experiences/university_of_strathclyde.png
draft: false
---

![Robot](/images/experiences/building_an_autonomous_robot/building_an_autonomous_robot.jpeg)

When I was at the University of Strathclyde, studying Computer and Electronic Systems, in my fourth year (Bachelors), I self-suggested a project involving the creation of an autonomous robot – a very ambitious goal where I wanted to cover the construction of a robot, including 3D printing a chassis mount, designing and assembling electronics, and of course writing the embedded software. In hindsight, it was an ambitious goal, one which could have done with a narrower scope.

![Exploded View](/images/experiences/building_an_autonomous_robot/exploded_view.png)

The exploded view shown above is the completed hardware assembly. It consisted of 5 Printed Circuit Boards developed in Eagle and manufactured by JLCPCB. Sadly I started developing this robot during the Pandemic, so assembly and progress was slow, however I was fortunate enough to get a paid Internship for this robot to ensure the development of the robot. This carried on for three months into the summer.

## The Rampaging Chariots Guild

The original robot (pre-autonomy) was designed for a robotics competition called the [Rampaging Chariots Guild](https://www.rampagingchariots.org.uk/index.php) - think Robot Wars, but more educational and less dramatic explosions. Here's what they're all about:

>The Rampaging Chariot is a powerful, radio controlled featherweight sporting robot that is used by schools and youth groups to compete in an annual Robotic Games to determine the National Champion. It is a project aimed at interesting young people in engineering organised by the Rampaging Chariots Guild.
>You receive the first robot as a free kit and your team builds it and tests it (this takes about 12 hours work). You can then design unique bodywork and think of ideas to improve its performance.

My ambitious goal? Take this basic teleoperated robot and give it a brain - making it fully autonomous, capable of navigating an arena, avoiding obstacles, and completing tasks without human intervention. The catch was that since the Rampaging Chariots platform is designed for young engineers, I needed to keep my custom PCBs simple enough for teenagers to assemble. No pressure!

## System Architecture

Being the over-eager engineer that I am, I absolutely loaded this robot with sensors. We're talking ultrasonic sensors, IR range sensors - basically giving it 360-degree environmental awareness. The plan was to create a robot that could "see" everything around it, regardless of the environment. I deliberately avoided LIDAR due to concerns with the Rampaging Chariots competition rules, which prohibit its use.

## Software/Firmware Architecture

The main processing unit of the Robot was a Raspberry Pi 3 running an object-oriented Python Stack. It had low-level communications through I2C and UART to the Motor Controller and Sensor Controller, running custom communication protocols. The high-level teleoperated control was done over TCP to a JavaFX Application. The Sensor controller being the main board for interacting with all the sensors ran pure C code with the STM32F1 HALs.

## Hardware Design

I'm an Embedded engineer and with that, I like to develop Printed Circuit Boards and love to 3D print things. So I developed custom mounts and custom boards, due to the Rampaging Chariots guild being targeted at teenagers/children, one of the requirements was that the boards had to be simple enough for them to solder together. So I kept the designs simple, with through-hole components where possible. This increased the size of the boards but made assembly much easier. All the boards were connected via I2C or UART to the Raspberry Pi.

![I2C Network](/images/experiences/building_an_autonomous_robot/hardware_design.png)

### Electromagnetic Shielding

A fun experience I had with the robot was when I was experimenting with PID control of the robot and was noticing I2C issues and forced shutdowns. It turns out the robot's motors (repurposed drill motors), were causing EMI spikes when maximum power was supplied causing I2C communication errors alongside forced shutdowns through a power off button being triggered. Eventually tin foil was used (wrapped in cardboard) to "shield" the motors EMI and prevent the system from being affected, a valid solution that did work!

## Lessons Learned

This project was an incredible learning experience, but it also taught me a lot about scope management. Looking back, I probably should have narrowed the project's focus a bit more. Trying to tackle everything at once made progress slow, especially with the added challenge of the pandemic. However, the skills I gained in PCB design, embedded programming, and system integration were invaluable. Plus, I got to build a pretty cool robot along the way!

## Images

{{<Carousel
  "/images/experiences/building_an_autonomous_robot/building_an_autonomous_robot.jpeg|Robot (Front)"
  "/images/experiences/building_an_autonomous_robot/robot_exploded.jpeg|Exploded View"
  "/images/experiences/building_an_autonomous_robot/robot_front.jpeg|Robot Front View"
  "/images/experiences/building_an_autonomous_robot/robot_open_roof.jpeg|Robot with Roof Off">}}

## Dissertation

My dissertation can be found below:

{{< embed-pdf url="./dissertation.pdf" >}}
