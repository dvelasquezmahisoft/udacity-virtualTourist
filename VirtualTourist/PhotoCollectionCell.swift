//
//  PhotoCollectionCell.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit

class PhotoCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var image: UIImageView!
    
    class var identifier: String { return String.className(self) }
    
    func setup(photoUrl: String){
        self.backgroundColor = .grayColor()
        let url = NSURL(string: photoUrl)
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
           
            
            ImageLoader.instance.imageFromUrl(url!, completionHandler: {(image: UIImage?, url: String) in
                print("Image load in getAllImagesFromUrl \(url)")
                self.image =  image
            })
            
        }
    }
}
