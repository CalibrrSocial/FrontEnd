//
//  ACollectionDatasource.swift
//  Calibrr
//
//
//  Copyright © Calibrr. All rights reserved.
//

import UIKit

class ACollectionDatasource : NSObject, UICollectionViewDataSource
{
    var noContentMessage : String { get{ return "" } }
    
    override init()
    {
        super.init()
        
        reload()
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        return UICollectionViewCell()
    }
    
    func reload() { }
    
    func hasNoItems() -> Bool
    {
        return false
    }
}
