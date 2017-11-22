//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class Route {
    let id: Int64?
    var number: String?
    var name: String?
    var sortPrefix: Int64?

    init(id: Int64, number: String, name: String, sortPrefix: Int64) {
        self.id = id
        self.number = number
        self.name = name
        self.sortPrefix = sortPrefix
    }
}
