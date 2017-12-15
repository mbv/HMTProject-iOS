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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        MapStore.instance.tryNavigateToStop()
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
        if let tmpStopRoute = MapStore.instance.scoreboard?.Routes?[indexPath.row] {
            MapStore.instance.showRoute(stopRoute: tmpStopRoute)
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

