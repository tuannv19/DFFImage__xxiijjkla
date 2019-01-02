//
//  ViewController.swift
//  CC_IMG
//
//  Created by tuannv on 12/21/18.
//  Copyright © 2018 tuannv. All rights reserved.
//

import UIKit
import Alamofire
import SnapKit
import CocoaLumberjack

class ViewController: UIViewController {
    
    var _hotVM  : ImgModelVM {
        let imgModelVM =  ImgModelVM.init(withType: .hot)
        imgModelVM.didFinishLoad = { model in
            if let _ = model {
                self.collectionView.reloadData()
            }
        }
        
        imgModelVM.didOccurError = { error in
            print(error)
            self.showAlertWithError(error: error)
        }
        
        return imgModelVM
    }
    
    var hotVM  : ImgModelVM!
    
    var collectionView : UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        hotVM  = _hotVM
        
        let cellLayout = CCLayout.init()
        cellLayout.delegate = self

        collectionView = UICollectionView.init(frame: CGRect(), collectionViewLayout: cellLayout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier:"UICollectionViewCell" )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.white
        
        self.view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.equalTo(view)
            make.right.equalTo(view)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        collectionView.reloadData()
        
        hotVM.fetch(next: false)
    }
    func showAlertWithError(error : NSError ) {
        let alert = UIAlertController(title: "Error: \(error.code)", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            switch action.style{
            case .default:
                print("default")
                
            case .cancel:
                print("cancel")
                
            case .destructive:
                print("destructive")
                
            }}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showLightBox(atIndex : Int = 0)  {
        
        // Create an array of images.
        let images = hotVM.imgModels?.lightBoxArray()
        
        // Create an instance of LightboxController.
        let controller = LightboxController(images: images!, startIndex: atIndex)
        // Set delegates.
        controller.pageDelegate = self
        controller.dismissalDelegate = self
        
        // Use dynamic background.
        controller.dynamicBackground = true
        
        // Present your controller.
        present(controller, animated: true, completion: nil)
        
    }
}
extension ViewController : UICollectionViewDelegate {
    
}
extension ViewController : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotVM.totalItem
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: false)
        
        showLightBox(atIndex: indexPath.row)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let imgElement = hotVM.imgModels?[indexPath.row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        
        for view in cell.subviews {
            view.removeFromSuperview()
        }
        
        let img = UIImageView.init()
        
        cell.addSubview(img)
        
        img.snp.makeConstraints { (make) in
            make.top.equalTo(cell)
            make.left.equalTo(cell)
            make.right.equalTo(cell)
            make.bottom.equalTo(cell)
        }
        
        APIHelper.init().getImage(imageName: (imgElement?.images)!)
            .done { (image) in
                img.image = image
                img.contentMode = .scaleAspectFit
            }.catch { (error) in
                print(error)
        }
        return cell
    }
}
//extension ViewController : UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize.init(width: 120, height: 100)
//    }
//}

extension ViewController : CCLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, sizeForPhotoAtIndexPath indexPath: IndexPath) -> CGSize {
                let imgElement = hotVM.imgModels?[indexPath.row]
                let currentHeight =  CGFloat ( (imgElement?.height)! )
                let currentWidth =  CGFloat ( (imgElement?.width)! )
                return CGSize(width: currentWidth, height: currentHeight)
    }
}
extension ViewController : LightboxControllerPageDelegate {
    func lightboxController(_ controller: LightboxController, didMoveToPage page: Int) {
        
    }
}
extension ViewController : LightboxControllerDismissalDelegate{
    func lightboxControllerWillDismiss(_ controller: LightboxController) {
        
    }
}
