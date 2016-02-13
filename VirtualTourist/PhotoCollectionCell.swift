//
//  PhotoCollectionCell.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var memeImage: UIImageView!
    
    class var identifier: String { return String.className(self) }
    
    func setup(){
    
    }
}
