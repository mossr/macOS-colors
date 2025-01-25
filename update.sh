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

# Create automatic commit message
git commit -m "$(
  git diff --cached --name-status Colors \
    | awk -F'\t' '
      {
        # If the first column starts with "R", it’s a rename (e.g. "R100")
        if ($1 ~ /^R[0-9]*/) {
          status = "R"
          newfile = $3
          sub(/^.*\//, "", newfile) # filename only
          sub(/\.clr$/, "", newfile) # remove .clr ext
        } else {
          status = $1
        }

        file = $2
        sub(/^.*\//, "", file) # filename only
        sub(/\.clr$/, "", file) # remove .clr ext

        # Sort files into arrays/strings by status
        if (status == "M") {
          updated = (updated ? updated ", " : "") file
        } else if (status == "A") {
          added = (added ? added ", " : "") file
        } else if (status == "D") {
          deleted = (deleted ? deleted ", " : "") file
        } else if (status == "R") {
          renamed = (renamed ? renamed ", " : "") file " -> " newfile
        }
      }
      END {
        msg = ""
        if (updated) { msg = msg "Updated [" updated "] " }
        if (added)   { msg = msg "Added [" added "] " }
        if (deleted) { msg = msg "Deleted [" deleted "] " }
        if (renamed) { msg = msg "Renamed [" renamed "] " }

        # Trim trailing space
        sub(/[[:space:]]+$/, "", msg)
        print msg
      }
    '
)"

# Show git log
git --no-pager log -1
