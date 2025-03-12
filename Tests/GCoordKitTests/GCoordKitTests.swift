import CoreLocation
@testable import GCoordKit
import Testing

@Test func example2Test() async throws {
    let coord = CLLocationCoordinate2D(latitude: 39.984154, longitude: 116.307490)
    let isInChinaBbox = try coord.isInChinaBbox(.GCJ02)
    let toCoord = try coord.transform(from: .GCJ02, to: .WGS84)
    print("coord = \(["coord": coord, "isInChinaBbox": isInChinaBbox, "toCoord": toCoord])")
}

@Test func exampleTest() async throws {
    /// 39.984154,116.307490
    let pos: Position = (lng: 116.307490, lat: 39.984154)
    let crsType: CRSType = .GCJ02
    let posInChinaBbox = try GCoordKit.isInChinaBbox(pos, from: crsType)

    let BD09 = try GCoordKit.transform(pos, from: crsType, to: .BD09)
    let BD09InChinaBbox = try GCoordKit.isInChinaBbox(BD09, from: .BD09)

    let BD09MC = try GCoordKit.transform(pos, from: crsType, to: .BD09MC)
    let BD09MCInChinaBbox = try GCoordKit.isInChinaBbox(BD09MC, from: .BD09MC)

    let EPSG3857 = try GCoordKit.transform(pos, from: crsType, to: .EPSG3857)
    let EPSG3857InChinaBbox = try GCoordKit.isInChinaBbox(EPSG3857, from: .EPSG3857)

    let GCJ02 = try GCoordKit.transform(pos, from: crsType, to: .GCJ02)
    let GCJ02InChinaBbox = try GCoordKit.isInChinaBbox(GCJ02, from: .GCJ02)

    let WGS84 = try GCoordKit.transform(pos, from: crsType, to: .WGS84)
    let WGS84InChinaBbox = try GCoordKit.isInChinaBbox(WGS84, from: .WGS84)

    print("pos = \(pos)")
    print("pos InChinaBbox = \(posInChinaBbox)")
    print("BD09 = \(BD09)")
    print("BD09 InChinaBbox = \(BD09InChinaBbox)")
    print("BD09MC = \(BD09MC)")
    print("BD09MC InChinaBbox = \(BD09MCInChinaBbox)")
    print("EPSG3857 = \(EPSG3857)")
    print("EPSG3857 InChinaBbox = \(EPSG3857InChinaBbox)")
    print("GCJ02 = \(GCJ02)")
    print("GCJ02 InChinaBbox = \(GCJ02InChinaBbox)")
    print("WGS84 = \(WGS84)")
    print("WGS84 InChinaBbox = \(WGS84InChinaBbox)")
}
