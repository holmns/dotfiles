#!/usr/bin/env swift
// Usage: swift sf_symbol.swift <symbol_name> <hex_color> [size] [variable_value] [output_path]
// Renders an SF Symbol in hierarchical mode with optional variable value (0.0–1.0).
// variable_value controls fill level for variable symbols like "wifi" or "speaker.wave.3".
// Example: swift sf_symbol.swift "wifi" "ffffff" 20 0.75 /tmp/wifi.png
import AppKit

let args = CommandLine.arguments
guard args.count >= 3 else {
    fputs("Usage: sf_symbol.swift <symbol_name> <hex_color> [size] [variable_value 0.0-1.0] [output_path]\n", stderr)
    exit(1)
}

let symbolName = args[1]
let hexStr = args[2].hasPrefix("#") ? String(args[2].dropFirst()) : args[2]
let size = args.count > 3 ? CGFloat(Double(args[3]) ?? 20.0) : 20.0

// Parse optional variable value (must be in 0.0–1.0 to be treated as variable)
var variableValue: Double? = nil
var outputPath: String? = nil
if args.count > 4 {
    if let v = Double(args[4]), v >= 0.0 && v <= 1.0 {
        variableValue = v
        outputPath = args.count > 5 ? args[5] : nil
    } else {
        outputPath = args[4]
    }
}

// Parse hex color
let hexInt = Int(hexStr, radix: 16) ?? 0xffffff
let r = CGFloat((hexInt >> 16) & 0xff) / 255.0
let g = CGFloat((hexInt >> 8) & 0xff) / 255.0
let b = CGFloat(hexInt & 0xff) / 255.0
let color = NSColor(red: r, green: g, blue: b, alpha: 1.0)

// Load symbol — use variableValue initializer when a value is provided (macOS 13+)
let symbol: NSImage?
if let v = variableValue {
    symbol = NSImage(systemSymbolName: symbolName, variableValue: v, accessibilityDescription: nil)
} else {
    symbol = NSImage(systemSymbolName: symbolName, accessibilityDescription: nil)
}

guard let symbol else {
    fputs("Error: SF Symbol '\(symbolName)' not found.\n", stderr)
    exit(1)
}

// Apply hierarchical color configuration
let config = NSImage.SymbolConfiguration(hierarchicalColor: color)
guard let configured = symbol.withSymbolConfiguration(config) else {
    fputs("Error: could not apply symbol configuration.\n", stderr)
    exit(1)
}

// Render at target size
let output = NSImage(size: NSSize(width: size, height: size))
output.lockFocus()
configured.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
                from: .zero, operation: .sourceOver, fraction: 1.0)
output.unlockFocus()

guard let tiff = output.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Error: failed to encode PNG.\n", stderr)
    exit(1)
}

if let path = outputPath {
    do {
        try png.write(to: URL(fileURLWithPath: path))
    } catch {
        fputs("Error writing to \(path): \(error)\n", stderr)
        exit(1)
    }
} else {
    FileHandle.standardOutput.write(png)
}
