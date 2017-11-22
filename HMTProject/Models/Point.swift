//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class Point {
    let id: Int64?
    var trackId: Int64?
    var trackType: Int?
    var pointSort: Int?
    var latitude: Float64?
    var longitude: Float64?


    init(id: Int64, trackId: Int64, trackType: Int, pointSort: Int, latitude: Float64, longitude: Float64) {
        self.id = id
        self.trackId = trackId
        self.trackType = trackType
        self.pointSort = pointSort
        self.latitude = latitude
        self.longitude = longitude
    }
}
