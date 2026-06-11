import AppKit
import Foundation

let root = CommandLine.arguments.dropFirst().first.map(URL.init(fileURLWithPath:)) ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
let assetsURL = root.appendingPathComponent("Assets", isDirectory: true)
let iconsetURL = assetsURL.appendingPathComponent("AppIcon.iconset", isDirectory: true)
let fileManager = FileManager.default

try fileManager.createDirectory(at: assetsURL, withIntermediateDirectories: true)
try? fileManager.removeItem(at: iconsetURL)
try fileManager.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

func pixelAligned(_ value: CGFloat) -> CGFloat {
    floor(value)
}

func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat, color: NSColor) {
    color.setFill()
    NSBezierPath(rect: NSRect(x: pixelAligned(x), y: pixelAligned(y), width: pixelAligned(width), height: pixelAligned(height))).fill()
}

func roundedRect(_ rect: NSRect, radius: CGFloat, color: NSColor) {
    color.setFill()
    NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius).fill()
}

func drawPixelLettersSG(origin: NSPoint, block: CGFloat, color: NSColor) {
    let sRows = [
        "1111",
        "1000",
        "1000",
        "1110",
        "0001",
        "0001",
        "1110"
    ]
    let gRows = [
        "1111",
        "1000",
        "1000",
        "1011",
        "1001",
        "1001",
        "1111"
    ]

    func draw(rows: [String], xOffset: CGFloat) {
        for (rowIndex, row) in rows.enumerated() {
            for (columnIndex, value) in row.enumerated() where value == "1" {
                rect(
                    origin.x + xOffset + CGFloat(columnIndex) * block,
                    origin.y + CGFloat(rows.count - 1 - rowIndex) * block,
                    block * 0.82,
                    block * 0.82,
                    color: color
                )
            }
        }
    }

    draw(rows: sRows, xOffset: 0)
    draw(rows: gRows, xOffset: block * 5.2)
}

func drawAppIcon(size: CGFloat) {
    let scale = size / 128.0
    let bg = NSRect(x: 8 * scale, y: 8 * scale, width: 112 * scale, height: 112 * scale)
    let shadow = NSShadow()
    shadow.shadowBlurRadius = 18 * scale
    shadow.shadowOffset = NSSize(width: 0, height: -4 * scale)
    shadow.shadowColor = NSColor.black.withAlphaComponent(0.28)
    shadow.set()
    roundedRect(bg, radius: 26 * scale, color: NSColor(calibratedWhite: 0.06, alpha: 1))

    NSGraphicsContext.saveGraphicsState()
    NSBezierPath(roundedRect: bg, xRadius: 26 * scale, yRadius: 26 * scale).addClip()
    let gradient = NSGradient(colors: [
        NSColor(calibratedRed: 0.18, green: 0.20, blue: 0.24, alpha: 1),
        NSColor(calibratedRed: 0.06, green: 0.07, blue: 0.09, alpha: 1)
    ])
    gradient?.draw(in: bg, angle: 90)

    let glowCenter = NSPoint(x: 84 * scale, y: 88 * scale)
    let glowColors = [
        NSColor.controlAccentColor.withAlphaComponent(0.28).cgColor,
        NSColor.controlAccentColor.withAlphaComponent(0).cgColor
    ] as CFArray
    if let radial = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: glowColors, locations: [0, 1]),
       let cg = NSGraphicsContext.current?.cgContext {
        cg.drawRadialGradient(
            radial,
            startCenter: glowCenter,
            startRadius: 0,
            endCenter: glowCenter,
            endRadius: 56 * scale,
            options: [.drawsAfterEndLocation]
        )
    }

    let keyboard = NSRect(x: 22 * scale, y: 25 * scale, width: 84 * scale, height: 66 * scale)
    roundedRect(NSRect(x: keyboard.minX + 2 * scale, y: keyboard.minY - 3 * scale, width: keyboard.width, height: keyboard.height), radius: 10 * scale, color: NSColor.black.withAlphaComponent(0.24))
    roundedRect(keyboard, radius: 10 * scale, color: NSColor(calibratedWhite: 0.12, alpha: 1))
    roundedRect(NSRect(x: 26 * scale, y: 30 * scale, width: 76 * scale, height: 55 * scale), radius: 6 * scale, color: NSColor(calibratedWhite: 0.17, alpha: 1))
    rect(30 * scale, 78 * scale, 68 * scale, 2 * scale, color: NSColor.white.withAlphaComponent(0.14))

    let key = NSColor(calibratedWhite: 0.63, alpha: 0.72)
    let keyHot = NSColor.controlAccentColor.withAlphaComponent(0.82)
    for row in 0..<3 {
        let y = CGFloat(63 - row * 10) * scale
        let offset = CGFloat(row) * 4 * scale
        let count = row == 0 ? 8 : 7
        for column in 0..<count {
            let x = 32 * scale + offset + CGFloat(column) * 8 * scale
            let isHot = (row == 0 && column == 5) || (row == 1 && column == 2)
            rect(x, y, 5 * scale, 4 * scale, color: isHot ? keyHot : key)
        }
    }

    roundedRect(NSRect(x: 39 * scale, y: 31 * scale, width: 50 * scale, height: 20 * scale), radius: 4 * scale, color: NSColor.controlAccentColor.withAlphaComponent(0.92))
    rect(43 * scale, 47 * scale, 42 * scale, 2 * scale, color: NSColor.white.withAlphaComponent(0.22))
    drawPixelLettersSG(origin: NSPoint(x: 48 * scale, y: 35 * scale), block: 2.05 * scale, color: NSColor.white.withAlphaComponent(0.92))

    rect(34 * scale, 27 * scale, 60 * scale, 2 * scale, color: NSColor.black.withAlphaComponent(0.25))
    NSGraphicsContext.restoreGraphicsState()
}

func renderPNG(size: Int, draw: (CGFloat) -> Void) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: size,
        pixelsHigh: size,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: size, height: size)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSColor.clear.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: size, height: size)).fill()
    draw(CGFloat(size))
    NSGraphicsContext.restoreGraphicsState()

    return rep.representation(using: .png, properties: [:])!
}

let iconSizes: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (name, size) in iconSizes {
    let data = renderPNG(size: size, draw: drawAppIcon)
    try data.write(to: iconsetURL.appendingPathComponent(name))
}

let iconutil = Process()
iconutil.executableURL = URL(fileURLWithPath: "/usr/bin/iconutil")
iconutil.arguments = ["-c", "icns", "-o", assetsURL.appendingPathComponent("AppIcon.icns").path, iconsetURL.path]
try iconutil.run()
iconutil.waitUntilExit()
guard iconutil.terminationStatus == 0 else {
    throw NSError(domain: "supergoal.iconutil", code: Int(iconutil.terminationStatus))
}
try? fileManager.removeItem(at: iconsetURL)

let menuData = renderPNG(size: 36) { _ in
    let ink = NSColor.black
    rect(2, 7, 32, 2, color: ink)
    rect(2, 27, 32, 2, color: ink)
    rect(2, 9, 2, 18, color: ink)
    rect(32, 9, 2, 18, color: ink)
    let keys: [(CGFloat, CGFloat, CGFloat)] = [
        (7, 12, 4), (13, 12, 4), (19, 12, 4), (25, 12, 4),
        (8, 18, 4), (14, 18, 4), (20, 18, 4), (26, 18, 3),
        (11, 23, 14)
    ]
    for key in keys {
        rect(key.0, key.1, key.2, 2, color: ink)
    }
}
try menuData.write(to: assetsURL.appendingPathComponent("MenuBarIconTemplate.png"))
