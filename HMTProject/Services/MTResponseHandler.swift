//
// Created by Konstantin Terekhov on 11/24/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation

class MTResponseHandler: MTAPICallbacks {
    static let instance = MTResponseHandler()
    private init() {}

    func requestComplete(request: [String: Any], json: SwiftyJSON.JSON) {
        switch request["Type"] {
            case ""
        }
    }
}
