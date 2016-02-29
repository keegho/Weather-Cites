//
//  ForcastTableViewCell.swift
//  Your Weather Station
//
//  Created by Kegham Karsian on 2/23/16.
//  Copyright © 2016 blowmymind. All rights reserved.
//

import UIKit

class ForcastTableViewCell: UITableViewCell {
    
    
    @IBOutlet var forcastCollection: UICollectionView!
    
    
    func setCollectionViewDataSourceDelegate
        <D: protocol<UICollectionViewDataSource, UICollectionViewDelegate>>
        (dataSourceDelegate: D, forRow row: Int) {
            
            forcastCollection.delegate = dataSourceDelegate
            forcastCollection.dataSource = dataSourceDelegate
            forcastCollection.tag = row
            forcastCollection.reloadData()
    }
    


//    override func awakeFromNib() {
//        super.awakeFromNib()
//        // Initialization code
//    }
//
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//
//        // Configure the view for the selected state
//    }

}
