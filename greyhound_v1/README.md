# Greyhound IHP v1

This folder contains resources and examples to bring up [Greyhound v1](https://github.com/mole99/greyhound-ihp-v1).

The following boards were used:

- https://github.com/mole99/greyhound-main-pcb
- https://github.com/mole99/greyhound-breakout-pcb

Currently, only the FPGA of Greyhound v1 was tested.

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
To compile the firmware the RISC-V compiler is needed. Alternatively the compiled firmware is included in the `board/firmware/` directory.

When compiling the firmware is located at `user_designs/designs/greyhound/firmware/firmware.bin`. 

The firmware includes two bitstreams. One for the XIF and one for the peripheral interface. Those bitstreams can be found in `user_designs/designs/greyhound/firmware/<example.bit>`.

To run the firmware one must execute the following command on the micro python board: 
```
upload_firmware("firmware/firmware.bin")
```
The upload script is interactive, since uploading the firmware requires Greyhound to be powered down.

For the prograam to run the fetch enable jumper must be set `HIGH`.

To rerun the program without re-uploading run:
```
boot_firmware()
```
