# Greyhound IHP Bringup

This repository contains resources and examples to bring up [Greyhound](https://github.com/mole99/greyhound-ihp).

## Prerequisites

Download and flash MicroPython for the RPi Pico onto the Greyhound Main Board: https://micropython.org/download/RPI_PICO/

Next, install a serial console such as picocom. Try to access the board over USB:

```
picocom /dev/ttyACM0 -b115200
```

You may need to add your user to the dialout group:

```
sudo usermod -a -G dialout $USER
```

To exit picocom: Strg+a, Strg+x

Once you are connected, you should see a Python REPL where you can input commands:

```
>>>
```

## Running Examples

Python script and example FPGA designs are available in `greyhound_v1/`.

To move them onto the Greyhound Main Board we use mpy-repl-tool.

```
pip install mpy-repl-tool
```

Exit picocom (if still open) and make sure the board is detected:

```
python3 -m there detect
```

```
/dev/ttyS3 - n/a
/dev/ttyS2 - n/a
/dev/ttyS1 - n/a
/dev/ttyS0 - n/a
/dev/ttyACM0 - Board in FS mode - Board CDC
```

List the files on the board:

```
python3 -m there ls
```

Push a file to the root of the file system:

```
python3 -m there push myfile.txt /
```

Delete a file:

```
python3 -m there rm /myfile.txt
```

Make sure to push the file structure in `greyhound_v1/board/` to the Greyhound Main Board. See `greyhound_v1/README.md` for more information.
