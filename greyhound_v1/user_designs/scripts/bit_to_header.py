#!/usr/bin/env python
import argparse
from pathlib import Path

def bit_to_header(i_bitstream:Path, o_header:Path) -> None:
    with i_bitstream.open("rb") as i_bitstream_file, o_header.open("w") as header_file:
        bitstream_words = []
        while bitstream_word := i_bitstream_file.read(4):
            bitstream_words.append(int.from_bytes(bitstream_word, "big"))

        header_file.write(f"static const uint32_t {o_header.stem}_bitstream[] = "+r"{"+f"\n0x")
        header_file.write(f"{",\n0x".join([f"{word:08x}" for word in bitstream_words])}")
        header_file.write(f"\n"+r"}"+f";\n")

if __name__ == "__main__":
    arg_parser = argparse.ArgumentParser(description="Build c header file from bitstream")
    arg_parser.add_argument("i_bitstream", help="Path to input bitstream")
    arg_parser.add_argument("o_header", help="Path to output c header file")
    args = arg_parser.parse_args()
    
    bit_to_header(Path(args.i_bitstream), Path(args.o_header))
