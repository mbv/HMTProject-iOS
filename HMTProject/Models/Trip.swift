//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class Trip {
    let id: Int64?
    var routeID: Int64?
    var EndStopA: String?
    var EndStopB: String?
    var NameA: String?
    var NameB: String?


    init(id: Int64) {
        self.id = id
    }
}
