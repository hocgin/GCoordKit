//
//  BD09Convert.swift
//  App
//
//  Created by hocgin on 2025/3/12.
//
import Foundation

class BD09Convert {
    public static let PI = Double.pi
    static let baiduFactor = (PI * 3000.0) / 180.0

    public static func GCJ02ToBD09(_ pos: Position) -> Position {
        let (lng, lat) = pos
        let x = lng
        let y = lat
        let z = sqrt(x * x + y * y) + 0.00002 * sin(y * baiduFactor)
        let theta = atan2(y, x) + 0.000003 * cos(x * baiduFactor)

        let newLon = z * cos(theta) + 0.0065
        let newLat = z * sin(theta) + 0.006

        return (lng: newLon, lat: newLat)
    }

    public static func BD09ToGCJ02(_ pos: Position) -> Position {
        let (lng, lat) = pos

        let x = lng - 0.0065
        let y = lat - 0.006
        let z = sqrt(x * x + y * y) - 0.00002 * sin(y * baiduFactor)
        let theta = atan2(y, x) - 0.000003 * cos(x * baiduFactor)
        let newLon = z * cos(theta)
        let newLat = z * sin(theta)

        return (lng: newLon, lat: newLat)
    }
}
