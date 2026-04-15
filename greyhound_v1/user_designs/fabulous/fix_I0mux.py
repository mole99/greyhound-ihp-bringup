import pickle

with open('bitStreamSpec.bin', 'rb') as f:
    specDict = pickle.load(f)

# Replace IOmux with I0mux

for tile, vals in specDict["TileSpecs"].items():
    print(tile)
    for i in ["A", "B", "C", "D", "E", "F", "G", "H"]:
        if f"{i}.IOmux" in specDict["TileSpecs"][tile].keys():
            print("pop!")
            specDict["TileSpecs"][tile][f"{i}.I0mux"] = specDict["TileSpecs"][tile].pop(f"{i}.IOmux")

for tile, vals in specDict["TileSpecs_No_Mask"].items():
    print(tile)
    for i in ["A", "B", "C", "D", "E", "F", "G", "H"]:
        if f"{i}.IOmux" in specDict["TileSpecs_No_Mask"][tile].keys():
            print("pop!")
            specDict["TileSpecs_No_Mask"][tile][f"{i}.I0mux"] = specDict["TileSpecs_No_Mask"][tile].pop(f"{i}.IOmux")


print(specDict["TileSpecs"]['X1Y1']['A.I0mux'])
print(specDict["TileSpecs_No_Mask"]['X1Y1']['A.I0mux'])

with open('bitStreamSpec_new.bin', 'wb') as f:
    pickle.dump(specDict, f)
