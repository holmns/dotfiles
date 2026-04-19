#!/usr/bin/env swift
// Queries WiFi RSSI via CoreWLAN and renders the wifi SF Symbol
// in hierarchical + variable mode as a PNG.
//
// Usage: swift wifi_icon.swift [output_path]
// Default output: /tmp/sketchybar_wifi.png
//
// Compile for faster startup (~5ms vs ~400ms interpreted):
//   swiftc wifi_icon.swift -framework CoreWLAN -framework AppKit -o wifi_icon
//
// RSSI → variable value mapping (0.0–1.0):
//   -50 dBm or better → 1.0 (3 bars)
//   -100 dBm          → 0.0 (no bars)
//   linear interpolation in between
import AppKit
import CoreWLAN

let outputPath = CommandLine.arguments.count > 1
    ? CommandLine.arguments[1]
    : "/tmp/sketchybar_wifi.png"
let size: CGFloat = 20.0

// Query WiFi state
let iface = CWWiFiClient.shared().interface()
let isConnected = iface?.ssid() != nil
let rssi = iface?.rssiValue() ?? -100

// Choose symbol and color
let symbolName: String
let hexColor: String
let variableValue: Double

if isConnected {
    symbolName   = "wifi"
    hexColor     = "ffffff"
    variableValue = min(1.0, max(0.0, Double(rssi + 100) / 50.0))
} else {
    symbolName   = "wifi.slash"
    hexColor     = "888888"
    variableValue = 0.0
}

// Parse hex color
let hexInt = Int(hexColor, radix: 16) ?? 0xffffff
let color  = NSColor(
    red:   CGFloat((hexInt >> 16) & 0xff) / 255.0,
    green: CGFloat((hexInt >>  8) & 0xff) / 255.0,
    blue:  CGFloat( hexInt        & 0xff) / 255.0,
    alpha: 1.0
)

// Load symbol with variable value (macOS 13+)
let symbol: NSImage?
if isConnected {
    symbol = NSImage(systemSymbolName: symbolName,
                     variableValue: variableValue,
                     accessibilityDescription: nil)
} else {
    symbol = NSImage(systemSymbolName: symbolName,
                     accessibilityDescription: nil)
}

guard let sym = symbol else {
    fputs("Error: SF Symbol '\(symbolName)' not found.\n", stderr)
    exit(1)
}

// Apply hierarchical color
let config = NSImage.SymbolConfiguration(hierarchicalColor: color)
guard let configured = sym.withSymbolConfiguration(config) else {
    fputs("Error: could not apply symbol configuration.\n", stderr)
    exit(1)
}

// Render at target size
let output = NSImage(size: NSSize(width: size, height: size))
output.lockFocus()
configured.draw(in: NSRect(x: 0, y: 0, width: size, height: size),
                from: .zero, operation: .sourceOver, fraction: 1.0)
output.unlockFocus()

guard let tiff   = output.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png    = bitmap.representation(using: .png, properties: [:]) else {
    fputs("Error: failed to encode PNG.\n", stderr)
    exit(1)
}

do {
    try png.write(to: URL(fileURLWithPath: outputPath))
} catch {
    fputs("Error writing to \(outputPath): \(error)\n", stderr)
    exit(1)
}
