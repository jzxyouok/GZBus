//
//  Station.swift
//  GZBus
//
//  Created by NendorS on 3/21/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import Foundation
import ObjectMapper

typealias Location = [String: Int]

class Station:Mappable {
    var code: Int!
    var errorMessage: String?
    var lineName: String?
    var stationName: String?
    var startPlatName :String?
    var endPlatName: String?
    var busLocation: [Location]?
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        code <- map["c"]
        errorMessage <- map["err.msg"]
        lineName <- map["d.busLine.lineName"]
        stationName <- map["d.busLine.stationNames"]
        startPlatName <- map["d.busLine.strPlatName"]
        endPlatName <- map["d.busLine.endPlatName"]
        busLocation <- map["d.busTerminal"]
    }
}