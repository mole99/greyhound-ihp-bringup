from utils import upload_bitstream, upload_firmware, run_firmware

#upload_bitstream("bitstreams/vga_demo.bit")

#time.sleep_ms(5000)

#upload_firmware("firmware/xif_gpio_blink.bin", freq=25_175_000)

#upload_firmware("firmware/greyhound_sine_periph.bin", freq=25_175_000)

run_firmware(freq=25_175_000)
