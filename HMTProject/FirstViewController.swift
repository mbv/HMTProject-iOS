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
import SocketIO

class FirstViewController: UIViewController, GMSMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource {

    struct Marker {
        var id: Int?
        var longitude: Double?
        var latitude: Double?
        var title: String?
        var marker: GMSMarker?
    }

    struct Vehicle {
        var id: Int?
        var longitude: Double?
        var latitude: Double?
        var marker: GMSMarker?
        var title: String?
        var number: Int?
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


    @IBOutlet weak var ScoreboardTableView: UITableView!
    @IBOutlet weak var myMapView: GMSMapView!
    var locationManager = CLLocationManager()
    var markers = [Int: Marker]()
    var markerMapToStopId = [GMSMarker: Int]()

    var vehicles = [Int: Vehicle]()
    var vehiclesMapToId = [GMSMarker: Int]()

    var scoreboard: Scoreboard?

    var socket: SocketIOClient?
    var clientId: Int = 0

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


        let icon = UIImage(named: "stop")

        let region: GMSVisibleRegion = mapView.projection.visibleRegion()
        let bounds: GMSCoordinateBounds = GMSCoordinateBounds(region: region)

        if let path = Bundle.main.path(forResource: "Stops", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                let json = JSON(data)
                for (_, subJson): (String, JSON) in json {
                    var tmpMarker = Marker()
                    tmpMarker.id = subJson["Id"].int
                    tmpMarker.latitude = subJson["Latitude"].double
                    tmpMarker.longitude = subJson["Longitude"].double
                    tmpMarker.title = subJson["Name"].string

                    let position = CLLocationCoordinate2D(latitude: tmpMarker.latitude!, longitude: tmpMarker.longitude!)
                    let tmpGMSMarker = GMSMarker(position: position)
                    tmpGMSMarker.icon = icon
                    tmpGMSMarker.title = tmpMarker.title
                    tmpGMSMarker.isFlat = true
                    tmpGMSMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
                    tmpGMSMarker.appearAnimation = GMSMarkerAnimation.pop;

                    if !bounds.contains(tmpGMSMarker.position) || mapView.camera.zoom < 14 {
                        tmpGMSMarker.map = nil
                    } else {
                        tmpGMSMarker.map = mapView
                    }

                    tmpGMSMarker.userData = tmpMarker.id

                    tmpMarker.marker = tmpGMSMarker

                    markers[tmpMarker.id!] = tmpMarker
                    markerMapToStopId[tmpGMSMarker] = tmpMarker.id!
                }
            }
        }
        checkSocket()
        self.scoreboard = Scoreboard()
        self.scoreboard?.Routes = [StopRoute]()

    }

    func checkSocket() {
        socket = SocketIOClient(socketURL: URL(string: "https://hmt.mbv-soft.ru")!, config: [.log(true), .compress])

        socket?.on(clientEvent: .connect) { data, ack in
            print("socket connected")
            self.socket?.emit("initClient", self.clientId)
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
                    //tmp.Id = subJson["Id"].int
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


                var icons: [UIImage] = [UIImage]()

                icons.append(UIImage(named: "bus_1")!)
                icons.append(UIImage(named: "bus_2")!)
                icons.append(UIImage(named: "bus_3")!)
                icons.append(UIImage(named: "bus_4")!)
                icons.append(UIImage(named: "bus_5")!)

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
                    tmp.title = subJson["Title"].string
                        tmp.number = subJson["Number"].int


                    let position = CLLocationCoordinate2D(latitude: tmp.latitude!, longitude: tmp.longitude!)
                    let tmpGMSMarker = GMSMarker(position: position)
                    tmpGMSMarker.title = tmp.title
                    tmpGMSMarker.icon = icons[tmp.number! - 1]
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

        socket?.connect()
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


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {

        if let markerId = markerMapToStopId[marker] {
            let json = JSON(["type": "stop", "id": markerId])
            self.scoreboard?.Routes?.removeAll()
            removeVehicles()

            if let data = json.rawString() {
                socket?.emit("get", data)
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


    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        let region: GMSVisibleRegion = mapView.projection.visibleRegion()
        let bounds: GMSCoordinateBounds = GMSCoordinateBounds(region: region)
        for (_, marker) in markers {
            if !bounds.contains(marker.marker!.position) || mapView.camera.zoom < 14 {
                if marker.marker!.map != nil {
                    marker.marker!.map = nil
                }
            } else {
                if marker.marker!.map == nil {
                    marker.marker!.map = mapView
                }
            }

        }
    }

}

