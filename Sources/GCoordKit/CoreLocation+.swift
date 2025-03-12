//
//  CoreLocation+.swift
//  App
//
//  Created by hocgin on 2025/3/12.
//

import CoreLocation

public extension CLLocationCoordinate2D {
    var postion: Position { (lng: self.longitude, lat: self.latitude) }

    /// 坐标系转换x
    func transform(from fromType: CRSType = .WGS84, to toType: CRSType) throws -> CLLocationCoordinate2D {
        let pos = try GCoordKit.transform(self.postion, from: fromType, to: toType)
        return CLLocationCoordinate2DMake(pos.lat, pos.lng)
    }

    /// 大致判断坐标是否在中国大陆
    func isInChinaBbox(_ type: CRSType = .WGS84) throws -> Bool {
        return try GCoordKit.isInChinaBbox(self.postion, from: type)
    }
}
