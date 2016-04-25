//
//  LoginViewController.swift
//  Loopback-Swift-Example
//
//  Created by Kevin Goedecke on 12/9/15.
//  Copyright © 2015 kevingoedecke. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var EmailTextField: UITextField!
    @IBOutlet weak var PasswordTextField: UITextField!
    @IBAction func LoginButton(sender: UIButton) {
        BackendUtilities.sharedInstance.clientRepo.userByLoginWithEmail(EmailTextField.text, password: PasswordTextField.text, success: { (client) -> Void in
                NSLog("Successfully logged in.");
            
            if let token = LoopbackAccessToken(userID: client._id.stringValue, tokenString: BackendUtilities.sharedInstance.adapter.accessToken, createDate: NSDate()) {
                SharedLoginManager.sharedInstance().storeLoopbackAccessToken(token)
            }
            
            // Display login confirmation
            let alertController = UIAlertController(title: "Login", message:
                "Successfully logged in", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }) { (error: NSError!) -> Void in
            NSLog("Error logging in. \(error)")
            
            // Display error alert
            let alertController = UIAlertController(title: "Login", message:
                "Login failed", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    override func viewDidLoad() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
