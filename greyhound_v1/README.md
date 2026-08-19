# Greyhound IHP v1

This folder contains resources and examples to bring up [Greyhound v1](https://github.com/mole99/greyhound-ihp-v1).

The following boards were used:

- https://github.com/mole99/greyhound-main-pcb
- https://github.com/mole99/greyhound-breakout-pcb

The eFPGA and the RISC-V CPU of Greyhound v1 was tested. So far everythign seems to work as expected, except for the built-in UART. If you need a UART, you can implement one using the eFPGA.

Important Pins:

| project_clk  | GPIO0  |                         |
|--------------|--------|-------------------------|
| project_rst  | GPIO1  | (active low)            |
| FPGA_MODE    | GPIO2  | (0=active SPI, 1=passive SPI) |
| FETCH_ENABLE | GPIO3  | (0=disabled, 1=enabled) |
| FPGA_MISO    | GPIO4  |                         |
| FPGA_CS_N    | GPIO5  |                         |
| FPGA_SCLK    | GPIO6  |                         |
| FPGA_MOSI    | GPIO7  |                         |
| CONFIG_BUSY  | GPIO16 |                         |
| CORE_SLEEP   | GPIO17 |                         |
|              |        |                         |

## Compiling Bitstreams

First, install Nix.

Then, under `user_designs/` run `nix-shell`. The first time, Nix will build Yosys and nextpnr.

Afterwards run `make all` to build all bitstreams, or `make counter` to build individual ones.

You can copy the final bitstreams under `user_designs/designs/greyhound/<example>/<example.bit>` to the `board/` directory.

To copy the directory structure under `board/` to the Greyhound Main Board, run:

```
python3 -m there mkdir bitstreams
python3 -m there mkdir firmware
python3 -m there push board/bitstreams/* /bitstreams/
python3 -m there push board/firmware/* /firmware/
python3 -m there push board/* /
```

After restarting the board `main.py` will automatically upload the default bitstream. Adjust `main.py` to your needs or send commands via the REPL:

```
upload_bitstream("bitstreams/greyhound_sine.bit")
```

To view VGA output, plug a [Tiny VGA](https://github.com/mole99/tiny-vga) into GPIO Bank1.

## Compiling Firmware

To compile the firmware a RISC-V cross-compiler is needed. To enable it, go into `firmware/` and run `nix-shell`.
The pre-compiled firmware is already included in the `board/firmware/` directory.

To upload new firmware, one must execute the following command on the micro python board: 

```
upload_firmware("firmware/firmware.bin")
```

The upload script is interactive, since uploading the firmware requires Greyhound to be powered down.
For the prograam to run the fetch enable jumper must be set `HIGH`.

To rerun the program without re-uploading run:

```
run_firmware(freq=25_175_000)
```

This is the default on startup.

