//
//  ImageExtension.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/24/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit

public enum ScaleMode: String {
    case Fill = "fill", AspectFit = "aspectfit", AspectFill = "aspectfill", None = "none"
}

extension UIImageView{
    
    private func getDataFromUrl(url:NSURL, completion: ((data: NSData?, response: NSURLResponse?, error: NSError? ) -> Void)) {
        
        NSURLSession.sharedSession().dataTaskWithURL(url) {
            (data, response, error) in
            completion(data: data, response: response, error: error)
            }.resume()
    }
    
    func downloadImage(url: NSURL, placeHolderName: String = "userDefault"){
        
        //Set placeholder image
        self.image = UIImage(named: placeHolderName)
        
        getDataFromUrl(url) { (data, response, error)  in
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                guard let data = data where error == nil else { return }
                self.image = UIImage(data: data)
            }
        }
    }
    
    
    func resizeImage(){
        
        var actualHeight = self.image!.size.height;
        var actualWidth = self.image!.size.width;
        let maxHeight = CGFloat(300.0)
        let maxWidth = CGFloat(400.0)
        var imgRatio = actualWidth/actualHeight;
        let maxRatio = maxWidth/maxHeight;
        let compressionQuality = CGFloat(0.5)
        
        if (actualHeight > maxHeight || actualWidth > maxWidth){
            if(imgRatio < maxRatio){
                //adjust width according to maxHeight
                imgRatio = maxHeight / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = maxHeight
            }
            else if(imgRatio > maxRatio)
            {
                //adjust height according to maxWidth
                imgRatio = maxWidth / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = maxWidth
            }
            else
            {
                actualHeight = maxHeight
                actualWidth = maxWidth
            }
        }
        
        let rect = CGRectMake(0.0, 0.0, actualWidth, actualHeight)
        UIGraphicsBeginImageContext(rect.size)
        image?.drawInRect(rect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext()
        let imageData = UIImageJPEGRepresentation(img, compressionQuality)
        UIGraphicsEndImageContext()
        
        self.image =  UIImage(data: imageData!)
    }
    
    
    
    func resizeImageWithScaleMode(scaleMode: ScaleMode, size: CGSize) -> UIImage {
        var resizeToSize: CGSize
        
        switch scaleMode {
        case .Fill:
            resizeToSize = size
        case .AspectFit:
            resizeToSize = self.image!.size.aspectFitSize(size)
        case .AspectFill:
            resizeToSize = self.image!.size.aspectFillSize(size)
        case .None:
            return image!
        }
        
        
        // Avoid unnecessary computations
        if (resizeToSize.width == image!.size.width && resizeToSize.height == image!.size.height) {
            return image!
        }
        
        let resizedImage = image?.scalingToSize(resizeToSize)
        
        return resizedImage!
    }
    
    func imageCircleForm(borderColor borderColor: UIColor = .clearColor()){
        layer.cornerRadius = 18
        
        clipsToBounds = true
        layer.borderWidth = 0.5
        layer.borderColor = borderColor.CGColor
    }
}


extension UIImage{
    
    func hasAlpha() -> Bool {
        let alpha = CGImageGetAlphaInfo(self.CGImage)
        switch alpha {
        case .First, .Last, .PremultipliedFirst, .PremultipliedLast, .Only:
            return true
        case .None, .NoneSkipFirst, .NoneSkipLast:
            return false
        }
    }
    
    
    
    func scalingToSize(toSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(toSize, !self.hasAlpha(), 0.0)
        drawInRect(CGRectMake(0, 0, toSize.width, toSize.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    
    class func imageWithColor(color: UIColor, _ size: CGSize = CGSize(width: 1, height: 1), _ opaque: Bool = true) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, opaque, 0)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    
}
