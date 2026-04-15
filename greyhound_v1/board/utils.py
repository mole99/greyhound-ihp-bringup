import os
import time
import machine

def upload_bitstream(bitstream, freq=25_175_000):

    print(f"freq: {machine.freq()}")

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
    
    pwm0 = machine.PWM(clock, freq=freq, duty_u16=32768) # 50% duty
    print(pwm0.freq())

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
