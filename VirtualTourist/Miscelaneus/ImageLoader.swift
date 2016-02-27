//
//  ImageLoader.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/27/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit


class ImageLoader {
    
    let cache = NSCache()
    let preloadElements = 5
    
    class var instance : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        
        return Static.instance
    }
    
    private func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    
    func imageFromUrl(url: NSURL, completionHandler:(image: UIImage?, url: String) -> ()){
        
        let data: NSData? = self.cache.objectForKey(url.absoluteString) as? NSData
        
        if let goodData = data {
            let image = UIImage(data: goodData)
            dispatch_async(dispatch_get_main_queue(), {() in
                completionHandler(image: image, url: url.absoluteString)
            })
            return
        }
        
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                
                guard let data = data where error == nil else { return }
                
                if let image = UIImage(data: data){
                    
                    let compressData = self.compressData(image: image, compressionQuality: 0.7)
                    
                    self.cache.setObject(compressData, forKey: url.absoluteString)
                    
                    dispatch_async(dispatch_get_main_queue(), {() in
                        completionHandler(image: image, url: url.absoluteString)
                    })
                }
                return
            }
        }
    }
    
    
    
    func imageFromCache(url: NSURL, completionHandler:(image: UIImage?, url: String) -> ()) -> Bool{
        
        let data: NSData? = self.cache.objectForKey(url.absoluteString) as? NSData
        
        if let goodData = data {
            
            let image = UIImage(data: goodData)
            
            dispatch_async(dispatch_get_main_queue(), {() in
                completionHandler(image: image, url: url.absoluteString)
            })
            
            return true
        }
        
        dispatch_async(dispatch_get_main_queue(), {() in
            completionHandler(image: nil, url: url.absoluteString)
        })
        
        return false
    }
    
    func imageInCache(url: NSURL) -> Bool{
        
        let data: NSData? = self.cache.objectForKey(url.absoluteString) as? NSData
        
        guard (data != nil) else{
            return false
        }
        
        return true
    }
    
    func compressData(image image: UIImage, compressionQuality: Float = 1.0) -> NSData! {
        let hasAlpha = image.hasAlpha()
        
        let data = hasAlpha ? UIImagePNGRepresentation(image) : UIImageJPEGRepresentation(image, CGFloat(compressionQuality))
        
        return data
    }
}