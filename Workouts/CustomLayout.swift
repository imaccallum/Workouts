//
//  CustomLayout.swift
//  Workouts
//
//  Created by Ian MacCallum on 3/24/15.
//  Copyright (c) 2015 MacCDevTeam. All rights reserved.
//

import Foundation
import UIKit

class CustomLayout: UICollectionViewLayout {
    let itemWidth: CGFloat = 128
    let rows: CGFloat = 3.0
    
    override func prepareLayout() {
        super.prepareLayout()
    }
    
    override func collectionViewContentSize() -> CGSize {
        return self.collectionView!.bounds.size
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        let currentRow = CGFloat(indexPath.row)
        let row = currentRow % rows
        let column = floor(currentRow / 3.0)
        
        
        let x: CGFloat = row * itemWidth
        let y: CGFloat = column * itemWidth
        attributes.frame = CGRect(x: x, y: y, width: itemWidth, height: itemWidth)
        
        
        var transform = CATransform3DIdentity
        
        var rotation: CGFloat!
        switch row {
        case 0: rotation = CGFloat(M_PI_4)
        case 1: rotation = CGFloat(M_PI)
        case 2: rotation = CGFloat(M_PI_4)
        default: rotation = CGFloat(M_PI_2)
        }
        
        transform = CATransform3DMakeRotation(rotation, 0, itemWidth / 2.0, 0)
        
//        transform = CATransform3DTranslate(theTransform, self.cellSize.width * (theDelta > 0.0f ? 0.5f : -0.5f), 0.0f, 0.0f);
//        transform = CATransform3DRotate(theTransform, theRotation * (CGFloat)M_PI / 180.0f, 0.0f, 1.0f, 0.0f);
//        transform = CATransform3DTranslate(theTransform, self.cellSize.width * (theDelta > 0.0f ? -0.5f : 0.5f), 0.0f, 0.0f);
        
        
        
        attributes.transform3D = transform
        return attributes
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var attributes = [UICollectionViewLayoutAttributes]()
        
        let sectionsCount = self.collectionView!.dataSource!.numberOfSectionsInCollectionView!(self.collectionView!)
        for section in 0..<sectionsCount {
            /// add header
            attributes.append(self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: NSIndexPath(forItem: 0, inSection: section))!)
            
            let itemsCount = self.collectionView!.numberOfItemsInSection(section)
            for item in 0..<itemsCount {
                let indexPath = NSIndexPath(forItem: item, inSection: section)
                attributes.append(self.layoutAttributesForItemAtIndexPath(indexPath)!)
            }
        }
        
    
        
        return attributes
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        attributes.frame = CGRect(x: 0, y: 0, width: 320, height: 50)
        
        return attributes
    }
}
