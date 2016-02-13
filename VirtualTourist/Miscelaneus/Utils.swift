//
//  Utils.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit


// MARK: Other Methods

/**
* Show the message in like do AlertMessage
*/

func showAlert(title:String = "", message:String = "", successBtnTitle: String = Messages.bDismiss, handlerSuccess: ((UIAlertAction) -> Void)? = nil, failBtnTitle: String = "", handlerFail: ((UIAlertAction) -> Void)? = nil, viewController: UIViewController) {
    
    let alert = UIAlertController(title: title,
        message: message, preferredStyle: .Alert)
    
    let dismissAction = UIAlertAction(title: successBtnTitle, style: .Default, handler: handlerSuccess)
    
    alert.addAction(dismissAction)
    
    if(failBtnTitle != ""){
        let failAction = UIAlertAction(title: failBtnTitle, style: .Destructive, handler: handlerFail)
        
        alert.addAction(failAction)
    }
    
    viewController.presentViewController(alert, animated: true, completion: nil)
}
    