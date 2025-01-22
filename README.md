<!-- GENERATED FILE, DO NOT EDIT DIRECTLY. SEE `readme.jl` -->
# macOS `.clr` files 
Store custom macOS `~/Library/Colors/*.clr` files. To create your own, fork this repo and run:
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
with the `.json` generated from `clr2json`

## Apple Logo
<img src='./svg/Apple Logo.svg'>

## Army Green
<img src='./svg/Army Green.svg'>

## Baby
<img src='./svg/Baby.svg'>

## Black Red Gray
<img src='./svg/Black Red Gray.svg'>

## Cobolt
<img src='./svg/Cobolt.svg'>

## Dawn
<img src='./svg/Dawn.svg'>

## Emerald
<img src='./svg/Emerald.svg'>

## Green Black
<img src='./svg/Green Black.svg'>

## Julia
<img src='./svg/Julia.svg'>

## LaTeX
<img src='./svg/LaTeX.svg'>

## MIT
<img src='./svg/MIT.svg'>

## MIT Lincoln Laboratory
<img src='./svg/MIT Lincoln Laboratory.svg'>

## MIT Sloan
<img src='./svg/MIT Sloan.svg'>

## Moss
<img src='./svg/Moss.svg'>

## Seafoam Green
<img src='./svg/Seafoam Green.svg'>

## Stanford
<img src='./svg/Stanford.svg'>

## Stanford Blacks
<img src='./svg/Stanford Blacks.svg'>

## Stanford Web
<img src='./svg/Stanford Web.svg'>

## Sun
<img src='./svg/Sun.svg'>

## Tufte
<img src='./svg/Tufte.svg'>

## Viridis 25
<img src='./svg/Viridis 25.svg'>

## Viridis 6
<img src='./svg/Viridis 6.svg'>

## Wentworth
<img src='./svg/Wentworth.svg'>

