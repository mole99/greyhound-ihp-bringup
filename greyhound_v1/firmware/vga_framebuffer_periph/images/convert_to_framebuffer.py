from PIL import Image

WIDTH = 640//4
HEIGHT = 480//4


for image_name in ["image_1", "image_2", "image_3"]:

    img = Image.open(f"{image_name}.jpg").convert("RGB")
    img = img.resize((WIDTH, HEIGHT))
    img.show()

    with open(f"{image_name}.h", "w") as file:

        file.write(f"// {image_name}\n\n");
        
        file.write(f"static const uint8_t {image_name}_data[] = {{\n");
        for y in range(HEIGHT):
            file.write(f"  ");
            for x in range(WIDTH):
                r, g, b = img.getpixel((x, y))
                print(f"{x} {y}: {r>>6} {g>>6} {b>>6}")
                
                # Disable dithering, i.e. always set lsb for red and green
                pixel = 0x1 << 7 | 0x1 << 6 | (r>>6)<<4 | (g>>6)<<2 | (b>>6)
                
                print(pixel)
                
                file.write(f"{pixel}, ");
            file.write("\n");
        file.write("};");

    with open(f"{image_name}_dither.h", "w") as file:

        file.write(f"// {image_name}_dither\n\n");
        
        file.write(f"static const uint8_t {image_name}_dither_data[] = {{\n");
        for y in range(HEIGHT):
            file.write(f"  ");
            for x in range(WIDTH):
                r, g, b = img.getpixel((x, y))
                print(f"{x} {y}: {r>>6} {g>>6} {b>>6}")
                
                # Get one additional lsb for red and green
                # Can be used for dithering
                r_lsb = (r>>5) & 0x1
                g_lsb = (g>>5) & 0x1
                
                pixel = r_lsb << 7 | g_lsb << 6 | (r>>6)<<4 | (g>>6)<<2 | (b>>6)
                
                print(pixel)
                
                file.write(f"{pixel}, ");
            file.write("\n");
        file.write("};");
