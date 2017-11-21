//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class Point {
    let id: Int64?
    var trackId:   Int64?
    var trackType: UInt?
    var pointSort: Int?
    var latitude:  Float64?
    var longitude: Float64?


    init(id: Int64) {
        self.id = id
    }
}
