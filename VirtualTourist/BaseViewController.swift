//
//  BaseViewController.swift
//  VirtualTourist
//
//  Created by Daniela Velasquez on 2/13/16.
//  Copyright © 2016 Mahisoft. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    //Loading UI
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: Life Cycle Methods
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Add gesture from hide keyboard when the user touch the screen
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "hideKeyboard"))
        
    }
    
    // MARK: - Keyboard management Methods
    /*
    * @author: Daniela Velasquez
    * Hide the keyboard
    */
    func hideKeyboard(){
        view.endEditing(true)
    }
    
    
    /*
    * @author: Daniela Velasquez
    * Return true if the device have internet access
    */
    func available() -> Bool{
        
        if(ConnectionsValidator.isConnectedToNetwork()){
            return true
        }else{
            showAlert(Messages.titleNetworkProblems, message: Messages.mNoInternetConnection, viewController: self)
        }
        
        return false
    }
    
    /**
     * @author: Daniela Velasquez
     * Show/Hide request mode in viewController
     */
    func showRequestMode(show show: Bool){
        
        dispatch_async(dispatch_get_main_queue()) {
            if (self.activityIndicator != nil){
                if(show){
                    self.activityIndicator.startAnimating()
                }else{
                    self.activityIndicator.stopAnimating()
                }
            }
            
            if((self.overlay) != nil){
                self.overlay.hidden = !show
            }
        }
    }
}
