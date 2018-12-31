//
//  CCLayout.swift
//  CC_IMG
//
//  Created by tuannv on 12/31/18.
//  Copyright © 2018 tuannv. All rights reserved.
//

import UIKit

protocol CCLayoutDelegate: class {
    func collectionView(_ collectionView:UICollectionView, sizeForPhotoAtIndexPath indexPath:IndexPath) -> CGSize
}

class CCLayout : UICollectionViewLayout {

    weak var delegate  : CCLayoutDelegate!
    let numberOfColumns = 2
    fileprivate var cellPadding: CGFloat = 4
    
    fileprivate var cache = [UICollectionViewLayoutAttributes]()
    
    fileprivate var contentHeight: CGFloat = 0
    fileprivate var contentWidth: CGFloat {
        guard let collectionView = collectionView else {
            return 0
        }
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: contentWidth, height: contentHeight)
    }
    
    override func prepare() {
        guard cache.isEmpty == true , let collectionView = collectionView else  {
            return
        }
        
        let columnWidth =  contentWidth / CGFloat( numberOfColumns )
        
        var xOffset = [CGFloat]()
        
        for column  in 0 ..< numberOfColumns{
            xOffset.append( CGFloat ( column  ) * columnWidth)
        }
        
        var column  = 0
        
        var yOffset = [CGFloat](repeating: 0, count: numberOfColumns)
        
        
        for item in 0 ..< collectionView.numberOfItems(inSection: 0){
            
            let indexPath = IndexPath(item: item, section: 0)
            
            let _imgSIze = delegate.collectionView(collectionView, sizeForPhotoAtIndexPath: indexPath)
            let imgHeight  =   ( columnWidth * _imgSIze.height ) / _imgSIze.width
            
            
            let height = imgHeight
            
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: height)
            let insetFrame = frame.insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = insetFrame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + height
            
            column = column < (numberOfColumns - 1) ? (column + 1) : 0
            
        }
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        var visibleLayoutAttributes = [UICollectionViewLayoutAttributes]()
        
        // Loop through the cache and look for items in the rect
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
