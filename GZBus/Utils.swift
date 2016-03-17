//
//  Utils.swift
//  GZBus
//
//  Created by NendorS on 3/5/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import UIKit

class ColorUtil {
    static let navigationBar = 0x20BF55
    static let station = 0x0B4F6C
    //01BAEF
    //FBFBFF
    //757575
    
    static let distance = [0xC4FFF9, 0x9CEAEF,0x68D8D6,0x3DCCC7,0x07BEB8]
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(Hex:Int) {
        self.init(red:(Hex >> 16) & 0xff, green:(Hex >> 8) & 0xff, blue:Hex & 0xff)
        
    }
}

extension UIImage {
    func tint(color: UIColor, blendMode: CGBlendMode, alpha: CGFloat = 1) -> UIImage
    {
        let drawRect = CGRectMake(0.0, 0.0, size.width, size.height)
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        
        UIRectFill(drawRect)
        
        drawInRect(drawRect, blendMode: blendMode, alpha: alpha)
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return tintedImage
    }
}
