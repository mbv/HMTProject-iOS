//
// Created by mbv on 11/25/17.
// Copyright (c) 2017 Konstantin Terehov. All rights reserved.
//

import Foundation
import GoogleMaps
import SwiftyJSON

class MapStore {
    static let instance = MapStore()

    private init() {
        self.scoreboard = Scoreboard()
        self.scoreboard?.Routes = [StopRoute]()
    }

    struct StopMarker {
        var stopModel: Stop
        var marker: GMSMarker?
    }

    struct Vehicle {
        var id: Int64?
        var longitude: Double?
        var latitude: Double?
        var marker: GMSMarker?
        var number: String?
        var vehicleType: Int?
        var tripType: Int?
        var routeId: Int64?
    }

    struct StopRoute {
        var Id: Int?
        var VehicleType: String?
        var Number: String?
        var EndStop: String?
        var Nearest: String?
        var Next: String?
    }

    struct Scoreboard {
        var StopId: Int64?
        var Routes: [StopRoute]?
        var Time: Int?
    }

    let mapVehicleType: [String: Int] = [
        "А": 0,
        "Т": 1,
        "#": 2,
    ]

    let iconStop = UIImage(named: "stop")!
    let iconStopStart = UIImage(named: "stop_start_bus")!
    let iconStopSelected = UIImage(named: "stop_selected")!

    let iconStopBus = UIImage(named: "stop_bus")!
    let iconStopBusTrolleybus = UIImage(named: "stop_bus_trolleybus")!
    let iconStopTram = UIImage(named: "stop_tram")!
    let iconStopTrolleybus = UIImage(named: "stop_trolleybus")!

    let iconBus = UIImage(named: "bus")!
    let iconBusR = UIImage(named: "bus_r")!

    let iconTrolleybus = UIImage(named: "trolleybus")!
    let iconTrolleybusR = UIImage(named: "trolleybus_r")!

    let iconTram = UIImage(named: "tram")!
    let iconTramR = UIImage(named: "tram_r")!

    var mapView: GMSMapView?
    var scoreboardTableView: UITableView?

    var stopMarkers = [Int64: StopMarker]()
    var stopMarkerMapToStopId = [GMSMarker: Int64]()

    var selectedStopMarker: Int64 = -1

    var vehicleMarkers = [Int64: Vehicle]()
    var vehicleMarkerMapToId = [GMSMarker: Int64]()

    var scoreboard: Scoreboard?

    var routeTrackA: GMSPolyline?
    var routeTrackB: GMSPolyline?

    var navigateToStop: Int64?

    func selectStopIcon(stop: Stop) -> UIImage {
        if stop.bearing == -1 {
            return iconStopStart
        } else {
            if stop.busType! && stop.trolleybusType! {
                return iconStopBusTrolleybus
            } else if stop.busType! {
                return iconStopBus
            } else if stop.trolleybusType! {
                return iconStopTrolleybus
            } else if stop.tramType! {
                return iconStopTram
            }
        }
        return iconStop
    }

    func setViews(mapView: GMSMapView, scoreboardTableView: UITableView) {
        self.mapView = mapView
        self.scoreboardTableView = scoreboardTableView
    }

    func loadStops() {
        removeStops()
        let region: GMSVisibleRegion = mapView!.projection.visibleRegion()
        let bounds: GMSCoordinateBounds = GMSCoordinateBounds(region: region)

        let stops = MainDB.instance.getStops()

        for stop in stops {
            var tmpMarker = StopMarker(stopModel: stop, marker: nil)

            let position = CLLocationCoordinate2D(latitude: stop.latitude!, longitude: stop.longitude!)
            let tmpGMSMarker = GMSMarker(position: position)
            tmpGMSMarker.icon = selectStopIcon(stop: stop)
            if stop.bearing != -1 {
                tmpGMSMarker.rotation = CLLocationDegrees(stop.bearing!)
            }

            tmpGMSMarker.title = stop.name
            tmpGMSMarker.isFlat = true
            tmpGMSMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            tmpGMSMarker.appearAnimation = GMSMarkerAnimation.pop;

            if !bounds.contains(tmpGMSMarker.position) || mapView!.camera.zoom < 14 {
                tmpGMSMarker.map = nil
            } else {
                tmpGMSMarker.map = mapView
            }

            tmpGMSMarker.userData = stop.id

            tmpMarker.marker = tmpGMSMarker

            stopMarkers[stop.id!] = tmpMarker
            stopMarkerMapToStopId[tmpGMSMarker] = stop.id!
        }
    }

    func tryNavigateToStop() {
        if self.navigateToStop != nil {
            let stop = stopMarkers[self.navigateToStop!]
            if stop != nil {
                let camera = GMSCameraPosition.camera(withLatitude: (stop!.stopModel.latitude)!, longitude: (stop!.stopModel.longitude)!, zoom: 17.0)

                self.mapView?.animate(to: camera)
                self.mapView?.selectedMarker = stop!.marker
                selectStopMarker(marker: stop!.marker!)
            }
        }
    }

    func removeStops() {
        for (_, stopMarker) in self.stopMarkers {
            stopMarker.marker?.map = nil
        }
        self.stopMarkers.removeAll()
    }

    func selectStopMarker(marker: GMSMarker) -> Bool {
        if let markerId = stopMarkerMapToStopId[marker] {
            if selectedStopMarker != markerId {
                if selectedStopMarker != -1 {
                    let marker = stopMarkers[selectedStopMarker]!
                    marker.marker?.icon = selectStopIcon(stop: marker.stopModel)
                    if marker.stopModel.bearing != -1 {
                        marker.marker?.rotation = CLLocationDegrees(marker.stopModel.bearing!)
                    }
                }
                selectedStopMarker = markerId
                stopMarkers[markerId]?.marker?.icon = iconStopSelected
                stopMarkers[markerId]?.marker?.rotation = 0

                scoreboard?.Routes?.removeAll()
                scoreboardTableView?.reloadData()
                removeVehicles()

                ServerCommunication.instance.getParams(stop: stopMarkers[markerId]!.stopModel)

            }
        } else if self.vehicleMarkerMapToId[marker] != nil {
            return false
        }
        return false
    }

    func removeVehicles() {
        for (_, vehicle) in self.vehicleMarkers {
            vehicle.marker?.map = nil
        }
        self.vehicleMarkers.removeAll()
    }

    func removeVehicles(without routeId: Int64) {
        for (key, vehicle) in self.vehicleMarkers {
            if vehicle.routeId != routeId {
                vehicle.marker?.map = nil
                self.vehicleMarkers.removeValue(forKey: key)
            }
        }
    }


    func updateMarkers() {
        let region: GMSVisibleRegion = mapView!.projection.visibleRegion()
        let bounds: GMSCoordinateBounds = GMSCoordinateBounds(region: region)
        for (_, marker) in stopMarkers {
            if bounds.contains(marker.marker!.position) && ((mapView!.camera.zoom >= 13) || (selectedStopMarker == marker.stopModel.id! && mapView!.camera.zoom >= 5)) {
                if marker.marker!.map == nil {
                    marker.marker!.map = mapView
                }
            } else {
                if marker.marker!.map != nil {
                    marker.marker!.map = nil
                }
            }

        }
        for (_, vehicle) in vehicleMarkers {
            if bounds.contains(vehicle.marker!.position) && mapView!.camera.zoom >= 5 {
                if vehicle.marker!.map == nil {
                    vehicle.marker!.map = mapView
                }
            } else {
                if vehicle.marker!.map != nil {
                    vehicle.marker!.map = nil
                }
            }
        }
    }

    func getVehiclesFromJson(json: JSON, route: Route) {
        for (_, subJson): (String, JSON) in json["Vehicles"] {
            let vehicleId = subJson["Id"].int64!
            if let vehicle = self.vehicleMarkers[vehicleId] {
                vehicle.marker?.position.latitude = subJson["Latitude"].double!
                vehicle.marker?.position.longitude = subJson["Longitude"].double!
                let tripType = subJson["TripType"].int

                vehicle.marker?.icon = getIconForVehicle(vehicleType: route.vehicleType!, tripType: tripType!, number: route.number!)
            } else {
                var tmp = Vehicle()
                tmp.id = subJson["Id"].int64
                tmp.latitude = subJson["Latitude"].double
                tmp.longitude = subJson["Longitude"].double
                tmp.number = route.number
                tmp.vehicleType = route.vehicleType
                tmp.tripType = subJson["TripType"].int
                tmp.routeId = route.id


                let position = CLLocationCoordinate2D(latitude: tmp.latitude!, longitude: tmp.longitude!)
                let tmpGMSMarker = GMSMarker(position: position)
                //tmpGMSMarker.title = tmp.title

                tmpGMSMarker.icon = getIconForVehicle(vehicleType: tmp.vehicleType!, tripType: tmp.tripType!, number: tmp.number!)
                tmpGMSMarker.groundAnchor = CGPoint(x: 0.5, y: 1)
                tmpGMSMarker.appearAnimation = GMSMarkerAnimation.pop;

                tmpGMSMarker.map = self.mapView

                tmp.marker = tmpGMSMarker;

                self.vehicleMarkers[tmp.id!] = tmp
                self.vehicleMarkerMapToId[tmpGMSMarker] = tmp.id
            }
        }
    }

    private func getIconForVehicle(vehicleType: Int, tripType: Int, number: String) -> UIImage {
        var icon: UIImage

        switch vehicleType {
        case 0:
            if tripType == 10 {
                icon = self.iconBus
            } else {
                icon = self.iconBusR
            }
        case 1:
            if tripType == 10 {
                icon = self.iconTrolleybus
            } else {
                icon = self.iconTrolleybusR
            }
        case 2:
            if tripType == 10 {
                icon = self.iconTram
            } else {
                icon = self.iconTramR
            }
        default:
            icon = UIImage()
        }


        icon = icon.addText(number as NSString, atPoint: CGPoint(x: 0, y: 8.5), textColor: UIColor.white, textFont: UIFont.boldSystemFont(ofSize: 16), centerX: true)
        return icon
    }

    func getScoreboardFromJson(json: JSON, stop: Stop) {
        self.scoreboard?.Routes?.removeAll()

        self.scoreboard?.StopId = stop.id
        self.scoreboard?.Time = parseDate(input: json["Timestamp"].string!)

        for (_, subJson): (String, JSON) in json["Routes"] {
            var tmp = StopRoute()
            tmp.Id = subJson["Id"].int
            tmp.VehicleType = subJson["Type"].string
            tmp.Number = subJson["Number"].string
            tmp.EndStop = subJson["EndStop"].string

            let info = subJson["Info"].arrayValue

            tmp.Nearest = info[0].string
            tmp.Next = info[1].string

            self.scoreboard?.Routes?.append(tmp)
        }

        let date = Date(timeIntervalSince1970: Double((self.scoreboard?.Time)!) / 1000.0)

        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "dd MMM YYYY HH:mm:ss"

        let dateString = dayTimePeriodFormatter.string(from: date)

        self.stopMarkers[(self.scoreboard?.StopId)!]?.marker?.snippet = dateString
        scoreboardTableView!.reloadData()
    }

    func showRoute(stopRoute: StopRoute) {

        let vehicleType = mapVehicleType[stopRoute.VehicleType!]!

        if let route = MainDB.instance.getRouteByParam(vehicleTypeValue: vehicleType, numberValue: stopRoute.Number!) {

            removeVehicles(without: route.id!)
            ServerCommunication.instance.clearRequests(routeId: route.id!)

            let pathAColors = [
                UIColor(red: 0.12, green: 0.48, blue: 0.96, alpha: 0.7),
                UIColor(red: 0.13, green: 0.96, blue: 0.36, alpha: 0.7),
                UIColor(red: 0.60, green: 0.13, blue: 0.96, alpha: 0.7)
            ]


            let pathBColors = [
                UIColor(red: 0.96, green: 0.29, blue: 0.12, alpha: 0.7),
                UIColor(red: 0.96, green: 0.84, blue: 0.13, alpha: 0.7),
                UIColor(red: 0.92, green: 0.53, blue: 0.27, alpha: 0.7)
            ]

            self.routeTrackA?.map = nil
            self.routeTrackB?.map = nil

            var path = GMSMutablePath()

            for point in MainDB.instance.getPointsForRoute(route: route, trackTypeValue: 0) {
                path.add(CLLocationCoordinate2D(latitude: point.latitude!, longitude: point.longitude!))
            }

            self.routeTrackA = GMSPolyline(path: path)

            self.routeTrackA?.map = self.mapView
            self.routeTrackA?.strokeWidth = 5

            self.routeTrackA?.strokeColor = pathAColors[vehicleType]

            path = GMSMutablePath()

            for point in MainDB.instance.getPointsForRoute(route: route, trackTypeValue: 1) {
                path.add(CLLocationCoordinate2D(latitude: point.latitude!, longitude: point.longitude!))
            }

            self.routeTrackB = GMSPolyline(path: path)

            self.routeTrackB?.map = self.mapView
            self.routeTrackB?.strokeWidth = 5

            self.routeTrackB?.strokeColor = pathBColors[vehicleType]
        }
    }

    private func parseDate(input: String) -> Int {
        let matched = matches(for: "[0-9]+", in: input)
        if let timestamp = matched.first {
            return Int(timestamp)!
        }
        return 0
}

    private func matches(for regex: String, in text: String) -> [String] {

        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                    range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }


}
