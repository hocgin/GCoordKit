//
//  GCJ02Convert.swift
//  App
//
//  Created by hocgin on 2025/3/12.
//
import Foundation

class GCJ02Convert {
    public static func isInChinaBbox(_ pos: Position) -> Bool {
        let (lon, lat) = pos
        return lon >= 72.004 && lon <= 137.8347 && lat >= 0.8293 && lat <= 55.8271
    }

    // 假设以下常量已在全局定义（根据实际需求补充初始化值）
    public static let a: Double = 6378245.0 // 长半轴
    public static let ee: Double = 0.00669342162296594323 // 偏心率平方
    public static let PI = Double.pi

    public static func transformLat(x: Double, y: Double) -> Double {
        var ret = -100.0 + 2.0 * x + 3.0 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(abs(x))
        ret += ((20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0) / 3.0
        ret += ((20.0 * sin(y * PI) + 40.0 * sin((y / 3.0) * PI)) * 2.0) / 3.0
        ret += ((160.0 * sin((y / 12.0) * PI) + 320.0 * sin((y * PI) / 30.0)) * 2.0) / 3.0

        return ret
    }

    public static func transformLon(x: Double, y: Double) -> Double {
        var ret = 300.0 + x + 2.0 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(abs(x))
        ret += ((20.0 * sin(6.0 * x * PI) + 20.0 * sin(2.0 * x * PI)) * 2.0) / 3.0
        ret += ((20.0 * sin(x * PI) + 40.0 * sin((x / 3.0) * PI)) * 2.0) / 3.0
        ret += ((150.0 * sin((x / 12.0) * PI) + 300.0 * sin((x / 30.0) * PI)) * 2.0) / 3.0

        return ret
    }

    public static func delta(lon: Double, lat: Double) -> [Double] {
        let dLon = transformLon(x: lon - 105.0, y: lat - 35.0)
        let dLat = transformLat(x: lon - 105.0, y: lat - 35.0)

        let radLat = (lat / 180.0) * PI
        var magic = sin(radLat)
        magic = 1 - ee * magic * magic

        let sqrtMagic = sqrt(magic)
        let finalDLon = (dLon * 180.0) / ((a / sqrtMagic) * cos(radLat) * PI)
        let finalDLat = (dLat * 180.0) / ((a * (1 - ee) / (magic * sqrtMagic)) * PI)

        return [finalDLon, finalDLat]
    }

    public static func WGS84ToGCJ02(_ pos: Position) -> Position {
        if !isInChinaBbox(pos) {
            return pos
        }
        let (lng, lat) = pos
        let d = Self.delta(lon: lng, lat: lat)

        return (
            lng: lng + d[0],
            lat: lat + d[1]
        )
    }

    public static func GCJ02ToWGS84(_ pos: Position) -> Position {
        if !isInChinaBbox(pos) {
            return pos
        }

        let (lng, lat) = pos
        var (wgsLon, wgsLat) = pos

        var tempPoint = Self.WGS84ToGCJ02((lng: wgsLon, lat: wgsLat))

        var dx = tempPoint.lng - lng
        var dy = tempPoint.lat - lat

        while abs(dx) > 1e-6 || abs(dy) > 1e-6 {
            wgsLon -= dx
            wgsLat -= dy

            tempPoint = Self.WGS84ToGCJ02((lng: wgsLon, lat: wgsLat))
            dx = tempPoint.lng - lng
            dy = tempPoint.lat - lat
        }

        return (lng: wgsLon, lat: wgsLat)
    }
}
