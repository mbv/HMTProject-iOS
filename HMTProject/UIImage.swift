//
//  UIImage.swift
//  HMTProject
//
//  Created by Konstantin Terehov on 8/9/17.
//  Copyright © 2017 Konstantin Terehov. All rights reserved.
//

import UIKit
import Foundation

extension UIImage {
    
    func addText(_ drawText: NSString, atPoint: CGPoint, textColor: UIColor?, textFont: UIFont?, centerX: Bool) -> UIImage {
        
        // Setup the font specific variables
        var _textColor: UIColor
        if textColor == nil {
            _textColor = UIColor.white
        } else {
            _textColor = textColor!
        }
        
        var _textFont: UIFont
        if textFont == nil {
            _textFont = UIFont.systemFont(ofSize: 16)
        } else {
            _textFont = textFont!
        }
        
        // Setup the image context using the passed image
        UIGraphicsBeginImageContextWithOptions(size, false, UIScreen.main.scale)
        
        // Setup the font attributes that will be later used to dictate how the text should be drawn
        let textFontAttributes = [
            NSFontAttributeName: _textFont,
            NSForegroundColorAttributeName: _textColor,
            ] as [String : Any]
        
        // Put the image into a rectangle as large as the original image
        draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        var x = atPoint.x
        
        let y = atPoint.y * UIScreen.main.scale
        
        if (centerX) {
        let boundingBox = drawText.boundingRect(with: CGSize(width: .greatestFiniteMagnitude, height: size.height / 3.0), options: .usesLineFragmentOrigin, attributes: textFontAttributes, context: nil)
        
            x = (size.width - boundingBox.width)/2.0
        }
        // Create a point within the space that is as bit as the image
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height)
        
        // Draw the text into an image
        drawText.draw(in: rect, withAttributes: textFontAttributes)
        
        
        // Create a new image out of the images we have created
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        
        // End the context now that we have the image we need
        UIGraphicsEndImageContext()
        
        //Pass the image back up to the caller
        return newImage!
        
    }
    
}
