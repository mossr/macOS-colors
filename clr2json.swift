import Foundation
import AppKit

// MARK: - Helper Functions

/// Convert a color component in [0, 1] to a two-digit hex string (00..FF).
func c2h(_ component: CGFloat) -> String {
    let value = Int(round(component * 255))
    return String(format: "%02x", value)
}

/// Convert an alpha component in [0, 1] to a two-digit hex string,
/// but omit it entirely if alpha == 1.0 (i.e., "ff").
func a2h(_ alpha: CGFloat) -> String {
    let hex = c2h(alpha)
    return (hex == "ff") ? "" : hex
}

/// Convert a string to Title Case (capitalize each word).
func toTitleCase(_ str: String) -> String {
    return str
        .lowercased()
        .split(separator: " ")
        .map { $0.prefix(1).capitalized + $0.dropFirst() }
        .joined(separator: " ")
}

/// Check if a string is a valid 3- or 6-digit hex color, optionally prefixed with `#`.
func isHexColor(_ str: String) -> Bool {
    let pattern = "^#?([0-9A-Fa-f]{3}|[0-9A-Fa-f]{6})$"
    guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
        return false
    }
    let range = NSRange(location: 0, length: str.utf16.count)
    return regex.firstMatch(in: str, options: [], range: range) != nil
}

// MARK: - Data Structures

/// A struct to hold the color data that will be converted to JSON.
struct ColorEntry: Encodable {
    let title: String
    let color: String
    let desc: String

    enum CodingKeys: String, CodingKey {
        case title
        case color
        case desc
    }
}

/// A struct to represent all palettes as an array of dictionaries.
/// Each dictionary maps a palette name to an array of color name-hex dictionaries.
struct AllPalettes: Encodable {
    let palettes: [[String: [[String: String]]]]
}

// MARK: - Main Logic

/// Reads all `.clr` files from `~/Library/Colors` and returns a dictionary mapping palette names to their color entries.
func readClrs() -> [String: [ColorEntry]] {
    // Expand the tilde to get the full path to ~/Library/Colors/
    let homeDir = FileManager.default.homeDirectoryForCurrentUser
    let colorsDir = homeDir
        .appendingPathComponent("Library")
        .appendingPathComponent("Colors")

    var palettes: [String: [ColorEntry]] = [:]

    // Retrieve all items in ~/Library/Colors
    var allItems: [String] = []
    do {
        allItems = try FileManager.default.contentsOfDirectory(atPath: colorsDir.path)
    } catch {
        print("Error reading ~/Library/Colors directory: \(error.localizedDescription)")
        return palettes
    }

    // Filter to only include files ending with ".clr" (case-insensitive)
    let clrFiles = allItems.filter { $0.lowercased().hasSuffix(".clr") }

    // If no .clr files, just exit
    guard !clrFiles.isEmpty else {
        print("No .clr files found in '~/Library/Colors'.")
        return palettes
    }

    // Sort the .clr files alphabetically to preserve ordering
    let sortedClrFiles = clrFiles.sorted { $0.lowercased() < $1.lowercased() }

    // Process each .clr file
    for clrFile in sortedClrFiles {
        let clrFilePath = colorsDir.appendingPathComponent(clrFile)
        let paletteName = (clrFile as NSString).deletingPathExtension

        // Load the NSColorList from the file
        guard let nsColorList = NSColorList(name: NSColor.Name(paletteName),
                                            fromFile: clrFilePath.path)
        else {
            // Failed to load color list from file.
            print("Warning: Failed to load color list from '\(clrFilePath.path)'. Skipping.")
            continue
        }

        var colorList: [ColorEntry] = []
        var titleCounts: [String: Int] = [:]

        // Iterate all keys (color names) in the color list in order
        for key in nsColorList.allKeys {
            guard let nsColor = nsColorList.color(withKey: key) else {
                // If we can’t retrieve a color object, skip
                continue
            }

            // Attempt to get an sRGB version
            let rgbColor = nsColor.usingColorSpace(.sRGB)

            // If it can't be converted to RGB, let's try grayscale or skip
            let colorValue: String
            if let c = rgbColor {
                // We have an RGB color
                let r = c2h(c.redComponent)
                let g = c2h(c.greenComponent)
                let b = c2h(c.blueComponent)
                let a = a2h(c.alphaComponent)
                // Build something like: #rrggbb or #rrggbbaa
                colorValue = "#" + [r, g, b, a].joined()
            } else {
                // Possibly a grayscale color
                let whiteVal = c2h(nsColor.whiteComponent)
                let alphaVal = a2h(nsColor.alphaComponent)
                colorValue = "#" + [whiteVal, whiteVal, whiteVal, alphaVal].joined()
            }

            // Original color name
            var finalTitle = key

            // Attempt to retrieve accessibilityName
            let accessibilityName = (nsColor.value(forKey: "accessibilityName") as? String) ?? ""
            let desc = toTitleCase(accessibilityName)

            // If the original color name is a hex code, use the accessibility name
            if isHexColor(finalTitle) && !accessibilityName.isEmpty {
                finalTitle = desc
            }

            // Handle duplicates
            if let count = titleCounts[finalTitle] {
                titleCounts[finalTitle] = count + 1
                finalTitle = "\(finalTitle) \(count + 1)"
            } else {
                titleCounts[finalTitle] = 1
            }

            colorList.append(ColorEntry(title: finalTitle, color: colorValue, desc: desc))
        }

        palettes[paletteName] = colorList
    }

    return palettes
}

/// Transforms the palettes dictionary into the desired JSON structure and writes it to a file.
func writePalettesJSON(palettes: [String: [ColorEntry]], outputPath: String) throws {
    // Sort the palette names alphabetically to preserve ordering
    let sortedPaletteNames = palettes.keys.sorted { $0.lowercased() < $1.lowercased() }

    // Transform each palette into the desired format
    var transformedPalettes: [[String: [[String: String]]]] = []

    for paletteName in sortedPaletteNames {
        if let colorEntries = palettes[paletteName] {
            // Transform [ColorEntry] into [[String: String]]
            let colorArray: [[String: String]] = colorEntries.map { colorEntry in
                return [colorEntry.title: colorEntry.color]
            }

            // Append to the transformed palettes array
            transformedPalettes.append([paletteName: colorArray])
        }
    }

    // Create the AllPalettes struct
    let allPalettes = AllPalettes(palettes: transformedPalettes)

    // Encode to JSON
    let encoder = JSONEncoder()
    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
    let jsonData = try encoder.encode(allPalettes)

    // Write to file
    let url = URL(fileURLWithPath: outputPath)
    try jsonData.write(to: url)
}

// MARK: - Command-Line Argument Handling

/// Displays the help message.
func displayHelp() {
    let helpMessage = """
    clr2json - Convert Apple .clr color files to JSON.

    Usage:
      clr2json <input.clr> <output.json>   Convert a single .clr file to JSON.
      clr2json                            Convert all .clr files in ~/Library/Colors to a single JSON file named 'palettes.json' in the current directory.
      clr2json -h, --help                 Display this help message.

    Examples:
      clr2json MyPalette.clr MyPalette.json
      clr2json
      clr2json --help
    """
    print(helpMessage)
}

// MARK: - Entry Point

func main() {
    let arguments = CommandLine.arguments
    let argumentCount = arguments.count

    // No arguments provided (other than the executable name)
    if argumentCount == 1 {
        // Batch mode: Read all .clr files from ~/Library/Colors and output to 'palettes.json'
        let palettes = readClrs()
        do {
            try writePalettesJSON(palettes: palettes, outputPath: "palettes.json")
            print("Successfully converted all .clr files in '~/Library/Colors' to 'palettes.json'.")
        } catch {
            print("Error writing JSON: \(error.localizedDescription)")
            exit(1)
        }
    }
    // Help flag
    else if argumentCount == 2 && (arguments[1] == "-h" || arguments[1] == "--help") {
        displayHelp()
        exit(0)
    }
    // Single file mode: Expecting two additional arguments
    else if argumentCount == 3 {
        let inputPath = arguments[1]
        let outputPath = arguments[2]

        // Validate input file existence
        guard FileManager.default.fileExists(atPath: inputPath) else {
            print("Error: Input file '\(inputPath)' does not exist.")
            exit(1)
        }

        // Validate input file extension
        guard inputPath.lowercased().hasSuffix(".clr") else {
            print("Error: Input file '\(inputPath)' is not a .clr file.")
            exit(1)
        }

        // Read the specified .clr file
        let palettes = readClrs()
        // Extract the specific palette
        let url = URL(fileURLWithPath: inputPath)
        let paletteName = url.deletingPathExtension().lastPathComponent

        guard let colorEntries = palettes[paletteName] else {
            print("Error: Palette '\(paletteName)' not found in the provided .clr file.")
            exit(1)
        }

        // Transform the specific palette into the desired format
        let transformedPalette: [[String: [[String: String]]]] = [
            [
                paletteName: colorEntries.map { [ $0.title: $0.color ] }
            ]
        ]

        // Create the AllPalettes struct
        let allPalettes = AllPalettes(palettes: transformedPalette)

        // Encode to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        do {
            let jsonData = try encoder.encode(allPalettes)
            let url = URL(fileURLWithPath: outputPath)
            try jsonData.write(to: url)
            print("Successfully converted '\(inputPath)' to '\(outputPath)'.")
        } catch {
            print("Error encoding JSON: \(error.localizedDescription)")
            exit(1)
        }
    }
    // Invalid usage
    else {
        print("Invalid usage. Use '-h' or '--help' for usage instructions.")
        exit(1)
    }
}

main()