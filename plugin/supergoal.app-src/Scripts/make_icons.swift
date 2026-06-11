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

func roundedStroke(_ rect: NSRect, radius: CGFloat, color: NSColor, lineWidth: CGFloat) {
    let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
    color.setStroke()
    path.lineWidth = lineWidth
    path.stroke()
}

func drawKeyboardMark(in frame: NSRect, scale: CGFloat, cornerRadius: CGFloat, strokeWidth: CGFloat, keyRadius: CGFloat = 0) {
    let shellColor = NSColor(calibratedRed: 0.09, green: 0.11, blue: 0.14, alpha: 1)
    let borderColor = NSColor(calibratedRed: 0.965, green: 0.973, blue: 0.984, alpha: 1)
    let accentColor = NSColor(calibratedRed: 0.553, green: 0.922, blue: 0.863, alpha: 1)

    roundedRect(frame, radius: cornerRadius, color: shellColor)
    roundedStroke(frame.insetBy(dx: strokeWidth / 2, dy: strokeWidth / 2), radius: max(0, cornerRadius - strokeWidth / 2), color: borderColor, lineWidth: strokeWidth)

    let display = NSRect(
        x: frame.minX + frame.width * 0.136,
        y: frame.minY + frame.height * 0.36,
        width: frame.width * 0.73,
        height: frame.height * 0.45
    )
    roundedStroke(display, radius: 3 * scale, color: accentColor, lineWidth: max(1.2 * scale, strokeWidth * 0.42))

    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: frame.height * 0.245, weight: .heavy),
        .foregroundColor: accentColor,
        .paragraphStyle: paragraph
    ]
    NSString(string: "SG").draw(in: display.insetBy(dx: 0, dy: display.height * 0.24), withAttributes: attrs)

    let keyWidth = frame.width * 0.085
    let keyHeight = frame.height * 0.09
    let gap = frame.width * 0.042
    let totalWidth = keyWidth * 6 + gap * 5
    let startX = frame.midX - totalWidth / 2
    let keyY = frame.minY + frame.height * 0.145
    for column in 0..<6 {
        let keyFrame = NSRect(
            x: startX + CGFloat(column) * (keyWidth + gap),
            y: keyY,
            width: keyWidth,
            height: keyHeight
        )
        roundedRect(keyFrame, radius: keyRadius, color: borderColor)
    }
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

    let keyboard = NSRect(x: 20 * scale, y: 34 * scale, width: 88 * scale, height: 64 * scale)
    roundedRect(NSRect(x: keyboard.minX + 3 * scale, y: keyboard.minY - 4 * scale, width: keyboard.width, height: keyboard.height), radius: 8 * scale, color: NSColor.black.withAlphaComponent(0.22))
    drawKeyboardMark(in: keyboard, scale: scale, cornerRadius: 7 * scale, strokeWidth: 4 * scale, keyRadius: 1.2 * scale)
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

func renderBitmap(width: Int, height: Int, draw: (CGFloat, CGFloat) -> Void) -> Data {
    let rep = NSBitmapImageRep(
        bitmapDataPlanes: nil,
        pixelsWide: width,
        pixelsHigh: height,
        bitsPerSample: 8,
        samplesPerPixel: 4,
        hasAlpha: true,
        isPlanar: false,
        colorSpaceName: .deviceRGB,
        bytesPerRow: 0,
        bitsPerPixel: 0
    )!
    rep.size = NSSize(width: width, height: height)

    NSGraphicsContext.saveGraphicsState()
    NSGraphicsContext.current = NSGraphicsContext(bitmapImageRep: rep)
    NSColor.clear.setFill()
    NSBezierPath(rect: NSRect(x: 0, y: 0, width: width, height: height)).fill()
    draw(CGFloat(width), CGFloat(height))
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

let colorMenuData = renderBitmap(width: 90, height: 54) { width, height in
    let scale = min(width / 118, height / 86)
    let x = (width - 118 * scale) / 2
    let y = (height - 86 * scale) / 2
    let shell = NSRect(x: x, y: y, width: 118 * scale, height: 86 * scale)
    drawKeyboardMark(in: shell, scale: scale, cornerRadius: 8 * scale, strokeWidth: 4 * scale, keyRadius: 1.1 * scale)
}
try colorMenuData.write(to: assetsURL.appendingPathComponent("MenuBarIcon.png"))

let menuData = renderBitmap(width: 60, height: 36) { width, _ in
    let scale = width / 60
    let ink = NSColor.black
    roundedStroke(NSRect(x: 5 * scale, y: 3 * scale, width: 50 * scale, height: 30 * scale), radius: 4 * scale, color: ink, lineWidth: 2 * scale)
    roundedStroke(NSRect(x: 14 * scale, y: 14 * scale, width: 32 * scale, height: 13 * scale), radius: 1.5 * scale, color: ink, lineWidth: 1.5 * scale)
    let paragraph = NSMutableParagraphStyle()
    paragraph.alignment = .center
    let attrs: [NSAttributedString.Key: Any] = [
        .font: NSFont.systemFont(ofSize: 8 * scale, weight: .heavy),
        .foregroundColor: ink,
        .paragraphStyle: paragraph
    ]
    NSString(string: "SG").draw(in: NSRect(x: 14 * scale, y: 15 * scale, width: 32 * scale, height: 10 * scale), withAttributes: attrs)
    for column in 0..<6 {
        rect(14 * scale + CGFloat(column) * 6 * scale, 7 * scale, 4 * scale, 3 * scale, color: ink)
    }
}
try menuData.write(to: assetsURL.appendingPathComponent("MenuBarIconTemplate.png"))
