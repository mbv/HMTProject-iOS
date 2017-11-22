//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class Stop {
    let id: Int64?
    var MTStopId: Int64?
    var bearing: Int64?
    var latitude: Float64?
    var longitude: Float64?
    var name: String?
    var busType: Bool?
    var trolleybusType: Bool?
    var tramType: Bool?


    init(id: Int64, MTStopId: Int64, bearing: Int64, latitude: Float64, longitude: Float64, name: String, busType: Bool, trolleybusType: Bool, tramType: Bool) {
        self.id = id
        self.MTStopId = MTStopId
        self.bearing = bearing
        self.latitude = latitude
        self.longitude = longitude
        self.name = name
        self.busType = busType
        self.trolleybusType = trolleybusType
        self.tramType = tramType
    }
}
