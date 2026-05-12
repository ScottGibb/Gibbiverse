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

{{< figure src="/images/posts/creating_a_multi_platform_rust_driver/vendors.drawio.svg" alt="Chip Vendors" class="tc" >}}

The beauty of using the `embedded-hal` traits is that we can write our driver code once and then use it on multiple platforms without any modifications. This is because the `embedded-hal` traits provide a common interface for interacting with hardware peripherals, regardless of the underlying platform. This means our vendors are responsible for implementing these traits in their HALs.

In this article we are going to go through two drivers:

- [TMAG5273 Driver](https://github.com/ScottGibb/tmag5273) A 3 Axis I2C Hall Effect Sensor
- [AP33772S Driver](https://github.com/ScottGibb/AP33772S-rs) A USB C Power Delivery with Extended Power Range I2C chip

Each of these drivers are good examples of multi platform code which is ran and tested on numeroud devices with differing HALs. Now the platforms we are going to show here are:

### TMAG5273

- STM32 devices using [STM32F072](https://www.digikey.co.uk/en/products/detail/stmicroelectronics/NUCLEO-F072RB/5047984?gclsrc=aw.ds&gad_source=1&gad_campaignid=20265362335&gbraid=0AAAAADrbLlikjcCWutNvRgeYAEnhhcGPu&gclid=CjwKCAjwn4vQBhBsEiwAq3hhN0O-Sf0t2qVptvRfRRpfq_qA06G0BwaiY-rfJF4EAiSHtwWPnQxUThoC4Y4QAvD_BwE) with the `embassy-stm32` HAL using `sync` code
- [PiPico](https://thepihut.com/products/raspberry-pi-pico) devices using the RP2040 with the `PiPico` HAL using `sync` code
- ESP32 devices using the [ESP32C3](https://thepihut.com/products/seeed-xiao-esp32c3?srsltid=AfmBOooz9P6QS397kYYt2brxuQZ_F2TquFDizV5mCHYJvl-TaH1AJyWU) with the `ESP-HAL` using  `sync` code

You may have noticed that this driver is only `sync` compatible, thats because we are not using the `maybe_async` dependency and thus are only supporting `embedded-hal`.

### AP33772S

- ESP32 devices using ESP32C3 with the `ESP-HAL` using `async` code with [Embassy](https://embassy.dev/).
- Desktop environments using the FT232H breakout board with the `ftdi-embedded-hal` crate using `sync` code.

## Microcontroller Platforms

Technically the ESP32C3 is not a microcontroller, its a System on Chip. However it is usally sits alongside other ESP32 devices unlike a Desktop Computer running Linux. So for the sake of this article we will include it in this section.

When working with Microcontoller platforms in Rust, the usual project setup is a little different as we include a `Config.toml` and sometimes a `Memory.x` and `build.rs` file. This doesnt tend to happen on `std` Rust applications but in the `no-std` world.

An example of the [STM32F072 Test project](https://github.com/ScottGibb/tmag5273/tree/main/tests/stm32f072) structure for the TMAG5273 is shown below:

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

The `Cargo.toml` for an STM32 project might look a bit like this:

```toml
[package]
name = "stm32f072"
version = "0.1.0"
edition = "2021"

[dependencies]
embassy-stm32 = { version = "0.2.0", features = [ "defmt", "memory-x", "stm32f072rb"] }

cortex-m ={version ="0.7.0", features = ["critical-section-single-core"]}
cortex-m-rt = "0.7.5"
# dependencies for defmt
defmt = { version = "1.0.1"}
defmt-rtt = { version = "1.0.0"}
portable-atomic = {version = "1.10.0", features = ["critical-section"]}

[dev-dependencies]
embedded-test = { version = "0.6.0", features =["defmt"] }
tests-common = { path = "../../tests-common" }
# The rest of the toml is cut off for conciseness.
```

Now due to the nature of that testing project, our driver dependency is actually coming from the internal `utils` test crate. Now this is a generic test crate that contains the actual generic tests which are then fed into each of the vendor platforms using `embedded-test`, more on this later.

```toml
[package]
name = "tests-common"
description = "Common tests for the TMAG5273 Driver that are platform agnostic"
version = "0.1.0"
edition = "2021"

[dependencies]
tmag5273 = { path = "../" } # Pull in our driver
embedded-hal-bus = { version = "0.3.0" }
embedded-hal = { version = "1.0.0" }
arbitrary-int = "2.0.0"
```

### Adding a Maybe-Async Driver with Embassy

Now we might want to use our driver on another platform, or use our driver in an `async` fashion, this is why its important to use a crate such as `maybe-async` as it allows us to write the code once and since the `embedded-hal` and `embedded-hal-async` are essentially the same we can swap between them at compile time.

Now in the microcontoller world, a popular `aync` framework is Embassy and it comes with a lot of support for different vendors, it not only provides the `async executor` but also HALs for each of the devies. In this blogs example we are going to use the `esp-hal` which comes with `async` built in unlike `stm32f1xx-hal`.

For that our project structure might look like this (Example taken from the [AP33772S Example](https://github.com/ScottGibb/AP33772S-rs/tree/main/examples/esp32c3)):

```bash
➜ fd --hidden --max-depth 2
.cargo/
.cargo/config.toml
.gitignore
.vscode/
.vscode/extensions.json
.vscode/launch.json
.vscode/settings.json
.vscode/tasks.json
Cargo.lock
Cargo.toml
README.md
build.rs
rust-toolchain.toml
src/
src/bin/
src/lib.rs
```

Now a key note for this, is that typically an ESP32 project can be made using [`esp-generate`](https://github.com/esp-rs/esp-generate), a fantastic tool to get up and running.

Now we can see here, were using the same structure as before with the `.cargo/config.toml` and the `build.rs`, this time we dont need the `Memory.x` however we do have a `rust-toolchain.toml`.

This is automatically generated by the `esp-generate` tool and looks like the following:

```toml
[toolchain]
channel    = "stable"
components = ["rust-src"]
targets = ["riscv32imc-unknown-none-elf"]
```

TODO: add some details what this file is for

As for the `config.toml` youll find some similarities between this ESP32C3 config and the STM32. We can see here again were using probe-rs and were setting the toolchain too. But the keypoint here is that we have a different chip architecture here. However this does not affect our driver at all.

```toml
[target.riscv32imc-unknown-none-elf]
runner = "probe-rs run --chip=esp32c3 --preverify --always-print-stacktrace --no-location --catch-hardfault"

[env]
DEFMT_LOG="info"

[build]
rustflags = [
  # Required to obtain backtraces (e.g. when using the "esp-backtrace" crate.)
  # NOTE: May negatively impact performance of produced code
  "-C", "force-frame-pointers",
]

target = "riscv32imc-unknown-none-elf"

[unstable]
build-std = ["core"]

```

As for the `Cargo.toml`, since we are using `Embassy` we have a slightly more complex dependency tree in this example.

```toml
[package]
edition      = "2021"
name         = "esp32c3"
rust-version = "1.86"
version      = "0.1.0"

[[bin]]
name = "esp32c3"
path = "./src/bin/main.rs"

[dependencies]
defmt = "1"
esp-bootloader-esp-idf = { version = "0.4", features = ["esp32c3"] }
esp-hal = { version = "=1.0.0-rc.0", features = [
  "defmt",
  "esp32c3",
  "unstable",
] }

critical-section = "1"
embassy-executor = { version = "0.7", features = [
  "defmt",
  "task-arena-size-20480",
] }
embassy-time = { version = "0.5", features = ["defmt"] }
esp-hal-embassy = { version = "0.9", features = ["defmt", "esp32c3"] }
panic-rtt-target = { version = "0.2", features = ["defmt"] }
rtt-target = { version = "0.6", features = ["defmt"] }
static_cell = "2"

ap33772s-rs = { path = "../../", default-features = false,features = ["defmt", "async"] } # Pull in our driver with async

[profile.dev]
# Rust debug is too slow.
# For debug builds always builds with some optimization
opt-level = "s"

[profile.release]
codegen-units    = 1     # LLVM can perform better optimizations using a single thread
debug            = 2
debug-assertions = false
incremental      = false
lto              = 'fat'
opt-level        = 's'
overflow-checks  = false

[workspace]
```

The more complicated dependency tree is entirely due to using `embassy` as it requires extra deps to allow the full async environment to run. This doesnt affect our driver however as it just `plugs` into the framework.

## What Do I add to my Cargo.toml

Now that weve covered both an Async and Sync project and given a bit of details about the MCU project structure, you might be asking what do I actually need to add to my `Cargo.toml` to get this working? Its very simple, you just need to add your driver as a dependency and then add the appropriate features for the platform you want to run on. For example if we wanted to run the AP33772S driver on an ESP32C3 with `async` support, we would add the following to our `Cargo.toml`:

```toml
[dependencies]
ap33772s-rs = { no-default-features = false, features = ["async"] } # Pull in our driver with async
```

Now depending on driver your pulling in, there may be a default feature set, which dictates if its `async` or `sync` compatible, so you may have to set `default-features = false` and then specify the features you want to use. In the case of the AP33772S driver, it is `sync` compatible by default, so we need to set `default-features = false` and then specify the `async` feature to get the async version of the driver. We can see that from its [`Cargo.toml`](https://github.com/ScottGibb/AP33772S-rs/blob/main/Cargo.toml) file:

```toml
[features]
default = ["sync", "defmt"]
sync = ["dep:embedded-hal", "maybe-async/is_sync"]
async = ["dep:embedded-hal-async"]
defmt = ["dep:defmt"]
interrupts = []
advanced = [] # Used to enable lower level register access
# Snippet of the Cargo.toml for the AP33772S driver, showing the features and how they relate to the dependencies.
```

If you want to use it synchronously, you can just add the dependency with the `sync` feature:

```toml
[dependencies]
ap33772s-rs = { no-default-features = false, features = ["sync"] } # Pull in our driver with sync
```

## Summary

I could provide tonnes of examples, but essentially the main point of this article is that by using the `embedded-hal` and `embedded-hal-async` traits, we can write our driver code once and then use it on multiple platforms without any modifications. This is because the `embedded-hal` traits provide a common interface for interacting with hardware peripherals, regardless of the underlying platform. This means our vendors are responsible for implementing these traits in their HALs, and as long as they do that correctly, our driver will work seamlessly across different platforms.

To better understand its best to check out the actual code for the drivers and see how they are used in the different platforms, as well as the tests which are ran on each platform to ensure that everything is working correctly.

---

## Next Time

Hopefully you found something useful here! If you have a disagreement or there's a better way of doing what I'm describing, please raise an issue on the [blog repository](https://github.com/ScottGibb/Gibbiverse) or submit a pull request with your improvements.

- Previous Part: [Creating a multi platform Rust Driver: FT232H Breakout Board](/posts/creating_a_multi_platform_rust_driver/part_2)
- Next Part: Coming Soon
