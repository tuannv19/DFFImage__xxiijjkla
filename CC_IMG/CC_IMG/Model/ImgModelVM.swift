//
//  ImgModelVM.swift
//  CC_IMG
//
//  Created by tuannv on 12/27/18.
//  Copyright © 2018 tuannv. All rights reserved.
//

import UIKit

enum  CategoryType: Int{
    case hot = 1, chauA, chauAu, tretrung, cosplay
}

class ImgModelVM {
    
    var imgModels : ImgModel? {
        didSet {
            self.didFinishLoad(imgModels)
            
        }
    }
    var totalItem : Int {
        return imgModels?.count ?? 0
    }
    
    var error : NSError? {
        didSet {
            self.didOccurError(error!)
        }
    }
    
    
    var currentInDex = 1
    let sizeToFecth  = 16
    private var type : CategoryType?
    private  lazy var service = APIHelper()
    
    var didFinishLoad : ((ImgModel?)->())!
    var didOccurError : ((NSError) ->())!
    
    var  next : Bool = false {
        didSet {
            if !next {
                currentInDex = 1
            }
        }
    }
    
    init(withType type: CategoryType) {
        self.type = type
        imgModels = ImgModel()
    }
    
    func fetch(next: Bool = true){
        service.getCategory(cids: (type?.rawValue)!, from: currentInDex , size: sizeToFecth)
            .done { (data) in
                self.imgModels  = data
            }.catch { (error) in
                self.error = error as NSError
        }
    }
    
    
}


