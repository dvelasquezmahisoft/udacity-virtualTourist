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
        let url = NSURL(string: photoUrl)
        
        //Set placeholder image
        self.backgroundColor = .grayColor()
        self.image.image = UIImage(named: "Launch")
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            ImageLoader.instance.imageFromUrl(url!, completionHandler: {(image: UIImage?, url: String) in
                if let imageTemp = image{
                    self.image.image = imageTemp
                }
            })
            
        }
    }
}
