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


    @IBOutlet weak var ScoreboardTableView: UITableView!
    @IBOutlet weak var myMapView: GMSMapView!
    var locationManager = CLLocationManager()



    var clientId: Int = 0

    var routeTrackA: GMSPolyline?
    var routeTrackB: GMSPolyline?


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


        ServerCommunication.instance.getUpdates()

        MapStore.instance.setViews(mapView: myMapView!, scoreboardTableView: ScoreboardTableView!)

        MapStore.instance.loadStops()
        //checkSocket()
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
        return MapStore.instance.scoreboard?.Routes?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreBoardRow", for: indexPath) as! ScoreboardTableViewCell

        let tmpScoreboard = MapStore.instance.scoreboard?.Routes?[indexPath.row]

        cell.RouteNumber.text = (tmpScoreboard?.VehicleType ?? "") + (tmpScoreboard?.Number ?? "")
        cell.RouteEndStop.text = tmpScoreboard?.EndStop
        cell.RouteNearest.text = tmpScoreboard?.Nearest
        cell.RouteNext.text = tmpScoreboard?.Next

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tmpScoreboard = MapStore.instance.scoreboard?.Routes?[indexPath.row]

        let json = JSON(["type": "route", "id": tmpScoreboard!.Id!])
        MapStore.instance.removeVehicles()

        if let data = json.rawString() {
            //socket?.emit("get", data)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        return MapStore.instance.selectStopMarker(marker: marker)
    }

    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        MapStore.instance.updateMarkers()
    }

}

