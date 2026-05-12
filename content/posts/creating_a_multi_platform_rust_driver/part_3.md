---
tags:
- Rust
- I2C
- async
- sync
- no-std
- std
- STM32
- ESP32
date: 2025-10-07
title: "Creating a multi platform Rust Driver: Using your driver on other platforms"
featured_image: /images/posts/creating_a_multi_platform_rust_driver/rust_banner.png
draft: false
---

In the previous part of the series, we discussed the FT232H breakout board and how we can use it with Rust to interact with our I2C devices from a desktop environment. In this part, we will explore how we we can use our I2C driver on multiple platforms without changing any of the driver code, thanks to the `embedded-hal` and `embedded-hal-async` traits.

## The Platforms

![Chip Manufacturers Banner Goes here]()

The beauty of using the `embedded-hal` traits is that we can write our driver code once and then use it on multiple platforms without any modifications. This is because the `embedded-hal` traits provide a common interface for interacting with hardware peripherals, regardless of the underlying platform. This means our vendors are responsible for implementing these traits in their HALs.

In this article we are going to go through two drivers:

- [TMAG5273 Driver](https://github.com/ScottGibb/tmag5273) A 3 Axis I2C Hall Effect Sensor
- [AP33772S Driver](https://github.com/ScottGibb/AP33772S-rs) A USB C Power Delivery with Extended Power Range I2C chip

Each of these drivers are good examples of multi platform code which is ran and tested on numeroud devices with differing HALs. Now the platforms we are going to show here are:

### TMAG5273

- STM32 devices using STM32F072 with the `embassy-stm32` HAL using `sync` code
- PiPico devices using the RP2040 with the `PiPico` HAL using `sync` code
- ESP32 devices using the ESP32C3 with the `ESP-HAL` using  `sync` code

You may have noticed that this driver is only `sync` compatible, thats because we are not using the `maybe_async` dependency and thus are only supporting `embedded-hal`.

### AP33772S

- ESP32 devices using ESP32C3 with the `ESP-HAL` using `async` code with [Embassy](https://embassy.dev/).
- Desktop environments using the FT232H breakout board with the `ftdi-embedded-hal` crate using `sync` code.

## Microcontroller Platforms

Technically the ESP32C3 is not a microcontroller, its a System on Chip. However it is usally sits alongside other ESP32 devices unlike a Desktop Computer running Linux. So for the sake of this article we will include it in this section.

When working with Microcontoller platforms in Rust, the usual project setup is a little different as we include a `Config.toml` and sometimes a `Memory.x` and `build.rs` file. This doesnt tend to happen on `std` Rust applications but in the `no-std` world.

An example of the [STM32F072 Test project]() structure for the TMAG5273 is shown below:

(Were using [fd](https://github.com/sharkdp/fd) here to show the file structure, a  Rust commandline tool)

```bash
➜ fd --hidden --max-depth 2
.cargo/
.cargo/config.toml
Cargo.toml
README.md
build.rs
memory.x
src/
src/lib.rs
tests/
tests/cold_start_tests_0.rs
tests/cold_start_tests_1.rs
tests/cold_start_tests_2.rs
tests/setting_register_tests_0.rs
```

These extra components are important for setting up the MCU and ensuring that our code can run on the target hardware. The `Config.toml` file is used to specify the target architecture and other build settings, while the `Memory.x` file is used to define the memory layout of the MCU. The `build.rs` file is a build script that can be used to perform custom build steps, such as generating code or linking against external libraries.

In this specific example we, the `config.toml` loks like this:

```toml
[target.thumbv6m-none-eabi]
runner = "probe-rs run --chip STM32F072RB --probe=0483:374b:066BFF495056805087253606"

[build]
target = "thumbv6m-none-eabi"
```

Here were specifying that our target architecture is `thumbv6m-none-eabi`, which is the architecture used by the STM32F072. We also specify a runner command that uses `probe-rs` to flash and run our code on the target hardware. In this particular use case it was part of the testing CI for the TMAG5273 project and thus we targeted a specific probe.

Now for our embedded C developers the `Memory.x` file is probably the most interesting part of this setup. This file is used to define the memory layout of the MCU, including the size and location of the flash and RAM. This is important because it allows us to ensure that our code can fit within the available memory on the target hardware. An example of the `Memory.x` file for the STM32F072 is shown below:

```txt
MEMORY
{
  /* NOTE K = KiBi = 1024 bytes */
  FLASH : ORIGIN = 0x08000000, LENGTH = 128K
  RAM : ORIGIN = 0x20000000, LENGTH = 16K
}

/* This is where the call stack will be allocated. */
/* The stack is of the full descending type. */
/* NOTE Do NOT modify `_stack_start` unless you know what you are doing */
_stack_start = ORIGIN(RAM) + LENGTH(RAM);
```

As for where this came, I cant remember exactly but it should match your chip and you may have to look at the datasheet to find the correct values for your specific chip.

An interesting file is the `build.rs` file, which is a Rust build script that can be used to perform custom build steps. In our case here we are using it to link in `defmt` and `embedded-test` - A future blog coming soon! (TODO: Link to blog about embedded testing with `embedded-test` and `defmt` xD)

```rust
fn main() {
    // stm32 specific
    println!("cargo:rustc-link-arg=-Tlink.x");
    // add linker script for embedded-test!!
    println!("cargo::rustc-link-arg-tests=-Tembedded-test.x");
    //link the defmt linker script
    println!("cargo:rustc-link-arg=-Tdefmt.x");
}
```

We can use this file to do extra steps, a good example I use this for is adding `commitment-issues` to my project to embedded git metadata into the application. - A future blog coming soon! (TODO: Link to blog about `commitment-issues` and embedding git metadata into embedded applications)

Once weve got the embedded project setup we can then add our driver like any other rust application by doing `cargo add`. In the case of the case of `TMAG5273` we can add as is and we dont have to worry about any `async` vs `sync` code because the driver is only `sync` compatible. For the `AP33772S` we have to add feature flags to specify if we want to use the `async` or `sync` code.

## Adding a Maybe-Async Driver with Embassy
