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


    init(id: Int64) {
        self.id = id
    }
}
