//
//  GCoord.swift
//  App
//
//  Created by hocgin on 2025/3/12.
//

import Foundation

// 经, 纬度
public typealias Position = (lng: Double, lat: Double)
typealias Transform = (Position) -> Position
enum GCoordError: Error {
    case transformError
}

public enum CRSType: String, Codable {
    case WGS84
    case GCJ02
    case BD09
    case EPSG3857
    case BD09MC
}

open class GCoordKit {
    private init() {}

    /// 转换经纬度
    public static func transform(_ pos: Position, from fromType: CRSType, to toType: CRSType) throws -> Position {
        if fromType == toType { return pos }
        if let transform = convert(fromType)[toType] {
            return transform(pos)
        }
        throw GCoordError.transformError
    }

    /// 大致判断是否为中国大陆
    public static func isInChinaBbox(_ pos: Position, from fromType: CRSType) throws -> Bool {
        var gcjPos: Position = pos
        if fromType != .GCJ02 {
            gcjPos = try Self.transform(pos, from: fromType, to: .GCJ02)
        }
        return GCJ02Convert.isInChinaBbox(gcjPos)
    }

    private static func convert(_ type: CRSType) -> [CRSType: Transform] {
        switch type {
        case .BD09:
            GCoordKit.BD09
        case .WGS84:
            GCoordKit.WGS84
        case .GCJ02:
            GCoordKit.GCJ02
        case .EPSG3857:
            GCoordKit.EPSG3857
        case .BD09MC:
            GCoordKit.BD09MC
        }
    }
}

/// @see https://github.com/hujiulong/gcoord
public extension GCoordKit {
    private static let WGS84: [CRSType: Transform] = [
        .GCJ02: WGS84ToGCJ02,
        .BD09: compose([GCJ02ToBD09, WGS84ToGCJ02]),
        .BD09MC: compose([BD09toBD09MC, GCJ02ToBD09, WGS84ToGCJ02]),
        .EPSG3857: WGS84ToEPSG3857,
    ]

    private static let GCJ02: [CRSType: Transform] = [
        .WGS84: GCJ02ToWGS84,
        .BD09: GCJ02ToBD09,
        .BD09MC: compose([BD09toBD09MC, GCJ02ToBD09]),
        .EPSG3857: compose([WGS84ToEPSG3857, GCJ02ToWGS84]),
    ]

    private static let BD09: [CRSType: Transform] = [
        .WGS84: compose([GCJ02ToWGS84, BD09ToGCJ02]),
        .GCJ02: GCJ02ToBD09,
        .EPSG3857: compose([WGS84ToEPSG3857, GCJ02ToWGS84, BD09ToGCJ02]),
        .BD09MC: BD09toBD09MC,
    ]

    private static let EPSG3857: [CRSType: Transform] = [
        .WGS84: EPSG3857ToWGS84,
        .GCJ02: compose([WGS84ToGCJ02, EPSG3857ToWGS84]),
        .BD09: compose([GCJ02ToBD09, WGS84ToGCJ02, EPSG3857ToWGS84]),
        .BD09MC: compose([
            BD09toBD09MC,
            GCJ02ToBD09,
            WGS84ToGCJ02,
            EPSG3857ToWGS84,
        ]),
    ]

    private static let BD09MC: [CRSType: Transform] = [
        .WGS84: compose([GCJ02ToWGS84, BD09ToGCJ02, BD09MCtoBD09]),
        .GCJ02: compose([BD09ToGCJ02, BD09MCtoBD09]),
        .EPSG3857: compose([
            WGS84ToEPSG3857,
            GCJ02ToWGS84,
            BD09ToGCJ02,
            BD09MCtoBD09,
        ]),
        .BD09: BD09MCtoBD09,
    ]

    static let GCJ02ToBD09 = BD09Convert.GCJ02ToBD09
    static let BD09ToGCJ02 = BD09Convert.BD09ToGCJ02
    static let WGS84ToGCJ02 = GCJ02Convert.WGS84ToGCJ02
    static let GCJ02ToWGS84 = GCJ02Convert.GCJ02ToWGS84
    static let BD09MCtoBD09 = BD09MCConvert.BD09MCtoBD09
    static let BD09toBD09MC = BD09MCConvert.BD09toBD09MC
    static let WGS84ToEPSG3857 = EPSG3857Convert.WGS84ToEPSG3857
    static let EPSG3857ToWGS84 = EPSG3857Convert.EPSG3857ToWGS84
//    static let isInChinaBbox = GCJ02Convert.isInChinaBbox
}

// public extension GCoordKit {
//    static func postion<Point: Numeric>(_ lat: Point, _ lon: Point) -> Position {
//        (lat: Double(from: lat), lon: Double(from: "\(lon)"))
//    }
// }

func compose(_ funs: [Transform]) -> Transform {
    {
        var last = $0
        for fun in funs {
            last = fun(last)
        }
        return last
    }
}
