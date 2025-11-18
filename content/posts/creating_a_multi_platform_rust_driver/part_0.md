---
tags:
- GitHub
- Rust
- Embedded
date: 2025-10-07
title: "Creating a multi platform Rust Driver"
draft: false
toc: true
featured_image: /images/posts/creating_a_multi_platform_rust_driver/rust_banner.png
---

Writing drivers that work consistently across microcontrollers, embedded Linux boards, and desktop operating systems is deceptively hard. Different HALs, conflicting abstractions, and platform-specific quirks often lead to duplicated code or forests of `#ifdef` blocks.

In this blog series, we’ll explore how to design and implement a **multi-platform Rust driver** that avoids all of that — one codebase, many targets. We’ll look at how Rust’s trait system, strong type guarantees, built-in testing support, and CI-friendly workflow make this *not only possible, but pleasant*.

This landing page provides a high-level overview. Each part of the series dives deeper into architecture, async/sync support, HAL design, testing, and continuous integration.

---

## 📚 Series Stages

- [Part 1: Embedded HAL](/posts/creating_a_multi_platform_rust_driver/part_1)
- *(More parts coming soon…)*

---

## 🦀 Why Use Rust for Drivers?

If you’re coming from C/C++ or Python, it’s natural to ask: *why Rust?*  
Driver development has long been dominated by C, so what sets Rust apart for cross-platform work?

Here are the advantages that matter most:

### **1. A Powerful Trait System Enabling Cross-Platform Abstractions**

Traits let you define clean interfaces for I²C, SPI, GPIO, delays, timers, and more.  
This allows the driver logic to be written once and run on:

- bare-metal MCUs via `embedded-hal`,
- embassy based MCUs via `embedded-hal-async`
- desktop environments, such as Linux and MacOS,
- custom boards and RTOSes.

This gives you portability without branching logic or duplicated files.

### **2. Modern Tooling With Cargo**

Cargo provides everything needed for maintainable driver development:

- reproducible builds  
- consistent dependency management  
- platform-specific feature flags  
- built-in semantic versioning  

For multi-platform work, this means predictable builds everywhere.

### **3. First-Class Support for CI/CD & Testing**

Rust’s tooling integrates cleanly with GitHub Actions, allowing you to automate:

- linting and formatting  
- running tests across targets  
- building multiple architectures  
- publishing releases safely  

Compared to traditional C workflows, Rust offers a drastically smoother and more robust CI experience.

---

## ⚙️ GitHub Automations for Drivers  

Modern Rust driver development isn’t just about code — it’s about automation.  
In this series, we’ll explore how to integrate powerful GitHub workflows for:

### **1. Automated Release Management**

Rust makes automated releases straightforward. You’ll learn how to use:

- `cargo-release` for version bumping & tagging  
- automated changelog generation  
- GitHub Releases publishing  
- crate publishing directly from CI  

This ensures your crate stays stable, predictable, and publicly trustworthy.

### **2. Linting & Formatting in CI**

GitHub Actions can enforce code quality using both Rust’s built-in tools and broader repository-wide checks.

This includes:

- `cargo fmt --check`  
- `cargo clippy --all-targets --all-features -- -D warnings`  
- MegaLinter for validating Markdown, YAML/TOML/JSON, and general repo hygiene  

Combined, these ensure both the driver code and the surrounding project remain consistent and maintainable.

### **3. Hardware-in-the-Loop (HIL) Testing**

Rust drivers often interface with real sensors, power controllers, or microcontrollers — so real hardware testing matters.

We’ll discuss how to automate HIL using GitHub Actions and custom runners to:

- build and flash test firmware onto real devices  
- test both synchronous and asynchronous driver modes  

Whether it's an STM32 board, ESP32, RP2040, or Linux SBC, automated HIL ensures your crate behaves reliably on actual hardware — not just in theory.

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
