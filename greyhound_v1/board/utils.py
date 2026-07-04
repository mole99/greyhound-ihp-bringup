import os
import time
import machine
from winbond import W25QFlash

def upload_bitstream(bitstream, freq=25_175_000):

    print(f"machine freq: {machine.freq()}")

    # Setup
    clock   = machine.Pin(0, machine.Pin.OUT)
    reset_n = machine.Pin(1, machine.Pin.OUT)

    # SPI
    fpga_miso = machine.Pin(4, machine.Pin.IN)
    fpga_cs_n = machine.Pin(5, machine.Pin.OUT)
    fpga_sclk = machine.Pin(6, machine.Pin.OUT)
    fpga_mosi = machine.Pin(7, machine.Pin.OUT)

    fpga_spi = machine.SPI(
        mosi=fpga_mosi,
        sck=fpga_sclk,
        miso=fpga_miso,
        polarity=0,
        phase=1,
        baudrate=1_000_000, # Let's try 1 MBaud/s
        bits=8,
        firstbit=machine.SPI.MSB,
    )

    # Inputs
    fpga_mode = machine.Pin(2, machine.Pin.IN)
    fetch_enable = machine.Pin(3, machine.Pin.IN)

    config_busy = machine.Pin(16, machine.Pin.IN)
    core_sleep  = machine.Pin(17, machine.Pin.IN)

    print(f"fpga_mode: {fpga_mode.value()}")
    print(f"fetch_enable: {fetch_enable.value()}")
    print(f"config_busy: {config_busy.value()}")
    print(f"core_sleep: {core_sleep.value()}")

    print(f"Starting the clock!")
    
    pwm0 = machine.PWM(clock, freq=25_175_000, duty_u16=32768) # 50% duty
    print(f"fpga clock: {pwm0.freq()}")

    print(f"Reset!")

    reset_n(0)
    time.sleep_ms(10)
    reset_n(1)

    def write_bitstream_spi(filename, spi_master, cs, active_low=True):
        with open(filename, 'br') as f:
            data = f.read(4)
            while data:
                try:
                    cs(not active_low)
                    spi_master.write(data)
                finally:
                    cs(active_low)
                
                # Next word
                data = f.read(4)

    print(f"Writing the bitstream {bitstream} !")
    write_bitstream_spi(bitstream, fpga_spi, fpga_cs_n)
    
    pwm0 = machine.PWM(clock, freq=freq, duty_u16=32768) # 50% duty
    print(f"fpga clock: {pwm0.freq()}")

def write_firmware(flash, firmware):
    with open(firmware, 'br') as f:
        data = f.read(256) # Read 1 page
        data_addr = 0

        while data:
            if len(data) < 256:
                firmware_data = data + b'\xFF'*(256-len(data))
            else:
                firmware_data = data

            flash._write(firmware_data, data_addr)
            data = f.read(256)
            data_addr += 256

def verify_firmware(flash, firmware):    
    with open(firmware, 'br') as f:
        data = f.read(256) # Read 1 page
        data_addr = 0

        while data:
            if len(data) < 256:
                firmware_data = data + b'\xFF'*(256-len(data))
            else:
                firmware_data = data

            firmware_read = bytearray(256)
            flash._read(firmware_read, data_addr)

            data = f.read(256)
            data_addr += 256
            assert(firmware_data == firmware_read)

def format_flash():
    # Setup
    clock   = machine.Pin(0, machine.Pin.OUT)
    reset_n = machine.Pin(1, machine.Pin.OUT)

    # Check if Greyhound is disabled and wait until it is
    reset_n(0)
    time.sleep_ms(10)
    input("Power down Greyhound by removing the power jumpers. Then press Enter to continue...")

    # FLASH: FLASH_CLK (10) -> SCLK, FLASH_CS_N (11) -> SCS_N, IO0 (12)-> MOSI, IO1 (13)-> MISO
    flash_sclk = machine.Pin(10, machine.Pin.OUT)
    flash_cs_n = machine.Pin(11, machine.Pin.OUT)
    flash_mosi = machine.Pin(12, machine.Pin.OUT)
    flash_miso = machine.Pin(13, machine.Pin.IN)

    fpga_spi = machine.SoftSPI(
        mosi=flash_mosi,
        sck=flash_sclk,
        miso=flash_miso,
        polarity=0,
        phase=1,
        baudrate=1_000_000, # Let's try 1 MBaud/s
        bits=8,
        firstbit=machine.SPI.MSB,
    )

    flash = W25QFlash(spi=fpga_spi, cs=flash_cs_n, baud=115200, software_reset=True)

    print(f"Erase flash")
    flash.format()
    fpga_spi.deinit()
    flash_sclk.init(machine.Pin.IN)
    flash_cs_n.init(machine.Pin.IN)
    flash_mosi.init(machine.Pin.IN)
    print(f"Done. Greyhound can now be powered up again.")

def upload_firmware(firmware:str, freq=25_175_000):
    print(f"freq: {machine.freq()}")

    # Setup
    clock   = machine.Pin(0, machine.Pin.OUT)
    reset_n = machine.Pin(1, machine.Pin.OUT)

    # Check if Greyhound is disabled and wait until it is
    reset_n(0)
    time.sleep_ms(10)
    input("Power down Greyhound by removing the power jumpers. Then press Enter to continue...")

    # FLASH: FLASH_CLK (10) -> SCLK, FLASH_CS_N (11) -> SCS_N, IO0 (12)-> MOSI, IO1 (13)-> MISO
    flash_sclk = machine.Pin(10, machine.Pin.OUT)
    flash_cs_n = machine.Pin(11, machine.Pin.OUT)
    flash_mosi = machine.Pin(12, machine.Pin.OUT)
    flash_miso = machine.Pin(13, machine.Pin.IN)

    fpga_spi = machine.SoftSPI(
        mosi=flash_mosi,
        sck=flash_sclk,
        miso=flash_miso,
        polarity=0,
        phase=1,
        baudrate=115200,
        bits=8,
        firstbit=machine.SPI.MSB,
    )

    flash = W25QFlash(spi=fpga_spi, cs=flash_cs_n, baud=115200, software_reset=True)

    print(f"Erase flash")
    flash.format()

    print(f"Write firmware")
    write_firmware(flash, firmware)

    print(f"Verify Integrity")
    verify_firmware(flash, firmware)

    print(f"Deassert SPI")
    fpga_spi.deinit()
    flash_sclk.init(machine.Pin.IN)
    flash_cs_n.init(machine.Pin.IN)
    flash_mosi.init(machine.Pin.IN)

    input("Firmware upload complete power up Greyhound by inserting the power jumpers. Then press Enter to continue...")

    # Inputs
    fpga_mode = machine.Pin(2, machine.Pin.IN)
    fetch_enable = machine.Pin(3, machine.Pin.IN)
    config_busy = machine.Pin(16, machine.Pin.IN)
    core_sleep  = machine.Pin(17, machine.Pin.IN)

    if fetch_enable.value() != 1:
        input("FETCH_ENABLE jumper is low. Resolve then press Enter to continue...")

    pwm0 = machine.PWM(clock, freq=25_175_000, duty_u16=32768) # 50% duty
    print(pwm0.freq())
    
    print("Flash bus released; project_clk requested %d Hz, PWM actual %d Hz"
          % (freq, pwm0.freq()))

    boot_firmware(release_rst=True, baudrate=57600) # Use half baudrate, Greyhound is clocked slower than sim

def boot_firmware(freq=25_175_000, release_rst=False, baudrate=115200):
    # Setup
    clock   = machine.Pin(0, machine.Pin.OUT)
    reset_n = machine.Pin(1, machine.Pin.OUT)

    if release_rst:
        time.sleep_ms(5)
        reset_n.value(1)
    else:
        reset_n.value(0)
        time.sleep_ms(1)
        pwm0 = machine.PWM(clock, freq=25_175_000, duty_u16=32768) # 50% duty
        print(pwm0.freq())
        time.sleep_ms(5)
        reset_n.value(1)

    print(f"Booted firmware !from Greyhound:")
