//
//  Bus.swift
//  GZBus
//
//  Created by NendorS on 3/21/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import Foundation
import ObjectMapper

class Bus: Mappable {
    var code: Int!
    var busString: String?
    var errorMessage: String?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        busString <- map["d.result"]
        code <- map["c"]
        errorMessage <- map["err.msg"]
    }
    
}

