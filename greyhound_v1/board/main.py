from utils import upload_bitstream, upload_firmware, run_firmware

#upload_bitstream("bitstreams/vga_demo.bit")
#upload_bitstream("bitstreams/vga_framebuffer_periph.bit", freq=25_175_000)

#time.sleep_ms(5000)

#upload_firmware("firmware/xif_gpio_blink.bin", freq=25_175_000)

#upload_firmware("firmware/greyhound_sine_periph.bin", freq=25_175_000)

upload_firmware("firmware/vga_framebuffer_periph.bin", freq=25_175_000)

#run_firmware(freq=25_175_000)
