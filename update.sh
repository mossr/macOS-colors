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
        # Remove path from file
        sub(/^.*\//, "", $2);
        # Remove .clr extension
        sub(/\.clr$/, "", $2);
        if($1=="A") { added = (added ? added ", " : "") $2 }
        if($1=="M") { updated = (updated ? updated ", " : "") $2 }
        if($1=="D") { deleted = (deleted ? deleted ", " : "") $2 }
      }
      END {
        msg="";
        if(updated) msg=msg "Updated [" updated "] ";
        if(added) msg=msg "Added [" added "] ";
        if(deleted) msg=msg "Deleted [" deleted "] ";
        # Strip trailing space
        sub(/[[:space:]]+$/, "", msg);
        print msg;
      }
    '
)"

# Show git log
git --no-pager log -1
