#!/bin/sh

# Create palettes.json from ~/Library/Colors/*.clr files
./clr2json

# Generate SVGs and README.md file
rm -rf SVG
julia readme.jl palettes.json

# Copy ~/Library/Colors/*.clr files
clrdir="Colors"
rm -rf $clrdir
mkdir $clrdir
cp ~/Library/Colors/*.clr $clrdir

# Add changes (if any) to be committed
git add Colors SVG README.md palettes.json
