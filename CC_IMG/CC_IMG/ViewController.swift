//
//  ViewController.swift
//  CC_IMG
//
//  Created by tuannv on 12/21/18.
//  Copyright © 2018 tuannv. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {
    
    var imgView  = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.view.addSubview(imgView)
        
        imgView.contentMode = .scaleAspectFit
        
        imgView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        
        APIHelper().getImage(imageName: "0e1232caf0472e60bce22c19421b8200.jpg")
            .done { [weak self ] (image) in
                self?.imgView.image = image
            }.catch { (error) in
                print(error)
        }
    }
}

