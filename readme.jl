# Adapted from https://github.com/JuliaGraphics/Colors.jl/blob/master/docs/namedcolorcharts.jl

using Pkg
Pkg.activate(@__DIR__)
using Colors
using JSON

function get_palettes(jsonpath::String)
	# Load and parse the JSON file
	if !isfile(jsonpath)
		error("JSON file '$jsonpath' does not exist.")
	end

	json_content = read(jsonpath, String)
	parsed_json = JSON.parse(json_content)
	palettes = parsed_json["palettes"]
	return palettes
end

get_palette_name(palette) = collect(keys(palette))[1]

function generate_svgs(jsonpath::String; outputdir="SVG")
	if !isdir(outputdir)
		mkdir(outputdir)
	end

	palettes = get_palettes(jsonpath)
	
	for i in eachindex(palettes)
		io = IOBuffer()

		palette_name = get_palette_name(palettes[i])
		colornames = map(kv->collect(keys(kv))[1], palettes[i][palette_name])
		colorvalues = map(kv->collect(values(kv))[1], palettes[i][palette_name])
		numbercells = length(colornames)
	
		numbercols = 10
		colwidth = 15 #mm
		swatchheight = 20 # mm
		pagewidth = 150 # mm
	
		margin = round(pagewidth - colwidth * numbercols) / 2
		numberrows = convert(Int, ceil(numbercells/numbercols))
		pageheight = numberrows * swatchheight + margin

		write(io, """
        <svg xmlns="http://www.w3.org/2000/svg" version="1.1"
                viewBox="0 0 $pagewidth $pageheight"
                width="$(pagewidth)mm" height="$(pageheight)mm"
                style="width:100%; height:auto;"
                shape-rendering="crispEdges" stroke="none">
            <defs>
                <style>
                    div {
                        text-anchor: middle;
                        font-size: 2.25px;
                        font-weight: 500;
                        font-family: Palatino, "Palatino Linotype", "Palatino LT STD", "Book Antiqua", Georgia, serif;
                        fill: currentColor;
                    }
                    .header {
                        font-size: 5px;
                        text-anchor: start;
                        font-family: Palatino, "Palatino Linotype", "Palatino LT STD", "Book Antiqua", Georgia, serif;
                        font-weight: bold;
                        fill: currentColor;
                    }
                    .container {
                        width: 100%;
                        height: 100%;
                        display: flex;
                        flex-direction: column;
                        justify-content: space-between;
                        padding: 2px;
                        box-sizing: border-box;
                    }
                    .w {
                        color: #fff !important;
                    }
                </style>
            </defs>\n""")
	
		for n = 1:numbercells
			name = colornames[n]
			col = colorvalues[n]
			colrgb = parse(RGB, col)
			x = round(margin + colwidth * ((n - 1) % numbercols), digits=1)
			y = round(swatchheight * ((n - 1) ÷ numbercols), digits=1)
			class = convert(Lab, colrgb).l > 60 ? "" : " class=\"w\""

			write(io, """

            <rect x="$x" y="$y" width="$colwidth" height="$swatchheight" fill="$col" />
            <foreignObject x="$x" y="$y" width="$colwidth" height="$swatchheight">
                <div xmlns="http://www.w3.org/1999/xhtml" class="container">
                    <div style="text-align: center;"$class>$name</div>
                    <div style="text-align: center;"$class>$(uppercase(col))</div>
                </div>
            </foreignObject>        
        """)
		end
	
		write(io, "</svg>")
		writesvg(io; filename=joinpath(outputdir, "$palette_name.svg"))
	end
    @info "Finished writing files to $(abspath(outputdir))"
end

function writesvg(io::IO; filename="palette.svg")
	open(filename, "w+") do file
		write(file, take!(io))
		flush(io)
	end
end

README = """
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

"""

function readme(jsonpath::String; svgdir="SVG")
	palettes = get_palettes(jsonpath)
	open("README.md", "w+") do f
		write(f, README)
		for palette in palettes
			name = get_palette_name(palette)
			write(f, "## $name\n")
			write(f, "<img src='./$svgdir/$name.svg'>\n\n")
		end
	end
    @info "Finished writing README.md"
	return nothing
end

if length(ARGS) == 1
    generate_svgs(ARGS[1])
    readme(ARGS[1])
else
    println("""
    Usage:
        julia readme.jl palettes.json
    """)
end