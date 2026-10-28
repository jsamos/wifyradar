import SwiftUI

enum Brand {
    static let primary = Color("BrandPrimary")
    static let light = Color("BrandLight")
    static let mid = Color("BrandMid")
    static let deep = Color("BrandDeep")
    static let onBrand = Color("BrandOnBrand")

    static var gradient: LinearGradient {
        LinearGradient(
            colors: [light, mid, deep],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var gradientStopNames: [String] {
        ["BrandLight", "BrandMid", "BrandDeep"]
    }

    enum Radius {
        static let control: CGFloat = 14
        static let chip: CGFloat = 999
    }
}
