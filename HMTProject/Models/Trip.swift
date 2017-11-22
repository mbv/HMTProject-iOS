//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class Trip {
    let id: Int64?
    var routeId: Int64?
    var endStopA: String?
    var endStopB: String?
    var nameA: String?
    var nameB: String?


    init(id: Int64, routeId: Int64, endStopA: String, endStopB: String, nameA: String, nameB: String) {
        self.id = id
        self.routeId = routeId
        self.endStopA = endStopA
        self.endStopB = endStopB
        self.nameA = nameA
        self.nameB = nameB
    }
}
