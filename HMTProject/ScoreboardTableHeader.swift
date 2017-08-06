//
//  ScoreboardTableHeader.swift
//  HMTProject
//
//  Created by Konstantin Terehov on 8/5/17.
//  Copyright © 2017 Konstantin Terehov. All rights reserved.
//

import UIKit

class ScoreboardTableHeader: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

extension UIView {
    class func fromNib<T : UIView>() -> T {
        return Bundle.main.loadNibNamed(String(describing: T.self), owner: nil, options: nil)![0] as! T
    }
}
