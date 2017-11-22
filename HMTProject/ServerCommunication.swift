//
// Created by Konstantin Terekhov on 8/30/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire

class ServerCommunication {

    private let SERVER_URL = "https://hmt.mbv-soft.ru"

    private let COMMAND_UPDATED_USER_DATA = "updated_user_data"
    private let COMMAND_UPDATED_DATA = "updated_data"
    private let COMMAND_OPERATION_DATA = "operation_data"

    var apiHelper: MTApiHelper = MTApiHelper.init()


    var initializerUser: InitializerUser?
    var storage: Storage?
    var operationExecutor: OperationExecutor?

    init() {

    }

    func initialize() {

    }

    func getParams() {
        let params: Parameters = [
            "type": "iOS",
            "uid": UIDevice.current.identifierForVendor!.uuidString,
            "requests": [
                [
                    "type": "Vehicle",
                    "params": [
                        "city": "minsk",
                        "transportType": "bus",
                        "route": "100"
                    ]
                ]
            ]
        ]
        Alamofire.request("http://localhost:5000/request", method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
                    switch response.result {
                    case .success(let value):
                        let json = JSON(value)
                        var cookies: [String: String] = [:]
                        for (_, cookie): (String, JSON) in json["Cookies"] {
                            cookies[cookie["Name"].string!] = cookie["Value"].string
                        }
                        self.apiHelper.initUser(cookies: cookies)
                        for (_, request): (String, JSON) in json["Requests"] {
                            self.apiHelper.GetData(url: request["Url"].string!, parameters: request["Params"].dictionaryObject!)
                        }
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
            "LastChanges": 100
        ]
        Alamofire.request("http://localhost:5000/updates", method: .post, parameters: params, encoding: JSONEncoding.default)
                .responseJSON { response in
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
                                        id: Int64(item["Id"].int!),
                                        trackId: Int64(item["TrackId"].int!),
                                        trackType: item["TrackType"].int!,
                                        pointSort: item["PointSort"].int!,
                                        latitude: item["Latitude"].double!,
                                        longitude: item["Longitude"].double!
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
                                    sortPrefix: Int64(item["SortPrefix"].int!)
                            ))
                        }
                        MainDB.instance.createUpdateRoutes(routes: routes)

                        print("Done")
                    case .failure(let error):
                        print(response)
                        print(error)
                    }

                }
    }

    private func onUpdatedUserData(data: JSON?) {


        //let token = data?["Token"].String
        //var cookies: [String: String] = [:]
        //for (_, subJson): (String, JSON) in (data?["Cookies"])! {
        //let key = subJson["Key"].String
        //let value = subJson["Value"].String
        //cookies[key] = value
        //}

        //initializerUser.initUser(token: token, cookies: cookies)
    }

    private func onUpdatedData(data: JSON?) {

    }


    private func parseResultToJson(data: [Any]) -> JSON? {
        /*if let rawStringData = data[0] as? String {
            let json = JSON(data: rawStringData.data(using: String.Encoding.utf8)!)

            return json
        }*/
        return nil
    }
}
