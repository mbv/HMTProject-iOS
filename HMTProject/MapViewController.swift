//
//  FirstViewController.swift
//  HMTProject
//
//  Created by Konstantin Terehov on 8/3/17.
//  Copyright © 2017 Konstantin Terehov. All rights reserved.
//

import UIKit
import GoogleMaps
import SwiftyJSON

class MapViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    struct Marker {
        var stopModel: Stop
        var marker: GMSMarker?
    }

    struct Vehicle {
        var id: Int?
        var longitude: Double?
        var latitude: Double?
        var marker: GMSMarker?
        var number: String?
        var vehicleType: Int?
        var tripType: Int?
        var routeId: Int?
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
        var StopId: Int?
        var Routes: [StopRoute]?
        var Time: Int?

    }

    let iconStop = UIImage(named: "stop")
    let iconStopStart = UIImage(named: "stop_start_bus")
    let iconStopSelected = UIImage(named: "stop_selected")

    let iconStopBus = UIImage(named: "stop_bus")
    let iconStopBusTrolleybus = UIImage(named: "stop_bus_trolleybus")
    let iconStopTram = UIImage(named: "stop_tram")
    let iconStopTrolleybus = UIImage(named: "stop_trolleybus")

    let iconBus = UIImage(named: "bus")!
    let iconBusR = UIImage(named: "bus_r")!

    let iconTrolleybus = UIImage(named: "trolleybus")!
    let iconTrolleybusR = UIImage(named: "trolleybus_r")!

    let iconTram = UIImage(named: "tram")!
    let iconTramR = UIImage(named: "tram_r")!


    @IBOutlet weak var ScoreboardTableView: UITableView!
    @IBOutlet weak var myMapView: GMSMapView!
    var locationManager = CLLocationManager()
    var markers = [Int64: Marker]()
    var markerMapToStopId = [GMSMarker: Int64]()
    var selectedMarker: Int64 = -1

    var vehicles = [Int: Vehicle]()
    var vehiclesMapToId = [GMSMarker: Int]()

    var scoreboard: Scoreboard?

    var clientId: Int = 0

    var routeTrackA: GMSPolyline?
    var routeTrackB: GMSPolyline?

    var apiHelper: MTApiHelper = MTApiHelper.init()
    var serverCommunication: ServerCommunication = ServerCommunication.init()

    func selectStopIcon(stop: Stop) -> UIImage? {
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


    override func viewDidLoad() {
        super.viewDidLoad()

        ScoreboardTableView.delegate = self
        ScoreboardTableView.dataSource = self
        self.automaticallyAdjustsScrollViewInsets = false

        let camera = GMSCameraPosition.camera(withLatitude: 53.93146, longitude: 27.48005, zoom: 10.0)


        self.myMapView.camera = camera
        self.myMapView.delegate = self
        self.myMapView?.isMyLocationEnabled = true
        self.myMapView.settings.myLocationButton = true
        self.myMapView.settings.compassButton = true
        self.myMapView.settings.zoomGestures = true

        self.locationManager.delegate = self
        self.locationManager.startUpdatingLocation()

        let mapView = myMapView!

        let region: GMSVisibleRegion = mapView.projection.visibleRegion()
        let bounds: GMSCoordinateBounds = GMSCoordinateBounds(region: region)

        let stops = MainDB.instance.getStops()

        for stop in stops {
            var tmpMarker = Marker(stopModel: stop, marker: nil)

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

            if !bounds.contains(tmpGMSMarker.position) || mapView.camera.zoom < 14 {
                tmpGMSMarker.map = nil
            } else {
                tmpGMSMarker.map = mapView
            }

            tmpGMSMarker.userData = stop.id

            tmpMarker.marker = tmpGMSMarker

            markers[stop.id!] = tmpMarker
            markerMapToStopId[tmpGMSMarker] = stop.id!
        }
        //checkSocket()
        self.scoreboard = Scoreboard()
        self.scoreboard?.Routes = [StopRoute]()

    }

///https://hmt.mbv-soft.ru
//ws://localhost:5000
    func checkSocket() {
        /*socket = SocketIOClient(socketURL: URL(string: "https://hmt.mbv-soft.ru")!, config: [.log(true), .compress])

        socket?.on(clientEvent: .connect) { data, ack in
            print("socket connected")
            let json = JSON(["type": "iOS", "id": UIDevice.current.identifierForVendor!.uuidString])

            if let data = json.rawString() {
                self.socket?.emit("initClient", data)
            }
        }

        socket?.on("init") { data, ack in
            if let rawStringData = data[0] as? String {
                let json = JSON(data: rawStringData.data(using: String.Encoding.utf8)!)
                self.clientId = json["ClientId"].int!
            }
        }

        socket?.on("send") { data, ack in
            if let rawStringData = data[0] as? String {
                self.scoreboard?.Routes?.removeAll()
                let json = JSON(data: rawStringData.data(using: String.Encoding.utf8)!)

                self.scoreboard?.StopId = json["StopId"].int
                self.scoreboard?.Time = json["Time"].int

                for (_, subJson): (String, JSON) in json["Records"] {
                    var tmp = StopRoute()
                    tmp.Id = subJson["Id"].int
                    tmp.VehicleType = subJson["Type"].string
                    tmp.Number = subJson["Number"].string
                    tmp.EndStop = subJson["EndStop"].string
                    tmp.Nearest = subJson["Nearest"].string
                    tmp.Next = subJson["Next"].string

                    self.scoreboard?.Routes?.append(tmp)
                }

                let date = Date(timeIntervalSince1970: Double((self.scoreboard?.Time)!) / 1000.0)

                let dayTimePeriodFormatter = DateFormatter()
                dayTimePeriodFormatter.dateFormat = "dd MMM YYYY HH:mm:ss"

                let dateString = dayTimePeriodFormatter.string(from: date)

                self.markers[(self.scoreboard?.StopId)!]?.marker?.snippet = dateString
                self.ScoreboardTableView.reloadData()
            }

        }

        socket?.on("sendV") { data, ack in
            if let rawStringData = data[0] as? String {

                let json = JSON(data: rawStringData.data(using: String.Encoding.utf8)!)


                // var icons: [UIImage] = [UIImage]()


                for (_, subJson): (String, JSON) in json["Vehicles"] {
                    let vehicleId = subJson["Id"].int!
                    if let vehicle = self.vehicles[vehicleId] {
                        vehicle.marker?.position.latitude = subJson["Latitude"].double!
                        vehicle.marker?.position.longitude = subJson["Longitude"].double!
                    } else {
                        var tmp = Vehicle()
                        tmp.id = subJson["Id"].int
                        tmp.latitude = subJson["Latitude"].double
                        tmp.longitude = subJson["Longitude"].double
                        tmp.number = subJson["Title"].string
                        tmp.vehicleType = subJson["VehicleType"].int
                        tmp.tripType = subJson["TripType"].int
                        tmp.routeId = subJson["RouteId"].int


                        let position = CLLocationCoordinate2D(latitude: tmp.latitude!, longitude: tmp.longitude!)
                        let tmpGMSMarker = GMSMarker(position: position)
                        //tmpGMSMarker.title = tmp.title
                        var icon: UIImage

                        switch tmp.vehicleType! {
                        case 0:
                            if tmp.tripType == 10 {
                                icon = self.iconBus
                            } else {
                                icon = self.iconBusR
                            }
                        case 1:
                            if tmp.tripType == 10 {
                                icon = self.iconTrolleybus
                            } else {
                                icon = self.iconTrolleybusR
                            }
                        case 2:
                            if tmp.tripType == 10 {
                                icon = self.iconTram
                            } else {
                                icon = self.iconTramR
                            }
                        default:
                            icon = UIImage()
                        }


                        icon = icon.addText((tmp.number!) as NSString, atPoint: CGPoint(x: 0, y: 8.5), textColor: UIColor.white, textFont: UIFont.boldSystemFont(ofSize: 16), centerX: true)
                        tmpGMSMarker.icon = icon
                        tmpGMSMarker.groundAnchor = CGPoint(x: 0.5, y: 1)
                        tmpGMSMarker.appearAnimation = GMSMarkerAnimation.pop;

                        tmpGMSMarker.map = self.myMapView

                        tmp.marker = tmpGMSMarker;

                        self.vehicles[tmp.id!] = tmp
                        self.vehiclesMapToId[tmpGMSMarker] = tmp.id
                    }
                }
            }
        }

        socket?.on("sendR") { data, ack in
            if let rawStringData = data[0] as? String {

                let json = JSON(data: rawStringData.data(using: String.Encoding.utf8)!)

                let vehicleType = json["VehicleType"].int

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

                for (_, subJson): (String, JSON) in json["Track"]["PointsA"] {
                    path.add(CLLocationCoordinate2D(latitude: subJson["Latitude"].double!, longitude: subJson["Longitude"].double!))
                }

                self.routeTrackA = GMSPolyline(path: path)

                self.routeTrackA?.map = self.myMapView
                self.routeTrackA?.strokeWidth = 5

                self.routeTrackA?.strokeColor = pathAColors[vehicleType!]

                path = GMSMutablePath()

                for (_, subJson): (String, JSON) in json["Track"]["PointsB"] {
                    path.add(CLLocationCoordinate2D(latitude: subJson["Latitude"].double!, longitude: subJson["Longitude"].double!))
                }

                self.routeTrackB = GMSPolyline(path: path)

                self.routeTrackB?.map = self.myMapView
                self.routeTrackB?.strokeWidth = 5

                self.routeTrackB?.strokeColor = pathBColors[vehicleType!]
            }
        }

        socket?.connect()*/
    }

//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        
//        let location = locations.last
//        
//        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 17.0)
//        
//        myMapView?.animate(to: camera)
//        
//        //Finally stop updating location otherwise it will come again and again in this delegate
//        self.locationManager.stopUpdatingLocation()
//        
//    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scoreboard?.Routes?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreBoardRow", for: indexPath) as! ScoreboardTableViewCell

        let tmpScoreboard = self.scoreboard?.Routes?[indexPath.row]

        cell.RouteNumber.text = (tmpScoreboard?.VehicleType ?? "") + (tmpScoreboard?.Number ?? "")
        cell.RouteEndStop.text = tmpScoreboard?.EndStop
        cell.RouteNearest.text = tmpScoreboard?.Nearest
        cell.RouteNext.text = tmpScoreboard?.Next

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tmpScoreboard = self.scoreboard?.Routes?[indexPath.row]

        let json = JSON(["type": "route", "id": tmpScoreboard!.Id!])
        removeVehicles()

        if let data = json.rawString() {
            //socket?.emit("get", data)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        if let markerId = markerMapToStopId[marker] {
            if selectedMarker != markerId {
                if selectedMarker != -1 {
                    let marker = markers[selectedMarker]!
                    marker.marker?.icon = selectStopIcon(stop: marker.stopModel)
                    if marker.stopModel.bearing != -1 {
                        marker.marker?.rotation = CLLocationDegrees(marker.stopModel.bearing!)
                    }
                }
                selectedMarker = markerId
                markers[markerId]?.marker?.icon = iconStopSelected
                markers[markerId]?.marker?.rotation = 0
                //let json = JSON(["type": "stop", "id": markerId])
                self.scoreboard?.Routes?.removeAll()
                self.ScoreboardTableView.reloadData()
                removeVehicles()

                //serverCommunication.getParams()
                serverCommunication.getUpdates()
                //socket?.emit("get", data)
                /*let param: [String: String] = [
                    "p": "minsk",
                    "tt": "bus",
                    "r": "100",
                    "v": "21",
                ]
                apiHelper.initUser(token: "", cookies: [ : ])
                apiHelper.GetData(url: "", parameters: param)*/

            }
        } else if self.vehiclesMapToId[marker] != nil {
            return false
        }
        return false
    }

    func removeVehicles() {
        for (_, vehicle) in self.vehicles {
            vehicle.marker?.map = nil
        }
        self.vehicles.removeAll()
    }

    func removeVehicles(without routeId: Int) {
        for (_, vehicle) in self.vehicles {
            if vehicle.routeId != routeId {
                vehicle.marker?.map = nil
                self.vehicles.removeValue(forKey: vehicle.routeId!)
            }
        }
    }


    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let region: GMSVisibleRegion = mapView.projection.visibleRegion()
        let bounds: GMSCoordinateBounds = GMSCoordinateBounds(region: region)
        for (_, marker) in markers {
            if bounds.contains(marker.marker!.position) && ((mapView.camera.zoom >= 13) || (selectedMarker == marker.stopModel.id! && mapView.camera.zoom >= 5)) {
                if marker.marker!.map == nil {
                    marker.marker!.map = mapView
                }
            } else {
                if marker.marker!.map != nil {
                    marker.marker!.map = nil
                }
            }

        }
        for (_, vehicle) in vehicles {
            if bounds.contains(vehicle.marker!.position) && mapView.camera.zoom >= 5 {
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

}

