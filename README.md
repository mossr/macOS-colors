<!-- GENERATED FILE, DO NOT EDIT DIRECTLY. SEE `readme.jl` -->
# macOS `.clr` files 
Store custom macOS `~/Library/Colors/*.clr` files used in [System Color Picker](https://github.com/sindresorhus/System-Color-Picker).

To create your own, fork this repo and run:
```sh
./update.sh
```

## Convert .clr files to .json

Convert your custom `.clr` files to `.json` format.

### Usage
```
Usage:
  clr2json <input.clr> <output.json>   Convert a single .clr file to JSON.
  clr2json                             Convert all .clr files in ~/Library/Colors to a single JSON file named 'palettes.json' in the current directory.
  clr2json -h, --help                  Display this help message.
```

To build the `clr2json` executable, run:
```sh
swiftc clr2json.swift -o clr2json
```

# Palettes

This `README.md` file and the `.svg` palette files were generated using
```sh
julia readme.jl palettes.json
```
with the `.json` generated from `clr2json` (but all you have to do is run `./update.sh`)

## Apple Logo
<img src='./SVG/Apple Logo.svg'>

## Army Green
<img src='./SVG/Army Green.svg'>

## Baby
<img src='./SVG/Baby.svg'>

## Black Red Gray
<img src='./SVG/Black Red Gray.svg'>

## Cobolt
<img src='./SVG/Cobolt.svg'>

## Dawn
<img src='./SVG/Dawn.svg'>

## Emerald
<img src='./SVG/Emerald.svg'>

## Green Black
<img src='./SVG/Green Black.svg'>

## Julia
<img src='./SVG/Julia.svg'>

## LaTeX
<img src='./SVG/LaTeX.svg'>

## MIT
<img src='./SVG/MIT.svg'>

## MIT Lincoln Laboratory
<img src='./SVG/MIT Lincoln Laboratory.svg'>

## MIT Sloan
<img src='./SVG/MIT Sloan.svg'>

## Moss
<img src='./SVG/Moss.svg'>

## Seafoam Green
<img src='./SVG/Seafoam Green.svg'>

## Stanford
<img src='./SVG/Stanford.svg'>

## Stanford Blacks
<img src='./SVG/Stanford Blacks.svg'>

## Stanford Web
<img src='./SVG/Stanford Web.svg'>

## Sun
<img src='./SVG/Sun.svg'>

## Tufte
<img src='./SVG/Tufte.svg'>

## Viridis 25
<img src='./SVG/Viridis 25.svg'>

## Viridis 6
<img src='./SVG/Viridis 6.svg'>

## Wentworth
<img src='./SVG/Wentworth.svg'>

