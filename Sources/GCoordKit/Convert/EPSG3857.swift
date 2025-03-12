//
//  EPSG3857Convert.swift
//  App
//
//  Created by hocgin on 2025/3/12.
//

import Foundation

class EPSG3857Convert {
    public static let PI = Double.pi
    static let R2D = 180.0 / PI
    static let D2R = PI / 180.0
    static let A = 6378137.0
    static let MAXEXTENT = 20037508.342789244

    public static func EPSG3857ToWGS84(_ xy: Position) -> Position {
        let (lng, lat) = xy
        return (
            lng: (lng * R2D) / A,
            lat: (PI * 0.5 - 2.0 * atan(exp(-lat / A))) * R2D
        )
    }

    public static func WGS84ToEPSG3857(lonLat: Position) -> Position {
        let (lng, lat) = lonLat

        // compensate longitudes passing the 180th meridian
        // from https://github.com/proj4js/proj4js/blob/master/lib/common/adjust_lon.js
        let adjusted =
            abs(lng) <= 180
                ? lng
                : lng - (lng < 0 ? -1 : 1) * 360
        var xy: [Double] = [
            A * adjusted * D2R,
            A * log(tan(PI * 0.25 + 0.5 * lat * D2R)),
        ]

        // if xy value is beyond maxextent (e.g. poles), return maxextent
        if xy[0] > MAXEXTENT { xy[0] = MAXEXTENT }
        if xy[0] < -MAXEXTENT { xy[0] = -MAXEXTENT }
        if xy[1] > MAXEXTENT { xy[1] = MAXEXTENT }
        if xy[1] < -MAXEXTENT { xy[1] = -MAXEXTENT }

        return (
            lng: xy[0],
            lat: xy[1]
        )
    }
}
