//
//  SecondViewController.swift
//  HMTProject
//
//  Created by Konstantin Terehov on 8/3/17.
//  Copyright © 2017 Konstantin Terehov. All rights reserved.
//

import UIKit



class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!

    var stops: [Stop]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self

        stops = MainDB.instance.getStops()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stops != nil {
            return stops!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableRow", for: indexPath)
        let stop = stops?[indexPath.row]

        cell.textLabel?.text = stop?.name
        if stop != nil {
            cell.detailTextLabel?.text = ((stop!.trolleybusType!) ? " A " : "") + (stop!.trolleybusType! ? " Tr " : "") + (stop!.tramType! ? " T " : "")
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let stop = stops?[indexPath.row] {
            MapStore.instance.navigateToStop = stop.id
            self.tabBarController?.selectedIndex = 0
        }
    }


}

