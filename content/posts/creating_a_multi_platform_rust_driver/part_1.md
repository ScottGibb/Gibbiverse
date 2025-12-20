---
tags:
- Rust
date: 2025-12-14
title: "Creating a multi platform Rust Driver: Embedded Hal"
draft: false
toc: true
featured_image: /images/posts/creating_a_multi_platform_rust_driver/rust_banner.png
---

In this first part of the series, we'll focus on the [Embedded HAL](https://github.com/rust-embedded/embedded-hal) (Hardware Abstraction Layer) and [Embedded HAL Async](https://github.com/rust-embedded/embedded-hal/tree/master/embedded-hal-async)—the foundation for writing portable Rust drivers.

## What is it?

![banner](/images/posts/creating_a_multi_platform_rust_driver/embedded_hal_banner.png)

The Embedded HAL provides a set of traits that let you write platform-agnostic code, making it much easier to support multiple hardware platforms. It doesn't just cover GPIO, I²C, and SPI—there are also traits for:

- [embedded-hal-bus](https://github.com/rust-embedded/embedded-hal/tree/master/embedded-hal-bus) - provides traits for shared bus access, allowing multiple devices to share the same bus without conflicts.
- [embedded-can](https://github.com/rust-embedded/embedded-hal/tree/master/embedded-can) - provides traits for Controller Area Network (CAN) communication, commonly used in automotive and industrial applications.
- And many more systems...

It's a set of official traits maintained by the [Rust Embedded Working Group](https://github.com/rust-embedded/wg) that provide standardised interfaces for embedded protocols. Instead of everyone reimplementing read/write functions for I²C, SPI, or GPIO, there's one common interface. There are two flavours: `embedded-hal` for blocking/synchronous operations, and `embedded-hal-async` for non-blocking/asynchronous ones.

### Why should we use it?

The problem with the Python and C ecosystems is that everyone develops their own drivers with their own interfaces—you can't easily reuse them, and wheels get reinvented constantly. In the Rust ecosystem, you build an I²C driver for something like the [AP33772S](https://www.diodes.com/part/view/AP33772S) using `embedded-hal` traits, and that driver code can run on *any* target that implements those traits—which is basically all modern Rust HALs. Every microcontroller and single-board computer looks the same to your driver: the underlying implementations differ, but the interface is identical. This means your driver runs anywhere that supports the traits.

This lets you truly "write once, deploy everywhere". A great example is a library we developed at [Dyson](/experiences/dyson/dyson) for the [TMAG5273 I²C 3-axis Hall effect sensor](https://github.com/dysonltd/tmag5273). It runs on multiple microcontrollers like STM32 and ESP32, on desktop Linux with an FT232H breakout board, on embedded Linux devices like the Raspberry Pi, and even on macOS.

### What actually is `async`, and why do we care?

> Okay, you've lost me—what does async have to do with any of this?

If you're coming from a bare-metal background, you probably haven't come across async much. There's enough to cover there that it warrants its own blog post! In short, async lets your code run concurrently and non-blocking—similar to how multithreading works in a Python application. You declare functions as `async` and add `await` where you need to wait for something. An async runtime then runs a polling loop, scheduling your async functions—similar to an RTOS, but with fundamentally different inner workings. For this series, async allows us to write non-blocking drivers that run on runtimes like [Embassy](https://embassy.dev/), [Tokio](https://tokio.rs/), [async-std](https://async.rs/), and others. This is perfect for applications that need to juggle multiple tasks at once—handling network requests, reading sensors, and controlling actuators without blocking the main thread.

## What does the code look like?

Let's dive in with some code examples and see how the embedded-hal works in practice.

### Your Cargo.toml and feature gating

To get started, we need to set up our `Cargo.toml` with the necessary dependencies. We'll include `embedded-hal` and `embedded-hal-async`—but we won't include any platform-specific HALs like `esp-hal` or `stm32-hal`. Those implement the traits for us; we're only concerned with *using* the traits.

```toml
#A extract from the AP33772S-rs Cargo.toml file
[features]
default = ["sync"]
sync = ["dep:embedded-hal", "maybe-async/is_sync"]
async = ["dep:embedded-hal-async"]
defmt = ["dep:defmt"]
interrupts = []
advanced = [] # Used to enable lower level register access

[dependencies]
# Hal Dependencies
maybe-async = "0.2"
defmt = {version = "1", optional = true}
embedded-hal = { version = "1", optional = true }
embedded-hal-async = { version = "1", optional = true }

# Driver Dependencies
arbitrary-int = "2"
bitbybit = "1"
uom = { version = "0.37",default-features = false, features = ["autoconvert", "si", "f32",]}
visibility = "0.1"
```

Here, we define two features: `sync` for synchronous/blocking operations and `async` for asynchronous/non-blocking operations. Depending on which feature is enabled, the appropriate HAL traits will be included. The beauty of embedded-hal is that the function signatures are identical between sync and async—the only difference is adding the `async` and `await` keywords in the async version.

This can be handled elegantly using the [maybe-async](https://crates.io/crates/maybe-async) crate, which lets you write code that compiles in both synchronous and asynchronous contexts without duplication. Perfect for our multi-platform driver—we want to support both blocking and non-blocking operations without maintaining separate codebases. The syntax in the TOML is straightforward:

```toml
sync = ["dep:embedded-hal", "maybe-async/is_sync"]
embedded-hal = { version = "1", optional = true }
```

The snippet above shows how we define the `sync` feature to include the blocking `embedded-hal` traits and set the `maybe-async` crate to synchronous mode. Similarly, for the `async` feature, we include the `embedded-hal-async` traits.

We define our dependencies as optional, then use feature flags to include them based on the selected mode. When adding this driver to an existing project, you just need to enable the correct feature flag. For example, in the [ESP32 example](https://github.com/ScottGibb/AP33772S-rs/blob/main/examples/esp32c3/Cargo.toml):

```toml
[dependencies]
# A Bunch of other dependencies
ap33772s-rs = { path = "../../", default-features = false, features = ["defmt", "async"] }
```

In the snippet above, we're saying: use the library at this path, disable default features, and enable `defmt` and `async`.

### Implementing the Driver

Now, let's look at how we can implement a simple driver using these traits. We will look again at the [AP33772S driver](https://github.com/ScottGibb/AP33772S-rs/tree/main) as an example.

```rust

/// Sync Based HAL Imports
#[cfg(feature = "sync")]
mod hal {
    pub use embedded_hal::delay::DelayNs;
    #[cfg(feature = "interrupts")]
    pub use embedded_hal::digital::InputPin;
    pub use embedded_hal::i2c::Error;
    pub use embedded_hal::i2c::ErrorKind;
    pub use embedded_hal::i2c::I2c;
    pub use embedded_hal::i2c::SevenBitAddress;
}

/// Async Based HAL Imports
#[cfg(feature = "async")]
mod hal {
    pub use embedded_hal_async::delay::DelayNs;
    #[cfg(feature = "interrupts")]
    pub use embedded_hal_async::digital::InputPin;
    pub use embedded_hal_async::i2c::Error;
    pub use embedded_hal_async::i2c::ErrorKind;
    pub use embedded_hal_async::i2c::I2c;
    pub use embedded_hal_async::i2c::SevenBitAddress;
}

pub struct Ap33772s<I2C: I2c, D: DelayNs> {
    pub(crate) i2c: I2C,
    /// The underlying delay mechanism required for the USB C Power Delivery negotiation
    pub(crate) delay: D,
}
impl<I2C: I2c, D: DelayNs> Ap33772s<I2C, D> {
    #[maybe_async::maybe_async]
    pub fn new(i2c: I2C, delay: D) -> Self {
        Self { i2c, delay }
    }
    #[maybe_async::maybe_async]
    pub async fn new_default(i2c: I2C, delay: D) -> Result<Self, Ap33772sError> {
        let mut device = Self::new(i2c, delay);
        device.is_device_present().await?;

        let device_status = device.get_status().await?;
        if device_status.i2c_ready()
            && device_status.started()
            && device_status.new_power_data_object()
        {
            Self::initialise(&mut device).await?;
        } else {
            // Device May already be initialised, to do a fresh install, the user must fully power cycle the device
            device.hard_reset().await?; // This does not fully power cycle the RotoPD board due to the device being powered by the STEMMA connector
            Self::initialise(&mut device).await?;
            return Err(Ap33772sError::InitialisationFailure);
        }
        Ok(device)
    }   
}
```

There's a lot going on here, so let's break it down. In a typical Rust crate, the convention is to have a `new` function that creates a new instance of the driver. It consumes a type implementing the I²C interface and a Delay interface—both `embedded-hal` traits. This lets you pass in *any* I²C implementation that conforms to those traits.

How we ensure that the functions are using the right APIs is defined based on the following snippet:

```rust
/// Sync Based HAL Imports
#[cfg(feature = "sync")]
mod hal {
    pub use embedded_hal::delay::DelayNs;
    #[cfg(feature = "interrupts")]
    pub use embedded_hal::digital::InputPin;
    pub use embedded_hal::i2c::Error;
    pub use embedded_hal::i2c::ErrorKind;
    pub use embedded_hal::i2c::I2c;
    pub use embedded_hal::i2c::SevenBitAddress;
}

/// Async Based HAL Imports
#[cfg(feature = "async")]
mod hal {
    pub use embedded_hal_async::delay::DelayNs;
    #[cfg(feature = "interrupts")]
    pub use embedded_hal_async::digital::InputPin;
    pub use embedded_hal_async::i2c::Error;
    pub use embedded_hal_async::i2c::ErrorKind;
    pub use embedded_hal_async::i2c::I2c;
    pub use embedded_hal_async::i2c::SevenBitAddress;
}
```

Here we're feature-gating the imports, ensuring only one HAL flavour is active at a time. Strictly speaking, this goes against Rust guidelines—features ideally shouldn't be mutually exclusive. It's a compromise you have to make in the current ecosystem. However, we can throw a compile error if both features are enabled:

```rust
#[cfg(all(feature = "sync", feature = "async"))]
compile_error!("You cannot use both sync and async features at the same time. Please choose one.");

#[cfg(all(not(feature = "async"), not(feature = "sync")))]
compile_error!("You must enable either the sync or async feature. Please choose one.");
```

Now, back to our `new` and `new_default` functions. Both consume an I²C object and a Delay object. They're generic, with the following trait bounds:

```rust
impl<I2C: I2c, D: DelayNs> Ap33772s<I2C, D> {
...
// More Functions surround the Ap33772s struct
}
```

In the rest of the code we can now use this I²C/Delay implementing struct like so:

```rust
impl<I2C: I2c, D: DelayNs> Ap33772s<I2C, D> {
    #[maybe_async::maybe_async]
    pub async fn write_one_byte_command(
        &mut self,
        command: impl WriteOneByteCommand,
    ) -> Result<(), Ap33772sError> {
        let command_address = command.get_command() as u8;
        let data = command.raw_value();
        self.i2c
            .write(Self::ADDRESS, &[command_address, data])
            .await?;
        Ok(())
    }
    /// More functions ...
}
```

The beauty here is how simple the I²C interaction becomes—you just call `write` on your I²C type and you're done. We decorate our function with `#[maybe_async::maybe_async]`, add `await` where needed, and that's it. No different function calls for different I²C implementations, no worrying about runtime execution. This code runs anywhere in the Rust ecosystem, on any platform. The underlying communication drivers are completely decoupled from our driver logic.

## The new_default function

Typically, `new_default` provides a fully initialised device with sensible default configurations. The convention in this ecosystem is that `new` returns a completely uninitialised device—you can call any function you want on it, but if something doesn't work, it'll throw an error (more on error handling in a later post). The responsibility is on the caller. `new_default`, on the other hand, sets up the minimum viable working sensor, guaranteeing that all subsequent function calls will work.

If we dive a bit deeper in the `new_default` function:

```rust
   #[maybe_async::maybe_async]
    pub async fn new_default(i2c: I2C, delay: D) -> Result<Self, Ap33772sError> {
        let mut device = Self::new(i2c, delay);
        device.is_device_present().await?;

        let device_status = device.get_status().await?;
        if device_status.i2c_ready()
            && device_status.started()
            && device_status.new_power_data_object()
        {
            Self::initialise(&mut device).await?;
        } else {
            // Device May already be initialised, to do a fresh install, the user must fully power cycle the device
            device.hard_reset().await?; // This does not fully power cycle the RotoPD board due to the device being powered by the STEMMA connector
            Self::initialise(&mut device).await?;
            return Err(Ap33772sError::InitialisationFailure);
        }
        Ok(device)
    }   
```

As you can see, there's a lot of initialisation happening here: we check if the device is present on the bus, confirm it's powered and ready, and throw an error if something's not right. We do that with the `?` syntax which basically allows us to bubble up any errors that may happen in the lower levels.

Something deeply ingrained in the Rust ecosystem is the `Result<T, E>` pattern. Instead of returning a number indicating an error state like in C, you return either the value you want or an error enum—which lets you match on the error and handle it far more effectively. More on this in a later post!

## Resources: The AP33772s Rust Driver

All of this blog post contains snippets from the AP33772S Rust Driver that I developed. You may find it easier to go through that code and compare the snippets to what I'm saying here to build a better picture. You can find it on the following [GitHub repository](https://github.com/ScottGibb/AP33772S-rs).

---

## Next Time

Hopefully you found something useful here! If you have a disagreement or there's a better way of doing what I'm describing, please raise an issue on the [blog repository](https://github.com/ScottGibb/Gibbiverse) or submit a pull request with your improvements.

- Previous Part: [Creating a multi platform Rust Driver: Overview](/posts/creating_a_multi_platform_rust_driver/part_0)
- Next Part: [Creating a multi platform Rust Driver: FT232H Breakout Board](/posts/creating_a_multi_platform_rust_driver/part_2)
