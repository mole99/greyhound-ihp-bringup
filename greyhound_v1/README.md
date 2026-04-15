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
python3 -m there push board/* /
```

After restarting the board `main.py` will automatically upload the default bitstream. Adjust `main.py` to your needs or send commands via the REPL:

```
upload_bitstream("bitstreams/greyhound_sine.bit")
```

To view VGA output, plug a [Tiny VGA](https://github.com/mole99/tiny-vga) into GPIO Bank1.
