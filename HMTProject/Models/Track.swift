//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class Track {
    let id: Int64?
    var routeId: Int64?
    var centerLatitude: Float64?
    var centerLongitude: Float64?


    init(id: Int64, routeId: Int64, centerLatitude: Float64, centerLongitude: Float64) {
        self.id = id
        self.routeId = routeId
        self.centerLatitude = centerLatitude
        self.centerLongitude = centerLongitude
    }
}
