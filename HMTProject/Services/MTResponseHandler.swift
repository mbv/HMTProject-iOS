//
// Created by Konstantin Terekhov on 11/24/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import SwiftyJSON

class MTResponseHandler: MTAPICallbacks {
    static let instance = MTResponseHandler()

    private init() {
    }

    func requestComplete(requestData: [String: Any], json: JSON) {
        //print(request)
        let request = requestData["request"] as! [String: Any]
        switch String(describing: request["type"]!) {
        case "Vehicle":
            DispatchQueue.main.async {
                MapStore.instance.getVehiclesFromJson(json: json, route: requestData["data"] as! Route)
            }
        case "ScoreBoard":
            DispatchQueue.main.async {
                MapStore.instance.getScoreboardFromJson(json: json, stop: requestData["data"] as! Stop)
            }

        default:
            print("default")

        }
    }
}
