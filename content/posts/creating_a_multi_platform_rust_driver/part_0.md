---
tags:
- GitHub
- Rust
- Embedded
- Drivers
- Sensors
- I2C
date: 2025-12-14
title: "Creating a multi platform Rust Driver: Overview"
draft: false
toc: true
featured_image: /images/posts/creating_a_multi_platform_rust_driver/rust_banner.png
---

Writing drivers that work consistently across microcontrollers, embedded Linux boards, and desktop operating systems is deceptively hard. Different HALs, conflicting abstractions, and platform-specific quirks often lead to duplicated code or forests of `#ifdef` blocks.

In this blog series, we’ll explore how to design and implement a **multi-platform Rust driver** that avoids all of that — one codebase, many targets. We’ll look at how [Rust’s](https://rust-lang.org/what/embedded/) trait system, strong type guarantees, built-in testing support, and CI-friendly workflow make this *not only possible, but pleasant*.

This landing page gives a high-level overview of what I learned building multi-platform Rust drivers. In this series, I’ll share insights on architecture, async and sync support, HAL design, testing, continuous integration and delivery, and release management.

---

## 📚 Series Stages

Weve split this series into manageable parts, each focusing on a key aspect of multi-platform Rust driver development:

- [Part 1: Embedded HAL](/posts/creating_a_multi_platform_rust_driver/part_1)
- *(More parts coming soon…)*

---

## 🦀 Why Use Rust for Drivers?

If you’re coming from C/C++ or Python, it’s natural to ask: *why Rust?*  
Driver development has long been dominated by C, so what sets Rust apart for cross-platform work?

Here are the advantages that matter most:

### 1. A Powerful Trait System Enabling Cross-Platform Abstractions

Traits let you define clean interfaces for I²C, SPI, GPIO, delays, timers, and more.  
This allows the driver logic to be written once and run on:

- bare-metal MCUs via `embedded-hal` running in a blocking or timeshared manner,
- Asynchronous based solutions via `embedded-hal-async`, could be an RTOS or an async runtime such as [embassy](https://embassy.dev/),
- desktop environments, such as Linux and MacOS

**One API to rule them all. no matter the target platform.**

This gives you portability without branching logic or duplicated files.

### 2. Modern Tooling With Cargo

Cargo provides everything needed for maintainable driver development:

- reproducible builds  
- consistent dependency management with Cargo.lock and Cargo.toml
- platform-specific feature flags  
- built-in semantic versioning
- cross compilation support using rustup and cargo targets
- Modern Language Server for code highlighting, autocompletion, and refactoring
- Good Compiler Errors that help you fix issues quickly

For multi-platform work, this means predictable builds everywhere, easy dependency updates and far cleaner automations.

### 3. First-Class CI/CD & Automation

Rust’s tooling integrates seamlessly with GitHub Actions, letting you automate the boring stuff—formatting, linting, testing, building, and even publishing releases. No more endless manual setup or wrestling with outdated tools: you can focus on real engineering.

In this series, I’ll show how to:

- Set up automated release management with [release-plz](https://release-plz.dev/)
- Enforce code quality with `cargo fmt`, `clippy`, and [MegaLinter](https://megalinter.io/latest/)
- Run tests and builds across multiple targets
- Dependency updates with [Dependabot](https://dependabot.com/)
- Automate hardware-in-the-loop (HIL) testing on real devices

All of this keeps your crate stable, maintainable, and trustworthy—without the yak shaving.

---

## 🔧 Real Driver Examples

This series is grounded in real, actively maintained Rust drivers with sync and async support:

- **TMAG5273 — 3-Axis Hall Effect I²C Driver**  
  <https://github.com/dysonltd/tmag5273>

- **AP33772S — USB-C Power Delivery I²C Driver**  
  <https://github.com/ScottGibb/AP33772S-rs>

- **MPR121-hal - 12-Key Capacitive Touch Sensor  I²C Driver**
  <https://github.com/SiebenCorgie/mpr121-hal>

---

## 🚀 What You’ll Learn

By the end, you'll understand how to build a driver crate that is:

- portable across multiple architectures,  
- built on clean trait-based abstractions,  
- easily testable on embedded & desktop platforms,  
- capable of supporting sync and async APIs,  
- backed by automated linting and formatting,  
- automatically released with semantic versioning,  
- validated using hardware-in-the-loop testing.  

Let’s get started → [Part 1](/posts/creating_a_multi_platform_rust_driver/part_1)
