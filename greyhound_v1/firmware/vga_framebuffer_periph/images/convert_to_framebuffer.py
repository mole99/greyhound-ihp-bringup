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
                
                pixel = (r>>6)<<4 | (g>>6)<<2 | (b>>6)
                
                print(pixel)
                
                file.write(f"{pixel}, ");
            file.write("\n");
        file.write("};");
