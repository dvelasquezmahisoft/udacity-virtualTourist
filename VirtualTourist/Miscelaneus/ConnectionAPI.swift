//
//  ConnectionAPI.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/25/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import UIKit

/**
 * ConnectionAPIProtocol
 */
@objc protocol ConnectionAPIProtocol : NSObjectProtocol {
    /**
     * @author: Daniela Velasquez
     * Delegate Funtion - ConnectionAPIProtocol
     * Is called when the request success
     */
    func  didReceiveSuccess(results results: AnyObject)
    
    /**
     * @author: Daniela Velasquez
     * Delegate Funtion - ConnectionAPIProtocol
     * Is called when the request failed
     */
    func didReceiveFail(error error: NSError, errorObject: AnyObject)
    
}


class ConnectionAPI : NSObject{
    
    
    let PHOTO_SOURCE_URL = "https://farm{farmId}.staticflickr.com/{serverId}/{photoId}_{secret}_q.jpg"
    
    var delegate: ConnectionAPIProtocol?
    var manager = Alamofire.Manager.sharedInstance
    var timeOutValue:NSTimeInterval = 10.0 //seconds
    
    override init() {
        self.delegate = nil
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = timeOutValue
        
        self.manager = Alamofire.Manager(configuration: configuration)
    }
    
    init(delegate: ConnectionAPIProtocol) {
        
        self.delegate = delegate
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = Alamofire.Manager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = timeOutValue
        
        self.manager = Alamofire.Manager(configuration: configuration)
    }
    
    /**
     * Set header parameters.
     * @param: Array with header tuples (key, value)
     */
    func setHeaders(params:[String:String]){
        
        var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
        
        for (key, value) in params{
            defaultHeaders[key] = value
        }
        
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        configuration.timeoutIntervalForRequest = timeOutValue
        
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    /**
     * @author: Daniela Velasquez
     * Request Adapter
     */
    func get(path: String, parametersArray: [String : AnyObject]?, serverTag: String) {
        self.request(.GET, path: path, parametersArray: parametersArray, encoding: .URL, serverTag: serverTag)
    }
    
    
    /**
     * @author: Daniela Velasquez
     * Request Adapter
     */
    func post(path: String, parametersArray: [String : AnyObject]? = nil, serverTag: String) {
        self.request(.POST, path: path, parametersArray: parametersArray, encoding: .JSON, serverTag: serverTag)
        
    }
    
    /**
     * @author: Daniela Velasquez
     * Request Adapter
     */
    func put(path: String, parametersArray: [String : AnyObject]?, serverTag: String) {
        self.request(.PUT, path: path, parametersArray: parametersArray, encoding: .JSON, serverTag: serverTag)
        
    }
    
    /**
     * @author: Daniela Velasquez
     * Request Adapter
     */
    func delete(path: String, parametersArray: [String : AnyObject]? = nil, serverTag: String) {
        self.request(.DELETE, path: path, parametersArray: parametersArray, encoding: .JSON,serverTag: serverTag)
        
    }
    
    
    func request(method: Alamofire.Method, path: String, parametersArray: [String : AnyObject]?, encoding: Alamofire.ParameterEncoding, serverTag: String) {
        
        let parameters = parametersArray
        
        self.manager.request(method, path, parameters: parameters, encoding: encoding)
            .response { (request, response, data, error) in
                if let errorCode = error?.code{
                    print(error)
                    self.delegate?.didReceiveFail(error: NSError(domain: "Fail", code: errorCode, userInfo: nil), errorObject: NSError(domain: "", code: 0, userInfo: nil))
                    return
                }
            }.responseJSON { response in
                let result = response.result
                switch result {
                case .Success(let data):
                    let status = response.response?.statusCode
                    
                    let jsonData = data as! NSDictionary
                    
                    if let JSONR: AnyObject = jsonData {
                        
                        print("JSON \(serverTag): \(JSONR)")
                        
                        if !self.errorResponse(status!) {
                            print("**** SUCCESS ****")
                            
                            if let jsonPhotosDictionary = JSONR["photos"] as? NSDictionary {
                                
                                if let jsonPhotoDataArray = jsonPhotosDictionary["photo"] as? NSArray {
                                    
                                    var photoProperties = [[String:String]]()
                                    
                                    for jsonPhotoData in jsonPhotoDataArray {
                                        if let photoProperty = self.photoParamsToProperties(jsonPhotoData as! NSDictionary) {
                                            
                                            photoProperties.append(photoProperty)
                                        }
                                    }
                                    
                                     self.delegate?.didReceiveSuccess(results: photoProperties)
                                    
                                } else {
                                    
                                    self.delegate?.didReceiveFail(error:NSError(domain: "Problems when try get photo from Flickr", code: 0, userInfo: nil), errorObject: ["message":"Problems when try get photo from Flickr"])
                                }
                                
                            }
                            
                            
                           
                        } else {
                            print("**** FAIL **** HTTP:\(status)")
                            self.delegate?.didReceiveFail(error:NSError(domain: "", code: 0, userInfo: nil), errorObject: JSONR)
                        }
                    }
                case .Failure(let error):
                    print("**** ERROR \(error) ****")
                    self.delegate?.didReceiveFail(error:error, errorObject: NSError(domain: "", code: 0, userInfo: nil))
                }
        }
    }

    
    
    func photoParamsToProperties(jsonData: NSDictionary) -> [String:String]? {
        
        let photoId = jsonData["id"] as? String
        let secret = jsonData["secret"] as? String
        let serverId = jsonData["server"] as? String
        let farmId = jsonData["farm"] as? Int
        
        if photoId != nil && secret != nil && serverId != nil && farmId != nil {
            
            let photoParams: [String:String] = [
                "photoId": photoId!,
                "secret": secret!,
                "serverId": serverId!,
                "farmId": "\(farmId!)",
                "imageSize": "q"
            ]
            
            let imageName = "\(photoId!)_\(secret!)_q.jpg"
            
            let remotePath = urlKeySubstitute(PHOTO_SOURCE_URL, kvp: photoParams)
            
            return [
                "imageName": imageName,
                "remotePath": remotePath
            ]
        }
        return nil
    }
    
    
    func urlKeySubstitute(method: String, kvp: [String:String]) -> String {
        var method = method
        for (key, value) in kvp {
            if method.rangeOfString("{\(key)}") != nil {
                method = method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
            }
        }
        return method
    }
    
    
    /*
    */
    func errorResponse(statusCode: Int) -> Bool {
        if statusCode < 200 || statusCode >= 300 {
            return true
        }
        
        return false
    }
}