//
//  HTTPUtils.swift
//  GZBus
//
//  Created by NendorS on 3/5/16.
//  Copyright © 2016 NendorS. All rights reserved.
//

import UIKit
import Alamofire

class HTTPUtils {
    private let apiURL = "http://api.chenjiehua.me/v2/bus"
    
    var delegate: HTTPDelegate?
    
    func get(parameters: [String: AnyObject]? = nil, headers: [String: String]? = nil) {
        Alamofire.request(.GET, apiURL, parameters: parameters, headers: headers).responseData{ response -> Void in
            switch response.result {
            case .Success(let data):
                self.delegate?.didReceiveResult(data)
            case .Failure(let error):
                self.delegate?.didReceiveError(error)
            }
        }
    }

}

protocol HTTPDelegate {
    func didReceiveResult(result: NSData)
    func didReceiveError(error: NSError)
}