import Foundation
import Testing
import UIKit
@testable import WifyRadar

struct BrandCatalogTests {
    @Test("AccentColor matches BrandPrimary and icon primary sample")
    func accentColorMatchesBrandPrimary() throws {
        // Scenario: Accent matches brand primary
        let accent = try catalogRGB(colorset: "AccentColor")
        let primary = try catalogRGB(colorset: "BrandPrimary")
        #expect(accent == primary)
        #expect(approximatelyEqual(accent, Self.iconPrimary))
        #expect(approximatelyEqual(try namedRGB("AccentColor"), Self.iconPrimary))
        #expect(approximatelyEqual(try namedRGB("BrandPrimary"), Self.iconPrimary))
    }

    @Test("brand named colors match frozen icon samples")
    func brandCatalogMatchesIconSamples() throws {
        // Scenario: Brand catalog matches icon samples
        #expect(approximatelyEqual(try catalogRGB(colorset: "BrandLight"), Self.iconLight))
        #expect(approximatelyEqual(try catalogRGB(colorset: "BrandMid"), Self.iconMid))
        #expect(approximatelyEqual(try catalogRGB(colorset: "BrandDeep"), Self.iconDeep))
        #expect(approximatelyEqual(try catalogRGB(colorset: "BrandOnBrand"), Self.iconOnBrand))

        #expect(approximatelyEqual(try namedRGB("BrandLight"), Self.iconLight))
        #expect(approximatelyEqual(try namedRGB("BrandMid"), Self.iconMid))
        #expect(approximatelyEqual(try namedRGB("BrandDeep"), Self.iconDeep))
        #expect(approximatelyEqual(try namedRGB("BrandOnBrand"), Self.iconOnBrand))
    }

    @Test("Brand.gradient uses light, mid, then deep stop names")
    func brandGradientUsesIconStops() {
        // Scenario: Brand gradient uses icon stops
        #expect(Brand.gradientStopNames == ["BrandLight", "BrandMid", "BrandDeep"])
    }

    private static let iconLight = RGB(red: 0.992, green: 0.600, blue: 0.749)
    private static let iconMid = RGB(red: 0.988, green: 0.341, blue: 0.643)
    private static let iconPrimary = RGB(red: 0.984, green: 0.149, blue: 0.510)
    private static let iconDeep = RGB(red: 0.976, green: 0.047, blue: 0.467)
    private static let iconOnBrand = RGB(red: 1, green: 1, blue: 1)
}

private struct RGB: Equatable {
    var red: Double
    var green: Double
    var blue: Double
}

private func approximatelyEqual(_ lhs: RGB, _ rhs: RGB, tolerance: Double = 0.012) -> Bool {
    abs(lhs.red - rhs.red) <= tolerance
        && abs(lhs.green - rhs.green) <= tolerance
        && abs(lhs.blue - rhs.blue) <= tolerance
}

private func namedRGB(_ name: String) throws -> RGB {
    let traits = UITraitCollection(userInterfaceStyle: .light)
    guard let color = UIColor(named: name, in: Bundle(for: PersistenceController.self), compatibleWith: traits) else {
        throw BrandCatalogTestError.missingNamedColor(name)
    }
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    guard color.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
        throw BrandCatalogTestError.unreadableNamedColor(name)
    }
    return RGB(red: Double(red), green: Double(green), blue: Double(blue))
}

private func catalogRGB(colorset: String) throws -> RGB {
    let url = try assetsRoot()
        .appendingPathComponent("\(colorset).colorset")
        .appendingPathComponent("Contents.json")
    let data = try Data(contentsOf: url)
    let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
    let colors = json?["colors"] as? [[String: Any]]
    let universal = try #require(colors?.first { $0["appearances"] == nil })
    let components = try #require((universal["color"] as? [String: Any])?["components"] as? [String: String])
    return RGB(
        red: try parseComponent(components["red"]),
        green: try parseComponent(components["green"]),
        blue: try parseComponent(components["blue"])
    )
}

private func parseComponent(_ raw: String?) throws -> Double {
    guard let raw, let value = Double(raw) else {
        throw BrandCatalogTestError.invalidComponent
    }
    return value
}

private func assetsRoot() throws -> URL {
    var url = URL(fileURLWithPath: #filePath)
    for _ in 0..<10 {
        let candidate = url.appendingPathComponent("WifyRadar/Assets.xcassets")
        if FileManager.default.fileExists(atPath: candidate.path) {
            return candidate
        }
        url.deleteLastPathComponent()
    }
    throw BrandCatalogTestError.missingAssetsRoot
}

private enum BrandCatalogTestError: Error {
    case missingNamedColor(String)
    case unreadableNamedColor(String)
    case invalidComponent
    case missingAssetsRoot
}
