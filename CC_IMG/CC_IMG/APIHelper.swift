//
//  APIHelper.swift
//  CC_IMG
//
//  Created by tuannv on 12/21/18.
//  Copyright © 2018 tuannv. All rights reserved.
//

import UIKit
import Foundation
import PromiseKit
import SDWebImage
import CocoaLumberjack
import Alamofire


//import Alamofire

fileprivate protocol cURL {
    var url : URL {get}
}

class APIHelper: NSObject {
    
    //
    //    enum Router: URLRequestConvertible {
    //
    //        var pmkRequest: URLRequest {
    //            return URLRequest.init(url: NSURL.init() as URL)
    //        }
    //
    //        static let baseUrlString = "some url string"
    //
    ////        case category(Int ,Int, Int, [String], Int)
    //        case image(String)
    //
    //        private  var baseCategoryURL : URL {
    //            return URL.init(string: "http://yogirl.mobi:8090/hot-girl/v1/list-by-category")!
    //        }
    //        private  var baseImageURL  : URL {
    //            return URL.init(string:"http://yogirl.mobi/images/2018/12/21")!
    //        }
    //
    //
    //        func asURL() throws -> URL {
    //            switch self {
    ////            case .category(let id, let from , let to , let ids, let size):
    ////                //                {"categoryId":1,"from":0,"ids":[],"size":1}
    ////                let postData = ["categoryId":id ,
    ////                                "from" : from ,
    ////                                "to": to ,
    ////                                "ids":ids,
    ////                                "size":size] as [String : Any]
    ////
    ////                var urlRequest = URLRequest.init(url: baseCategoryURL)
    ////
    ////                urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
    ////
    //////                return try! Alamofire.URLEncoding.default.encode(urlRequest, with: postData)
    ////
    //            case .image(let imgName):
    //                return  baseImageURL
    //                    .appendingPathComponent(imgName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)
    //            }
    //        }
    //    }
    
    //    enum APIEndPoint {
    //        case category
    //        case image(String)
    //
    //        private var baseCategoryURL : NSURL {
    //            return NSURL.init(string:"http://yogirl.mobi:8090/hot-girl/v1/list-by-category")!
    //        }
    //
    //        private var baseImageURL : NSURL {
    //            return NSURL.init(string:"http://yogirl.mobi/images/2018/12/21")!
    //        }
    //
    //        var url : NSURL {
    //            switch self {
    //            case .category:
    //                return NSURL()
    //            case .image(var imgName):
    //                imgName = imgName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    //                return baseCategoryURL.appendingPathComponent(imgName)! as NSURL
    //            }
    //        }
    //
    //    }
    
    
    func getCategory(cids: Int = 0 , from : Int , ids : [String]  = [], size : Int)  -> Promise<ImgModel> {
        
        //        return Promise { seal in
        //            Alamofire.request(CategoryEndpoint.get(cids, from, ids, size)).logRequest().logResponse().responseJSON { (response) in
        //                switch response.result {
        //                case .success(let jData) :
        //                    var data : Data
        //                    var imgModel :ImgModel
        //                    do {
        //                        imgModel = try newJSONDecoder().decode(ImgModel.self, from: response.result.value as! Data)
        //                        seal.fulfill(imgModel)
        //                    }catch let error {
        //                        return seal.reject(error)
        //                    }
        //
        //                //                        seal.reject(NSError.init(domain: "CC_IMG", code: 1, userInfo: [NSLocalizedDescriptionKey:"Ko convert dc"]))
        //                case .failure(let error) :
        //                    seal.reject(error)
        //
        //                }
        //            }
        //        }
        
        return Promise { seal in
            Alamofire.request(CategoryEndpoint.get(cids, from, ids, size)).responseData(completionHandler: { (response) in
                switch response.result {
                case .failure(let error) :
                    return seal.reject(error)
                case .success(let value) :
                    var imgModel :ImgModel
                    do {
                        imgModel = try newJSONDecoder().decode(ImgModel.self, from: value )
                        seal.fulfill(imgModel)
                    }catch let error {
                        return seal.reject(error)
                    }
                }
            })
        }
        
        
        //        return Promise { seal in
        //            Alamofire.request(CategoryEndpoint.get(cids, from, ids, size)).responseImgModel { (modal) in
        //                print(modal)
        //                seal.fulfill(ImgModel())
        //            }
        //        }
    }
    
    func getImage(imageName: String) -> Promise<UIImage> {
        return  SDWebImageManager.shared().ex_loadImage(url: ImageEndpoint.get(imageName).url)
    }
    
    func brokenPromise<T>(method : String = #function) -> Promise<T> {
        return Promise<T> { seal in
            let error = NSError.init(domain: "CC_IMG",
                                     code: 0,
                                     userInfo: [NSLocalizedDescriptionKey : "\(method) not implement"])
            seal.reject(error)
        }
        
    }
}

extension SDWebImageManager {
    public func ex_loadImage(url: URL) -> Promise<UIImage>{
        return Promise { seal in
            SDWebImageManager.shared().loadImage(with: url as URL, options: [], progress: nil, completed: { (image, data, error, cacheType, done, url) in
                if done && error == nil {
                    seal.fulfill(image!)
                }else if let error = error {
                    seal.reject(error)
                }else {
                    abort()
                }
            })
        }
    }
}

extension Alamofire.DataRequest {
    public func logRequest() -> Self {
        let message  =  """
        \n-----------Request-----------
        url: \(request?.url?.absoluteString ?? "")
        header: \(request?.allHTTPHeaderFields ?? [:])
        method: \(request!.httpMethod ?? "")
        body: \(String.init(data: (request?.httpBody)!, encoding: .utf8) ?? "")
        -----------------------------
        """
        DDLogInfo(message)
        return self
    }
    public func logResponse() -> Self {
        //        response: \(String.init(data: (response.data)!, encoding: .utf8) ?? "")
        return response(completionHandler: { (response) in
            guard let code = response.response?.statusCode , let path = response.request?.url?.absoluteString else {
                return
            }
            let message  =  """
            \n-----------Response-----------
            url: \(path)
            totalTime : \(response.timeline.totalDuration)
            responseCode : \(code)
            -----------------------------
            """
            DDLogInfo(message)
            
        })
    }
}
