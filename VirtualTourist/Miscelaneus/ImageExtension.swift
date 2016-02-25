//
//  ImageExtension.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/24/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit


extension UIImageView{
    
    private func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, placeHolderName: String = "Launch"){
        
        //Set placeholder image
        self.image = UIImage(named: placeHolderName)
        
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.image = UIImage(data: data)
            }
        }
    }
    
}
