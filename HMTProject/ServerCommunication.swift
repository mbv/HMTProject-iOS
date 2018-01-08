//
// Created by Konstantin Terekhov on 8/30/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class ServerCommunication {
    static let instance = ServerCommunication()

    private let SERVER_URL = "https://hmt.mbvsoft.ru"
    //private let SERVER_URL = "http://localhost:5000"

    private var nextRequestId: Int64 = 1;
    private var mapRequestIdToData = [Int64: [String: Any]]()

    struct Request {
        var url: String
        var parameters: Parameters
        var requestId: Int64
    }

    private var requests = [Request]()

    private var gettingTimer: Timer!


    private init() {

    }

    func getParams(stop: Stop) {
        if gettingTimer != nil {
            gettingTimer.invalidate()
        }
        let routes = MainDB.instance.getRoutesAcrossStop(stop: stop)
        var requests: [Any] = [
            formatRequest(request: [
                "type": "ScoreBoard",
                "params": [
                    "city": "minsk",
                    "stop": "\(stop.MTStopId!)"
                ]
            ], additionalData: stop)
        ]

        for route in routes {
            requests.append(formatRequest(request: [
                "type": "Vehicle",
                "params": [
                    "city": "minsk",
                    "transportType": route.vehicleTypeName(),
                    "route": route.number!
                ]
            ], additionalData: route))
        }

        let params: Parameters = [
            "type": "iOS",
            "uid": UIDevice.current.identifierForVendor!.uuidString,
            "requests": requests
        ]
        Alamofire.request("\(SERVER_URL)/request", method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        self.setTimerForGettingData(json: json)
                    case .failure(let error):
                        print(response)
                        print(error)
                    }

                }
    }

    func getUpdates() {
        let params: Parameters = [
            "type": "iOS",
            "uid": UIDevice.current.identifierForVendor!.uuidString,
            "LastChanges": MainDB.instance.getCreateLastUpdate()
        ]
        let queue = DispatchQueue(label: "server-response-queue", qos: .utility, attributes: [.concurrent])
        Alamofire.request("\(SERVER_URL)/updates", method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON(
                        queue: queue,
                        completionHandler: { response in
                            switch response.result {
                            case .success(let value):
                                let json = JSON(value)

                                var stops = [Stop]()
                                for (_, item): (String, JSON) in json["Data"]["Tables"]["Stops"]["Items"] {
                                    stops.append(Stop(
                                            id: Int64(item["Id"].int!),
                                            MTStopId: Int64(item["MTStopId"].int!),
                                            bearing: Int64(item["Bearing"].int!),
                                            latitude: item["Latitude"].double!,
                                            longitude: item["Longitude"].double!,
                                            name: item["Name"].string!,
                                            busType: item["BusType"].bool!,
                                            trolleybusType: item["TrolleybusType"].bool!,
                                            tramType: item["TramType"].bool!
                                    ))
                                }
                                MainDB.instance.createUpdateStops(stops: stops)

                                var trips = [Trip]()
                                for (_, item): (String, JSON) in json["Data"]["Tables"]["Trips"]["Items"] {
                                    trips.append(Trip(
                                            id: Int64(item["Id"].int!),
                                            routeId: Int64(item["RouteId"].int!),
                                            endStopA: item["EndStopA"].string!,
                                            endStopB: item["EndStopB"].string!,
                                            nameA: item["NameA"].string!,
                                            nameB: item["NameB"].string!
                                    ))
                                }
                                MainDB.instance.createUpdateTrips(trips: trips)

                                var tracks = [Track]()
                                for (_, item): (String, JSON) in json["Data"]["Tables"]["Tracks"]["Items"] {
                                    tracks.append(Track(
                                            id: Int64(item["Id"].int!),
                                            routeId: Int64(item["RouteId"].int!),
                                            centerLatitude: item["CenterLatitude"].double!,
                                            centerLongitude: item["CenterLongitude"].double!
                                    ))
                                    var points = [Point]()
                                    for (_, point): (String, JSON) in item["Points"] {
                                        points.append(Point(
                                                id: Int64(point["Id"].int!),
                                                trackId: Int64(point["TrackId"].int!),
                                                trackType: point["TrackType"].int!,
                                                pointSort: point["PointSort"].int!,
                                                latitude: point["Latitude"].double!,
                                                longitude: point["Longitude"].double!
                                        ))
                                    }
                                    MainDB.instance.createUpdatePoints(points: points)
                                }
                                MainDB.instance.createUpdateTracks(tracks: tracks)

                                var stopTrips = [StopTrip]()
                                for (_, item): (String, JSON) in json["Data"]["Tables"]["StopTrips"]["Items"] {
                                    stopTrips.append(StopTrip(
                                            id: Int64(item["Id"].int!),
                                            tripId: Int64(item["TripId"].int!),
                                            stopId: Int64(item["StopId"].int!)
                                    ))
                                }
                                MainDB.instance.createUpdateStopTrips(stopTrips: stopTrips)

                                var routes = [Route]()
                                for (_, item): (String, JSON) in json["Data"]["Tables"]["Routes"]["Items"] {
                                    routes.append(Route(
                                            id: Int64(item["Id"].int!),
                                            number: item["Number"].string!,
                                            name: item["Name"].string!,
                                            sortPrefix: Int64(item["SortPrefix"].int!),
                                            vehicleType: item["VehicleType"].int!
                                    ))
                                }
                                MainDB.instance.createUpdateRoutes(routes: routes)

                                MainDB.instance.createUpdateLastUpdate(newValue: json["Data"]["LastUpdates"].int64!)

                                print("Done")
                            case .failure(let error):
                                print(response)
                                print(error)
                            }

                        })
    }

    func clearRequests(routeId: Int64) {
        var requests = [Request]()
        for request in self.requests {
            let requestData = self.mapRequestIdToData[request.requestId]!
            let requestType = (requestData["request"] as! [String: Any])["type"]!

            switch String(describing: requestType) {
            case "Vehicle":
                if let route = requestData["data"] as? Route {
                    if route.id == routeId {
                        requests.append(request)
                    }
                }
            case "ScoreBoard":
                requests.append(request)
            default:
                print("default")
            }

        }
        self.requests = requests
    }

    private func formatRequest(request: [String: Any], additionalData: Any) -> Any {
        var tmpRequest = request
        tmpRequest["requestId"] = nextRequestId;
        mapRequestIdToData[nextRequestId] = [
            "request": tmpRequest,
            "data": additionalData
        ]
        nextRequestId += 1
        return tmpRequest
    }

    private func setTimerForGettingData(json: JSON) {
        requests.removeAll()
        var cookies: [String: String] = [:]
        for (_, cookie): (String, JSON) in json["Cookies"] {
            cookies[cookie["Name"].string!] = cookie["Value"].string
        }
        MTApiHelper.instance.initUser(cookies: cookies)
        for (_, request): (String, JSON) in json["Requests"] {
            let tmp = Request(
                    url: request["Url"].string!,
                    parameters: request["Params"].dictionaryObject!,
                    requestId: request["RequestId"].int64!
            )
            requests.append(tmp)
        }
        if gettingTimer != nil {
            gettingTimer.invalidate()
        }
        gettingTimer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(timerForGettingData), userInfo: nil, repeats: true)
        timerForGettingData()
    }

    @objc
    func timerForGettingData() {
        for request in self.requests {
            MTApiHelper.instance.GetData(url: request.url, parameters: request.parameters, originalRequest: self.mapRequestIdToData[request.requestId]!)
        }
    }
}
