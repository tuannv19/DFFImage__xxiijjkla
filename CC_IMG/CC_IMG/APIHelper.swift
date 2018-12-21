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


class APIHelper: NSObject {
    
    enum APIEndPoint {
        case category
        case image(String)
        
        private var baseCategoryURL : NSURL {
            return NSURL.init(string:"http://yogirl.mobi/images/2018/12/21")!
        }
        
        private var baseImageURL : NSURL {
            return NSURL.init(string:"http://yogirl.mobi/images/2018/12/21")!
        }
        
        var url : NSURL {
            switch self {
            case .category:
                return NSURL()
            case .image(var imgName):
                imgName = imgName.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
                return baseCategoryURL.appendingPathComponent(imgName)! as NSURL
            }
        }
        
    }
    
    //    http://yogirl.mobi/images/2018/12/21/0e1232caf0472e60bce22c19421b8200.jpg
    private static let imgURL = "http://yogirl.mobi/images/2018/12/21/"
    
    func getCategory()  {
        
    }
    
    func getImage(imageName: String) -> Promise<UIImage> {
        return SDWebImageManager.shared().ex_loadImage(url: APIEndPoint.image(imageName).url)
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
    public func ex_loadImage(url: NSURL) -> Promise<UIImage>{
        return Promise { seal in
            SDWebImageManager.shared().loadImage(with: nil, options: [], progress: nil, completed: { (image, data, error, cacheType, done, url) in
                if done && error != nil {
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
