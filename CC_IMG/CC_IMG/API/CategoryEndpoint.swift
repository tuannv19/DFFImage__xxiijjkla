//
//  CategoryEndpoint.swift
//  CC_IMG
//
//  Created by tuannv on 12/24/18.
//  Copyright © 2018 tuannv. All rights reserved.
//

import UIKit
import Alamofire

enum CategoryEndpoint : URLRequestConvertible {
    
    static let baseURLString = "http://yogirl.mobi:8090/hot-girl/v1/list-by-category"
    
    var pmkRequest: URLRequest {
        return try! self.asURLRequest()
    }
    
    case get(Int, Int, [String ] , Int)
    
    var params : [String : Any] {
        switch self {
        case .get(let cid, let from, let ids, let size) :
            return ["categoryId" : cid ,
                    "from" : from ,
                    "ids" : ids,
                    "size": size]
        }
    }
    
//    var params: [String : Any] {
//        switch self {
//        case .get(<#T##String#>):
//            <#code#>
//        default:
//            <#code#>
//        }
//    }
    
    
    func asURLRequest() throws -> URLRequest {
        let url = try CategoryEndpoint.baseURLString.asURL()
        var mRequest =  URLRequest.init(url: url)
        
        mRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        mRequest.httpMethod = "POST"
        
        let jsonData =  try JSONSerialization.data(withJSONObject: params, options: [])
        let jsonString =  String.init(data: jsonData, encoding: .utf8)
        
        mRequest.httpBody = jsonString?.data(using: .utf8)
        
        
        return mRequest
    }
}
enum ImageEndpoint : URLRequestConvertible {
    var url: URL {
        return  try! self.asURLRequest().url!
    }
    
    static let baseURLString = "http://yogirl.mobi/images"
    
    var pmkRequest: URLRequest {
        return try! self.asURLRequest()
    }
    
    
    case get(String)
    
    var path : String {
        switch self {
        case .get(let path):
            return path
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try ImageEndpoint.baseURLString.asURL()
        return  URLRequest.init(url: url.appendingPathComponent(path))
    }
    
}
