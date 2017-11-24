//
// Created by Konstantin Terekhov on 11/21/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class Route {
    let vehicleTypeNames: [Int: String] = [
        0: "bus",
        1: "trolleybus",
        2: "tram"
    ]

    let id: Int64?
    var number: String?
    var name: String?
    var sortPrefix: Int64?
    var vehicleType: Int?

    init(id: Int64, number: String, name: String, sortPrefix: Int64, vehicleType: Int) {
        self.id = id
        self.number = number
        self.name = name
        self.sortPrefix = sortPrefix
        self.vehicleType = vehicleType
    }

    func vehicleTypeName() -> String {
        if vehicleType != nil {
            return vehicleTypeNames[vehicleType!]!
        }
        return ""
    }
}
