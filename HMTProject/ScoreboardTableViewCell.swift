//
//  ScoreboardTableViewCell.swift
//  HMTProject
//
//  Created by Konstantin Terehov on 8/5/17.
//  Copyright © 2017 Konstantin Terehov. All rights reserved.
//

import UIKit

class ScoreboardTableViewCell: UITableViewCell {

    @IBOutlet weak var RouteNumber: UILabel!
    @IBOutlet weak var RouteEndStop: UILabel!
    @IBOutlet weak var RouteNearest: UILabel!
    @IBOutlet weak var RouteNext: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
