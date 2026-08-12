from utils import upload_bitstream

#upload_bitstream("bitstreams/vga_demo.bit")

#upload_bitstream("bitstreams/greyhound_sine.bit")

#upload_bitstream("bitstreams/seven_seg.bit", 2**16)

machine.freq(100_000_000)
upload_bitstream("bitstreams/vga_test.bit", 10_000_000)
