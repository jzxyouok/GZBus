//
//  ColorUtil.swift
//  GZBus
//
//  Created by NendorS on 3/5/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import UIKit

class ColorUtil {
    static let navigationBar = 0x5595EF
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
